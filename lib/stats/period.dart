// Zeitraumwahl im Verlauf. Rein rechnend, ohne Flutter, damit ohne
// Oberflaeche pruefbar.
import '../db/app_database.dart';

enum Period {
  week('Woche', Duration(days: 7)),
  month('Monat', Duration(days: 30)),
  year('Jahr', Duration(days: 365)),
  all('Alles', null);

  const Period(this.label, this._span);

  final String label;
  final Duration? _span;

  /// Anfang des Zeitraums, oder null fuer "Alles".
  DateTime? startFrom(DateTime now) =>
      _span == null ? null : now.subtract(_span);
}

/// Messungen im gewaehlten Zeitraum, aelteste zuerst.
///
/// Messungen mit einem Zeitstempel in der Zukunft fallen heraus: Bei
/// falsch gestellter Geraeteuhr kommen sie vor und wuerden jeden
/// Zeitraum verfaelschen (docs/protocol/hem-6232t.md §8.2).
List<Measurement> filterByPeriod(
  List<Measurement> all,
  Period period,
  DateTime now,
) {
  final start = period.startFrom(now);
  return [
    for (final m in all)
      if (!m.measuredAt.isAfter(now) &&
          (start == null || !m.measuredAt.isBefore(start)))
        m,
  ]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
}
