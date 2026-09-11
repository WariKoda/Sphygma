import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/chart_geometry.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/trend_chart.dart';

Measurement _m(int sys, DateTime at, {int? id, int? sequence}) => Measurement(
  id: id ?? at.millisecondsSinceEpoch,
  userSlot: 1,
  deviceSequence: sequence ?? at.millisecondsSinceEpoch ~/ 1000,
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
  builder: (context, child) =>
      SphygmaThemeScope(theme: themeFor(v), child: child!),
  home: Scaffold(body: SizedBox(width: 300, child: child)),
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

  testWidgets(
    'ohne Messungen erscheint ein Hinweis statt einer leeren Flaeche',
    (tester) async {
      await tester.pumpWidget(
        _wrap(ThemeVariant.instrument, const TrendChart(measurements: [])),
      );

      expect(find.textContaining('Keine Messungen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('nennt ausgeschlossene Messungen auch bei leerer Kurve', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ThemeVariant.instrument,
        const TrendChart(measurements: [], excludedMeasurementCount: 3),
      ),
    );

    expect(
      find.textContaining('3 Messungen mit fraglicher Gerätezeit'),
      findsOneWidget,
    );
  });

  testWidgets('eine einzelne Messung stuerzt nicht ab', (tester) async {
    await tester.pumpWidget(
      _wrap(ThemeVariant.instrument, TrendChart(measurements: [_m(120, t0)])),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('Geometriehoehe entspricht der tatsaechlichen Zeichenflaeche', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ThemeVariant.instrument,
        TrendChart(
          measurements: [_m(120, t0)],
          metric: ChartMetric.pulse,
          height: 120,
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('trend-chart-canvas'))).height,
      120,
    );
  });

  testWidgets('Auswahl meldet die Messungs-ID und zeigt alle Werte', (
    tester,
  ) async {
    int? selectedId;
    final measurement = _m(128, t0, id: 42, sequence: 542);
    await tester.pumpWidget(
      _wrap(
        ThemeVariant.instrument,
        TrendChart(
          measurements: [measurement],
          onMeasurementSelected: (id) => selectedId = id,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('trend-chart-canvas')));
    await tester.pump();

    expect(selectedId, 42);
    expect(find.textContaining('128 / 80'), findsOneWidget);
    expect(find.textContaining('Puls 70'), findsOneWidget);
    expect(find.textContaining('01.09.2026'), findsOneWidget);
  });

  testWidgets('Metrikwechsel behaelt die Auswahl derselben Messungs-ID', (
    tester,
  ) async {
    final measurement = _m(128, t0, id: 42, sequence: 542);
    Widget chart(ChartMetric metric) => _wrap(
      ThemeVariant.instrument,
      TrendChart(measurements: [measurement], metric: metric),
    );
    await tester.pumpWidget(chart(ChartMetric.bloodPressure));
    await tester.tap(find.byKey(const Key('trend-chart-canvas')));
    await tester.pump();

    await tester.pumpWidget(chart(ChartMetric.pulse));
    await tester.pump();

    expect(find.textContaining('128 / 80'), findsOneWidget);
    expect(find.textContaining('Puls 70'), findsOneWidget);
  });

  testWidgets('Vor und Zurueck erreicht Punkte mit demselben Zeitpunkt', (
    tester,
  ) async {
    final measurements = [
      _m(120, t0, id: 1, sequence: 11),
      _m(130, t0, id: 2, sequence: 12),
    ];
    await tester.pumpWidget(
      _wrap(ThemeVariant.instrument, TrendChart(measurements: measurements)),
    );

    await tester.tap(find.byKey(const Key('trend-chart-canvas')));
    await tester.pump();
    expect(find.textContaining('120 / 80'), findsOneWidget);

    await tester.tap(find.byTooltip('Nächste Messung'));
    await tester.pump();
    expect(find.textContaining('130 / 80'), findsOneWidget);

    await tester.tap(find.byTooltip('Vorherige Messung'));
    await tester.pump();
    expect(find.textContaining('120 / 80'), findsOneWidget);
  });

  testWidgets('320 Pixel und grosse Systemschrift laufen nicht ueber', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _wrap(
          ThemeVariant.instrument,
          TrendChart(measurements: drei, height: 180),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
