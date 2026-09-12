import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/theme/material_theme.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/widgets/surface_panel.dart';
import 'package:sphygma/ui/widgets/this_week_panel.dart';
import 'package:sphygma/ui/widgets/measurement_list_item.dart';
import 'package:sphygma/ui/widgets/panel_header.dart';

import 'package:sphygma/ui/widgets/week_grid.dart';

import 'today_vitals_test.dart' show reading;

void main() {
  for (final variant in allVariants) {
    testWidgets(
      'Wochenraster und Messungszeile ${variant.name}: große Schrift und Aktionen',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final values = [reading(1, DateTime(2026, 9, 13, 7), 123, 82, 76)];
        var selected = 0;
        var opened = 0;
        final theme = themeFor(variant);
        await tester.pumpWidget(
          MaterialApp(
            theme: materialThemeFor(theme),
            builder: (context, child) => SphygmaThemeScope(
              theme: theme,
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(2)),
                child: child!,
              ),
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: theme.listPadding,
                  child: Column(
                    children: [
                      SurfacePanel(
                        child: ThisWeekPanel(
                          measurements: values,
                          now: DateTime(2026, 9, 13),
                          onFieldTap: (_) => selected++,
                        ),
                      ),
                      SurfacePanel(
                        child: Column(
                          children: [
                            const PanelHeader(
                              title: 'Letzte Messungen',
                              icon: Icons.history,
                            ),
                            MeasurementListItem(
                              measurement: values.first,
                              timestamp: '13.09.2026 · 07:00',
                              onTap: () => opened++,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final sunday = find.descendant(
          of: find.byType(WeekGrid),
          matching: find.text('123'),
        );
        await tester.ensureVisible(sunday);
        await tester.pumpAndSettle();
        await tester.tap(sunday);
        expect(selected, 1);
        final row = find.byType(MeasurementListItem);
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        await tester.tap(row);
        expect(opened, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
