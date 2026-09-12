import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_metadata_repository.dart';
import 'package:sphygma/db/measurement_plan_repository.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/phase_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/plan/plan_controller.dart';
import 'package:sphygma/plan/plan_models.dart';
import 'package:sphygma/plan/reminder_gateway.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';

class _Settings extends SettingsRepository {
  _Settings(super.db);
  bool failTimestamp = false;

  @override
  Future<void> setLastSuccessfulSyncAt(DateTime value) async {
    if (failTimestamp) throw StateError('Sync-Zeitpunkt nicht speicherbar');
    await super.setLastSuccessfulSyncAt(value);
  }
}

class _Readout extends SyncService {
  _Readout({required super.keyStore, required super.repository});
  bool fail = false;

  @override
  Future<SyncResult> sync({void Function(String)? log}) async {
    if (fail) throw StateError('Readout fehlgeschlagen');
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
    final stored = await repository.importAll([
      SlotRecord(userSlot: 1, record: parseRecord(raw)!, rawBytes: raw),
    ]);
    return SyncResult(readFromDevice: 1, newlyStored: stored);
  }
}

class _FailingSink implements HealthSink {
  int writes = 0;

  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {
    writes++;
    throw StateError('Export fehlgeschlagen');
  }

  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

class _Gateway implements ReminderGateway {
  _Gateway(this.now);
  final DateTime Function() now;
  ReminderSnapshot native = const ReminderSnapshot(
    generation: 0,
    enabled: false,
    rules: [],
  );

  ReminderReceipt _receipt(ReminderSnapshot snapshot) {
    final at = now();
    final day =
        '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')}';
    final occurrences = <PlannedOccurrence>[
      for (final rule in snapshot.rules)
        for (final minute in rule.minutesOfDay)
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
    ];
    return ReminderReceipt(
      generation: snapshot.generation,
      appliedGeneration: snapshot.generation,
      mode: snapshot.enabled ? ReminderMode.exact : ReminderMode.off,
      notificationsAllowed: true,
      exactAllowed: true,
      channelBlocked: false,
      pendingOccurrenceKeys: occurrences.map((o) => o.key).toList(),
      occurrences: occurrences,
      timeChanges: const [],
    );
  }

  @override
  Future<ReminderReceipt> inspect() async => _receipt(native);

  @override
  Future<ReminderReceipt> replace(ReminderSnapshot desired) async {
    native = desired;
    return _receipt(desired);
  }

  @override
  Future<ReminderReceipt> requestAccess() async => inspect();

  @override
  Future<ReminderReceipt> openAccessSettings() async => inspect();
}

void main() {
  late AppDatabase db;
  late MeasurementRepository measurements;
  late MeasurementPlanRepository plans;
  late PlanController plan;
  late AppController app;
  late _Readout readout;
  late _FailingSink sink;
  late _Settings settings;
  late _Gateway gateway;
  final now = DateTime.utc(2024, 3, 15, 7, 30);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    measurements = MeasurementRepository(db);
    plans = MeasurementPlanRepository(db, now: () => now);
    await plans.setFeatureEnabled(true);
    await plans.start(1, [465]);
    gateway = _Gateway(() => now);
    plan = PlanController(
      repository: plans,
      measurements: measurements,
      gateway: gateway,
      now: () => now,
    );
    final keys = InMemoryPairingKeyStore();
    await keys.save(Uint8List(16));
    readout = _Readout(keyStore: keys, repository: measurements);
    sink = _FailingSink();
    settings = _Settings(db);
    await settings.setUserSlot(1);
    app = AppController(
      settings: settings,
      keyStore: keys,
      repository: measurements,
      metadataRepository: MeasurementMetadataRepository(db),
      phaseRepository: PhaseRepository(db),
      syncService: readout,
      exportService: ExportService(repository: measurements, sink: sink),
      planController: plan,
      statusStream: () => const Stream.empty(),
      clock: () => now,
    );
    await app.init();
  });

  tearDown(() async {
    app.dispose();
    plan.dispose();
    await db.close();
  });

  test(
    'Import aktualisiert Erfüllung auch bei anschließendem Exportfehler',
    () async {
      expect(plan.fulfillment, isEmpty);

      await app.sync();

      expect(plan.fulfillment.values, [(userSlot: 1, deviceSequence: 1)]);
      expect(sink.writes, 1);
      expect(app.autoExportProblem, contains('Export fehlgeschlagen'));
    },
  );

  test('Readoutfehler erfindet keine neue Erfüllung', () async {
    readout.fail = true;

    await expectLater(app.sync(), throwsStateError);

    expect(plan.fulfillment, isEmpty);
    expect(await measurements.allForSlot(1), isEmpty);
  });
  test('Sync-Zeitstempelfehler verhindert keine Zuordnung des gespeicherten Imports', () async {
    settings.failTimestamp = true;

    await expectLater(
      app.sync(),
      throwsA(
        predicate<Object>(
          (error) => error.toString().contains(
            'Geräteabgleich erfolgreich, Zeitpunkt konnte nicht gespeichert',
          ),
        ),
      ),
    );

    expect(plan.fulfillment.values, [(userSlot: 1, deviceSequence: 1)]);
    expect(gateway.native.fulfilledKeys, plan.fulfillment.keys.toList());
    final stored = (await measurements.allForSlot(1)).single;
    expect(stored.rawBytes, [
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
    expect(stored.exportedAt, isNull);
    expect(sink.writes, 0);
    expect(app.lastSuccessfulSyncAt, isNull);
    expect(await settings.lastSuccessfulSyncAt(), isNull);
    expect(app.status, contains('Zeitpunkt konnte nicht gespeichert'));
  });
}
