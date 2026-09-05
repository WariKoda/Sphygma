// Zwei Linien und eine gestrichelte Schwelle. Kein Diagrammpaket: Was
// gebraucht wird, passt in eine Datei, und eine Abhaengigkeit weniger ist
// in einer App mit Gesundheitsdaten ein Gewinn.
import 'package:flutter/material.dart';

import '../../db/app_database.dart';
import '../../stats/chart_geometry.dart';
import '../theme/sphygma_theme.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.measurements,
    this.height = 120,
  });

  final List<Measurement> measurements;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    if (measurements.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Keine Messungen in diesem Zeitraum',
            style: TextStyle(fontSize: 13, color: t.muted),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) => CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: _TrendPainter(
            geometry: ChartGeometry.fit(
              measurements: measurements,
              width: constraints.maxWidth,
              height: height,
            ),
            lineColor: t.onSurface,
            secondaryColor: t.muted,
            gridColor: t.line,
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.geometry,
    required this.lineColor,
    required this.secondaryColor,
    required this.gridColor,
  });

  final ChartGeometry geometry;
  final Color lineColor;
  final Color secondaryColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    _dashedLine(canvas, size, geometry.thresholdY);
    _polyline(canvas, geometry.systolicPoints, lineColor, 1.6);
    _polyline(canvas, geometry.diastolicPoints, secondaryColor, 1.6);
    _dot(canvas, geometry.systolicPoints.last, lineColor);
  }

  void _polyline(Canvas canvas, List<Offset> points, Color color, double w) {
    if (points.length < 2) {
      if (points.length == 1) _dot(canvas, points.first, color);
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = w
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _dot(Canvas canvas, Offset at, Color color) =>
      canvas.drawCircle(at, 3, Paint()..color = color);

  /// Die Leitlinien-Schwelle, gestrichelt gezeichnet.
  void _dashedLine(Canvas canvas, Size size, double y) {
    if (y < 0 || y > size.height) return;
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    const dash = 3.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.geometry != geometry ||
      old.lineColor != lineColor ||
      old.secondaryColor != secondaryColor;
}
