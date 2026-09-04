import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/esc_classification.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';

const _t = SphygmaTheme(
  name: 'Prüfmuster',
  surface: Color(0xFFFAF9F7),
  onSurface: Color(0xFF1B1B1A),
  muted: Color(0x991B1B1A),
  line: Color(0xFFE4E1DB),
  accent: Color(0xFF1B1B1A),
  categoryColors: {
    EscCategory.optimal: Color(0xFF7EA77E),
    EscCategory.normal: Color(0xFF7EA77E),
    EscCategory.highNormal: Color(0xFFC9B45E),
    EscCategory.grade1: Color(0xFFC07D5A),
    EscCategory.grade2: Color(0xFFC07D5A),
    EscCategory.grade3: Color(0xFFA84C3A),
  },
  radius: 8,
  gapSmall: 8,
  gapLarge: 20,
  headlineSize: 56,
  useRoundedCards: false,
);

void main() {
  testWidgets('of() liefert die eingesetzte Gestaltung', (tester) async {
    late SphygmaTheme seen;
    await tester.pumpWidget(SphygmaThemeScope(
      theme: _t,
      child: Builder(builder: (context) {
        seen = SphygmaTheme.of(context);
        return const SizedBox();
      }),
    ));

    expect(seen.name, 'Prüfmuster');
    expect(seen.headlineSize, 56);
  });

  test('jede Kategorie hat eine Farbe - keine Luecke', () {
    for (final c in EscCategory.values) {
      expect(_t.categoryColors[c], isNotNull, reason: 'fehlt: $c');
    }
  });

  testWidgets('of() wirft ohne Scope statt still einen Default zu liefern',
      (tester) async {
    await tester.pumpWidget(Builder(builder: (context) {
      expect(() => SphygmaTheme.of(context), throwsFlutterError);
      return const SizedBox();
    }));
  });
}
