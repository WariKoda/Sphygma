import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/omron_session.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/measurement_metadata_repository.dart';
import 'package:sphygma/db/phase_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';

final class _Platform extends FlutterBluePlusPlatform {
  final scans = StreamController<BmScanResponse>.broadcast();
  final events = <String>[];
  int sequence = 0;
  bool active = false;
  Completer<void>? startGate;
  Object? startError;
  Object? stopError;
  @override
  Stream<BmScanResponse> get onScanResponse => scans.stream;
  @override
  Future<BmBluetoothAdapterState> getAdapterState(
    BmBluetoothAdapterStateRequest r,
  ) async => BmBluetoothAdapterState(adapterState: BmAdapterStateEnum.on);
  void advertise(int n) {
    sequence = n;
    if (!active) return;
    scans.add(
      BmScanResponse(
        advertisements: [
          BmScanAdvertisement.fromMap({
            'remote_id': 'AA:BB:CC:DD:EE:FF',
            'adv_name': 'BLESmart_test',
            'manufacturer_data': {
              0x020e: [1, 1, n & 255, n >> 8, n, 0, 0, 0],
            },
          }),
        ],
        success: true,
        errorCode: 0,
        errorString: '',
      ),
    );
  }

  @override
  Future<bool> startScan(BmScanSettings r) async {
    await startGate?.future;
    if (startError case final error?) throw error;
    active = true;
    events.add(r.continuousUpdates ? 'watch start' : 'readout scan');
    if (!r.continuousUpdates) Timer.run(() => advertise(sequence));
    return true;
  }

  @override
  Future<bool> stopScan(BmStopScanRequest r) async {
    events.add('stop');
    active = false;
    if (stopError case final error?) throw error;
    return true;
  }
}

class _Readout extends SyncService {
  _Readout({
    required super.repository,
    required super.keyStore,
    required this.platform,
  });
  final _Platform platform;
  int imports = 0;
  @override
  Future<SyncResult> sync({void Function(String)? log}) async {
    await OmronSession.scan(); // Echter Scan und globaler Plugin-Stop; nur der EEPROM-Inhalt ist simuliert.
    final n = platform.sequence;
    final count = await repository.importAll([
      SlotRecord(
        userSlot: 1,
        rawBytes: Uint8List(14),
        record: BloodPressureRecord(
          systolic: 120,
          diastolic: 80,
          pulse: 65,
          timestamp: DateTime(2026, 9, 11, 8, n),
          arrhythmiaFlag: false,
          movementFlag: false,
          sequence: n,
        ),
      ),
    ]);
    imports++;
    return SyncResult(readFromDevice: 1, newlyStored: count);
  }
}

class _Sink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite w) async {}
  @override
  Future<void> deleteBloodPressure(String id) async {}
}

