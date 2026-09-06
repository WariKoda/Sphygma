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
  headlineWeight: FontWeight.w300,
  useRoundedCards: false,
  showDividers: true,
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

  group('Die Handschrift entscheidet über die Gliederung', () {
    test('mit Trennstrich zieht rowDivider eine Linie', () {
      const mitStrich = SphygmaTheme(
        name: 'mit',
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF000000),
        muted: Color(0xFF888888),
        line: Color(0xFFDDDDDD),
        accent: Color(0xFF000000),
        categoryColors: {
          EscCategory.optimal: Color(0xFF7EA77E),
          EscCategory.normal: Color(0xFF7EA77E),
          EscCategory.highNormal: Color(0xFFC9B45E),
          EscCategory.grade1: Color(0xFFC07D5A),
          EscCategory.grade2: Color(0xFFC07D5A),
          EscCategory.grade3: Color(0xFFA84C3A),
        },
        radius: 4,
        gapSmall: 8,
        gapLarge: 16,
        headlineSize: 48,
        headlineWeight: FontWeight.w300,
        useRoundedCards: false,
        showDividers: true,
      );

      expect(mitStrich.rowDivider.border, isNotNull);
      expect(mitStrich.rowGap, mitStrich.gapSmall);
      expect(mitStrich.rowSpacing(4), 4, reason: 'mit Strich bleibt der Wert');
    });

    test('ohne Trennstrich gliedert Luft statt Linie', () {
      // „Aura" und „Pegel" ziehen keine Striche. Ohne zusätzlichen Abstand
      // klebten ihre Zeilen aneinander — die Handschrift wäre dann nur eine
      // andere Farbe auf derselben Zeichnung.
      const ohneStrich = SphygmaTheme(
        name: 'ohne',
        surface: Color(0xFF14181F),
        onSurface: Color(0xFFE8ECF2),
        muted: Color(0xFF94A0B0),
        line: Color(0x12FFFFFF),
        accent: Color(0xFF6C5CE7),
        categoryColors: {
          EscCategory.optimal: Color(0xFF8FB89A),
          EscCategory.normal: Color(0xFF8FB89A),
          EscCategory.highNormal: Color(0xFFE2C08A),
          EscCategory.grade1: Color(0xFFD98C7A),
          EscCategory.grade2: Color(0xFFC9705E),
          EscCategory.grade3: Color(0xFFB85B4C),
        },
        radius: 18,
        gapSmall: 11,
        gapLarge: 20,
        headlineSize: 58,
        headlineWeight: FontWeight.w300,
        useRoundedCards: true,
        showDividers: false,
      );

      expect(ohneStrich.rowDivider.border, isNull);
      expect(ohneStrich.rowGap, greaterThan(ohneStrich.gapSmall));
      // rowSpacing rechnet auf dem Abstand, den die Zeile sonst hätte —
      // sonst blieben eng oder weit gesetzte Zeilen bei den strichlosen
      // Handschriften auf ihrem festen Wert stehen und klebten aneinander.
      expect(ohneStrich.rowSpacing(4), greaterThan(4));
      expect(ohneStrich.rowSpacing(20), greaterThan(20));
    });
  });
}
