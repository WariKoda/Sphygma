// Mittelwerte und Tagesgruppen ueber eine bereits gefilterte Messliste.
// Der Zeitraum steckt in der Liste, nicht in dieser Rechnung - so bleibt
// sie unabhaengig von der Zeitraumwahl der Oberflaeche.
import '../db/app_database.dart';
import 'trend_stats.dart';

class PeriodAverages {
  const PeriodAverages._({
    required this.overall,
    required this.morning,
    required this.evening,
  });

  /// Alle Messungen des Zeitraums.
  final Average? overall;

  /// Messungen vor 12:00 Uhr.
  final Average? morning;

  /// Messungen ab 18:00 Uhr.
  final Average? evening;

  static PeriodAverages of(List<Measurement> measurements) {
    Reading toReading(Measurement m) => Reading(
          measuredAt: m.measuredAt,
          systolic: m.systolic,
          diastolic: m.diastolic,
          pulse: m.pulse,
        );

    final readings = measurements.map(toReading).toList();
    return PeriodAverages._(
      overall: Average.of(readings),
      morning: Average.of(
        readings.where((r) => r.measuredAt.hour < 12).toList(),
      ),
      evening: Average.of(
        readings.where((r) => r.measuredAt.hour >= 18).toList(),
      ),
    );
  }
}

/// Ein Kalendertag mit seinen Messungen, neueste zuerst.
class DayGroup {
  const DayGroup({required this.day, required this.measurements});

  final DateTime day;
  final List<Measurement> measurements;
}

/// Messungen nach Kalendertag, neuester Tag zuerst.
List<DayGroup> groupByDay(List<Measurement> measurements) {
  final byDay = <DateTime, List<Measurement>>{};
  for (final m in measurements) {
    final day = DateTime(m.measuredAt.year, m.measuredAt.month, m.measuredAt.day);
    byDay.putIfAbsent(day, () => []).add(m);
  }

  final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final day in days)
      DayGroup(
        day: day,
        measurements: byDay[day]!
          ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt)),
      ),
  ];
}
