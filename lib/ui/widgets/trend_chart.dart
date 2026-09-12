import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../db/app_database.dart';
import '../../stats/chart_geometry.dart';
import '../theme/sphygma_theme.dart';
import 'chart_selection_summary.dart';

class TrendChart extends StatefulWidget {
  const TrendChart({
    super.key,
    required this.measurements,
    this.height = 120,
    this.metric = ChartMetric.bloodPressure,
    this.onMeasurementSelected,
    this.excludedMeasurementCount = 0,
  });

  final List<Measurement> measurements;
  final double height;
  final ChartMetric metric;
  final ValueChanged<int>? onMeasurementSelected;
  final int excludedMeasurementCount;

  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
  int? _selectedId;

  @override
  void didUpdateWidget(TrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedId != null &&
        !widget.measurements.any((m) => m.id == _selectedId)) {
      _selectedId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SphygmaTheme.of(context);
    if (widget.measurements.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Keine Messungen in diesem Zeitraum',
                style: TextStyle(fontSize: 13, color: theme.muted),
              ),
              if (widget.excludedMeasurementCount > 0)
                Text(
                  '${widget.excludedMeasurementCount} Messungen mit fraglicher Gerätezeit nicht in der Kurve',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: theme.muted),
                ),
            ],
          ),
        ),
      );
    }

    final ordered = [...widget.measurements]
      ..sort((a, b) {
        final byTime = a.measuredAt.compareTo(b.measuredAt);
        return byTime != 0
            ? byTime
            : a.deviceSequence.compareTo(b.deviceSequence);
      });
    final selectedIndex = _selectedId == null
        ? null
        : ordered.indexWhere((m) => m.id == _selectedId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: theme.gapSmall,
          runSpacing: theme.gapSmall / 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              widget.metric == ChartMetric.bloodPressure
                  ? 'Blutdruck (mmHg)'
                  : 'Puls (/min)',
              style: TextStyle(fontSize: 12, color: theme.muted),
            ),
            if (widget.metric == ChartMetric.bloodPressure) ...[
              _LegendDot(color: theme.onSurface, filled: true),
              Text(' SYS', style: TextStyle(fontSize: 11, color: theme.muted)),
              SizedBox(width: theme.gapSmall),
              _LegendDot(color: theme.muted, filled: false),
              Text(' DIA', style: TextStyle(fontSize: 11, color: theme.muted)),
            ],
          ],
        ),
        SizedBox(height: theme.gapSmall / 2),
        LayoutBuilder(
          builder: (context, constraints) {
            final geometry = ChartGeometry.fit(
              measurements: ordered,
              width: constraints.maxWidth,
              height: widget.height,
              metric: widget.metric,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${geometry.minValue}–${geometry.maxValue} '
                  '${widget.metric == ChartMetric.bloodPressure ? 'mmHg' : '/min'}',
                  style: TextStyle(fontSize: 10, color: theme.muted),
                ),
                SizedBox(
                  height: widget.height,
                  child: Semantics(
                    label: _semanticsLabel(ordered, selectedIndex),
                    slider: true,
                    onIncrease: selectedIndex == null
                        ? () => _selectIndex(ordered, 0)
                        : () => _selectIndex(
                            ordered,
                            math.min(selectedIndex + 1, ordered.length - 1),
                          ),
                    onDecrease: selectedIndex == null
                        ? () => _selectIndex(ordered, ordered.length - 1)
                        : () => _selectIndex(
                            ordered,
                            math.max(selectedIndex - 1, 0),
                          ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) => _selectNearest(
                        ordered,
                        geometry,
                        details.localPosition.dx,
                      ),
                      child: CustomPaint(
                        key: const Key('trend-chart-canvas'),
                        size: Size(constraints.maxWidth, widget.height),
                        painter: _TrendPainter(
                          geometry: geometry,
                          metric: widget.metric,
                          selectedId: _selectedId,
                          lineColor: theme.onSurface,
                          secondaryColor: theme.muted,
                          gridColor: theme.line,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (widget.excludedMeasurementCount > 0)
          Text(
            '${widget.excludedMeasurementCount} Messungen mit fraglicher Gerätezeit nicht in der Kurve',
            style: TextStyle(fontSize: 11, color: theme.muted),
          ),
        if (selectedIndex != null && selectedIndex >= 0)
          ChartSelectionSummary(
            measurement: ordered[selectedIndex],
            onPrevious: selectedIndex > 0
                ? () => _selectIndex(ordered, selectedIndex - 1)
                : null,
            onNext: selectedIndex < ordered.length - 1
                ? () => _selectIndex(ordered, selectedIndex + 1)
                : null,
          ),
      ],
    );
  }

  void _selectNearest(
    List<Measurement> ordered,
    ChartGeometry geometry,
    double x,
  ) {
    final points = widget.metric == ChartMetric.pulse
        ? geometry.pulsePoints
        : geometry.systolicPoints;
    var closest = 0;
    var distance = double.infinity;
    for (var i = 0; i < points.length; i++) {
      final candidate = (points[i].dx - x).abs();
      if (candidate < distance) {
        closest = i;
        distance = candidate;
      }
    }
    _selectIndex(ordered, closest);
  }

  void _selectIndex(List<Measurement> ordered, int index) {
    final id = ordered[index].id;
    setState(() => _selectedId = id);
    widget.onMeasurementSelected?.call(id);
  }

  String _semanticsLabel(List<Measurement> ordered, int? selectedIndex) {
    if (selectedIndex == null || selectedIndex < 0) {
      return 'Diagramm mit ${ordered.length} Messungen. Durch Wischen Messung auswählen.';
    }
    final m = ordered[selectedIndex];
    return 'Messung ${selectedIndex + 1} von ${ordered.length}: ${m.systolic} zu ${m.diastolic} Millimeter Quecksilbersäule, Puls ${m.pulse} pro Minute.';
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.filled});
  final Color color;
  final bool filled;
  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: filled ? color : null,
      border: Border.all(color: color),
    ),
  );
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.geometry,
    required this.metric,
    required this.selectedId,
    required this.lineColor,
    required this.secondaryColor,
    required this.gridColor,
  });
  final ChartGeometry geometry;
  final ChartMetric metric;
  final int? selectedId;
  final Color lineColor;
  final Color secondaryColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final thresholdY = geometry.thresholdY;
    if (thresholdY != null) {
      _dashedLine(canvas, size, thresholdY);
    }
    if (metric == ChartMetric.pulse) {
      _polyline(canvas, geometry.pulsePoints, lineColor);
      for (final point in geometry.pulsePoints) {
        _dot(canvas, point, lineColor, filled: true);
      }
    } else {
      _polyline(canvas, geometry.systolicPoints, lineColor);
      _polyline(canvas, geometry.diastolicPoints, secondaryColor);
      for (final point in geometry.systolicPoints) {
        _dot(canvas, point, lineColor, filled: true);
      }
      for (final point in geometry.diastolicPoints) {
        _dot(canvas, point, secondaryColor, filled: false);
      }
    }
    final selectedIndex = selectedId == null
        ? -1
        : geometry.measurementIds.indexOf(selectedId!);
    if (selectedIndex >= 0) {
      final point = metric == ChartMetric.pulse
          ? geometry.pulsePoints[selectedIndex]
          : geometry.systolicPoints[selectedIndex];
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _polyline(Canvas canvas, List<Offset> points, Color color) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _dot(Canvas canvas, Offset at, Color color, {required bool filled}) =>
      canvas.drawCircle(
        at,
        3,
        Paint()
          ..color = color
          ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );

  void _dashedLine(Canvas canvas, Size size, double y) {
    if (y < 0 || y > size.height) return;
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + 3, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.geometry != geometry ||
      old.metric != metric ||
      old.selectedId != selectedId ||
      old.lineColor != lineColor ||
      old.secondaryColor != secondaryColor ||
      old.gridColor != gridColor;
}
