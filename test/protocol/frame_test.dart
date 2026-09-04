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

  group('buildWriteEepromCommand', () {
    // Aufbau wie das Lesekommando, aber mit Nutzdaten:
    // [len] 01c0 [addr:2] [datalen:1] [daten] 0x00 [xor].
    // Spezifikation: docs/protocol/hem-6232t.md §3.6.
    test('baut einen Schreibbefehl fuer 8 Leerbytes', () {
      final frame = buildWriteEepromCommand(
        address: 0x0dca,
        data: Uint8List.fromList(List.filled(8, 0xff)),
      );

      expect(
        frame,
        Uint8List.fromList([
          0x10, 0x01, 0xc0, 0x0d, 0xca, 0x08,
          0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
          0x00, 0x1e,
        ]),
      );
    });

    test('das Laengenbyte zaehlt Nutzdaten plus 8 Rahmenbytes', () {
      final frame = buildWriteEepromCommand(
        address: 0x02e8,
        data: Uint8List.fromList([0x01, 0x02, 0x03]),
      );

      expect(frame.first, 3 + 8);
      expect(frame.length, 3 + 8);
    });

    test('das gebaute Frame hat immer XOR-Pruefsumme 0', () {
      final frame = buildWriteEepromCommand(
        address: 0x0860,
        data: Uint8List.fromList([0xde, 0xad, 0xbe, 0xef]),
      );

      expect(xorChecksum(frame), 0);
    });

    test('nimmt 16 Nutzdatenbytes an - so schreibt die Hersteller-App', () {
      final frame = buildWriteEepromCommand(
        address: 0x02a4,
        data: Uint8List.fromList(List.filled(16, 0x5a)),
      );

      expect(frame.length, 24);
      expect(frame.first, 24);
      expect(xorChecksum(frame), 0);
      expect(splitIntoTxChannels(frame).length, 2);
    });

    test('wirft bei mehr als 16 Nutzdatenbytes', () {
      expect(
        () => buildWriteEepromCommand(
          address: 0,
          data: Uint8List.fromList(List.filled(17, 0)),
        ),
        throwsArgumentError,
      );
    });

    test('wirft bei leeren Nutzdaten', () {
      expect(
        () => buildWriteEepromCommand(address: 0, data: Uint8List(0)),
        throwsArgumentError,
      );
    });
  });

  group('splitIntoTxChannels', () {
    // Der Mitschnitt der Hersteller-App (2026-09-04) zeigt: ein
    // 24-Byte-Rahmen geht als 16 Bytes auf TX-Kanal 0 und 8 Bytes auf
    // TX-Kanal 1. omblepy teilt mit derselben Breite.
    test('laesst ein 8-Byte-Kommando auf einem Kanal', () {
      final parts = splitIntoTxChannels(startTransmissionFrame);

      expect(parts.length, 1);
      expect(parts.first, startTransmissionFrame);
    });

    test('ein 16-Byte-Rahmen passt noch in einen Kanal', () {
      final frame = Uint8List.fromList(List.filled(16, 0x11));

      expect(splitIntoTxChannels(frame).length, 1);
    });

    test('teilt einen 24-Byte-Rahmen in 16 plus 8', () {
      final frame = Uint8List.fromList(
        List.generate(24, (i) => i),
      );

      final parts = splitIntoTxChannels(frame);

      expect(parts.length, 2);
      expect(parts[0].length, 16);
      expect(parts[1].length, 8);
      expect(parts[0].first, 0);
      expect(parts[1].first, 16);
    });

    test('wirft, wenn mehr Kanaele noetig waeren als das Geraet hat', () {
      final frame = Uint8List(16 * 4 + 1);

      expect(() => splitIntoTxChannels(frame), throwsArgumentError);
    });
  });

  group('gegen den Mitschnitt der Hersteller-App', () {
    // Aufgezeichnet am 2026-09-04 mit dem Bluetooth-HCI-Mitschnitt von
    // Android. Die OMRON-connect-App schrieb 16 Bytes nach 0x02A4:
    //   TX-Kanal 0: 18 01 c0 02 a4 10 80 05 80 00 80 00 80 00 02 1d
    //   TX-Kanal 1: 00 00 00 0e 00 00 00 7b
    // Das Geraet bestaetigte mit 81c0 und derselben Adresse.
    //
    // Dieser Test ist der Beleg, dass unser Frame-Bau dem der
    // Hersteller-App Byte fuer Byte entspricht - einschliesslich
    // Laengenbyte, Adresse, Nutzdatenlaenge, Fuellbyte und Pruefsumme.
    final capturedFrame = Uint8List.fromList([
      0x18, 0x01, 0xc0, 0x02, 0xa4, 0x10, //
      0x80, 0x05, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, //
      0x02, 0x1d, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, //
      0x00, 0x7b,
    ]);

    test('buildWriteEepromCommand erzeugt exakt den mitgeschnittenen Rahmen',
        () {
      final frame = buildWriteEepromCommand(
        address: 0x02a4,
        data: Uint8List.fromList([
          0x80, 0x05, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00,
          0x02, 0x1d, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00,
        ]),
      );

      expect(frame, capturedFrame);
    });

    test('die Aufteilung trifft die beiden mitgeschnittenen TX-Kanaele', () {
      final parts = splitIntoTxChannels(capturedFrame);

      expect(parts.length, 2);
      expect(parts[0], capturedFrame.sublist(0, 16));
      expect(parts[1], capturedFrame.sublist(16));
    });

    test('der mitgeschnittene Rahmen hat XOR-Pruefsumme 0', () {
      expect(xorChecksum(capturedFrame), 0);
    });
  });

  group('Adressgrenzen', () {
    test('Lesekommando wirft bei einer Adresse ueber 0xffff', () {
      expect(
        () => buildReadEepromCommand(address: 0x10000, length: 8),
        throwsArgumentError,
      );
    });

    test('Schreibkommando wirft bei negativer Adresse', () {
      expect(
        () => buildWriteEepromCommand(
          address: -1,
          data: Uint8List.fromList([0x00]),
        ),
        throwsArgumentError,
      );
    });

    test('die hoechste gueltige Adresse wird angenommen', () {
      expect(
        () => buildReadEepromCommand(address: 0xffff, length: 1),
        returnsNormally,
      );
    });

    test('wirft, wenn der Bereich hinten aus dem Adressraum laeuft', () {
      // 0xffff plus zwei Bytes waere 0x10000 - passt nicht mehr in die
      // 16-Bit-Adresse des Kommandos.
      expect(
        () => buildReadEepromCommand(address: 0xffff, length: 2),
        throwsArgumentError,
      );
    });
  });

  group('splitIntoTxChannels Grenzfaelle', () {
    test('wirft bei leerem Rahmen', () {
      expect(() => splitIntoTxChannels(Uint8List(0)), throwsArgumentError);
    });

    test('genau 64 Bytes fuellen alle vier Kanaele', () {
      final parts = splitIntoTxChannels(Uint8List(64));

      expect(parts.length, 4);
      expect(parts.every((p) => p.length == 16), isTrue);
    });

    test('kein Byte geht bei der Aufteilung verloren', () {
      final frame = Uint8List.fromList(List.generate(40, (i) => i & 0xff));

      final joined = <int>[
        for (final part in splitIntoTxChannels(frame)) ...part,
      ];

      expect(joined, frame);
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
      'wirft, wenn Byte 5 mehr Nutzdaten meldet als das Frame traegt',
      () {
        // Frueher wurde hier mit 0xFF aufgefuellt. Ein unvollstaendiges
        // Frame (fehlender RX-Kanal) waere damit von einem echten
        // Leerbereich nicht zu unterscheiden gewesen, und eine Messung
        // waere stillschweigend verschwunden.
        final raw = Uint8List.fromList(
          [0x08, 0x81, 0x00, 0x00, 0x50, 0x04, 0x00, 0xdd],
        );

        expect(
          () => parseResponseFrame(raw),
          throwsA(isA<ProtocolException>()),
        );
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
