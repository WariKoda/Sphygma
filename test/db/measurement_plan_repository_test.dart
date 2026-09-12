import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_plan_repository.dart';
import 'package:sphygma/plan/plan_models.dart';
import 'package:sphygma/plan/reminder_gateway.dart';

import 'measurement_metadata_repository_test.dart'
    show seedMetadataMeasurements;

void main() {
  late AppDatabase db;
  late MeasurementPlanRepository repo;
  late DateTime now;
  setUp(() async {
    now = DateTime.utc(2026, 9, 11, 6);
    db = AppDatabase(NativeDatabase.memory());
    repo = MeasurementPlanRepository(db, now: () => now);
    await seedMetadataMeasurements(db);
  });
  tearDown(() => db.close());

  Future<PlannedOccurrence> occurrence(
    int slot,
    int minute, {
    String date = '2026-09-11',
  }) async {
    final details = (await repo.readSlot(slot))!;
    return PlannedOccurrence(
      key: '$slot:${details.revision.id}:$date:$minute',
      userSlot: slot,
      revisionId: details.revision.id,
      dueAt: DateTime.parse('${date}T00:00:00Z').add(Duration(minutes: minute)),
      localDate: date,
      minuteOfDay: minute,
      zoneId: 'UTC',
      timeAmbiguous: false,
    );
  }

  Future<bool> receipt(List<PlannedOccurrence> items, {int? generation}) async {
    final g = generation ?? (await repo.desiredSnapshot()).generation;
    return repo.acceptReceipt(
      ReminderReceipt(
        generation: g,
        appliedGeneration: g,
        mode: ReminderMode.exact,
        notificationsAllowed: true,
        exactAllowed: true,
        channelBlocked: false,
        pendingOccurrenceKeys: items.map((o) => o.key).toList(),
        occurrences: items,
        timeChanges: [],
      ),
    );
  }

  test(
    'ein Plan pro Slot, täglich sortierte Zeiten und echte Standardeinstellung',
    () async {
      expect(await repo.isEnabled(), isFalse);
      expect(await repo.readSlot(1), isNull);
      await repo.setFeatureEnabled(true);
      final id = await repo.start(1, [1200, 480, 720]);
      expect((await repo.readSlot(1))!.minutes, [480, 720, 1200]);
      expect((await repo.readSlot(1))!.plan.id, id);
      expect((await repo.readSlot(1))!.plan.endedAt, isNull);
      await expectLater(repo.start(1, [600]), throwsStateError);
      await repo.start(2, [600]);
      expect((await repo.desiredSnapshot()).rules, hasLength(2));
    },
  );
  test(
    'leere, doppelte und ungültige Zeiten sowie Slots ändern nichts',
    () async {
      for (final times in <List<int>>[
        [],
        [480, 480],
        [-1],
        [1440],
      ]) {
        await expectLater(repo.start(1, times), throwsArgumentError);
      }
      await expectLater(repo.start(0, [480]), throwsArgumentError);
      expect(await repo.readSlot(1), isNull);
      expect((await repo.desiredSnapshot()).generation, 0);
    },
  );
  test(
    'Ausschalten erhält Plan, schließt Revision und Neustart gilt ab jetzt',
    () async {
      await repo.setFeatureEnabled(true);
      final id = await repo.start(1, [480]);
      now = DateTime.utc(2026, 9, 11, 9);
      await repo.setFeatureEnabled(false);
      final disabled = await repo.desiredSnapshot();
      expect(disabled.enabled, isFalse);
      expect(disabled.rules.single.endsAtUtc, now);
      expect((await repo.readSlot(1))!.plan.id, id);
      now = DateTime.utc(2026, 9, 12, 7);
      await repo.setFeatureEnabled(true);
      final enabled = await repo.desiredSnapshot();
      expect(enabled.rules, hasLength(2));
      expect(enabled.rules.last.effectiveAtUtc, now);
      expect((await repo.readSlot(1))!.plan.id, id);
    },
  );
  test(
    'Änderung erhält Vergangenheit und ersetzt nur zukünftige Terminbelege',
    () async {
      await repo.setFeatureEnabled(true);
      final id = await repo.start(1, [480, 1200]);
      final past = await occurrence(1, 480);
      final future = await occurrence(1, 1200);
      await receipt([past, future]);
      now = DateTime.utc(2026, 9, 11, 10);
      await repo.changeTimes(id, [600, 1300]);
      expect((await repo.occurrences(1)).map((o) => o.key), [past.key]);
      expect((await repo.readSlot(1))!.plan.id, id);
      final rules = (await repo.desiredSnapshot()).rules;
      expect(rules.first.endsAtUtc, now);
      expect(rules.last.effectiveAtUtc, now);
    },
  );
  test('veraltete Quittung bestätigt keine neuere Konfiguration', () async {
    await repo.setFeatureEnabled(true);
    await repo.start(1, [480]);
    final g = (await repo.desiredSnapshot()).generation;
    final o = await occurrence(1, 480);
    await repo.setFeatureEnabled(false);
    expect(await receipt([o], generation: g), isFalse);
    expect(await repo.occurrences(1), isEmpty);
    expect(
      (await db.select(db.reminderSync).getSingle()).appliedGeneration,
      isNull,
    );
  });
  test(
    'Quittung speichert Belege, bestätigt Generation und sendet Acks',
    () async {
      await repo.setFeatureEnabled(true);
      await repo.start(1, [480]);
      final o = await occurrence(1, 480);
      expect(await receipt([o]), isTrue);
      final snapshot = await repo.desiredSnapshot();
      expect(snapshot.acknowledgedOccurrenceKeys, [o.key]);
      expect(
        (await db.select(db.reminderSync).getSingle()).appliedGeneration,
        snapshot.generation,
      );
      await receipt([o]);
      expect(await repo.occurrences(1), hasLength(1));
    },
  );
  test('Beenden lässt Neubeginn zu; alte Pläne bleiben Historie', () async {
    await repo.setFeatureEnabled(true);
    final first = await repo.start(1, [480]);
    now = now.add(const Duration(hours: 2));
    await repo.end(first);
    await expectLater(repo.changeTimes(first, [500]), throwsStateError);
    final next = await repo.start(1, [600]);
    expect(next, isNot(first));
    expect(await db.select(db.measurementPlans).get(), hasLength(2));
  });
  test(
    'manuelle Belegung ersetzt atomar und beachtet Slot und echte Messung',
    () async {
      await repo.setFeatureEnabled(true);
      await repo.start(1, [480]);
      await repo.start(2, [480]);
      final o = await occurrence(1, 480);
      final foreign = await occurrence(2, 480);
      await receipt([o, foreign]);
      const first = (userSlot: 1, deviceSequence: 10);
      const second = (userSlot: 1, deviceSequence: 11);
      await repo.assign(first, o.key);
      await repo.assign(second, o.key);
      expect(await repo.assignments(1), {second: o.key});
      await expectLater(repo.assign(first, foreign.key), throwsArgumentError);
      await expectLater(
        repo.assign((userSlot: 1, deviceSequence: 999), o.key),
        throwsStateError,
      );
      await repo.assign(second, null);
      expect(await repo.assignments(1), {second: null});
      await repo.useAutomaticAssignment(second);
      expect(await repo.assignments(1), isEmpty);
    },
  );
  test(
    'Zeitzonenwechsel darf künftigen Beleg ändern, historische Belege nicht',
    () async {
      await repo.setFeatureEnabled(true);
      await repo.start(1, [480]);
      final old = await occurrence(1, 480);
      await receipt([old]);
      final changed = PlannedOccurrence(
        key: old.key,
        userSlot: old.userSlot,
        revisionId: old.revisionId,
        dueAt: old.dueAt!.subtract(const Duration(hours: 1)),
        localDate: old.localDate,
        minuteOfDay: old.minuteOfDay,
        zoneId: 'Europe/London',
        timeAmbiguous: false,
      );
      await receipt([changed]);
      expect((await repo.occurrences(1)).single.zoneId, 'Europe/London');
      now = DateTime.utc(2026, 9, 11, 10);
      await expectLater(receipt([old]), throwsStateError);
      expect((await repo.occurrences(1)).single.zoneId, 'Europe/London');
    },
  );

  test('Revisionen zum selben Zeitpunkt werden durch ID geordnet', () async {
    await repo.setFeatureEnabled(true);
    final id = await repo.start(1, [480]);
    await repo.changeTimes(id, [600]);
    final rules = (await repo.desiredSnapshot()).rules;
    expect(rules.first.endsAtUtc, rules.last.effectiveAtUtc);
    expect(rules.first.revisionId, lessThan(rules.last.revisionId));
    expect((await repo.readSlot(1))!.minutes, [600]);
  });

  test('rückwärts gestellte Uhr erzeugt keine erfundene Revision', () async {
    await repo.setFeatureEnabled(true);
    final id = await repo.start(1, [480]);
    final generation = (await repo.desiredSnapshot()).generation;
    now = now.subtract(const Duration(hours: 1));
    await expectLater(repo.changeTimes(id, [600]), throwsStateError);
    expect((await repo.desiredSnapshot()).generation, generation);
    expect((await repo.readSlot(1))!.minutes, [480]);
  });
  test('verspäteter nativer Beleg stellt ersetzten Zukunftstermin nicht wieder her', () async {
    await repo.setFeatureEnabled(true);
    final id = await repo.start(1, [480, 1200]);
    final past = await occurrence(1, 480);
    final oldFuture = await occurrence(1, 1200);
    await receipt([past, oldFuture]);
    now = DateTime.utc(2026, 9, 11, 10);
    await repo.changeTimes(id, [1300]);
    // Native Quittung hat die neue Generation, enthält aber noch alte Belege.
    await receipt([past, oldFuture]);
    expect((await repo.occurrences(1)).map((o) => o.key), [past.key]);
  });
  test('Fehler entzieht Bestätigung auch bei gleicher Generation', () async {
    await repo.setFeatureEnabled(true);
    await repo.start(1, [480]);
    await receipt([await occurrence(1, 480)]);
    final generation = (await repo.desiredSnapshot()).generation;
    await repo.recordFailure(
      generation,
      StateError('Speichern fehlgeschlagen'),
    );
    final state = await db.select(db.reminderSync).getSingle();
    expect(state.appliedGeneration, isNull);
    expect(state.lastError, contains('Speichern fehlgeschlagen'));
  });

  test(
    'native Generation voraus erzeugt atomar eine höhere Drift-Generation',
    () async {
      expect(await repo.advanceGenerationBeyond(40), 41);
      expect((await repo.desiredSnapshot()).generation, 41);
      expect(await repo.advanceGenerationBeyond(12), 41);
    },
  );

  test('mehrere unbeantwortete Zeitzonenwechsel erhalten ursprünglichen Änderungszeitpunkt', () async {
    await repo.setFeatureEnabled(true);
    await repo.start(1, [480]);
    final old = await occurrence(1, 480);
    await receipt([old]);
    final changed = PlannedOccurrence(
      key: old.key,
      userSlot: old.userSlot,
      revisionId: old.revisionId,
      dueAt: DateTime.utc(2026, 9, 11, 9),
      localDate: old.localDate,
      minuteOfDay: old.minuteOfDay,
      zoneId: 'America/New_York',
      timeAmbiguous: false,
    );
    now = DateTime.utc(2026, 9, 11, 10);
    final generation = (await repo.desiredSnapshot()).generation;
    await repo.acceptReceipt(
      ReminderReceipt(
        generation: generation,
        appliedGeneration: generation,
        mode: ReminderMode.exact,
        notificationsAllowed: true,
        exactAllowed: true,
        channelBlocked: false,
        pendingOccurrenceKeys: [],
        occurrences: [changed],
        timeChanges: [
          ReminderTimeChange(
            eventId: 'a',
            occurredAtUtc: DateTime.utc(2026, 9, 11, 6, 30),
            oldZoneId: 'UTC',
            newZoneId: 'Europe/London',
          ),
          ReminderTimeChange(
            eventId: 'b',
            occurredAtUtc: DateTime.utc(2026, 9, 11, 6, 45),
            oldZoneId: 'Europe/London',
            newZoneId: 'America/New_York',
          ),
        ],
      ),
    );
    expect((await repo.occurrences(1)).single.zoneId, 'America/New_York');
  });
  test('native Rücknahme löscht nur beim Zeitwechsel noch zukünftige Belege atomar', () async {
    await repo.setFeatureEnabled(true);
    await repo.start(1, [480, 1200]);
    final past = await occurrence(1, 480);
    final future = await occurrence(1, 1200);
    await receipt([past, future]);
    await repo.assign((userSlot: 1, deviceSequence: 10), future.key);
    now = DateTime.utc(2026, 9, 11, 21);
    final generation = (await repo.desiredSnapshot()).generation;
    await repo.acceptReceipt(
      ReminderReceipt(
        generation: generation,
        appliedGeneration: generation,
        mode: ReminderMode.exact,
        notificationsAllowed: true,
        exactAllowed: true,
        channelBlocked: false,
        pendingOccurrenceKeys: [],
        occurrences: [],
        retiredOccurrenceKeys: [past.key, future.key],
        timeChanges: [
          ReminderTimeChange(
            eventId: 'retirement',
            occurredAtUtc: DateTime.utc(2026, 9, 11, 10),
            oldZoneId: 'UTC',
            newZoneId: 'Asia/Tokyo',
          ),
        ],
      ),
    );
    expect((await repo.occurrences(1)).map((o) => o.key), [past.key]);
    expect(await repo.assignments(1), isEmpty);
    expect((await repo.desiredSnapshot()).acknowledgedEventIds, ['retirement']);
  });
}
