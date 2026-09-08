// Alle Flächen einer Gestaltung werden gleich behandelt.
//
// Die Flächen tragen die Gestaltung: Radius, Polster, Kante und Ton kommen
// aus dem Theme, nicht aus dem einzelnen Bildschirm. Baut ein Bildschirm
// seine eigene Karte, sieht sie in einer Handschrift zufällig richtig aus und
// in den anderen falsch — und eine Änderung an der Gestaltung zieht an
// dreißig Stellen nach, von denen man eine vergisst.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/surface_panel.dart';

void main() {
  group('Die Fläche nimmt ihre Maße aus der Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('${v.name}: Radius und Polster stammen aus dem Theme',
          (tester) async {
        final t = themeFor(v);
        await tester.pumpWidget(MaterialApp(
          home: SphygmaThemeScope(
            theme: t,
            child: const Scaffold(
              body: Column(
                children: [
                  SurfacePanel(child: Text('Erste')),
                  SurfacePanel(tone: 1, child: Text('Zweite')),
                ],
              ),
            ),
          ),
        ));

        final container = tester
            .widgetList<Container>(find.descendant(
              of: find.byType(SurfacePanel),
              matching: find.byType(Container),
            ))
            .toList();
        expect(container, hasLength(2));

        for (final c in container) {
          final d = c.decoration! as BoxDecoration;
          expect(
            d.borderRadius,
            BorderRadius.circular(t.radius),
            reason: '${v.name}: Radius weicht vom Theme ab',
          );
          expect(
            c.padding,
            EdgeInsets.all(t.panelPadding),
            reason: '${v.name}: Polster weicht vom Theme ab',
          );
        }
      });

      test('${v.name}: die beiden Tonstufen sind unterscheidbar', () {
        // Zwei Flächen übereinander sollen sich absetzen können. Sind beide
        // Stufen gleich, verschwimmt die Gliederung in dieser Handschrift.
        final t = themeFor(v);
        expect(
          t.panelBase == t.panelRaised,
          isFalse,
          reason: '${v.name}: beide Stufen sind ${t.panelBase}',
        );
      });
    }
  });

  group('Hervorhebung', () {
    testWidgets('eine offene Frage bekommt eine Kante', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.diary),
          child: const Scaffold(
            body: SurfacePanel(highlighted: true, child: Text('Offen')),
          ),
        ),
      ));

      final d = tester
          .widget<Container>(find
              .descendant(
                of: find.byType(SurfacePanel),
                matching: find.byType(Container),
              )
              .first)
          .decoration! as BoxDecoration;
      expect(d.border, isNotNull,
          reason: 'eine ausstehende Entscheidung muss auffallen');
    });

    testWidgets('gewöhnlicher Inhalt folgt der Handschrift', (tester) async {
      // „Tagebuch" zeichnet keine Kante; ohne Hervorhebung bleibt das so.
      await tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.diary),
          child: const Scaffold(body: SurfacePanel(child: Text('Normal'))),
        ),
      ));

      final d = tester
          .widget<Container>(find
              .descendant(
                of: find.byType(SurfacePanel),
                matching: find.byType(Container),
              )
              .first)
          .decoration! as BoxDecoration;
      expect(d.border, isNull);
    });
  });
}
