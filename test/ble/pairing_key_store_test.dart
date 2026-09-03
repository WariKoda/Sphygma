import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ble/pairing_key_store.dart';

void main() {
  group('PairingKeyStore.loadOrCreate', () {
    test('erzeugt beim ersten Aufruf einen 16-Byte-Key', () async {
      final store = InMemoryPairingKeyStore();

      final key = await store.loadOrCreate();

      expect(key, hasLength(16));
    });

    test('liefert beim zweiten Aufruf denselben Key', () async {
      final store = InMemoryPairingKeyStore();

      final first = await store.loadOrCreate();
      final second = await store.loadOrCreate();

      expect(second, first);
    });

    test('zwei Stores erzeugen unterschiedliche Keys', () async {
      final a = await InMemoryPairingKeyStore().loadOrCreate();
      final b = await InMemoryPairingKeyStore().loadOrCreate();

      expect(a, isNot(equals(b)));
    });

    test('load ohne Key liefert null, nicht einen Ersatzwert', () async {
      expect(await InMemoryPairingKeyStore().load(), isNull);
    });
  });

  group('Hex-Kodierung fuer den Speicher', () {
    test('roundtrip', () {
      final key = Uint8List.fromList(List.generate(16, (i) => i * 17 & 0xff));

      expect(pairingKeyFromHex(pairingKeyToHex(key)), key);
    });

    test('wirft bei falscher Laenge - kein stilles Auffuellen', () {
      expect(() => pairingKeyFromHex('abcd'), throwsFormatException);
    });
  });
}
