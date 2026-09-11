import 'package:drift/drift.dart';

import '../stats/measurement_metadata.dart';
import 'app_database.dart';
import 'metadata_validation.dart';

class MeasurementMetadataRepository implements MetadataStore {
  MeasurementMetadataRepository(this._db);
  final AppDatabase _db;

  @override
  Future<Map<int, MeasurementMetadata>> readSlot(int userSlot) async {
    validateMetadataSlot(userSlot);
    return _db.transaction(() async {
      final notes = await (_db.select(
        _db.measurementNotes,
      )..where((n) => n.userSlot.equals(userSlot))).get();
      final links = await (_db.select(
        _db.measurementTagLinks,
      )..where((l) => l.userSlot.equals(userSlot))).get();
      final available = (await tags(userSlot)).map((t) => t.id).toSet();
      final tagIds = <int, Set<int>>{};
      for (final link in links) {
        if (!available.contains(link.tagId)) {
          throw StateError(
            'Tagzuordnung verweist auf einen fehlenden oder fremden Tag.',
          );
        }
        (tagIds[link.deviceSequence] ??= {}).add(link.tagId);
      }
      final bodies = {for (final n in notes) n.deviceSequence: n.body};
      return Map.unmodifiable({
        for (final seq in {...bodies.keys, ...tagIds.keys})
          seq: MeasurementMetadata(
            note: bodies[seq],
            tagIds: tagIds[seq] ?? {},
          ),
      });
    });
  }

  @override
  Future<List<MeasurementTag>> tags(int userSlot) async {
    validateMetadataSlot(userSlot);
    return (_db.select(_db.measurementTags)
          ..where((t) => t.userSlot.equals(userSlot))
          ..orderBy([(t) => OrderingTerm.asc(t.normalizedName)]))
        .get();
  }

  String _name(String name) {
    final clean = name.trim();
    if (clean.isEmpty || clean.runes.length > 40) {
      throw ArgumentError('Ein Tag braucht 1 bis 40 Zeichen.');
    }
    return clean;
  }

  Future<MeasurementTag> _tag(int id) async {
    final tag = await (_db.select(
      _db.measurementTags,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (tag == null) throw StateError('Der Tag ist nicht mehr vorhanden.');
    return tag;
  }

  @override
  Future<int> createTag(int userSlot, String name) async {
    validateMetadataSlot(userSlot);
    final clean = _name(name);
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.measurementTags)..where(
                (t) =>
                    t.userSlot.equals(userSlot) &
                    t.normalizedName.equals(clean.toLowerCase()),
              ))
              .getSingleOrNull();
      if (existing != null) return existing.id;
      return _db
          .into(_db.measurementTags)
          .insert(
            MeasurementTagsCompanion.insert(
              userSlot: userSlot,
              name: clean,
              normalizedName: clean.toLowerCase(),
            ),
          );
    });
  }

  @override
  Future<void> renameTag(int tagId, String name) async {
    final clean = _name(name);
    await _db.transaction(() async {
      final tag = await _tag(tagId);
      final duplicate =
          await (_db.select(_db.measurementTags)..where(
                (t) =>
                    t.userSlot.equals(tag.userSlot) &
                    t.normalizedName.equals(clean.toLowerCase()),
              ))
              .getSingleOrNull();
      if (duplicate != null && duplicate.id != tagId) {
        throw ArgumentError('Ein Tag mit diesem Namen existiert bereits.');
      }
      await (_db.update(
        _db.measurementTags,
      )..where((t) => t.id.equals(tagId))).write(
        MeasurementTagsCompanion(
          name: Value(clean),
          normalizedName: Value(clean.toLowerCase()),
        ),
      );
    });
  }

  @override
  Future<void> deleteTag(int tagId) async {
    await _db.transaction(() async {
      await _tag(tagId);
      await (_db.delete(
        _db.measurementTagLinks,
      )..where((t) => t.tagId.equals(tagId))).go();
      await (_db.delete(
        _db.measurementTags,
      )..where((t) => t.id.equals(tagId))).go();
    });
  }

  Future<void> _validateTags(int slot, Set<int> tagIds) async {
    for (final id in tagIds) {
      if ((await _tag(id)).userSlot != slot) {
        throw ArgumentError('Der Tag gehört zu einem anderen Speicherplatz.');
      }
    }
  }

  Future<void> _add(MeasurementKey key, Set<int> tagIds) async {
    for (final id in tagIds) {
      await _db
          .into(_db.measurementTagLinks)
          .insert(
            MeasurementTagLinksCompanion.insert(
              userSlot: key.userSlot,
              deviceSequence: key.deviceSequence,
              tagId: id,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  @override
  Future<void> save(
    MeasurementKey key, {
    required String? note,
    required Set<int> tagIds,
  }) async {
    final body = note?.trim();
    if (body != null && body.runes.length > 4000) {
      throw ArgumentError('Eine Bemerkung darf höchstens 4000 Zeichen haben.');
    }
    await _db.transaction(() async {
      await requireMetadataMeasurement(_db, key);
      await _validateTags(key.userSlot, tagIds);
      await (_db.delete(_db.measurementNotes)..where(
            (n) =>
                n.userSlot.equals(key.userSlot) &
                n.deviceSequence.equals(key.deviceSequence),
          ))
          .go();
      if (body != null && body.isNotEmpty) {
        await _db
            .into(_db.measurementNotes)
            .insert(
              MeasurementNotesCompanion.insert(
                userSlot: key.userSlot,
                deviceSequence: key.deviceSequence,
                body: body,
                updatedAt: DateTime.now(),
              ),
            );
      }
      await (_db.delete(_db.measurementTagLinks)..where(
            (l) =>
                l.userSlot.equals(key.userSlot) &
                l.deviceSequence.equals(key.deviceSequence),
          ))
          .go();
      await _add(key, tagIds);
    });
  }

  @override
  Future<void> addTags(Set<MeasurementKey> keys, Set<int> tagIds) async {
    await _db.transaction(() async {
      for (final key in keys) {
        await requireMetadataMeasurement(_db, key);
        await _validateTags(key.userSlot, tagIds);
      }
      for (final key in keys) {
        await _add(key, tagIds);
      }
    });
  }
}