Future<void> _until(bool Function() condition) async {
  final end = DateTime.now().add(const Duration(seconds: 2));
  while (!condition()) {
    if (DateTime.now().isAfter(end)) throw TimeoutException('condition');
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  final platform = _Platform();
  setUpAll(() => FlutterBluePlusPlatform.instance = platform);
  tearDown(() async {
    final gate = platform.startGate;
    if (gate != null && !gate.isCompleted) gate.complete();
    platform.startGate = null;
    platform.startError = null;
    platform.stopError = null;
    await FlutterBluePlus.stopScan();
  });
  test(
    'Cancel waehrend des Starts wartet auf Start und raeumt danach auf',
    () async {
      final gate = Completer<void>();
      platform.startGate = gate;
      final sub = watchOmronStatus().listen((_) {});
      addTearDown(() => sub.cancel().timeout(const Duration(seconds: 1)));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      var completed = false;
      final cancellation = sub.cancel().then((_) => completed = true);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(completed, false);
      gate.complete();
      await cancellation.timeout(const Duration(seconds: 1));
      expect(platform.active, false);
    },
  );
  test('Startfehler erreicht den Listener und beendet den Stream', () async {
    final error = StateError('start failed');
    platform.startError = error;
    final errors = <Object>[];
    final done = Completer<void>();
    final sub = watchOmronStatus().listen(
      (_) {},
      onError: errors.add,
      onDone: done.complete,
    );
    addTearDown(() => sub.cancel().timeout(const Duration(seconds: 1)));
    await done.future.timeout(const Duration(seconds: 1));
    expect(errors, [same(error)]);
  });
  test('Scanfehler erreicht den Listener und beendet den Stream', () async {
    final errors = <Object>[];
    final done = Completer<void>();
    final sub = watchOmronStatus().listen(
      (_) {},
      onError: errors.add,
      onDone: done.complete,
    );
    addTearDown(() => sub.cancel().timeout(const Duration(seconds: 1)));
    await _until(() => platform.active);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    platform.scans.add(
      BmScanResponse(
        advertisements: [],
        success: false,
        errorCode: 6,
        errorString: 'scan failed',
      ),
    );
    await done.future.timeout(const Duration(seconds: 1));
    expect(errors, [
      isA<FlutterBluePlusException>().having((e) => e.code, 'code', 6),
    ]);
  });
  test(
    'Neuer Watcher aus Fehlerhandler wird nicht vom alten Cleanup gestoppt',
    () async {
      StreamSubscription<dynamic>? next;
      final done = Completer<void>();
      watchOmronStatus().listen(
        (_) {},
        onError: (Object error) {
          next = watchOmronStatus().listen((_) {});
        },
        onDone: done.complete,
      );
      addTearDown(() async {
        await next?.cancel().timeout(const Duration(seconds: 1));
      });
      await _until(() => platform.active);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      platform.scans.add(
        BmScanResponse(
          advertisements: [],
          success: false,
          errorCode: 6,
          errorString: 'scan failed',
        ),
      );
      await done.future.timeout(const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(platform.active, isTrue);
    },
  );
  test('Fehlgeschlagener Stop wird beim Cancel weitergereicht', () async {
    final sub = watchOmronStatus().listen((_) {});
    await _until(() => platform.active);
    final error = StateError('stop failed');
    platform.stopError = error;
    await expectLater(sub.cancel(), throwsA(same(error)));
  });
  test(
    'Cancel vor dem ersten Advertising wartet nicht auf ein Scanereignis',
    () async {
      final sub = watchOmronStatus().listen((_) {});
      addTearDown(() => sub.cancel().timeout(const Duration(seconds: 1)));
      await _until(() => platform.active);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel().timeout(const Duration(seconds: 1));
      expect(platform.active, false);
    },
  );
  test(
    'zwei Advertisings loesen mit echtem Watcher zwei Imports aus',
    () async {
      platform.events.clear();
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = MeasurementRepository(db);
      final settings = SettingsRepository(db);
      await settings.setUserSlot(1);
      await settings.setRawSetting('auto_sync', 'true');
      await settings.setRawSetting('auto_export', 'false');
      final keyStore = InMemoryPairingKeyStore();
      await keyStore.save(Uint8List(16));
      final service = _Readout(
        repository: repository,
        keyStore: keyStore,
        platform: platform,
      );
      final c = AppController(
        settings: settings,
        keyStore: keyStore,
        repository: repository,
        metadataRepository: MeasurementMetadataRepository(db),
        phaseRepository: PhaseRepository(db),
        syncService: service,
        exportService: ExportService(repository: repository, sink: _Sink()),
      );
      addTearDown(() async {
        await c.setAutoSync(false).timeout(const Duration(seconds: 1));
        c.dispose();
      });
      await c.init();
      await _until(() => platform.active);
      platform.advertise(1);
      await _until(
        () =>
            service.imports == 1 &&
            !c.busy &&
            platform.active &&
            c.autoSyncActive,
      );
      platform.advertise(2);
      await _until(
        () =>
            service.imports == 2 &&
            !c.busy &&
            platform.active &&
            c.autoSyncActive,
      );
      expect(await repository.highestSequenceFor(1), 2);
      expect(platform.events, [
        'watch start',
        'stop',
        'readout scan',
        'stop',
        'watch start',
        'stop',
        'readout scan',
        'stop',
        'watch start',
      ]);
      await c.setAutoSync(false).timeout(const Duration(seconds: 1));
    },
  );
}
