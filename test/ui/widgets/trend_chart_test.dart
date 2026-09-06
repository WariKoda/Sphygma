import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/trend_chart.dart';

Measurement _m(int sys, DateTime at) => Measurement(
      id: at.millisecondsSinceEpoch,
      userSlot: 1,
      deviceSequence: at.millisecondsSinceEpoch ~/ 1000,
      systolic: sys,
      diastolic: 80,
      pulse: 70,
      measuredAt: at,
      movement: false,
      arrhythmia: false,
      rawBytes: Uint8List(14),
      importedAt: at,
      exportedAt: null,
    );

Widget _wrap(ThemeVariant v, Widget child) => MaterialApp(
      home: SphygmaThemeScope(
        theme: themeFor(v),
        child: Scaffold(body: SizedBox(width: 300, child: child)),
      ),
    );

void main() {
  final t0 = DateTime(2026, 9, 1);
  final drei = [
    _m(120, t0),
    _m(135, t0.add(const Duration(days: 1))),
    _m(128, t0.add(const Duration(days: 2))),
  ];

  group('in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('zeichnet ohne Fehler (${v.name})', (tester) async {
        await tester.pumpWidget(_wrap(v, TrendChart(measurements: drei)));

        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('ohne Messungen erscheint ein Hinweis statt einer leeren Flaeche',
      (tester) async {
    await tester.pumpWidget(
      _wrap(ThemeVariant.instrument, const TrendChart(measurements: [])),
    );

    expect(find.textContaining('Keine Messungen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('eine einzelne Messung stuerzt nicht ab', (tester) async {
    await tester.pumpWidget(
      _wrap(ThemeVariant.instrument, TrendChart(measurements: [_m(120, t0)])),
    );

    expect(tester.takeException(), isNull);
  });
}
