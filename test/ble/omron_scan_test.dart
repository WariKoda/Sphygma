import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ble/omron_session.dart';

final class _Platform extends FlutterBluePlusPlatform {
  final scans = StreamController<BmScanResponse>.broadcast();
  final connections = StreamController<BmConnectionStateResponse>.broadcast();
  final services = StreamController<BmDiscoverServicesResult>.broadcast();
  bool scanFails = false;
  bool stopFails = false;
  Completer<void>? stopGate;
  Completer<void>? startGate;
  final stopFailure = StateError("stop failed");
  int disconnects = 0;

  @override
  Stream<BmScanResponse> get onScanResponse => scans.stream;
  @override
  Stream<BmConnectionStateResponse> get onConnectionStateChanged =>
      connections.stream;
  @override
  Stream<BmDiscoverServicesResult> get onDiscoveredServices => services.stream;
  @override
  Future<BmBluetoothAdapterState> getAdapterState(
    BmBluetoothAdapterStateRequest request,
  ) async => BmBluetoothAdapterState(adapterState: BmAdapterStateEnum.on);

  @override
  Future<bool> startScan(BmScanSettings request) async {
    await startGate?.future;
    Timer.run(
      () => scans.add(
        BmScanResponse(
          advertisements: scanFails
              ? []
              : [
                  BmScanAdvertisement.fromMap({
                    'remote_id': 'AA:BB:CC:DD:EE:FF',
                    'adv_name': 'BLESmart_test',
                  }),
                ],
          success: !scanFails,
          errorCode: scanFails ? 6 : 0,
          errorString: scanFails ? 'scan failed' : '',
        ),
      ),
    );
    return true;
  }

  @override
  Future<bool> stopScan(BmStopScanRequest request) async {
    await stopGate?.future;
    if (stopFails) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      throw stopFailure;
    }
    return true;
  }

  @override
  Future<bool> connect(BmConnectRequest request) async {
    connections.add(
      BmConnectionStateResponse(
        remoteId: request.remoteId,
        connectionState: BmConnectionStateEnum.connected,
        disconnectReasonCode: null,
        disconnectReasonString: null,
      ),
    );
    return true;
  }

  @override
  Future<bool> discoverServices(BmDiscoverServicesRequest request) async {
    services.add(
      BmDiscoverServicesResult(
        remoteId: request.remoteId,
        services: [],
        success: true,
        errorCode: 0,
        errorString: '',
      ),
    );
    return true;
  }

  @override
  Future<bool> disconnect(BmDisconnectRequest request) async {
    disconnects++;
    connections.add(
      BmConnectionStateResponse(
        remoteId: request.remoteId,
        connectionState: BmConnectionStateEnum.disconnected,
        disconnectReasonCode: null,
        disconnectReasonString: null,
      ),
    );
    return true;
  }
}

void main() {
  final platform = _Platform();
  setUpAll(() => FlutterBluePlusPlatform.instance = platform);
  tearDown(() async {
    platform.startGate = null;
    platform.stopGate = null;
    platform.stopFails = false;
    platform.scanFails = false;
    await FlutterBluePlus.stopScan();
  });

  for (final starting in [false, true]) {
    test(
      'Scan-Timeout begrenzt ausstehenden Plattform-${starting ? "Start" : "Stop"}',
      () async {
        final gate = Completer<void>();
        if (starting) {
          platform.startGate = gate;
        } else {
          platform.stopGate = gate;
        }
        final scan = OmronSession.scan(
          timeout: const Duration(milliseconds: 10),
        );
        final outcome = scan.then<Object>(
          (_) => 'returned',
          onError: (Object error) => error,
        );
        final result = await Future.any<Object>([
          outcome,
          Future<String>.delayed(
            const Duration(seconds: 6),
            () => 'still waiting',
          ),
        ]);
        gate.complete();
        await outcome;
        await FlutterBluePlus.stopScan();
        expect(result, isA<TimeoutException>());
      },
    );
  }

  test('normaler Treffer wird nach bestätigtem Stop zurückgegeben', () async {
    final result = await OmronSession.scan();
    expect(result.device.remoteId.str, 'AA:BB:CC:DD:EE:FF');
    expect(FlutterBluePlus.isScanningNow, isFalse);
  });

  test('fehlender Status liefert nach regulärem Timeout den Treffer', () async {
    final result = await OmronSession.scan(
      timeout: const Duration(milliseconds: 10),
      waitForStatus: true,
    );
    expect(result.device.remoteId.str, 'AA:BB:CC:DD:EE:FF');
    expect(result.status, isNull);
  });

  test('Fehler beim zeitgesteuerten Stop bleibt beim Aufrufer', () async {
    platform.stopFails = true;
    await expectLater(
      OmronSession.scan(
        timeout: const Duration(milliseconds: 10),
        waitForStatus: true,
      ),
      throwsA(same(platform.stopFailure)),
    );
  });
}
