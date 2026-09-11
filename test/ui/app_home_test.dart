import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/app_home.dart';
import 'package:sphygma/ui/phases/phase_management_screen.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/today_screen.dart';

import 'a3_test_support.dart';

void main() {
  late A3Harness harness;

  setUp(() async {
    harness = A3Harness();
    await harness.settings.setRawSetting('app_concept', 'phase');
    await harness.start();
  });
  tearDown(() => harness.close());

  Widget app() => MaterialApp(
    builder: (context, child) => SphygmaThemeScope(
      theme: themeFor(ThemeVariant.instrument),
      child: child!,
    ),
    home: AppHome(controller: harness.controller),
  );

  testWidgets('legacy concept setting still starts on unified Today', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('Konzept'), findsNothing);
    expect(find.text('Anlässe'), findsNothing);
  });

  testWidgets('phase management is exposed from history only when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Verlauf'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Phasen verwalten'), findsNothing);

    await tester.runAsync(() => harness.controller.setPhasesEnabled(true));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Phasen verwalten'));
    await tester.pumpAndSettle();
    expect(find.byType(PhaseManagementScreen), findsOneWidget);
  });
}
