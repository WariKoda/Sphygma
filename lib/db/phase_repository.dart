import 'package:drift/drift.dart';

import '../stats/measurement_metadata.dart';
import 'app_database.dart';
import 'metadata_validation.dart';

class PhaseRepository implements PhaseStore {
  PhaseRepository(this._db);
  final AppDatabase _db;

  @override
  Future<List<ScopedPhase>> phases(int userSlot) async {
    validateMetadataSlot(userSlot);
    return (_db.select(_db.scopedPhases)
          ..where((p) => p.userSlot.equals(userSlot))
          ..orderBy([
            (p) => OrderingTerm.desc(p.beginsAt),
            (p) => OrderingTerm.asc(p.id),
          ]))
        .get();
  }

  Future<ScopedPhase> _phase(int id) async {
    final row = await (_db.select(
      _db.scopedPhases,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (row == null) throw StateError('Die Phase ist nicht mehr vorhanden.');
    return row;
  }

  @override
  Future<int> savePhase({
    int? id,
    required int userSlot,
    required String name,
    required DateTime begin,
    required DateTime? end,
  }) async {
    validateMetadataSlot(userSlot);
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Die Phase braucht einen Namen.');
    if (end != null && end.isBefore(begin)) {
      throw ArgumentError('Das Ende darf nicht vor dem Beginn liegen.');
    }
    return _db.transaction(() async {
      if (id == null) {
        return _db
            .into(_db.scopedPhases)
            .insert(
              ScopedPhasesCompanion.insert(
                userSlot: userSlot,
                name: clean,
                beginsAt: begin,
                endsAt: Value(end),
                anchor: 'bestaetigt',
                createdAt: DateTime.now(),
              ),
            );
      }
      final previous = await _phase(id);
      if (previous.userSlot != userSlot) {
        throw ArgumentError('Die Phase gehört zu einem anderen Speicherplatz.');
      }
      await (_db.update(_db.scopedPhases)..where((p) => p.id.equals(id))).write(
        ScopedPhasesCompanion(
          name: Value(clean),
          beginsAt: Value(begin),
          endsAt: Value(end),
          anchor: Value(
            previous.beginsAt == begin ? previous.anchor : 'bestaetigt',
          ),
        ),
      );
      return id;
    });
  }

  @override
  Future<void> deletePhase(int id) async {
    await _db.transaction(() async {
      await _phase(id);
      // Der leere Header ist eine bewusste Ausnahme von der Automatik.
      await (_db.delete(
        _db.phaseSelectionMembers,
      )..where((m) => m.phaseId.equals(id))).go();
      await (_db.delete(_db.scopedPhases)..where((p) => p.id.equals(id))).go();
    });
  }

  @override
  Future<Map<int, Set<int>>> selections(int userSlot) async {
    validateMetadataSlot(userSlot);
    return _db.transaction(() async {
      final headers = await (_db.select(
        _db.phaseSelections,
      )..where((p) => p.userSlot.equals(userSlot))).get();
      final members = await (_db.select(
        _db.phaseSelectionMembers,
      )..where((p) => p.userSlot.equals(userSlot))).get();
      final validIds = (await phases(userSlot)).map((p) => p.id).toSet();
      final result = {for (final h in headers) h.deviceSequence: <int>{}};
      for (final member in members) {
        final set = result[member.deviceSequence];
        if (set == null || !validIds.contains(member.phaseId)) {
          throw StateError(
            'Phasenzuordnung verweist auf einen fehlenden oder fremden Eintrag.',
          );
        }
        set.add(member.phaseId);
      }
      return Map.unmodifiable({
        for (final e in result.entries) e.key: Set<int>.unmodifiable(e.value),
      });
    });
  }

  @override
  Future<void> select(MeasurementKey key, Set<int> phaseIds) async {
    await _db.transaction(() async {
      await requireMetadataMeasurement(_db, key);
      for (final id in phaseIds) {
        if ((await _phase(id)).userSlot != key.userSlot) {
          throw ArgumentError(
            'Die Phase gehört zu einem anderen Speicherplatz.',
          );
        }
      }
      await _clear(key);
      await _db
          .into(_db.phaseSelections)
          .insert(
            PhaseSelectionsCompanion.insert(
              userSlot: key.userSlot,
              deviceSequence: key.deviceSequence,
              decidedAt: DateTime.now(),
            ),
          );
      for (final id in phaseIds) {
        await _db
            .into(_db.phaseSelectionMembers)
            .insert(
              PhaseSelectionMembersCompanion.insert(
                userSlot: key.userSlot,
                deviceSequence: key.deviceSequence,
                phaseId: id,
              ),
            );
      }
    });
  }

  Future<void> _clear(MeasurementKey key) async {
    await (_db.delete(_db.phaseSelectionMembers)..where(
          (p) =>
              p.userSlot.equals(key.userSlot) &
              p.deviceSequence.equals(key.deviceSequence),
        ))
        .go();
    await (_db.delete(_db.phaseSelections)..where(
          (p) =>
              p.userSlot.equals(key.userSlot) &
              p.deviceSequence.equals(key.deviceSequence),
        ))
        .go();
  }

  @override
  Future<void> useAutomatic(MeasurementKey key) async {
    await _db.transaction(() async {
      await requireMetadataMeasurement(_db, key);
      await _clear(key);
    });
  }
}
