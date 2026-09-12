import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/phases/phase_management_screen.dart';
import 'package:sphygma/ui/phases/phase_selection_editor.dart';
import 'package:sphygma/ui/theme/material_theme.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

import '../a3_test_support.dart';

void main() {
  late A3Harness harness;
  setUp(() async {
    harness = A3Harness();
    await harness.start();
    await harness.addMeasurement();
  });
  tearDown(() => harness.close());

  Widget app(Widget child) {
    final theme = themeFor(ThemeVariant.instrument);
    return MaterialApp(
      theme: materialThemeFor(theme),
      builder: (context, child) =>
          SphygmaThemeScope(theme: theme, child: child!),
      home: child,
    );
  }

  testWidgets('Phasendialog behält Eingaben während der Rückanimation', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(PhaseManagementScreen(controller: harness.controller)),
    );

    await tester.tap(find.text('Phase anlegen'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Therapie');
    await tester.tap(find.text('Speichern'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();

    expect(harness.controller.phases.single.name, 'Therapie');
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports multiple, empty and automatic phase selection', (
    tester,
  ) async {
    final now = DateTime.now();
    final first = await harness.controller.savePhase(
      name: 'Therapie',
      begin: now.subtract(const Duration(days: 2)),
      end: null,
    );
    final second = await harness.controller.savePhase(
      name: 'Urlaub',
      begin: now.subtract(const Duration(days: 1)),
      end: null,
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => SphygmaThemeScope(
          theme: themeFor(ThemeVariant.instrument),
          child: child!,
        ),
        home: Scaffold(
          body: PhaseSelectionEditor(
            controller: harness.controller,
            deviceSequence: 1,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Phasenauswahl speichern'));
    await tester.pumpAndSettle();
    expect((await harness.phases.selections(1))[1], {first, second});

    await tester.tap(find.text('Therapie'));
    await tester.tap(find.text('Urlaub'));
    await tester.tap(find.text('Phasenauswahl speichern'));
    await tester.pumpAndSettle();
    expect((await harness.phases.selections(1))[1], isEmpty);

    await tester.tap(find.text('Automatisch zuordnen'));
    await tester.pumpAndSettle();
    expect(await harness.phases.selections(1), isEmpty);
  });
}
