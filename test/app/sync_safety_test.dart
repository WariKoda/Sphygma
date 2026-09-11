import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/omron_advertising.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/measurement_metadata_repository.dart';
import 'package:sphygma/db/phase_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';

class _RecordingSink implements HealthSink {
  final writes = <String>[];
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {
    writes.add(write.clientRecordId);
  }

  @override
  Future<void> deleteBloodPressure(String id) async {}
}

class _Readout extends SyncService {
  _Readout({required super.keyStore, required super.repository});
  bool fail = false;
  int sequence = 0;
  @override
  Future<void> pair({void Function(String)? log}) async {
    await keyStore.loadOrCreate();
  }

  @override
  Future<SyncResult> sync({void Function(String)? log}) async {
    if (fail) throw StateError('Readout abgebrochen');
    sequence++;
    final records = [
      SlotRecord(
        userSlot: 1,
        record: BloodPressureRecord(
          systolic: 120,
          diastolic: 80,
          pulse: 70,
          timestamp: DateTime(2026, 9, 10, 8, sequence),
          arrhythmiaFlag: false,
          movementFlag: false,
          sequence: sequence,
        ),
        rawBytes: Uint8List(14),
      ),
    ];
    return SyncResult(
      readFromDevice: 1,
      newlyStored: await repository.importAll(records),
    );
  }
}

class _GatedRepository extends MeasurementRepository {
  _GatedRepository(super.db);
  final entered = Completer<void>();
  final release = Completer<void>();
  @override
  Future<int?> intakeFloor(int slot) async {
    if (slot == 2) {
      if (!entered.isCompleted) entered.complete();
      await release.future;
    }
    return super.intakeFloor(slot);
  }
}

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late SettingsRepository settings;
  late InMemoryPairingKeyStore keys;
  late _Readout readout;
  late _RecordingSink sink;
  final controllers = <AppController>[];

  Future<AppController> boot({
    Stream<OmronAdvertisedStatus> Function()? stream,
  }) async {
    final c = AppController(
      settings: settings,
      keyStore: keys,
      repository: repository,
      metadataRepository: MeasurementMetadataRepository(db),
      phaseRepository: PhaseRepository(db),
      syncService: readout,
      exportService: ExportService(repository: repository, sink: sink),
      statusStream: stream ?? () => const Stream.empty(),
    );
    controllers.add(c);
    await c.init();
    if (c.userSlot == null) await c.setUserSlot(1);
    return c;
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    settings = SettingsRepository(db);
    keys = InMemoryPairingKeyStore();
    readout = _Readout(keyStore: keys, repository: repository);
    sink = _RecordingSink();
  });
  tearDown(() async {
    for (final c in controllers) {
      c.dispose();
    }
    controllers.clear();
    await pumpEventQueue();
    await db.close();
  });

  test('ohne ausdrückliche Wahl startet trotz Pairing kein Autosync', () async {
    await keys.save(Uint8List(16));
    var starts = 0;
    await boot(
      stream: () {
        starts++;
        return const Stream.empty();
      },
    );
    expect(starts, 0);
  });

  test(
    'offene Übernahme sperrt auch den zweiten Sync und einen Neustart',
    () async {
      final c = await boot();
      await c.pair();
      await c.sync(autoExport: false);
      await c.sync();
      expect(sink.writes, isEmpty);
      final restarted = await boot();
      await restarted.sync();
      expect(sink.writes, isEmpty);
      await restarted.takeOnlyNew();
      await restarted.sync();
      expect(sink.writes, ['sphygma-slot1-seq4']);
    },
  );

  test(
    'nach abgebrochenem Erstauslesen gibt es keine Übernahme ins Leere',
    () async {
      final c = await boot();
      await c.pair();
      readout.fail = true;
      await expectLater(c.sync(autoExport: false), throwsStateError);
      await expectLater(c.takeOnlyNew(), throwsStateError);
      readout.fail = false;
      await c.sync();
      expect(sink.writes, isEmpty);
      await c.takeAll();
      await c.sync();
      expect(sink.writes, ['sphygma-slot1-seq1', 'sphygma-slot1-seq2']);
    },
  );
  test(
    'Autosync wird ausdrücklich eingeschaltet und die Wahl bleibt gespeichert',
    () async {
      await keys.save(Uint8List(16));
      final c = await boot();
      expect(c.autoSyncEnabled, isFalse);
      await c.setAutoSync(true);
      expect(c.autoSyncEnabled, isTrue);
      expect((await boot()).autoSyncEnabled, isTrue);
      await c.setAutoSync(false);
      expect(c.autoSyncActive, isFalse);
      expect((await boot()).autoSyncEnabled, isFalse);
    },
  );

  test(
    'ein ungültiger Autosync-Wert wird nicht als Zustimmung behandelt',
    () async {
      await settings.setRawSetting('auto_sync', 'kaputt');
      await expectLater(boot(), throwsStateError);
    },
  );

  test(
    'die offene Übernahme eines anderen Slots bleibt unabhängig gesperrt',
    () async {
      final c = await boot();
      await c.pair();
      await c.sync();
      await c.takeAll();
      await c.setUserSlot(2);
      expect(c.intakeDecisionPending, isTrue);
      await c.setUserSlot(1);
      expect(c.intakeDecisionPending, isFalse);
    },
  );
  test(
    'ein Slotwechsel sperrt parallele Übernahme mit veraltetem Zustand',
    () async {
      final gated = _GatedRepository(db);
      final c = AppController(
        settings: settings,
        keyStore: keys,
        repository: gated,
        metadataRepository: MeasurementMetadataRepository(db),
        phaseRepository: PhaseRepository(db),
        syncService: readout,
        exportService: ExportService(repository: gated, sink: sink),
        statusStream: () => const Stream.empty(),
      );
      controllers.add(c);
      await c.init();
      await c.setUserSlot(1);
      await settings.setIntakeState(2, IntakeState.awaitingReadout);
      final switching = c.setUserSlot(2);
      await gated.entered.future;
      final choice = c.takeOnlyNew();
      final failure = expectLater(choice, throwsStateError);
      await pumpEventQueue();
      gated.release.complete();
      await switching;
      await failure;
      expect(await settings.intakeState(2), IntakeState.awaitingReadout);
    },
  );
  test(
    'auch manuelle Exporte verlangen eine abgeschlossene Übernahme',
    () async {
      final c = await boot();
      await c.pair();
      await c.sync(autoExport: false);
      await expectLater(c.exportAll(), throwsStateError);
      await expectLater(c.exportOne(c.measurements.first), throwsStateError);
      expect(sink.writes, isEmpty);
      await c.takeAll();
      await c.exportAll();
      expect(sink.writes, ['sphygma-slot1-seq1']);
    },
  );
}
