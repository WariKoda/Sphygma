// Rechnet Messwerte in Bildpunkte um. Bewusst getrennt vom Zeichnen:
// Hier verstecken sich die Fehler, und so sind sie ohne Oberflaeche
// pruefbar.
import 'dart:ui';

import '../db/app_database.dart';

class ChartGeometry {
  const ChartGeometry._({
    required this.systolicPoints,
    required this.diastolicPoints,
    required this.thresholdY,
    required this.minValue,
    required this.maxValue,
  });

  /// Punkte der oberen Linie, in Zeichenreihenfolge.
  final List<Offset> systolicPoints;

  /// Punkte der unteren Linie.
  final List<Offset> diastolicPoints;

  /// Hoehe der Schwellenlinie im Bild.
  final double thresholdY;

  final int minValue;
  final int maxValue;

  /// Randabstand oben und unten, damit Punkte nicht am Rand kleben.
  static const double _padding = 6;

  /// Verteilt [measurements] gleichmaessig ueber [width] und skaliert die
  /// Werte auf [height].
  ///
  /// Die Punkte sitzen in gleichen Abstaenden, nicht nach Zeitabstand:
  /// Bei unregelmaessigem Messen waeren echte Zeitabstaende unlesbar, und
  /// die Geraeteuhr ist ohnehin nicht garantiert (§8.2).
  ///
  /// Wirft bei leerer Liste oder nicht positiver Groesse - beides ist ein
  /// Fehler des Aufrufers, kein Zustand, den diese Klasse glaetten darf.
  static ChartGeometry fit({
    required List<Measurement> measurements,
    required double width,
    required double height,
    double threshold = 135,
  }) {
    if (measurements.isEmpty) {
      throw ArgumentError.value(
        measurements.length,
        'measurements',
        'darf nicht leer sein - ohne Messungen gibt es keine Kurve',
      );
    }
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Breite und Hoehe muessen positiv sein');
    }

    var min = measurements.first.diastolic;
    var max = measurements.first.systolic;
    for (final m in measurements) {
      if (m.diastolic < min) min = m.diastolic;
      if (m.systolic > max) max = m.systolic;
    }
    if (threshold < min) min = threshold.floor();
    if (threshold > max) max = threshold.ceil();

    // Ohne Spanne waere die Skalierung eine Division durch null.
    final span = (max - min) == 0 ? 1.0 : (max - min).toDouble();
    final usable = height - 2 * _padding;

    double y(num value) =>
        _padding + usable - ((value - min) / span) * usable;

    final step =
        measurements.length == 1 ? 0.0 : width / (measurements.length - 1);

    return ChartGeometry._(
      systolicPoints: [
        for (var i = 0; i < measurements.length; i++)
          Offset(i * step, y(measurements[i].systolic)),
      ],
      diastolicPoints: [
        for (var i = 0; i < measurements.length; i++)
          Offset(i * step, y(measurements[i].diastolic)),
      ],
      thresholdY: y(threshold),
      minValue: min,
      maxValue: max,
    );
  }
}
