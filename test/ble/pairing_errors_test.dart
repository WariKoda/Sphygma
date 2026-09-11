import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ble/pairing.dart';

class _UnlockCharacteristic extends BluetoothCharacteristic {
  _UnlockCharacteristic()
    : super(
        remoteId: const DeviceIdentifier('test'),
        serviceUuid: Guid('1800'),
        characteristicUuid: Guid('2a00'),
      );
  final values = StreamController<List<int>>();
  final error = StateError('unlock channel failed');
  @override
  Stream<List<int>> get onValueReceived => values.stream;
  @override
  Future<bool> setNotifyValue(
    bool notify, {
    int timeout = 15,
    bool forceIndications = false,
  }) async => true;
  @override
  Future<void> write(
    List<int> value, {
    bool withoutResponse = false,
    bool allowLongWrite = false,
    int timeout = 15,
  }) async {
    values.addError(error);
  }
}

void main() {
  for (final pair in [true, false]) {
    test('${pair ? "Pairing" : "Unlock"} reicht Streamfehler weiter', () async {
      final characteristic = _UnlockCharacteristic();
      addTearDown(characteristic.values.close);
      final operation = pair
          ? writeNewPairingKey(
              unlockCharacteristic: characteristic,
              key: Uint8List(16),
            )
          : unlockWithPairingKey(
              unlockCharacteristic: characteristic,
              key: Uint8List(16),
            );
      await expectLater(operation, throwsA(same(characteristic.error)));
    });
  }
}
