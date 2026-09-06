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

  group('Bänder dürfen nicht verschmelzen', () {
    testWidgets('benachbarte Flächen tragen verschiedene Tonstufen',
        (tester) async {
      // Bänder laufen ohne Abstand ineinander. Tragen zwei benachbarte
      // denselben Ton, verschmelzen sie zu einer Fläche und das
      // Abschnittsende verschwindet — die Aussage, für die „Pegel"
      // gezeichnet wurde.
      await tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.pegel, surface: SurfaceStyle.band),
          child: const Scaffold(
            body: Column(
              children: [
                SurfacePanel(child: Text('Erster Abschnitt')),
                SurfacePanel(tone: 1, child: Text('Zweiter Abschnitt')),
                SurfacePanel(child: Text('Dritter Abschnitt')),
              ],
            ),
          ),
        ),
      ));

      final toene =
          tester.widgetList<SurfacePanel>(find.byType(SurfacePanel))
              .map((p) => p.tone)
              .toList();
      for (var i = 1; i < toene.length; i++) {
        expect(toene[i] == toene[i - 1], isFalse,
            reason: 'Fläche $i trägt denselben Ton wie ihre Vorgängerin');
      }
    });

    testWidgets('das Tagesprofil wechselt den Ton zwischen seinen Abschnitten',
        (tester) async {
      // Derselbe Anspruch am echten Bildschirm: Wer beim Umstellen zweimal
      // dieselbe Stufe setzt, bekommt hier einen roten Test.
      await tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.pegel, surface: SurfaceStyle.band),
          child: const Scaffold(
            body: Column(
              children: [
                SurfacePanel(child: Text('Kopf')),
                SurfacePanel(tone: 1, child: Text('Abschnitte')),
                SurfacePanel(child: Text('Aussage')),
              ],
            ),
          ),
        ),
      ));

      final toene =
          tester.widgetList<SurfacePanel>(find.byType(SurfacePanel))
              .map((p) => p.tone)
              .toList();
      expect(toene, [0, 1, 0]);
    });
  });

  group('Jede Form gliedert auf ihre Weise', () {
    testWidgets('Linie trennt durch Abstand, weil ihr Fläche und Strich fehlen',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.instrument, surface: SurfaceStyle.linie),
          child: const Scaffold(body: SurfacePanel(child: Text('Inhalt'))),
        ),
      ));

      final container = tester.widget<Container>(find
          .descendant(
              of: find.byType(SurfacePanel), matching: find.byType(Container))
          .first);
      // Ohne Abstand stießen zwei Abschnitte übergangslos aneinander — in
      // dieser Form trennt sie nichts anderes.
      expect(container.margin, isNotNull, reason: 'Luft ist die Gliederung');
      expect(container.decoration, isNull, reason: 'aber keine Fläche');
      expect(container.color, isNull);
    });

    testWidgets('Karte trennt durch Abstand zwischen den Flächen',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.diary, surface: SurfaceStyle.karte),
          child: const Scaffold(body: SurfacePanel(child: Text('Inhalt'))),
        ),
      ));

      final container = tester.widget<Container>(find
          .descendant(
              of: find.byType(SurfacePanel), matching: find.byType(Container))
          .first);
      expect(container.margin, isNotNull);
    });

    testWidgets('Band trennt durch den Tonwechsel, nicht durch Abstand',
        (tester) async {
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
      // „Ganzflächige Bänder ohne Rand, Schatten, Radius oder Abstand."
      expect(container.margin, isNull);
    });
  });

  group('Was auffallen soll, fällt in jeder Form auf', () {
    testWidgets('eine hervorgehobene Fläche trägt auch bei „Linie" eine Kante',
        (tester) async {
      // Der Prüfbereich zeigt offene Grenzfälle als Kacheln. Ohne Kante
      // stünden sie im Modus „Linie" als bloßer Text zwischen anderem Text —
      // die Aussage „hier ist etwas offen" ginge verloren.
      await tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.instrument, surface: SurfaceStyle.linie),
          child: const Scaffold(
            body: SurfacePanel(highlighted: true, child: Text('Offen')),
          ),
        ),
      ));

      final container = tester.widget<Container>(find
          .descendant(
              of: find.byType(SurfacePanel), matching: find.byType(Container))
          .first);
      final deko = container.decoration as BoxDecoration?;
      expect(deko?.border, isNotNull, reason: 'eine offene Frage braucht Kante');
    });

    testWidgets('ohne Hervorhebung bleibt „Linie" flächenlos', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.instrument, surface: SurfaceStyle.linie),
          child: const Scaffold(body: SurfacePanel(child: Text('Normal'))),
        ),
      ));

      final container = tester.widget<Container>(find
          .descendant(
              of: find.byType(SurfacePanel), matching: find.byType(Container))
          .first);
      expect(container.decoration, isNull);
    });
  });
}
