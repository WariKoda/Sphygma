// Spezifikation: docs/protocol/hem-6232t.md §1-2.
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/protocol/hem6232t_device.dart';

void main() {
  test('4 RX- und 4 TX-Kanaele, alle UUIDs paarweise verschieden', () {
    expect(Hem6232tDevice.rxCharacteristicUuids, hasLength(4));
    expect(Hem6232tDevice.txCharacteristicUuids, hasLength(4));

    final all = [
      Hem6232tDevice.parentServiceUuid,
      Hem6232tDevice.unlockCharacteristicUuid,
      ...Hem6232tDevice.rxCharacteristicUuids,
      ...Hem6232tDevice.txCharacteristicUuids,
    ];
    expect(all.toSet(), hasLength(all.length));
  });

  test('2 User-Slots mit je 100 Records ab den dokumentierten Adressen', () {
    expect(Hem6232tDevice.userStartAddresses, [0x02e8, 0x0860]);
    expect(Hem6232tDevice.recordsPerUser, 100);
    expect(Hem6232tDevice.recordByteSize, 14);
    expect(Hem6232tDevice.transmissionBlockSize, 0x38);
  });
}
