import 'dart:typed_data';

import 'package:drift/native.dart';
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

class NoopSink implements HealthSink {
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}

  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
}

class A3Harness {
  A3Harness()
    : db = AppDatabase(NativeDatabase.memory()),
      keys = InMemoryPairingKeyStore() {
    measurements = MeasurementRepository(db);
    metadata = MeasurementMetadataRepository(db);
    phases = PhaseRepository(db);
    settings = SettingsRepository(db);
    controller = AppController(
      settings: settings,
      keyStore: keys,
      repository: measurements,
      metadataRepository: metadata,
      phaseRepository: phases,
      syncService: SyncService(keyStore: keys, repository: measurements),
      exportService: ExportService(repository: measurements, sink: NoopSink()),
      statusStream: () => const Stream.empty(),
    );
  }

  final AppDatabase db;
  final InMemoryPairingKeyStore keys;
  late final MeasurementRepository measurements;
  late final MeasurementMetadataRepository metadata;
  late final PhaseRepository phases;
  late final SettingsRepository settings;
  late final AppController controller;

  Future<void> start() async {
    await controller.init();
    await controller.setUserSlot(1);
  }

  Future<void> addMeasurement({int sequence = 1}) async {
    await measurements.importAll([
      SlotRecord(
        userSlot: 1,
        record: BloodPressureRecord(
          systolic: 124,
          diastolic: 82,
          pulse: 65,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          arrhythmiaFlag: false,
          movementFlag: false,
          sequence: sequence,
        ),
        rawBytes: Uint8List(14),
      ),
    ]);
    await controller.refreshForTest();
  }

  Future<void> close() async {
    controller.dispose();
    await db.close();
  }
}
