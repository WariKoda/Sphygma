import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ble/flutter_blue_plus_transport.dart';
import 'package:sphygma/protocol/exceptions.dart';

class _Characteristic extends BluetoothCharacteristic {
  _Characteristic(int index)
    : super(
        remoteId: const DeviceIdentifier('test'),
        serviceUuid: Guid('1800'),
        characteristicUuid: Guid((0x2a00 + index).toRadixString(16)),
      );
  final values = StreamController<List<int>>();
  @override
  Stream<List<int>> get onValueReceived => values.stream;
  @override
  Future<bool> setNotifyValue(
    bool notify, {
    int timeout = 15,
    bool forceIndications = false,
  }) async => true;
}

void main() {
  late List<_Characteristic> rx;
  late FlutterBluePlusTransport transport;
  setUp(() async {
    rx = List.generate(4, _Characteristic.new);
    transport = FlutterBluePlusTransport(
      txCharacteristics: rx,
      rxCharacteristics: rx,
    );
    await transport.enableNotifications();
  });
  tearDown(() async {
    await transport.disableNotifications();
    for (final c in rx) {
      await c.values.close();
    }
  });
  test('Notify-Streamfehler erreicht den wartenden Aufrufer', () async {
    final error = StateError('notify failed');
    final response = transport.readResponse();
    final assertion = expectLater(response, throwsA(same(error)));
    rx[0].values.addError(error);
    await assertion;
  });
  test('leeres Notify-Paket wird als Protokollfehler weitergereicht', () async {
    final response = transport.readResponse();
    final assertion = expectLater(response, throwsA(isA<ProtocolException>()));
    rx[0].values.add([]);
    await assertion;
  });
  test('geschlossener RX-Kanal beendet die wartende Antwort', () async {
    final assertion = expectLater(
      transport.readResponse(),
      throwsA(isA<ProtocolException>()),
    );
    await rx[0].values.close();
    await assertion;
  });
  test('Fehler vor readResponse bleibt fuer den Aufrufer erhalten', () async {
    final error = StateError('notify failed before read');
    rx[0].values.addError(error);
    await Future<void>.delayed(Duration.zero);
    await expectLater(transport.readResponse(), throwsA(same(error)));
  });
}
