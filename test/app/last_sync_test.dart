import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_metadata_repository.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/phase_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';

class _Readout extends SyncService {
  _Readout({required super.keyStore, required super.repository});
  bool fail = false;
  bool importMeasurement = false;
  @override
  Future<SyncResult> sync({void Function(String)? log}) async {
    if (fail) throw StateError('Readout fehlgeschlagen');
    if (!importMeasurement) {
      return SyncResult(readFromDevice: 0, newlyStored: 0);
    }
    final stored = await repository.importAll([
      SlotRecord(
        userSlot: 1,
        record: BloodPressureRecord(
          systolic: 120,
          diastolic: 80,
          pulse: 70,
          timestamp: DateTime(2026, 9, 11, 12),
          arrhythmiaFlag: false,
          movementFlag: false,
          sequence: 1,
        ),
        rawBytes: Uint8List(14),
      ),
    ]);
    return SyncResult(readFromDevice: 1, newlyStored: stored);
  }
}

class _Sink implements HealthSink {
  bool fail = false;
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {
    if (fail) throw StateError('Export fehlgeschlagen');
  }
}

void main() {
  late AppDatabase db;
  late SettingsRepository settings;
  late AppController controller;
  late _Readout readout;
  late _Sink sink;
  final completedAt = DateTime.utc(2026, 9, 11, 12, 34);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsRepository(db);
    final keys = InMemoryPairingKeyStore();
    await keys.save(Uint8List(16));
    final repository = MeasurementRepository(db);
    readout = _Readout(keyStore: keys, repository: repository);
    sink = _Sink();
    controller = AppController(
      settings: settings,
      keyStore: keys,
      repository: repository,
      metadataRepository: MeasurementMetadataRepository(db),
      phaseRepository: PhaseRepository(db),
      syncService: readout,
      exportService: ExportService(repository: repository, sink: sink),
      statusStream: () => const Stream.empty(),
      clock: () => completedAt,
    );
    await controller.init();
    await controller.setUserSlot(1);
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  test(
    'erfolgreicher Readout ohne neue Werte zählt und überlebt Neustart',
    () async {
      await controller.sync();
      expect(controller.lastSuccessfulSyncAt, completedAt);
      expect(await SettingsRepository(db).lastSuccessfulSyncAt(), completedAt);
    },
  );

  test('Readoutfehler verändert den letzten Erfolg nicht', () async {
    final previous = completedAt.subtract(const Duration(days: 1));
    await settings.setLastSuccessfulSyncAt(previous);
    readout.fail = true;
    await expectLater(controller.sync(), throwsStateError);
    expect(await settings.lastSuccessfulSyncAt(), previous);
  });

  test(
    'Exportfehler ändert nichts am erfolgreichen Readout-Zeitpunkt',
    () async {
      readout.importMeasurement = true;
      sink.fail = true;

      await controller.sync();

      expect(await settings.lastSuccessfulSyncAt(), completedAt);
      expect(controller.autoExportProblem, contains('Export fehlgeschlagen'));
    },
  );
}
