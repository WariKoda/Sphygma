import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_metadata_repository.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/phase_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/stats/measurement_windows.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';

class _Settings extends SettingsRepository {
  _Settings(super.db);
  bool fail = false;
  @override
  Future<void> setMeasurementWindows(MeasurementWindows value) async {
    if (fail) throw StateError('Schreiben fehlgeschlagen');
    await super.setMeasurementWindows(value);
  }
}

class _Sink implements HealthSink {
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
}

void main() {
  test('init lädt Fenster, Setter persistiert vor Benachrichtigung und erhält Zustand bei Fehler', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final settings = _Settings(db);
    final keys = InMemoryPairingKeyStore();
    final repository = MeasurementRepository(db);
    final custom = MeasurementWindows(
      morningStart: 360,
      morningEnd: 660,
      eveningStart: 1140,
      eveningEnd: 60,
    );
    await settings.setMeasurementWindows(custom);
    final controller = AppController(
      settings: settings,
      keyStore: keys,
      repository: repository,
      metadataRepository: MeasurementMetadataRepository(db),
      phaseRepository: PhaseRepository(db),
      syncService: SyncService(keyStore: keys, repository: repository),
      exportService: ExportService(repository: repository, sink: _Sink()),
      statusStream: () => const Stream.empty(),
    );
    addTearDown(() async {
      controller.dispose();
      await db.close();
    });
    await controller.init();
    expect(controller.measurementWindows.encode(), custom.encode());
    var notifications = 0;
    controller.addListener(() {
      notifications++;
    });
    await controller.setMeasurementWindows(MeasurementWindows.defaults);
    expect(notifications, 1);
    expect(
      (await settings.measurementWindows()).encode(),
      controller.measurementWindows.encode(),
    );
    settings.fail = true;
    await expectLater(
      controller.setMeasurementWindows(custom),
      throwsStateError,
    );
    expect(notifications, 1);
    expect(
      controller.measurementWindows.encode(),
      MeasurementWindows.defaults.encode(),
    );
  });
}
