import 'dart:ui';

import '../db/app_database.dart';

enum ChartMetric { bloodPressure, pulse }

class ChartGeometry {
  const ChartGeometry._({
    required this.systolicPoints,
    required this.diastolicPoints,
    required this.pulsePoints,
    required this.measurementIds,
    required this.thresholdY,
    required this.minValue,
    required this.maxValue,
  });

  final List<Offset> systolicPoints;
  final List<Offset> diastolicPoints;
  final List<Offset> pulsePoints;
  final List<int> measurementIds;
  final double? thresholdY;
  final int minValue;
  final int maxValue;
  static const double _padding = 6;

  static ChartGeometry fit({
    required List<Measurement> measurements,
    required double width,
    required double height,
    double threshold = 135,
    ChartMetric metric = ChartMetric.bloodPressure,
  }) {
    if (measurements.isEmpty) {
      throw ArgumentError.value(
        measurements.length,
        'measurements',
        'darf nicht leer sein - ohne Messungen gibt es keine Kurve',
      );
    }
    if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) {
      throw ArgumentError('Breite und Hoehe muessen endlich und positiv sein');
    }

    final ordered = [...measurements]
      ..sort((a, b) {
        final byTime = a.measuredAt.compareTo(b.measuredAt);
        return byTime != 0
            ? byTime
            : a.deviceSequence.compareTo(b.deviceSequence);
      });
    final bloodValues = <num>[
      for (final m in ordered) ...[m.systolic, m.diastolic],
      threshold,
    ];
    final pulseValues = [for (final m in ordered) m.pulse];
    final List<num> values = metric == ChartMetric.bloodPressure
        ? bloodValues
        : pulseValues.cast<num>();
    final min = values.reduce((a, b) => a < b ? a : b).floor();
    final max = values.reduce((a, b) => a > b ? a : b).ceil();

    double y(num value, int lower, int upper) {
      final span = upper == lower ? 1.0 : (upper - lower).toDouble();
      final usable = height - 2 * _padding;
      return _padding + usable - ((value - lower) / span) * usable;
    }

    double x(DateTime at) {
      final span = ordered.last.measuredAt
          .difference(ordered.first.measuredAt)
          .inMicroseconds;
      if (span == 0) return width / 2;
      return at.difference(ordered.first.measuredAt).inMicroseconds /
          span *
          width;
    }

    final pulseMin = pulseValues.reduce((a, b) => a < b ? a : b);
    final pulseMax = pulseValues.reduce((a, b) => a > b ? a : b);
    return ChartGeometry._(
      systolicPoints: [
        for (final m in ordered)
          Offset(x(m.measuredAt), y(m.systolic, min, max)),
      ],
      diastolicPoints: [
        for (final m in ordered)
          Offset(x(m.measuredAt), y(m.diastolic, min, max)),
      ],
      pulsePoints: [
        for (final m in ordered)
          Offset(x(m.measuredAt), y(m.pulse, pulseMin, pulseMax)),
      ],
      measurementIds: [for (final m in ordered) m.id],
      thresholdY: metric == ChartMetric.bloodPressure
          ? y(threshold, min, max)
          : null,
      minValue: min,
      maxValue: max,
    );
  }
}
