// Trendkennzahlen (PLAN.md M6): reine Funktionen ueber Messwerte, ohne
// Bewertung. Die ESC-Klassifikation liegt getrennt in esc_classification.dart
// hinter einem Compile-Time-Flag (PLAN.md §3.2).

class Reading {
  Reading({
    required this.measuredAt,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
  });

  final DateTime measuredAt;
  final int systolic;
  final int diastolic;
  final int pulse;
}

/// Mittelwerte, kaufmaennisch gerundet. Nie fuer eine leere Menge -
/// dann gibt es kein Objekt (null), keine Nullen.
class Average {
  Average._({
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.count,
  });

  final int systolic;
  final int diastolic;
  final int pulse;
  final int count;

  static Average? of(List<Reading> readings) {
    if (readings.isEmpty) return null;
    int mean(int Function(Reading) f) =>
        (readings.map(f).reduce((a, b) => a + b) / readings.length).round();
    return Average._(
      systolic: mean((r) => r.systolic),
      diastolic: mean((r) => r.diastolic),
      pulse: mean((r) => r.pulse),
      count: readings.length,
    );
  }
}

class TrendStats {
  TrendStats._({
    required this.last7Days,
    required this.morning,
    required this.evening,
  });

  /// Alle Messungen der letzten 7 Tage (bezogen auf [now]).
  final Average? last7Days;

  /// Messungen vor 12:00 Uhr innerhalb der letzten 7 Tage.
  final Average? morning;

  /// Messungen ab 18:00 Uhr innerhalb der letzten 7 Tage.
  final Average? evening;

  static TrendStats compute(List<Reading> readings, {required DateTime now}) {
    final since = now.subtract(const Duration(days: 7));
    final recent = readings
        .where((r) => !r.measuredAt.isBefore(since) && !r.measuredAt.isAfter(now))
        .toList();
    return TrendStats._(
      last7Days: Average.of(recent),
      morning: Average.of(recent.where((r) => r.measuredAt.hour < 12).toList()),
      evening: Average.of(recent.where((r) => r.measuredAt.hour >= 18).toList()),
    );
  }
}
