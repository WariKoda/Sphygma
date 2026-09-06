import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/target_range.dart';

void main() {
  group('Heimmessung mit 135/85', () {
    final z = TargetRange.heim;

    test('deutlich darunter liegt im Zielbereich', () {
      expect(z.classify(systolic: 118, diastolic: 76), TargetZone.imZielbereich);
      expect(z.classify(systolic: 129, diastolic: 79), TargetZone.imZielbereich);
    });

    test('knapp unter der Schwelle ist grenzwertig', () {
      expect(z.classify(systolic: 130, diastolic: 78), TargetZone.grenzwertig);
      expect(z.classify(systolic: 134, diastolic: 84), TargetZone.grenzwertig);
    });

    test('ab der Schwelle liegt es darüber', () {
      expect(z.classify(systolic: 135, diastolic: 80), TargetZone.darueber);
      expect(z.classify(systolic: 120, diastolic: 85), TargetZone.darueber);
    });

    test('der schlechtere der beiden Werte entscheidet', () {
      // Systolisch tadellos, diastolisch über der Schwelle: Das Ergebnis
      // richtet sich nach dem schlechteren Wert, nicht nach dem Mittel.
      expect(z.classify(systolic: 110, diastolic: 92), TargetZone.darueber);
      expect(z.classify(systolic: 133, diastolic: 70), TargetZone.grenzwertig);
    });
  });

  group('Praxisschwellen sind andere', () {
    test('140/90 statt 135/85', () {
      final p = TargetRange.praxis;
      expect(p.systolicLimit, 140);
      expect(p.diastolicLimit, 90);

      // Ein Wert, der zu Hause schon darüber liegt, ist in der Praxis noch
      // grenzwertig — deshalb dürfen die Schwellen nie verwechselt werden.
      expect(p.classify(systolic: 136, diastolic: 86), TargetZone.grenzwertig);
      expect(
        TargetRange.heim.classify(systolic: 136, diastolic: 86),
        TargetZone.darueber,
      );
    });
  });

  group('Eigene Schwellen', () {
    test('lassen sich setzen', () {
      final eigen = TargetRange(systolicLimit: 125, diastolicLimit: 75);
      expect(eigen.classify(systolic: 126, diastolic: 70), TargetZone.darueber);
    });

    test('unsinnige Schwellen werfen', () {
      expect(
        () => TargetRange(systolicLimit: 60, diastolicLimit: 85),
        throwsArgumentError,
      );
      expect(
        () => TargetRange(systolicLimit: 135, diastolicLimit: 140),
        throwsArgumentError,
        reason: 'diastolisch über systolisch ergibt keinen Sinn',
      );
    });
  });

  group('Unsinnige Messwerte werfen', () {
    final z = TargetRange.heim;

    test('nicht positiv ist kein Blutdruck', () {
      expect(() => z.classify(systolic: 0, diastolic: 80), throwsArgumentError);
      expect(() => z.classify(systolic: 120, diastolic: -5), throwsArgumentError);
    });

    test('diastolisch über systolisch ist ein Messfehler', () {
      expect(
        () => z.classify(systolic: 80, diastolic: 120),
        throwsArgumentError,
      );
    });
  });
}
