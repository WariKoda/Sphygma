// Die dritte Achse: Karte, Band oder gar keine Fläche.
//
// Konzept ordnet, Gestaltung färbt — und keins von beidem sagte, ob Inhalt
// in Karten, auf Bändern oder frei zwischen Haarlinien steht. Dabei war das
// in den Entwürfen ausgearbeitet und der auffälligste Unterschied zwischen
// ihnen. Diese Tests halten fest, dass die Form wirklich durchschlägt.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/surface_style.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/surface_panel.dart';

Future<BoxDecoration?> _dekorationVon(
  WidgetTester tester,
  ThemeVariant variant,
  SurfaceStyle form,
) async {
  await tester.pumpWidget(MaterialApp(
    home: SphygmaThemeScope(
      theme: themeFor(variant, surface: form),
      child: const Scaffold(
        body: SurfacePanel(child: Text('Inhalt')),
      ),
    ),
  ));
  final container = find.descendant(
    of: find.byType(SurfacePanel),
    matching: find.byType(Container),
  );
  if (container.evaluate().isEmpty) return null;
  return tester.widget<Container>(container.first).decoration as BoxDecoration?;
}

void main() {
  group('Die Form schlägt bis in die Fläche durch', () {
    testWidgets('Linie zeichnet keine Fläche', (tester) async {
      final d = await _dekorationVon(
          tester, ThemeVariant.instrument, SurfaceStyle.linie);

      // Kein Container, keine Farbe, kein Radius — der Inhalt steht auf dem
      // Grund, gegliedert wird anderswo.
      expect(d, isNull);
      expect(find.text('Inhalt'), findsOneWidget);
    });

    testWidgets('Karte hebt sich mit runden Ecken ab', (tester) async {
      final d =
          await _dekorationVon(tester, ThemeVariant.diary, SurfaceStyle.karte);

      expect(d, isNotNull);
      expect(d!.borderRadius, isNotNull);
      expect(d.color, isNotNull);
      expect(find.text('Inhalt'), findsOneWidget);
    });

    testWidgets('Band füllt die Breite ohne Radius', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.pegel, surface: SurfaceStyle.band),
          child: const Scaffold(body: SurfacePanel(child: Text('Inhalt'))),
        ),
      ));

      final container = tester.widget<Container>(find
          .descendant(
              of: find.byType(SurfacePanel), matching: find.byType(Container))
          .first);
      // Ein Band trägt seine Farbe direkt, ohne Radius und ohne Rand: Der
      // Tonwechsel ist die Zäsur.
      expect(container.color, isNotNull, reason: 'das Band trägt eine Fläche');
      expect(container.decoration, isNull, reason: 'kein Radius, kein Rand');
      expect(find.text('Inhalt'), findsOneWidget);
    });
  });

  group('Die Achse ist frei kombinierbar', () {
    test('jede Gestaltung lässt sich in jeder Form zeigen', () {
      // 6 × 3 = 18 Kombinationen, auch die nicht entworfenen. Keine darf
      // beim Bauen scheitern.
      for (final v in allVariants) {
        for (final f in allSurfaceStyles) {
          final t = themeFor(v, surface: f);
          expect(t.surfaceStyle, f, reason: '${v.name} + ${f.name}');
        }
      }
    });

    test('ohne Wahl gilt die Vorgabe des Entwurfs', () {
      // Die Vorgaben stammen aus docs/design/handschriften.html.
      expect(themeFor(ThemeVariant.instrument).surfaceStyle, SurfaceStyle.linie);
      expect(themeFor(ThemeVariant.diary).surfaceStyle, SurfaceStyle.karte);
      expect(themeFor(ThemeVariant.material).surfaceStyle, SurfaceStyle.karte);
      expect(themeFor(ThemeVariant.aura).surfaceStyle, SurfaceStyle.karte);
      expect(themeFor(ThemeVariant.pulseGrid).surfaceStyle, SurfaceStyle.linie);
      expect(themeFor(ThemeVariant.pegel).surfaceStyle, SurfaceStyle.band);
    });

    test('eine Wahl überstimmt die Vorgabe', () {
      expect(
        themeFor(ThemeVariant.pegel, surface: SurfaceStyle.karte).surfaceStyle,
        SurfaceStyle.karte,
      );
    });
  });
}
