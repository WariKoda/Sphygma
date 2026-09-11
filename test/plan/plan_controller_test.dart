import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_plan_repository.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/plan/plan_controller.dart';
import 'package:sphygma/plan/plan_models.dart';
import 'package:sphygma/plan/reminder_gateway.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';

class FakeReminderGateway implements ReminderGateway {
  FakeReminderGateway(this.now);
  final DateTime Function() now;
  final snapshots = <ReminderSnapshot>[];
  ReminderSnapshot native = const ReminderSnapshot(
    generation: 0,
    enabled: false,
    rules: [],
  );
  int accessRequests = 0;
  bool fail = false;
  bool openPlan = false;
  bool omitConfirmation = false;
  List<PlannedOccurrence>? forcedOccurrences;
  List<ReminderTimeChange> forcedTimeChanges = const [];
  int? nativeGenerationFloor;
  Completer<void>? hold;
  ReminderReceipt? inspectReceipt;
  ReminderReceipt? accessReceipt;
  final calls = <String>[];
  ReminderReceipt _receipt(ReminderSnapshot snapshot) {
    final at = now();
    final day =
        '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')}';
    final occurrences = forcedOccurrences == null
        ? <PlannedOccurrence>[
            for (final rule in snapshot.rules)
              for (final minute in rule.minutesOfDay)
                if (DateTime.utc(at.year, at.month, at.day)
                        .add(Duration(minutes: minute))
                        .isAfter(
                          rule.effectiveAtUtc.subtract(
                            const Duration(microseconds: 1),
                          ),
                        ) &&
                    (rule.endsAtUtc == null ||
                        DateTime.utc(at.year, at.month, at.day)
                            .add(Duration(minutes: minute))
                            .isBefore(rule.endsAtUtc!)))
                  PlannedOccurrence(
                    key: '${rule.userSlot}:${rule.revisionId}:$day:$minute',
                    userSlot: rule.userSlot,
                    revisionId: rule.revisionId,
                    dueAt: DateTime.utc(
                      at.year,
                      at.month,
                      at.day,
                    ).add(Duration(minutes: minute)),
                    localDate: day,
                    minuteOfDay: minute,
                    zoneId: 'UTC',
                    timeAmbiguous: false,
                  ),
          ]
        : [...forcedOccurrences!];
    return ReminderReceipt(
      generation: snapshot.generation,
      appliedGeneration: omitConfirmation ? null : snapshot.generation,
      mode: snapshot.enabled ? ReminderMode.exact : ReminderMode.off,
      notificationsAllowed: true,
      exactAllowed: true,
      channelBlocked: false,
      pendingOccurrenceKeys: occurrences
          .where(
            (o) =>
                o.dueAt != null &&
                o.dueAt!.isAfter(at) &&
                !snapshot.fulfilledKeys.contains(o.key),
          )
          .map((o) => o.key)
          .toList(),
      occurrences: occurrences,
      timeChanges: forcedTimeChanges,
      openPlanRequested: openPlan,
    );
  }

  @override
  Future<ReminderReceipt> replace(ReminderSnapshot desired) async {
    calls.add('replace');
    snapshots.add(desired);
    await hold?.future;
    if (fail) throw StateError('Native Planung fehlgeschlagen');
    final floor = nativeGenerationFloor;
    if (floor != null && desired.generation < floor) {
      return _receipt(
        ReminderSnapshot(
          generation: floor,
          enabled: native.enabled,
          rules: native.rules,
        ),
      );
    }
    native = desired;
    return _receipt(desired);
  }

  @override
  Future<ReminderReceipt> inspect() async {
    calls.add('inspect');
    return inspectReceipt ?? _receipt(native);
  }

  @override
  Future<ReminderReceipt> requestAccess() async {
    calls.add('requestAccess');
    accessRequests++;
    return accessReceipt ?? inspect();
  }
}

class FakeCalendarTimer implements ControllerCalendarTimer {
  Duration? delay;
  void Function()? callback;
  int cancelCount = 0;
  @override
  void cancel() {
    cancelCount++;
    callback = null;
  }

