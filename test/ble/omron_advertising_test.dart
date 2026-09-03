// Befund M1 (docs/protocol/hem-6232t.md §2.1): Das Geraet bewirbt nur
// 0x1810, ein Service-Filter findet es nie - erkannt wird es am Namen.
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ble/omron_advertising.dart';

void main() {
  group('isOmronAdvertisingName', () {
    test('Pairing-Modus: BLEsmart_ (kleines s)', () {
      expect(isOmronAdvertisingName('BLEsmart_0000024400112233AABB'), isTrue);
    });

    test('Normalmodus: BLESmart_ (grosses S)', () {
      expect(isOmronAdvertisingName('BLESmart_0000024400112233AABB'), isTrue);
    });

    test('fremde Geraete und leere Namen nicht', () {
      expect(isOmronAdvertisingName(''), isFalse);
      expect(isOmronAdvertisingName('1EFDA2529C0159'), isFalse);
      expect(isOmronAdvertisingName('smartBLE_x'), isFalse);
    });
  });
}
