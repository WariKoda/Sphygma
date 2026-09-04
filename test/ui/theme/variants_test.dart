import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/esc_classification.dart';
import 'package:sphygma/ui/theme/variants.dart';

void main() {
  test('jede Variante ist vollstaendig', () {
    for (final v in allVariants) {
      final t = themeFor(v);
      expect(t.name, isNotEmpty, reason: '$v ohne Namen');
      expect(t.headlineSize, greaterThan(0));
      for (final c in EscCategory.values) {
        expect(t.categoryColors[c], isNotNull, reason: '$v: Farbe fehlt fuer $c');
      }
    }
  });

  test('die Varianten sind unterscheidbar', () {
    final namen = allVariants.map((v) => themeFor(v).name).toSet();

    expect(namen, hasLength(allVariants.length));
  });

  test('steigende Schwere bekommt nicht dieselbe Farbe wie optimal', () {
    for (final v in allVariants) {
      final t = themeFor(v);

      expect(
        t.categoryColors[EscCategory.grade3],
        isNot(t.categoryColors[EscCategory.optimal]),
        reason: '$v: Grad 3 sieht aus wie optimal',
      );
    }
  });
}