  @override
  void schedule(Duration delay, void Function() callback) {
    this.delay = delay;
    this.callback = callback;
  }

  void fire() {
    final pending = callback;
    callback = null;
    pending?.call();
  }
}

void main() {
  late AppDatabase db;
  late MeasurementPlanRepository plans;
  late MeasurementRepository measurements;
  late FakeReminderGateway gateway;
  late PlanController controller;
  late DateTime now;
  late FakeCalendarTimer calendarTimer;
  PlanController create() => PlanController(
    repository: plans,
    measurements: measurements,
    gateway: gateway,
    now: () => now,
    calendarTimer: calendarTimer,
  );
  setUp(() {
    now = DateTime.utc(2024, 3, 15, 7, 30);
    db = AppDatabase(NativeDatabase.memory());
    plans = MeasurementPlanRepository(db, now: () => now);
    measurements = MeasurementRepository(db);
    gateway = FakeReminderGateway(() => now);
    calendarTimer = FakeCalendarTimer();
    controller = create();
  });
  tearDown(() async {
    controller.dispose();
    await db.close();
  });
  Future<void> importReading({int slot = 1}) async {
    final raw = Uint8List.fromList([
      0x55,
      0x6b,
      0x18,
      0x44,
      0x0d,
      0xe7,
      0x0a,
      0xa1,
      0,
      0,
      0,
      1,
      0,
      0,
    ]);
    await measurements.importAll([
      SlotRecord(userSlot: slot, record: parseRecord(raw)!, rawBytes: raw),
    ]);
  }

  test(
    'ausgeschaltet lädt ohne Berechtigungsdialog und ohne Planpflicht',
    () async {
      await controller.load();
      expect(controller.enabled, isFalse);
      expect(controller.mode, ReminderMode.off);
      expect(controller.todayOccurrences, isEmpty);
      expect(gateway.accessRequests, 0);
    },
  );
  test(
    'Aktivieren, Zeiten speichern, aus/an und Neustart erhalten den Plan',
    () async {
      await controller.setUserSlot(1);
      await controller.setEnabled(true);
      await controller.saveTimes([465, 720, 1200]);
      expect(controller.currentSlotPlan!.minutes, [465, 720, 1200]);
      expect(controller.todayOccurrences, hasLength(3));
      final id = controller.currentSlotPlan!.plan.id;
      await controller.setEnabled(false);
      expect(gateway.snapshots.last.enabled, isFalse);
      expect(controller.mode, ReminderMode.off);
      expect(controller.todayOccurrences, isEmpty);
      await controller.setEnabled(true);
      controller.dispose();
      controller = create();
      await controller.setUserSlot(1);
      await controller.load();
      expect(controller.currentSlotPlan!.plan.id, id);
    },
  );
  test(
    'echte Rohmessung erfüllt Termin und unterdrückt anstehende Erinnerung',
    () async {
      await controller.setUserSlot(1);
      await controller.setEnabled(true);
      await controller.saveTimes([465, 720]);
      await importReading();
      await controller.refreshAfterSync();
      expect(controller.fulfillment.values, [(userSlot: 1, deviceSequence: 1)]);
      expect(
        gateway.snapshots.last.fulfilledKeys,
        controller.fulfillment.keys.toList(),
      );
      expect(controller.nextOccurrence!.minuteOfDay, 720);
    },
  );
  test(
    'Slotwechsel verändert fremden Plan nicht und beide Slots bleiben geplant',
    () async {
      await controller.setUserSlot(1);
      await controller.setEnabled(true);
      await controller.saveTimes([465]);
      await controller.setUserSlot(2);
      await controller.saveTimes([720]);
      expect(controller.currentSlotPlan!.plan.userSlot, 2);
      expect((await plans.readSlot(1))!.minutes, [465]);
      expect(gateway.snapshots.last.rules.map((r) => r.userSlot).toSet(), {
        1,
        2,
      });
    },
  );
  test(
    'fehlgeschlagenes Abschalten bleibt sichtbar und wird erneut versucht',
    () async {
      await controller.setUserSlot(1);
      await controller.setEnabled(true);
      await controller.saveTimes([465]);
      gateway.fail = true;
      await expectLater(controller.setEnabled(false), throwsStateError);
      expect(controller.enabled, isFalse);
      expect(controller.mode, ReminderMode.failed);
      expect(controller.error, contains('Native Planung fehlgeschlagen'));
      gateway.fail = false;
      await controller.reconcileReminders();
      expect(controller.mode, ReminderMode.off);
      expect(controller.error, isNull);
    },
  );
  test('queued Ausschalten gewinnt gegen ausstehende alte Quittung', () async {
    await controller.setUserSlot(1);
    gateway.hold = Completer<void>();
    final on = controller.setEnabled(true);
    await Future<void>.delayed(Duration.zero);
    final off = controller.setEnabled(false);
    gateway.hold!.complete();
    await Future.wait([on, off]);
    expect(controller.enabled, isFalse);
    expect(gateway.snapshots.last.enabled, isFalse);
    expect(controller.mode, ReminderMode.off);
  });
  test(
    'Prozessneustart nach DB-Mutation wendet unbestätigten Wunsch an',
    () async {
      await plans.setFeatureEnabled(true);
      await plans.start(1, [465]);
      await controller.setUserSlot(1);
      await controller.load();
      expect(controller.mode, ReminderMode.exact);
      expect(gateway.snapshots.last.enabled, isTrue);
    },
  );

  test('inspect läuft vor replace', () async {
    await controller.load();
    expect(gateway.calls.take(2), ['inspect', 'replace']);
  });

  test(
    'Ausschalten sendet disabled Snapshot vor jedem weiteren inspect',
    () async {
      await controller.setUserSlot(1);
      await controller.setEnabled(true);
      await controller.saveTimes([465]);
      gateway.calls.clear();

      await controller.setEnabled(false);

      expect(gateway.calls.first, 'replace');
      expect(gateway.calls, isNot(contains('inspect')));
      expect(gateway.snapshots.last.enabled, isFalse);
    },
  );

  test(
    'neue Erfüllung erreicht replace ohne Rearm des alten Native-Zustands',
    () async {
      await controller.setUserSlot(1);
      await controller.setEnabled(true);
      await controller.saveTimes([465]);
      await importReading();
      gateway.calls.clear();

      await controller.refreshAfterSync();

      expect(gateway.calls.first, 'replace');
      expect(gateway.calls, isNot(contains('inspect')));
      expect(gateway.snapshots.last.fulfilledKeys, isNotEmpty);
    },
  );

  test(
    'replace-first bewahrt Receipt-Evidence und quittiert sie danach',
    () async {
      await controller.setUserSlot(1);
      await controller.setEnabled(true);
      gateway.forcedTimeChanges = [
        ReminderTimeChange(
          eventId: 'zone-before-mutation',
          occurredAtUtc: now.subtract(const Duration(minutes: 1)),
          oldZoneId: 'UTC',
          newZoneId: 'Europe/Berlin',
        ),
      ];

      await controller.saveTimes([465]);

      final events = await db.select(db.planTimeChanges).get();
      expect(
        events.map((event) => event.eventId),
        contains('zone-before-mutation'),
      );
      expect(
        gateway.snapshots.last.acknowledgedEventIds,
        contains('zone-before-mutation'),
      );
    },
  );

  test(
    'replace-first überholt eine vorausliegende native Generation',
    () async {
      await controller.setUserSlot(1);
      await controller.setEnabled(true);
      gateway.nativeGenerationFloor = 40;
      gateway.calls.clear();
      final snapshotCount = gateway.snapshots.length;

      await controller.saveTimes([465]);

      expect(gateway.calls, ['replace', 'replace', 'replace']);
      expect(gateway.snapshots[snapshotCount + 1].generation, 41);
      expect(gateway.snapshots.last.generation, 41);
      expect((await plans.desiredSnapshot()).generation, 41);
    },
  );

  test('requestAccess übernimmt den konsumierten Öffnungswunsch', () async {
    await plans.setFeatureEnabled(true);
    await controller.load();
    final generation = (await plans.desiredSnapshot()).generation;
    gateway.accessReceipt = ReminderReceipt(
      generation: generation,
      appliedGeneration: generation,
      mode: ReminderMode.exact,
      notificationsAllowed: true,
      exactAllowed: true,
      channelBlocked: false,
      pendingOccurrenceKeys: const [],
      occurrences: const [],
      timeChanges: const [],
      openPlanRequested: true,
    );

    await controller.requestAccess();

    expect(controller.takeOpenPlanRequest(), isTrue);
    expect(controller.takeOpenPlanRequest(), isFalse);
  });

  test(
    'lokale Eingabefehler lassen bestätigten Native-Modus bestehen',
    () async {
      await controller.setUserSlot(1);
      await controller.setEnabled(true);
      await controller.saveTimes([465]);
      final before = await db.select(db.reminderSync).getSingle();

      await expectLater(controller.saveTimes([]), throwsArgumentError);

      final after = await db.select(db.reminderSync).getSingle();
      expect(controller.mode, ReminderMode.exact);
      expect(controller.error, contains('gültige, eindeutige Uhrzeit'));
      expect(after.appliedGeneration, before.appliedGeneration);
    },
  );

  test('native Generation voraus erzeugt neuen Drift-Wunsch darüber', () async {
    gateway.inspectReceipt = const ReminderReceipt(
      generation: 50,
      appliedGeneration: 50,
      mode: ReminderMode.off,
      notificationsAllowed: true,
      exactAllowed: true,
      channelBlocked: false,
      pendingOccurrenceKeys: [],
      occurrences: [],
      timeChanges: [],
    );

    await controller.load();

    expect(gateway.snapshots.first.generation, 51);
    expect(gateway.snapshots.first.enabled, isFalse);
    expect((await plans.desiredSnapshot()).generation, 51);
  });

  test('fehlende native Bestätigung übernimmt keine Terminbelege', () async {
    await controller.setUserSlot(1);
    await controller.setEnabled(true);
    gateway.omitConfirmation = true;

    await expectLater(controller.saveTimes([465]), throwsStateError);

    expect(await plans.occurrences(1), isEmpty);
    expect(controller.mode, ReminderMode.failed);
  });

  test(
    'Kalendertimer entfernt einen abgelaufenen nächsten Termin UI-lokal',
    () async {
      await controller.setUserSlot(1);
      await controller.setEnabled(true);
      await controller.saveTimes([465]);
      expect(controller.nextOccurrence?.minuteOfDay, 465);
      final replaces = gateway.snapshots.length;

      now = DateTime.utc(2024, 3, 15, 7, 46);
      calendarTimer.fire();
      await pumpEventQueue();

      expect(controller.nextOccurrence, isNull);
      expect(gateway.snapshots, hasLength(replaces));
      controller.dispose();
      expect(calendarTimer.callback, isNull);
      controller = create();
    },
  );

  test('Kalendertimer reconciled genau am Tageswechsel', () async {
    await controller.setUserSlot(1);
    await controller.setEnabled(true);
    await controller.saveTimes([465]);
    now = DateTime.utc(2024, 3, 15, 7, 46);
    calendarTimer.fire();
    await pumpEventQueue();
    final replaces = gateway.snapshots.length;

    now = DateTime.utc(2024, 3, 16);
    calendarTimer.fire();
    await pumpEventQueue();

    expect(gateway.snapshots.length, greaterThan(replaces));
    expect(controller.todayOccurrences.single.localDate, '2024-03-16');
  });

  test('anderer Importzonen-Instant ändert die zivile Rohzeit nicht', () async {
    await controller.setUserSlot(1);
    await controller.setEnabled(true);
    await controller.saveTimes([465]);
    await importReading();
    await (db.update(db.measurements)
          ..where((row) => row.userSlot.equals(1))
          ..where((row) => row.deviceSequence.equals(1)))
        .write(
          MeasurementsCompanion(
            measuredAt: Value(DateTime.utc(2024, 3, 15, 6, 45)),
          ),
        );

    await controller.refreshAfterSync();

    expect(controller.fulfillment.values, [(userSlot: 1, deviceSequence: 1)]);
  });

  test('abweichende Roh- und DB-Sequenz bleibt ein harter Fehler', () async {
    await controller.setUserSlot(1);
    await controller.setEnabled(true);
    await controller.saveTimes([465]);
    await importReading();
    await (db.update(db.measurements)
          ..where((row) => row.userSlot.equals(1))
          ..where((row) => row.deviceSequence.equals(1)))
        .write(const MeasurementsCompanion(deviceSequence: Value(2)));

    await expectLater(controller.refreshAfterSync(), throwsStateError);

    expect(controller.error, contains('Rohaufzeichnung passt nicht'));
  });

  test('Intake-Grenze schließt auch manuell zugeordnete Messung aus', () async {
    await controller.setUserSlot(1);
    await controller.setEnabled(true);
    await controller.saveTimes([465]);
    await importReading();
    final occurrence = controller.todayOccurrences.single;
    await controller.assign((userSlot: 1, deviceSequence: 1), occurrence.key);
    expect(controller.fulfillment, contains(occurrence.key));

    await measurements.setIntakeFloor(1, 2);
    await controller.refreshAfterSync();

    expect(controller.fulfillment, isEmpty);
  });

  test('mehrdeutiger Termin wird nur durch manuelle Auswahl erfüllt', () async {
    await plans.setFeatureEnabled(true);
    await plans.start(1, [465]);
    final details = (await plans.readSlot(1))!;
    final ambiguous = PlannedOccurrence(
      key: '1:${details.revision.id}:2024-03-15:465',
      userSlot: 1,
      revisionId: details.revision.id,
      dueAt: null,
      localDate: '2024-03-15',
      minuteOfDay: 465,
      zoneId: null,
      timeAmbiguous: true,
    );
    gateway.forcedOccurrences = [ambiguous];
    await controller.setUserSlot(1);
    await controller.load();
    await importReading();
    await controller.refreshAfterSync();
    expect(controller.fulfillment, isEmpty);

    await controller.assign((userSlot: 1, deviceSequence: 1), ambiguous.key);

    expect(controller.fulfillment[ambiguous.key], (
      userSlot: 1,
      deviceSequence: 1,
    ));
  });

  test('DST-Lücke 02:30 erfüllt nicht fälschlich den Termin 03:30', () async {
    now = DateTime.utc(2024, 3, 31, 1);
    await plans.setFeatureEnabled(true);
    await plans.start(1, [150, 210]);
    final revision = (await plans.readSlot(1))!.revision.id;
    gateway.forcedOccurrences = [
      PlannedOccurrence(
        key: '1:$revision:2024-03-31:150',
        userSlot: 1,
        revisionId: revision,
        dueAt: null,
        localDate: '2024-03-31',
        minuteOfDay: 150,
        zoneId: null,
        timeAmbiguous: true,
      ),
      PlannedOccurrence(
        key: '1:$revision:2024-03-31:210',
        userSlot: 1,
        revisionId: revision,
        dueAt: DateTime.utc(2024, 3, 31, 1, 30),
        localDate: '2024-03-31',
        minuteOfDay: 210,
        zoneId: 'Europe/Berlin',
        timeAmbiguous: false,
      ),
    ];
    await controller.setUserSlot(1);
    await controller.load();
    final raw = Uint8List.fromList([
      80,
      95,
      24,
      70,
      15,
      226,
      7,
      128,
      0,
      0,
      1,
      0,
      0,
      0,
    ]);
    await measurements.importAll([
      SlotRecord(userSlot: 1, record: parseRecord(raw)!, rawBytes: raw),
    ]);

    await controller.refreshAfterSync();

    expect(controller.fulfillment, isEmpty);
  });
}
