import 'package:drift/drift.dart';

import '../plan/plan_models.dart';
import '../plan/reminder_gateway.dart';
import '../stats/measurement_metadata.dart';
import 'app_database.dart';
import 'metadata_validation.dart';

class PlanDetails {
  PlanDetails({
    required this.plan,
    required this.revision,
    required this.minutes,
  });
  final MeasurementPlan plan;
  final PlanRevision revision;
  final List<int> minutes;
}

class MeasurementPlanRepository {
  MeasurementPlanRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _now;
  static const enabledKey = 'measurement_plan_enabled';

  Future<bool> isEnabled() async {
    final setting = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(enabledKey))).getSingleOrNull();
    if (setting == null) return false;
    return switch (setting.value) {
      'true' => true,
      'false' => false,
      _ => throw StateError('Ungültige Messplan-Einstellung.'),
    };
  }

  List<int> _minutes(List<int> values) {
    if (values.isEmpty ||
        values.any((m) => m < 0 || m >= 1440) ||
        values.toSet().length != values.length) {
      throw ArgumentError(
        'Mindestens eine gültige, eindeutige Uhrzeit ist erforderlich.',
      );
    }
    return List.of(values)..sort();
  }

  Future<MeasurementPlan> _plan(int id) async {
    final p = await (_db.select(
      _db.measurementPlans,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (p == null) throw StateError('Der Messplan ist nicht vorhanden.');
    return p;
  }

  Future<PlanDetails> _details(MeasurementPlan plan) async {
    final revisions =
        await (_db.select(_db.planRevisions)
              ..where((r) => r.planId.equals(plan.id))
              ..orderBy([(r) => OrderingTerm.desc(r.id)])
              ..limit(1))
            .get();
    if (revisions.isEmpty) throw StateError('Messplan ohne Revision.');
    final r = revisions.single;
    final times =
        await (_db.select(_db.planTimes)
              ..where((t) => t.revisionId.equals(r.id))
              ..orderBy([(t) => OrderingTerm.asc(t.minuteOfDay)]))
            .get();
    return PlanDetails(
      plan: plan,
      revision: r,
      minutes: _minutes(times.map((t) => t.minuteOfDay).toList()),
    );
  }

  Future<void> _bump() => _db.customStatement(
    'UPDATE reminder_sync SET desired_generation=desired_generation+1, last_error=NULL WHERE id=1',
  );

  Future<void> _revision(
    int planId,
    List<int> minutes,
    bool enabled,
    DateTime at,
  ) async {
    final id = await _db
        .into(_db.planRevisions)
        .insert(
          PlanRevisionsCompanion.insert(
            planId: planId,
            effectiveAt: at,
            enabled: enabled,
          ),
        );
    for (final minute in minutes) {
      await _db
          .into(_db.planTimes)
          .insert(
            PlanTimesCompanion.insert(revisionId: id, minuteOfDay: minute),
          );
    }
  }

  Future<int> start(int slot, List<int> minutes) async {
    validateMetadataSlot(slot);
    final times = _minutes(minutes);
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.measurementPlans)
                ..where((p) => p.userSlot.equals(slot) & p.endedAt.isNull()))
              .getSingleOrNull();
      if (existing != null) {
        throw StateError(
          'Für diesen Speicherplatz läuft bereits ein Messplan.',
        );
      }
      final at = _now().toUtc();
      final id = await _db
          .into(_db.measurementPlans)
          .insert(
            MeasurementPlansCompanion.insert(userSlot: slot, startedAt: at),
          );
      await _revision(id, times, await isEnabled(), at);
      await _bump();
      return id;
    });
  }

  void _checkClock(PlanDetails details, DateTime at) {
    if (at.isBefore(details.revision.effectiveAt)) {
      throw StateError(
        'Die Handyuhr liegt vor der letzten Planänderung. Bitte Uhrzeit prüfen.',
      );
    }
  }

  Future<void> _discardFuture(int planId, DateTime at) async {
    final revisions = await (_db.select(
      _db.planRevisions,
    )..where((r) => r.planId.equals(planId))).get();
    final future =
        await (_db.select(_db.planOccurrences)..where(
              (o) =>
                  o.revisionId.isIn(revisions.map((r) => r.id)) &
                  o.dueAt.isBiggerOrEqualValue(at),
            ))
            .get();
    final keys = future.map((o) => o.occurrenceKey).toList();
    if (keys.isEmpty) return;
    await (_db.delete(
      _db.planAssignmentOverrides,
    )..where((a) => a.occurrenceKey.isIn(keys))).go();
    await (_db.delete(
      _db.planOccurrences,
    )..where((o) => o.occurrenceKey.isIn(keys))).go();
  }

  Future<void> changeTimes(int planId, List<int> minutes) async {
    final times = _minutes(minutes);
    await _db.transaction(() async {
      final p = await _plan(planId);
      if (p.endedAt != null) {
        throw StateError('Der Messplan wurde bereits beendet.');
      }
      final old = await _details(p);
      final at = _now().toUtc();
      _checkClock(old, at);
      await _discardFuture(planId, at);
      await _revision(planId, times, await isEnabled(), at);
      await _bump();
    });
  }

  Future<void> end(int planId) async {
    await _db.transaction(() async {
      final p = await _plan(planId);
      if (p.endedAt != null) {
        throw StateError('Der Messplan wurde bereits beendet.');
      }
      final old = await _details(p);
      final at = _now().toUtc();
      _checkClock(old, at);
      await _discardFuture(planId, at);
      await (_db.update(_db.measurementPlans)
            ..where((p) => p.id.equals(planId)))
          .write(MeasurementPlansCompanion(endedAt: Value(at)));
      await _bump();
    });
  }

  Future<void> setFeatureEnabled(bool enabled) async {
    await _db.transaction(() async {
      if (await isEnabled() == enabled) return;
      final open = await (_db.select(
        _db.measurementPlans,
      )..where((p) => p.endedAt.isNull())).get();
      final at = _now().toUtc();
      for (final p in open) {
        final old = await _details(p);
        _checkClock(old, at);
        await _discardFuture(p.id, at);
        await _revision(p.id, old.minutes, enabled, at);
      }
      await _db
          .into(_db.appSettings)
          .insert(
            AppSettingsCompanion.insert(key: enabledKey, value: '$enabled'),
            mode: InsertMode.insertOrReplace,
          );
      await _bump();
    });
  }

  Future<PlanDetails?> readSlot(int slot) async {
    validateMetadataSlot(slot);
    return _db.transaction(() async {
      final plans =
          await (_db.select(_db.measurementPlans)
                ..where((p) => p.userSlot.equals(slot))
                ..orderBy([(p) => OrderingTerm.desc(p.id)])
                ..limit(1))
              .get();
      return plans.isEmpty ? null : _details(plans.single);
    });
  }

  Future<ReminderSnapshot> desiredSnapshot({
    List<String> fulfilledKeys = const [],
  }) async {
    return _db.transaction(() async {
      final enabled = await isEnabled();
      final state = await _db.select(_db.reminderSync).getSingle();
      final plans = await (_db.select(
        _db.measurementPlans,
      )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
      final rules = <ReminderRule>[];
      for (final p in plans) {
        final revisions =
            await (_db.select(_db.planRevisions)
                  ..where((r) => r.planId.equals(p.id))
                  ..orderBy([(r) => OrderingTerm.asc(r.id)]))
                .get();
        if (revisions.isEmpty) throw StateError('Messplan ohne Revision.');
        for (var i = 0; i < revisions.length; i++) {
          final revision = revisions[i];
          if (!revision.enabled) continue;
          final end = i + 1 < revisions.length
              ? revisions[i + 1].effectiveAt
              : p.endedAt;
          final times = await (_db.select(
            _db.planTimes,
          )..where((t) => t.revisionId.equals(revision.id))).get();
          rules.add(
            ReminderRule(
              planId: p.id,
              revisionId: revision.id,
              userSlot: p.userSlot,
              minutesOfDay: _minutes(times.map((t) => t.minuteOfDay).toList()),
              effectiveAtUtc: revision.effectiveAt.toUtc(),
              endsAtUtc: end?.toUtc(),
            ),
          );
        }
      }
      final occurrences = await _db.select(_db.planOccurrences).get();
      final events = await _db.select(_db.planTimeChanges).get();
      return ReminderSnapshot(
        generation: state.desiredGeneration,
        enabled: enabled,
        rules: rules,
        fulfilledKeys: List.unmodifiable(fulfilledKeys),
        acknowledgedOccurrenceKeys: occurrences
            .map((o) => o.occurrenceKey)
            .toList(),
        acknowledgedEventIds: events.map((e) => e.eventId).toList(),
      );
    });
  }

  DateTime _changeCutoff(
    String? oldZone,
    String? newZone,
    List<ReminderTimeChange> events,
  ) {
    var cutoff = _now().toUtc();
    String? currentZone = oldZone;
    DateTime? chainStart;
    final changes = [...events]
      ..sort((a, b) => a.occurredAtUtc.compareTo(b.occurredAtUtc));
    for (final event in changes) {
      if (event.oldZoneId == oldZone) {
        chainStart = event.occurredAtUtc;
        currentZone = event.newZoneId;
      } else if (event.oldZoneId == currentZone) {
        currentZone = event.newZoneId;
      } else {
        chainStart = null;
        currentZone = event.newZoneId;
      }
      if (event.newZoneId == oldZone && event.oldZoneId != event.newZoneId) {
        chainStart = null;
      }
    }
    if (currentZone == newZone &&
        chainStart != null &&
        chainStart.isBefore(cutoff)) {
      cutoff = chainStart;
    }
    return cutoff;
  }

  Future<bool> acceptReceipt(ReminderReceipt receipt) async {
    return _db.transaction(() async {
      final state = await _db.select(_db.reminderSync).getSingle();
      if (state.desiredGeneration != receipt.generation) return false;
      final rules = {
        for (final rule in (await desiredSnapshot()).rules)
          rule.revisionId: rule,
      };
      for (final occurrence in receipt.occurrences) {
        final revision = await (_db.select(
          _db.planRevisions,
        )..where((r) => r.id.equals(occurrence.revisionId))).getSingleOrNull();
        if (revision == null) {
          throw StateError('Termin verweist auf eine unbekannte Revision.');
        }
        final p = await _plan(revision.planId);
        if (p.userSlot != occurrence.userSlot ||
            occurrence.key !=
                '${p.userSlot}:${revision.id}:${occurrence.localDate}:${occurrence.minuteOfDay}') {
          throw StateError(
            'Terminidentität stimmt nicht mit dem Messplan überein.',
          );
        }
        final times = await (_db.select(
          _db.planTimes,
        )..where((t) => t.revisionId.equals(revision.id))).get();
        if (!revision.enabled ||
            !times.any((t) => t.minuteOfDay == occurrence.minuteOfDay)) {
          throw StateError('Termin gehört nicht zu einer aktiven Planzeit.');
        }
        final rule = rules[revision.id];
        final due = occurrence.dueAt;
        // Android kann einen vor der Änderung erzeugten Beleg noch quittieren.
        // Die neue Generation macht einen abgelösten Solltermin nicht wieder gültig.
        if (rule == null ||
            (due != null &&
                (due.isBefore(rule.effectiveAtUtc) ||
                    (rule.endsAtUtc != null &&
                        !due.isBefore(rule.endsAtUtc!))))) {
          continue;
        }
        final existing =
            await (_db.select(_db.planOccurrences)
                  ..where((o) => o.occurrenceKey.equals(occurrence.key)))
                .getSingleOrNull();
        if (existing != null) {
          final changed =
              existing.dueAt?.toUtc() != occurrence.dueAt?.toUtc() ||
              existing.zoneId != occurrence.zoneId ||
              existing.timeAmbiguous != occurrence.timeAmbiguous;
          if (!changed) continue;
          final cutoff = _changeCutoff(
            existing.zoneId,
            occurrence.zoneId,
            receipt.timeChanges,
          );
          if (existing.dueAt == null || existing.dueAt!.isBefore(cutoff)) {
            throw StateError(
              'Ein historischer Terminbeleg darf nicht nachträglich verändert werden.',
            );
          }
          await (_db.update(
            _db.planOccurrences,
          )..where((o) => o.occurrenceKey.equals(occurrence.key))).write(
            PlanOccurrencesCompanion(
              dueAt: Value(occurrence.dueAt),
              zoneId: Value(occurrence.zoneId),
              timeAmbiguous: Value(occurrence.timeAmbiguous),
            ),
          );
          continue;
        }
        await _db
            .into(_db.planOccurrences)
            .insert(
              PlanOccurrencesCompanion.insert(
                occurrenceKey: occurrence.key,
                revisionId: occurrence.revisionId,
                dueAt: Value(occurrence.dueAt),
                localDate: occurrence.localDate,
                minuteOfDay: occurrence.minuteOfDay,
                zoneId: Value(occurrence.zoneId),
                timeAmbiguous: occurrence.timeAmbiguous,
              ),
            );
      }
      final activeKeys = receipt.occurrences.map((o) => o.key).toSet();
      for (final key in receipt.retiredOccurrenceKeys) {
        if (activeKeys.contains(key)) {
          throw StateError(
            'Ein Termin kann nicht gleichzeitig zurückgenommen und bestätigt werden.',
          );
        }
        final old = await (_db.select(
          _db.planOccurrences,
        )..where((o) => o.occurrenceKey.equals(key))).getSingleOrNull();
        if (old == null || old.dueAt == null) continue;
        final sortedEvents = [...receipt.timeChanges]
          ..sort((a, b) => a.occurredAtUtc.compareTo(b.occurredAtUtc));
        final cutoff = _changeCutoff(
          old.zoneId,
          sortedEvents.isEmpty ? old.zoneId : sortedEvents.last.newZoneId,
          sortedEvents,
        );
        if (old.dueAt!.isBefore(cutoff)) continue;
        await (_db.delete(
          _db.planAssignmentOverrides,
        )..where((a) => a.occurrenceKey.equals(key))).go();
        await (_db.delete(
          _db.planOccurrences,
        )..where((o) => o.occurrenceKey.equals(key))).go();
      }
      for (final event in receipt.timeChanges) {
        await _db
            .into(_db.planTimeChanges)
            .insert(
              PlanTimeChangesCompanion.insert(
                eventId: event.eventId,
                occurredAt: event.occurredAtUtc,
                oldZoneId: Value(event.oldZoneId),
                newZoneId: event.newZoneId,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      if (receipt.mode == ReminderMode.failed &&
          (receipt.error == null || receipt.error!.isEmpty)) {
        throw StateError('Erinnerungsfehler ohne Beschreibung.');
      }
      final applied =
          receipt.appliedGeneration == receipt.generation &&
          receipt.mode != ReminderMode.failed;
      await (_db.update(_db.reminderSync)..where((s) => s.id.equals(1))).write(
        ReminderSyncCompanion(
          appliedGeneration: applied
              ? Value(receipt.generation)
              : const Value(null),
          lastError: Value(receipt.error),
        ),
      );
      return true;
    });
  }

  Future<List<PlannedOccurrence>> occurrences(int slot) async {
    validateMetadataSlot(slot);
    final plans = await (_db.select(
      _db.measurementPlans,
    )..where((p) => p.userSlot.equals(slot))).get();
    final revisions = await (_db.select(
      _db.planRevisions,
    )..where((r) => r.planId.isIn(plans.map((p) => p.id)))).get();
    final rows =
        await (_db.select(_db.planOccurrences)
              ..where((o) => o.revisionId.isIn(revisions.map((r) => r.id)))
              ..orderBy([
                (o) => OrderingTerm.asc(o.localDate),
                (o) => OrderingTerm.asc(o.minuteOfDay),
              ]))
            .get();
    return rows
        .map(
          (o) => PlannedOccurrence(
            key: o.occurrenceKey,
            userSlot: slot,
            revisionId: o.revisionId,
            dueAt: o.dueAt?.toUtc(),
            localDate: o.localDate,
            minuteOfDay: o.minuteOfDay,
            zoneId: o.zoneId,
            timeAmbiguous: o.timeAmbiguous,
          ),
        )
        .toList();
  }

  Future<Map<MeasurementKey, String?>> assignments(int slot) async {
    validateMetadataSlot(slot);
    final rows = await (_db.select(
      _db.planAssignmentOverrides,
    )..where((a) => a.userSlot.equals(slot))).get();
    return {
      for (final row in rows)
        (userSlot: slot, deviceSequence: row.deviceSequence): row.occurrenceKey,
    };
  }

  Future<void> assign(MeasurementKey key, String? occurrenceKey) async {
    await _db.transaction(() async {
      await requireMetadataMeasurement(_db, key);
      if (occurrenceKey != null) {
        final occurrence =
            await (_db.select(_db.planOccurrences)
                  ..where((o) => o.occurrenceKey.equals(occurrenceKey)))
                .getSingleOrNull();
        if (occurrence == null) {
          throw StateError('Der Termin ist nicht mehr vorhanden.');
        }
        final revision = await (_db.select(
          _db.planRevisions,
        )..where((r) => r.id.equals(occurrence.revisionId))).getSingle();
        if ((await _plan(revision.planId)).userSlot != key.userSlot) {
          throw ArgumentError(
            'Der Termin gehört zu einem anderen Speicherplatz.',
          );
        }
        await (_db.delete(
          _db.planAssignmentOverrides,
        )..where((a) => a.occurrenceKey.equals(occurrenceKey))).go();
      }
      await (_db.delete(_db.planAssignmentOverrides)..where(
            (a) =>
                a.userSlot.equals(key.userSlot) &
                a.deviceSequence.equals(key.deviceSequence),
          ))
          .go();
      await _db
          .into(_db.planAssignmentOverrides)
          .insert(
            PlanAssignmentOverridesCompanion.insert(
              userSlot: key.userSlot,
              deviceSequence: key.deviceSequence,
              occurrenceKey: Value(occurrenceKey),
              decidedAt: _now().toUtc(),
            ),
          );
      await _bump();
    });
  }

  Future<void> useAutomaticAssignment(MeasurementKey key) async {
    await _db.transaction(() async {
      await requireMetadataMeasurement(_db, key);
      await (_db.delete(_db.planAssignmentOverrides)..where(
            (a) =>
                a.userSlot.equals(key.userSlot) &
                a.deviceSequence.equals(key.deviceSequence),
          ))
          .go();
      await _bump();
    });
  }

  Future<void> recordFailure(int generation, Object error) async {
    await (_db.update(_db.reminderSync)..where(
          (s) => s.id.equals(1) & s.desiredGeneration.equals(generation),
        ))
        .write(
          ReminderSyncCompanion(
            appliedGeneration: const Value(null),
            lastError: Value(error.toString()),
          ),
        );
  }

  Future<int> advanceGenerationBeyond(int nativeGeneration) async {
    if (nativeGeneration < 0) {
      throw ArgumentError.value(nativeGeneration, 'nativeGeneration');
    }
    return _db.transaction(() async {
      final state = await _db.select(_db.reminderSync).getSingle();
      if (state.desiredGeneration > nativeGeneration) {
        return state.desiredGeneration;
      }
      final next = nativeGeneration + 1;
      await (_db.update(_db.reminderSync)..where((s) => s.id.equals(1))).write(
        ReminderSyncCompanion(
          desiredGeneration: Value(next),
          appliedGeneration: const Value(null),
          lastError: const Value(null),
        ),
      );
      return next;
    });
  }

  Future<void> markMeasurementsChanged() => _db.transaction(_bump);
}
