import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/widgets/measurement_list_item.dart';

import 'today_vitals_test.dart' show reading;

void main() {
  for (final variant in allVariants) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('kompakte Messungszeile ${variant.name}, Schrift $scale', (
        tester,
      ) async {
        final font = FontLoader('Archivo')
          ..addFont(rootBundle.load('assets/fonts/Archivo.ttf'));
        await font.load();
        final theme = themeFor(variant);
        var taps = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Archivo'),
            home: SphygmaThemeScope(
              theme: theme,
              child: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: 280,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MeasurementTableHeader(),
                          MeasurementListItem(
                            compact: true,
                            measurement: reading(
                              1,
                              DateTime(2026, 9, 12, 7, 42),
                              133,
                              86,
                              78,
                            ),
                            timestamp: '07:42',
                            onTap: () => taps++,
                          ),
                          MeasurementListItem(
                            compact: true,
                            measurement:
                                reading(
                                  2,
                                  DateTime(2026, 9, 12),
                                  99,
                                  101,
                                  108,
                                ).copyWith(
                                  exportedAt: Value(DateTime(2026, 9, 12)),
                                ),
                            timestamp: '08:00',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final pressure = find.text('133/86');
        final time = find.text('07:42');
        final pending = find.byIcon(Icons.remove_circle_outline);
        final exported = find.byIcon(Icons.check_circle_outline);
        expect(pending, findsOneWidget);
        expect(exported, findsOneWidget);
        expect(tester.getTopLeft(pending).dx, tester.getTopLeft(exported).dx);
        expect(
          tester.widget<Icon>(pending).size,
          tester.widget<Icon>(exported).size,
        );
        expect(
          tester.widget<Icon>(pending).color,
          tester.widget<Icon>(exported).color,
        );
        expect(find.text('mmHg'), findsNothing);
        expect(find.text('Puls · bpm'), findsOneWidget);
        expect(find.text('Blutdruck · mmHg'), findsOneWidget);
        final headerStyle = DefaultTextStyle.of(
          tester.element(find.text('Uhrzeit')),
        ).style;
        expect(headerStyle.fontWeight, FontWeight.w400);
        expect(headerStyle.fontSize, 12);
        expect(
          tester.getTopRight(pressure).dx,
          tester.getTopRight(find.text('99/101')).dx,
        );
        expect(
          tester.getTopRight(find.text('78')).dx,
          tester.getTopRight(find.text('108')).dx,
        );
        expect(
          tester.getTopRight(find.text('78')).dx,
          tester.getTopRight(find.byType(MeasurementTableHeader)).dx,
        );
        if (scale == 1) {
          final check = find.byKey(const ValueKey('exported-dot'));
          expect(
            tester.getTopLeft(check).dx,
            greaterThan(tester.getTopRight(find.text('08:00')).dx),
          );
          expect(
            tester.getTopRight(check).dx,
            lessThan(tester.getTopLeft(find.text('99/101')).dx),
          );
        }
        if (scale == 1) {
          expect(
            tester.getTopLeft(pressure).dx,
            greaterThan(tester.getTopLeft(time).dx),
          );
          expect(
            (tester.getTopLeft(pressure).dy - tester.getTopLeft(time).dy).abs(),
            lessThan(8),
          );
        }
        if (scale == 1) {
          expect(
            (tester.getTopLeft(find.text('78')).dy -
                    tester.getTopLeft(pressure).dy)
                .abs(),
            lessThan(1),
            reason: 'Auch der Puls steht in derselben Wertezeile',
          );
        }
        expect(tester.takeException(), isNull);
        await tester.tap(find.byType(MeasurementListItem).first);
        expect(taps, 1);
      });
    }
  }
}
