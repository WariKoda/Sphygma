import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/widgets/classification_scale.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

void main() {
  Future<void> show(WidgetTester tester, int sys, int dia) => tester.pumpWidget(
    MaterialApp(
      home: SphygmaThemeScope(
        theme: themeFor(ThemeVariant.diary),
        child: Scaffold(
          body: ClassificationScale.forReading(systolic: sys, diastolic: dia),
        ),
      ),
    ),
  );
  testWidgets(
    'niedrig erscheint anstelle von optimal und erklärt die Referenz',
    (tester) async {
      await show(tester, 85, 55);
      expect(find.text('Niedrig'), findsOneWidget);
      expect(find.text('Optimal'), findsNothing);
      await tester.tap(find.byTooltip('Einordnung erklären'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Hypotonie'), findsOneWidget);
      expect(find.textContaining('unter 90'), findsOneWidget);
      expect(find.textContaining('keine ESC/ESH-Stufe'), findsOneWidget);
      await tester.tap(find.text('Schließen'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
  testWidgets('hoher und niedriger Teil sind gleichzeitig sichtbar', (
    tester,
  ) async {
    await show(tester, 140, 55);
    expect(
      find.text('Bluthochdruck Grad 1 · Diastolisch niedrig'),
      findsOneWidget,
    );
    await show(tester, 130, 55);
    expect(find.text('Hochnormal · Diastolisch niedrig'), findsOneWidget);
  });
  testWidgets('gemischter Hinweis und Erklärung passen bei großer Schrift', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await show(tester, 140, 55);
    expect(
      find.text('Bluthochdruck Grad 1 · Diastolisch niedrig'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Einordnung erklären'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Schließen'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
