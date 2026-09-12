import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/stats/measurement_windows.dart';
import 'package:sphygma/ui/widgets/measurement_windows_editor.dart';

void main() {
  Future<void> open(
    WidgetTester tester,
    Future<void> Function(MeasurementWindows) save, {
    ThemeVariant variant = ThemeVariant.instrument,
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => SphygmaThemeScope(
          theme: themeFor(variant),
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MeasurementWindowsEditor(
                    initialValue: MeasurementWindows.defaults,
                    onSave: save,
                  ),
                ),
              ),
              child: const Text('Öffnen'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Öffnen'));
    await tester.pumpAndSettle();
  }

  Future<void> change(WidgetTester tester, String key, String hour) async {
    await tester.scrollUntilVisible(find.byKey(Key(key)), 150);
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, hour);
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();
  }

  for (final variant in allVariants) {
    testWidgets(
      'Fenster bei großer Schrift vollständig bedienbar (${variant.name})',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        MeasurementWindows? saved;
        await open(
          tester,
          (value) async {
            saved = value;
          },
          variant: variant,
          scale: 2,
        );
        for (final key in [
          'morning-start',
          'morning-end',
          'evening-start',
          'evening-end',
        ]) {
          await tester.scrollUntilVisible(find.byKey(Key(key)), 150);
          expect(tester.takeException(), isNull);
        }
        await tester.scrollUntilVisible(find.text('Speichern'), 150);
        await tester.tap(find.text('Speichern'));
        await tester.pumpAndSettle();
        expect(saved!.encode(), MeasurementWindows.defaults.encode());
        expect(find.text('Öffnen'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Entwurf abbrechen verändert nichts', (tester) async {
    var saves = 0;
    await open(tester, (_) async {
      saves++;
    });
    await change(tester, 'morning-start', '06');
    await tester.scrollUntilVisible(find.text('Abbrechen'), 200);
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.text('Öffnen'), findsOneWidget);
  });
  testWidgets('Speichern übernimmt beide Fenster zusammen', (tester) async {
    MeasurementWindows? saved;
    await open(tester, (value) async {
      saved = value;
    });
    await change(tester, 'morning-start', '06');
    await tester.scrollUntilVisible(find.text('Speichern'), 200);
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(saved!.morningStart, 360);
    expect(saved!.eveningEnd, 1380);
    expect(find.text('Öffnen'), findsOneWidget);
  });
  testWidgets('Überschneidung bleibt im Editor mit verständlichem Fehler', (
    tester,
  ) async {
    var saves = 0;
    await open(tester, (_) async {
      saves++;
    });
    await change(tester, 'morning-end', '19');
    await tester.scrollUntilVisible(find.text('Speichern'), 200);
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.textContaining('überschneiden'), findsOneWidget);
  });
  testWidgets('Speicherfehler bleibt sichtbar und erlaubt erneuten Versuch', (
    tester,
  ) async {
    await open(tester, (_) async {
      throw StateError('Datenträger voll');
    });
    await tester.scrollUntilVisible(find.text('Speichern'), 200);
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Datenträger voll'), findsOneWidget);
    expect(find.byType(MeasurementWindowsEditor), findsOneWidget);
  });
  testWidgets('Standardzeiten setzen nur den Entwurf zurück', (tester) async {
    MeasurementWindows? saved;
    await open(tester, (value) async {
      saved = value;
    });
    await change(tester, 'morning-start', '06');
    await tester.scrollUntilVisible(
      find.text('Standardzeiten wiederherstellen'),
      200,
    );
    await tester.tap(find.text('Standardzeiten wiederherstellen'));
    await tester.pumpAndSettle();
    expect(saved, isNull);
    await tester.scrollUntilVisible(find.text('Speichern'), 200);
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(saved!.encode(), MeasurementWindows.defaults.encode());
  });
  testWidgets('Leeres Fenster wird nicht gespeichert', (tester) async {
    var saves = 0;
    await open(tester, (_) async {
      saves++;
    });
    await change(tester, 'morning-end', '05');
    await tester.scrollUntilVisible(find.text('Speichern'), 200);
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.textContaining('verschieden'), findsOneWidget);
  });
}
