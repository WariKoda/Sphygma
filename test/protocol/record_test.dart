// Testvektoren aus docs/protocol/hem-6232t.md §7.2, gegen beide
// Referenzimplementierungen (omblepy, UBPM) verifiziert.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/protocol/exceptions.dart';
import 'package:sphygma/protocol/record.dart';

/// Haengt 6 Fuellbytes an, da ein echter Record 14 Bytes lang ist und nur
/// die ersten 8 ausgewertet werden (docs/protocol/hem-6232t.md §6.1).
Uint8List _record(List<int> first8) =>
    Uint8List.fromList([...first8, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa]);

void main() {
  group('parseRecord - Vektor A (Referenzfall)', () {
    final bytes = _record([0x55, 0x6b, 0x18, 0x44, 0x0d, 0xe7, 0x0a, 0xa1]);

    test('liest Messwerte und Zeitstempel korrekt', () {
      final record = parseRecord(bytes);

      expect(record, isNotNull);
      expect(record!.systolic, 132);
      expect(record.diastolic, 85);
      expect(record.pulse, 68);
      expect(record.timestamp, DateTime(2024, 3, 15, 7, 42, 33));
      expect(record.arrhythmiaFlag, isFalse);
      expect(record.movementFlag, isFalse);
    });
  });

  group('parseRecord - Vektor B (Flag ihb gesetzt, omblepy-Zuordnung)', () {
    test('ihb=1, mov=0; Messwerte/Zeit unveraendert', () {
      final bytes = _record([0x55, 0x6b, 0x18, 0x44, 0x8d, 0xe7, 0x0a, 0xa1]);

      final record = parseRecord(bytes)!;

      expect(record.arrhythmiaFlag, isTrue);
      expect(record.movementFlag, isFalse);
      expect(record.systolic, 132);
      expect(record.timestamp, DateTime(2024, 3, 15, 7, 42, 33));
    });
  });

  group('parseRecord - Vektor C (Flag mov gesetzt, omblepy-Zuordnung)', () {
    test('ihb=0, mov=1; Messwerte/Zeit unveraendert', () {
      final bytes = _record([0x55, 0x6b, 0x18, 0x44, 0x4d, 0xe7, 0x0a, 0xa1]);

      final record = parseRecord(bytes)!;

      expect(record.arrhythmiaFlag, isFalse);
      expect(record.movementFlag, isTrue);
      expect(record.systolic, 132);
      expect(record.timestamp, DateTime(2024, 3, 15, 7, 42, 33));
    });
  });

  test('leerer Record (14x 0xFF) ergibt null, kein Fehler', () {
    final bytes = Uint8List.fromList(List.filled(14, 0xff));

    expect(parseRecord(bytes), isNull);
  });

  test('Sekunden werden auf 59 geklemmt, wenn das Geraet bis 63 liefert', () {
    final bytes = _record([0x0a, 0x4b, 0x18, 0x46, 0x04, 0x20, 0x00, 0x3f]);

    final record = parseRecord(bytes)!;

    expect(record.timestamp, DateTime(2024, 1, 1, 0, 0, 59));
    expect(record.diastolic, 10);
    expect(record.systolic, 100);
    expect(record.pulse, 70);
  });

  test('wirft ProtocolException bei falscher Record-Laenge', () {
    final tooShort = Uint8List.fromList(List.filled(13, 0));

    expect(() => parseRecord(tooShort), throwsA(isA<ProtocolException>()));
  });
}
