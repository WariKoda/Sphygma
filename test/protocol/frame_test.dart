// Testvektoren aus docs/protocol/hem-6232t.md §3.4/§3.5/§7.1, gegen beide
// Referenzimplementierungen (omblepy, UBPM) verifiziert.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/protocol/exceptions.dart';
import 'package:sphygma/protocol/frame.dart';

void main() {
  group('xorChecksum', () {
    test('is zero for a well-formed start-transmission frame', () {
      final bytes = Uint8List.fromList([
        0x08, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x18,
      ]);

      expect(xorChecksum(bytes), 0);
    });

    test('is non-zero when a byte is corrupted', () {
      final bytes = Uint8List.fromList([
        0x08, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x19, // letztes Byte kaputt
      ]);

      expect(xorChecksum(bytes), isNot(0));
    });
  });

  group('feste Frames', () {
    test('startTransmission entspricht 0800000000100018', () {
      expect(
        startTransmissionFrame,
        Uint8List.fromList([0x08, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x18]),
      );
    });

    test('endTransmission entspricht 080f000000000007', () {
      expect(
        endTransmissionFrame,
        Uint8List.fromList([0x08, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07]),
      );
    });
  });

  group('buildReadEepromCommand', () {
    test('baut das Beispiel aus der Spezifikation: 0x26 Bytes @ 0x0260', () {
      final frame = buildReadEepromCommand(address: 0x0260, length: 0x26);

      expect(
        frame,
        Uint8List.fromList(
          [0x08, 0x01, 0x00, 0x02, 0x60, 0x26, 0x00, 0x4d],
        ),
      );
    });

    test('das gebaute Frame hat immer XOR-Pruefsumme 0', () {
      final frame = buildReadEepromCommand(address: 0x0700, length: 0x38);

      expect(xorChecksum(frame), 0);
    });

    test('wirft bei Laenge > 0xff, da das Laengenfeld ein Byte ist', () {
      expect(
        () => buildReadEepromCommand(address: 0, length: 0x100),
        throwsArgumentError,
      );
    });
  });

  group('parseResponseFrame', () {
    test('liest Typ, Adresse und Nutzdaten aus einer 8100-Antwort', () {
      final raw = Uint8List.fromList(
        [0x0a, 0x81, 0x00, 0x01, 0x00, 0x02, 0xab, 0xcd, 0x00, 0xee],
      );

      final response = parseResponseFrame(raw);

      expect(response.type, 0x8100);
      expect(response.address, 0x0100);
      expect(response.data, Uint8List.fromList([0xab, 0xcd]));
    });

    test('Sonderfall 8f00: Byte 6 ist der Fehlercode, nicht laengenbestimmt', () {
      final ok = Uint8List.fromList(
        [0x08, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x87],
      );
      final err = Uint8List.fromList(
        [0x08, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x03, 0x84],
      );

      expect(parseResponseFrame(ok).data, Uint8List.fromList([0x00]));
      expect(parseResponseFrame(err).data, Uint8List.fromList([0x03]));
    });

    test(
      'meldet Byte 5 mehr Nutzdaten als vorhanden, wird mit 0xFF aufgefuellt',
      () {
        final raw = Uint8List.fromList(
          [0x08, 0x81, 0x00, 0x00, 0x50, 0x04, 0x00, 0xdd],
        );

        final response = parseResponseFrame(raw);

        expect(response.data, Uint8List.fromList([0xff, 0xff, 0xff, 0xff]));
      },
    );

    test('wirft ProtocolException bei ungueltiger Pruefsumme', () {
      final corrupted = Uint8List.fromList(
        [0x0a, 0x81, 0x00, 0x01, 0x00, 0x02, 0xab, 0xcd, 0x00, 0xef],
      );

      expect(
        () => parseResponseFrame(corrupted),
        throwsA(isA<ProtocolException>()),
      );
    });
  });
}
