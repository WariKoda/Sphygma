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

  // Bit 32 (b4.bit7) = Bewegung, Bit 33 (b4.bit6) = Arrhythmie. An echter
  // Hardware verifiziert (M1, 2026-09-03): das Geraet zeigt beim
  // Speicherabruf die Symbole selbst an - siehe docs/protocol/hem-6232t.md
  // §6.2. omblepy hat die beiden fuer dieses Modell vertauscht, UBPM stimmt.
  group('parseRecord - Vektor B (Bit 32 gesetzt)', () {
    test('Bit 32 ist Bewegung, nicht Arrhythmie', () {
      final bytes = _record([0x55, 0x6b, 0x18, 0x44, 0x8d, 0xe7, 0x0a, 0xa1]);

      final record = parseRecord(bytes)!;

      expect(record.movementFlag, isTrue);
      expect(record.arrhythmiaFlag, isFalse);
      expect(record.systolic, 132);
      expect(record.timestamp, DateTime(2024, 3, 15, 7, 42, 33));
    });
  });

  group('parseRecord - Vektor C (Bit 33 gesetzt)', () {
    test('Bit 33 ist Arrhythmie, nicht Bewegung', () {
      final bytes = _record([0x55, 0x6b, 0x18, 0x44, 0x4d, 0xe7, 0x0a, 0xa1]);

      final record = parseRecord(bytes)!;

      expect(record.arrhythmiaFlag, isTrue);
      expect(record.movementFlag, isFalse);
      expect(record.systolic, 132);
      expect(record.timestamp, DateTime(2024, 3, 15, 7, 42, 33));
    });
  });

  group('parseRecord - Records vom HEM-6232T (M1, geraetebestaetigt)', () {
    // Aus echten 14-Byte-Records abgeleitet: Datum, Zeit, Flag-Bits und
    // Bytes 8-13 sind unveraendert, nur sys/dia/puls (Bytes 0, 1, 3) wurden
    // auf fiktive Werte gesetzt - die Originale sind personenbezogene
    // Gesundheitsdaten. Die Flag-Zuordnung ist durch Fotos des
    // Geraetedisplays im Speicherabruf belegt (docs/protocol/hem-6232t.md
    // §6.2, §7.3).
    Uint8List derived(String hex) => Uint8List.fromList([
          for (var i = 0; i < hex.length; i += 2)
            int.parse(hex.substring(i, i + 2), radix: 16),
        ]);

    test('Bewegungssymbol am Geraet -> movementFlag', () {
      final record = parseRecord(derived('4c5d574892531efa1200020e8679'))!;

      expect(record.systolic, 118);
      expect(record.diastolic, 76);
      expect(record.pulse, 72);
      expect(record.timestamp, DateTime(2023, 4, 18, 19, 59, 58));
      expect(record.movementFlag, isTrue);
      expect(record.arrhythmiaFlag, isFalse);
    });

    test('Arrhythmie-Symbol am Geraet -> arrhythmiaFlag', () {
      final record = parseRecord(derived('5b74574251131d892000020d639c'))!;

      expect(record.systolic, 141);
      expect(record.diastolic, 91);
      expect(record.pulse, 66);
      expect(record.timestamp, DateTime(2023, 4, 8, 19, 54, 9));
      expect(record.arrhythmiaFlag, isTrue);
      expect(record.movementFlag, isFalse);
    });

    test('prospektiv: angekuendigte Bewegungsmessung -> movementFlag', () {
      // Messung wurde VOR dem Auslesen als Bewegungsmessung angekuendigt;
      // der Record traegt Bit 32 - Vorhersage bestaetigt.
      final record = parseRecord(derived('59705761926214e902000212708f'))!;

      expect(record.systolic, 137);
      expect(record.diastolic, 89);
      expect(record.pulse, 97);
      expect(record.timestamp, DateTime(2023, 4, 19, 2, 19, 41));
      expect(record.movementFlag, isTrue);
      expect(record.arrhythmiaFlag, isFalse);
    });

    test('kein Symbol am Geraet -> keine Flags', () {
      final record = parseRecord(derived('5263573a11121d340000020c02fd'))!;

      expect(record.systolic, 124);
      expect(record.diastolic, 82);
      expect(record.pulse, 58);
      expect(record.timestamp, DateTime(2023, 4, 8, 18, 52, 52));
      expect(record.arrhythmiaFlag, isFalse);
      expect(record.movementFlag, isFalse);
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
