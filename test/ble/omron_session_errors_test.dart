import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ble/omron_session.dart';
import 'package:sphygma/protocol/exceptions.dart';

final class _Platform extends FlutterBluePlusPlatform {
  final scans = StreamController<BmScanResponse>.broadcast();
  final connections = StreamController<BmConnectionStateResponse>.broadcast();
  final services = StreamController<BmDiscoverServicesResult>.broadcast();
  bool scanFails = false;
  bool stopFails = false;
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
  setUpAll(() {
    FlutterBluePlusPlatform.instance = platform;
  });
  setUp(() {
    platform.scanFails = false;
    platform.stopFails = false;
    platform.disconnects = 0;
  });
  tearDown(() async {
    await FlutterBluePlus.stopScan();
  });

  test('asynchroner Scanfehler bleibt als Plattformfehler erhalten', () async {
    platform.scanFails = true;
    await expectLater(
      OmronSession.scan(),
      throwsA(isA<FlutterBluePlusException>().having((e) => e.code, 'code', 6)),
    );
  });
  test('Fehler beim Scan-Stop wird vor einer Verbindung gemeldet', () async {
    platform.stopFails = true;
    await expectLater(OmronSession.scan(), throwsA(same(platform.stopFailure)));
  });
  test(
    'fehlender Parent-Service schliesst die geoeffnete Verbindung',
    () async {
      await expectLater(OmronSession.open(), throwsA(isA<ProtocolException>()));
      expect(platform.disconnects, 1);
    },
  );
}
