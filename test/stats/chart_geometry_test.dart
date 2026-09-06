import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/chart_geometry.dart';

Measurement _m(int sys, int dia, DateTime at) => Measurement(
      id: at.millisecondsSinceEpoch,
      userSlot: 1,
      deviceSequence: at.millisecondsSinceEpoch ~/ 1000,
      systolic: sys,
      diastolic: dia,
      pulse: 70,
      measuredAt: at,
      movement: false,
      arrhythmia: false,
      rawBytes: Uint8List(14),
      importedAt: at,
      exportedAt: null,
    );

void main() {
  final t0 = DateTime(2026, 9, 1);

  test('der hoechste Wert liegt oben, der niedrigste unten', () {
    final g = ChartGeometry.fit(
      measurements: [
        _m(120, 80, t0),
        _m(140, 90, t0.add(const Duration(days: 1))),
      ],
      width: 100,
      height: 100,
    );

    // Kleineres y heisst weiter oben.
    expect(g.systolicPoints[1].dy, lessThan(g.systolicPoints[0].dy));
    expect(g.diastolicPoints[0].dy, greaterThan(g.systolicPoints[0].dy));
  });

  test('Punkte verteilen sich ueber die volle Breite', () {
    final g = ChartGeometry.fit(
      measurements: [
        _m(120, 80, t0),
        _m(125, 82, t0.add(const Duration(days: 1))),
        _m(130, 85, t0.add(const Duration(days: 2))),
      ],
      width: 200,
      height: 100,
    );

    expect(g.systolicPoints.first.dx, 0);
    expect(g.systolicPoints.last.dx, 200);
    expect(g.systolicPoints, hasLength(3));
  });

  test('eine einzelne Messung sitzt am linken Rand, ohne Division durch 0',
      () {
    final g = ChartGeometry.fit(
      measurements: [_m(120, 80, t0)],
      width: 200,
      height: 100,
    );

    expect(g.systolicPoints, hasLength(1));
    expect(g.systolicPoints.first.dx, 0);
    expect(g.systolicPoints.first.dy.isFinite, isTrue);
  });

  test('gleiche Werte ergeben endliche Punkte statt Division durch 0', () {
    // Ohne Spanne waere die Skalierung 0/0.
    final g = ChartGeometry.fit(
      measurements: [
        _m(120, 120, t0),
        _m(120, 120, t0.add(const Duration(days: 1))),
      ],
      width: 100,
      height: 100,
    );

    for (final p in [...g.systolicPoints, ...g.diastolicPoints]) {
      expect(p.dy.isFinite, isTrue);
    }
  });

  test('die Schwelle liegt im Bild, wenn sie in die Spanne faellt', () {
    final g = ChartGeometry.fit(
      measurements: [
        _m(120, 80, t0),
        _m(150, 95, t0.add(const Duration(days: 1))),
      ],
      width: 100,
      height: 100,
      threshold: 135,
    );

    expect(g.thresholdY, greaterThanOrEqualTo(0));
    expect(g.thresholdY, lessThanOrEqualTo(100));
  });

  test('wirft bei leerer Liste - eine leere Kurve ist ein Aufruferfehler',
      () {
    expect(
      () => ChartGeometry.fit(measurements: [], width: 100, height: 100),
      throwsArgumentError,
    );
  });

  test('wirft bei nicht positiver Groesse', () {
    expect(
      () => ChartGeometry.fit(
        measurements: [_m(120, 80, t0)],
        width: 0,
        height: 100,
      ),
      throwsArgumentError,
    );
  });
}
