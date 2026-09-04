// Deutung der Omron-Herstellerdaten aus dem Advertising.
//
// Testvektoren sind echte Aufzeichnungen vom 2026-09-04 (Bluetooth-HCI-
// Mitschnitt, docs/protocol/hem-6232t.md §2.1). Der Uebergang von 539 auf
// 541 entstand durch zwei Messungen am Geraet; beide Zaehler stiegen um
// genau 2, was die Deutung belegt.
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ble/omron_advertising.dart';

/// Firmenkennung Omron Healthcare, wie sie flutter_blue_plus als
/// Schluessel in [AdvertisementData.manufacturerData] liefert.
const int _omron = 0x020e;

/// Aufgezeichnet vor zwei Messungen: hoechste Nummer 539, Platzzeiger 3.
const List<int> _before = [0x01, 0x01, 0x1b, 0x02, 0x03, 0x0e, 0x00, 0x00];

/// Dieselbe Stelle nach zwei Messungen: Nummer 541, Platzzeiger 5.
const List<int> _after = [0x01, 0x01, 0x1d, 0x02, 0x05, 0x0e, 0x00, 0x00];

void main() {
  group('parseOmronStatus', () {
    test('liest Nummer und Platzzeiger beider Slots', () {
      final status = parseOmronStatus({_omron: _before});

      expect(status, isNotNull);
      expect(status!.highestSequence(1), 539);
      expect(status.writePointer(1), 3);
      expect(status.highestSequence(2), 14);
      expect(status.writePointer(2), 0);
    });

    test('bildet zwei Messungen als Anstieg um 2 ab', () {
      final before = parseOmronStatus({_omron: _before})!;
      final after = parseOmronStatus({_omron: _after})!;

      expect(after.highestSequence(1) - before.highestSequence(1), 2);
      expect(after.writePointer(1) - before.writePointer(1), 2);
      // Slot 2 blieb unberuehrt.
      expect(after.highestSequence(2), before.highestSequence(2));
    });

    test('null, wenn kein Omron-Eintrag vorhanden ist', () {
      expect(parseOmronStatus(const {}), isNull);
      expect(parseOmronStatus(const {0x004c: [1, 2, 3]}), isNull);
    });

    test('null bei zu kurzem Eintrag - lieber nichts als geraten', () {
      expect(parseOmronStatus({_omron: const [0x01, 0x01, 0x1b]}), isNull);
    });

    test('deutet auch Slot 2 mit gesetztem Oberbyte richtig', () {
      // Beide echten Aufzeichnungen haben fuer Slot 2 ein Null-Oberbyte;
      // eine vertauschte Bytefolge fiele dort nicht auf. Hier stehen
      // Slot 1 auf 0x0102 = 258 und Slot 2 auf 0x0304 = 772.
      final status = parseOmronStatus({
        _omron: const [0x01, 0x01, 0x02, 0x01, 0x07, 0x04, 0x03, 0x09],
      })!;

      expect(status.highestSequence(1), 258);
      expect(status.writePointer(1), 7);
      expect(status.highestSequence(2), 772);
      expect(status.writePointer(2), 9);
    });

    test('genau 8 Bytes reichen, 7 reichen nicht', () {
      expect(
        parseOmronStatus({_omron: const [1, 1, 1, 0, 0, 1, 0, 0]}),
        isNotNull,
      );
      expect(
        parseOmronStatus({_omron: const [1, 1, 1, 0, 0, 1, 0]}),
        isNull,
      );
    });

    test('ein laengerer Eintrag wird akzeptiert, Rest ignoriert', () {
      final status = parseOmronStatus({
        _omron: [..._before, 0xaa, 0xbb],
      });

      expect(status?.highestSequence(1), 539);
    });

    test('wirft bei einem Slot ausserhalb von 1 und 2', () {
      final status = parseOmronStatus({_omron: _before})!;

      expect(() => status.highestSequence(0), throwsArgumentError);
      expect(() => status.highestSequence(3), throwsArgumentError);
      expect(() => status.writePointer(0), throwsArgumentError);
    });
  });

  group('hasNewMeasurements', () {
    test('erkennt neue Messungen gegenueber dem eigenen Stand', () {
      final status = parseOmronStatus({_omron: _after})!;

      expect(status.hasNewMeasurements(userSlot: 1, knownSequence: 539), isTrue);
      expect(status.hasNewMeasurements(userSlot: 1, knownSequence: 541), isFalse);
    });

    test('ein hoeherer eigener Stand meldet nichts Neues', () {
      // Kann nach einem Geraetetausch oder Werksreset vorkommen. Hier ist
      // Zurueckhaltung richtig: nicht ungefragt synchronisieren.
      final status = parseOmronStatus({_omron: _after})!;

      expect(status.hasNewMeasurements(userSlot: 1, knownSequence: 600), isFalse);
    });

    test('ohne eigenen Stand gilt jede vorhandene Messung als neu', () {
      final status = parseOmronStatus({_omron: _after})!;

      expect(status.hasNewMeasurements(userSlot: 1, knownSequence: null), isTrue);
    });

    test('ein leerer Slot meldet auch ohne eigenen Stand nichts Neues', () {
      // Slot 2 haette Nummer 14; ein echter Leerstand waere 0.
      final empty = parseOmronStatus({
        _omron: const [0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
      })!;

      expect(empty.hasNewMeasurements(userSlot: 2, knownSequence: null), isFalse);
    });
  });
}
