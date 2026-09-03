// Schwellen: 2018 ESC/ESH Guidelines for the management of arterial
// hypertension, Eur Heart J 2018;39:3021-3104, Tabelle 3 (Praxisblutdruck)
// und Tabelle 9 (Heimblutdruck >= 135/85 = Hypertonie).
// Die Kategorie ergibt sich aus dem hoeheren der beiden Werte.
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/esc_classification.dart';

void main() {
  group('classifyOffice (ESC/ESH 2018, Praxis)', () {
    test('optimal: <120 und <80', () {
      expect(classifyOffice(systolic: 119, diastolic: 79), EscCategory.optimal);
    });

    test('normal: 120-129 und/oder 80-84', () {
      expect(classifyOffice(systolic: 120, diastolic: 70), EscCategory.normal);
      expect(classifyOffice(systolic: 110, diastolic: 84), EscCategory.normal);
    });

    test('hochnormal: 130-139 und/oder 85-89', () {
      expect(classifyOffice(systolic: 139, diastolic: 70), EscCategory.highNormal);
      expect(classifyOffice(systolic: 110, diastolic: 85), EscCategory.highNormal);
    });

    test('Grad 1: 140-159 und/oder 90-99', () {
      expect(classifyOffice(systolic: 140, diastolic: 70), EscCategory.grade1);
      expect(classifyOffice(systolic: 110, diastolic: 99), EscCategory.grade1);
    });

    test('Grad 2: 160-179 und/oder 100-109', () {
      expect(classifyOffice(systolic: 179, diastolic: 70), EscCategory.grade2);
      expect(classifyOffice(systolic: 110, diastolic: 100), EscCategory.grade2);
    });

    test('Grad 3: >=180 und/oder >=110', () {
      expect(classifyOffice(systolic: 180, diastolic: 70), EscCategory.grade3);
      expect(classifyOffice(systolic: 110, diastolic: 110), EscCategory.grade3);
    });

    test('der hoehere Wert entscheidet', () {
      expect(classifyOffice(systolic: 125, diastolic: 95), EscCategory.grade1);
    });
  });

  group('isHomeHypertension (ESC/ESH 2018, Heimmessung >= 135/85)', () {
    test('Schwelle inklusive, und/oder', () {
      expect(isHomeHypertension(systolic: 135, diastolic: 80), isTrue);
      expect(isHomeHypertension(systolic: 120, diastolic: 85), isTrue);
      expect(isHomeHypertension(systolic: 134, diastolic: 84), isFalse);
    });
  });
}
