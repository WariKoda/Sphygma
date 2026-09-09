// Trägt jede Form ihren eigenen Aufbau des großen Werts?
//
// Bis zum 09.09.2026 zeigten alle sechs Formen denselben Bruch und trennten
// sich nur in Radius, Abstand und Gewicht — genau deshalb sahen vier von
// ihnen gleich aus. Dieser Test hält das erste echte Aufbau-Merkmal fest.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/reading_headline.dart';

Future<void> _zeige(WidgetTester tester, Characteristic form) {
  return tester.pumpWidget(
    MaterialApp(
      home: SphygmaThemeScope(
        theme: themeFrom(
          characteristic: form,
          palette: Palette.papier,
          typeface: Typeface.system,
        ),
        child: Scaffold(
          body: ReadingHeadline(
            systolic: 144,
            diastolic: 92,
            pulse: 89,
            measuredAt: DateTime(2026, 7, 12, 7, 13),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Raster zeigt zwei gleichwertige Blöcke', (tester) async {
    await _zeige(tester, Characteristic.raster);

    // Zwei Zahlen, zwei Beschriftungen — kein Bruch.
    expect(find.text('144'), findsOneWidget);
    expect(find.text('92'), findsOneWidget);
    expect(find.text('SYS'), findsOneWidget);
    expect(find.text('DIA'), findsOneWidget);
    expect(find.text('144/92'), findsNothing);
  });

  testWidgets('alle übrigen Formen zeigen den Bruch', (tester) async {
    for (final form in Characteristic.values) {
      if (form == Characteristic.raster) continue;
      await _zeige(tester, form);
      expect(find.text('144/92'), findsOneWidget, reason: form.name);
      expect(find.text('SYS'), findsNothing, reason: form.name);
    }
  });

  testWidgets('der Aufbau kommt aus der Form, nicht aus der Farbwelt', (
    tester,
  ) async {
    // Die Achsen sind unabhängig: Raster bleibt Raster, egal welche Farbwelt
    // darunter liegt.
    for (final farbwelt in Palette.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: SphygmaThemeScope(
            theme: themeFrom(
              characteristic: Characteristic.raster,
              palette: farbwelt,
              typeface: Typeface.system,
            ),
            child: Scaffold(
              body: ReadingHeadline(
                systolic: 144,
                diastolic: 92,
                pulse: 89,
                measuredAt: DateTime(2026, 7, 12, 7, 13),
              ),
            ),
          ),
        ),
      );
      expect(find.text('SYS'), findsOneWidget, reason: farbwelt.name);
    }
  });

  testWidgets('die Blöcke laufen auch bei großer Systemschrift nicht über', (
    tester,
  ) async {
    // Wer die Schrift vergrößert, braucht sie am dringendsten. Zwei Zahlen
    // nebeneinander sind breiter als eine mit Schrägstrich — ohne Begrenzung
    // läuft die Zeile über den Rand. Gefunden im Codex-Gegenblick.
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: SphygmaThemeScope(
            theme: themeFrom(
              characteristic: Characteristic.raster,
              palette: Palette.papier,
              typeface: Typeface.system,
            ),
            child: Scaffold(
              body: ReadingHeadline(
                systolic: 144,
                diastolic: 92,
                pulse: 89,
                measuredAt: DateTime(2026, 7, 12, 7, 13),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
