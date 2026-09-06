// Die Messwoche als Objekt — Grundlage des Konzepts „Sieben Tage".
//
// Ein einzelner Blutdruckwert sagt fast nichts, ein gleitender Schnitt mittelt
// über einen zufälligen Zeitraum. Aussagekraft hat die Messwoche: sieben Tage,
// morgens und abends gemessen, mit einem Zielwert, der für zu Hause gilt.
// Damit hat die App ein natürliches Objekt — eine Woche ist vollständig oder
// nicht, und ihr Wert gilt in der Sprechstunde.
//
// **Der erste Tag zählt nicht in den Wochenwert.** So verlangt es die
// Leitlinie für die Selbstmessung: Am ersten Tag ist man noch nicht eingespielt
// und misst meist zu hoch. Der Vollwert bleibt trotzdem abrufbar, sonst wirkte
// die Zahl willkürlich.
import '../db/app_database.dart';
import 'time_of_day_band.dart';
import 'trend_stats.dart';

/// Die vierzehn Felder einer Woche: sieben Tage, morgens und abends.
const int fieldsPerWeek = 14;

/// Eine Kalenderwoche mit ihren Messungen.
class MeasurementWeek {
  MeasurementWeek({
    required this.beginsAt,
    required this.measurements,
    required this.filledFields,
    required this.average,
    required this.averageWithFirstDay,
    required this.morningAverage,
    required this.eveningAverage,
  });

  /// Montag, 00:00 — Wochen laufen von Montag bis Sonntag.
  final DateTime beginsAt;

  DateTime get endsAt => beginsAt.add(const Duration(days: 7));

  /// Alle Messungen dieser Woche, älteste zuerst.
  final List<Measurement> measurements;

  /// Wie viele der vierzehn Felder belegt sind. Mehrere Messungen in einem
  /// Feld zählen einmal — sie sind ein Messen, kein zweites Feld.
  final int filledFields;

  /// Der Wochenwert ohne den ersten Tag. Null, wenn danach nichts übrig
  /// bleibt — eine Woche aus einem Tag hat keinen Wochenwert.
  final Average? average;

  /// Derselbe Wert über alle sieben Tage, damit die Zahl nachvollziehbar ist.
  final Average? averageWithFirstDay;

  final Average? morningAverage;
  final Average? eveningAverage;

  bool get isComplete => filledFields == fieldsPerWeek;
}

/// Bildet Messwochen von Montag bis Sonntag, die jüngste zuerst.
///
/// [grid] bestimmt, wo morgens endet und abends beginnt — standardmäßig um
/// 12 Uhr, verschiebbar für Schichtdienst.
List<MeasurementWeek> buildWeeks(
  List<Measurement> measurements, {
  BandGrid? grid,
}) {
  if (measurements.isEmpty) return const [];

  final slots = {for (final m in measurements) m.userSlot};
  if (slots.length > 1) {
    throw ArgumentError.value(
      slots.toList()..sort(),
      'measurements',
      'enthält mehrere Speicherplätze — eine Messwoche gehört zu einem '
          'Benutzer, nicht zu zweien',
    );
  }

  final raster = grid ?? BandGrid.grob;

  final nachWoche = <DateTime, List<Measurement>>{};
  for (final m in measurements) {
    nachWoche.putIfAbsent(_mondayOf(m.measuredAt), () => []).add(m);
  }

  final montage = nachWoche.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final montag in montage) _build(montag, nachWoche[montag]!, raster),
  ];
}

DateTime _mondayOf(DateTime at) {
  final tag = DateTime(at.year, at.month, at.day);
  return tag.subtract(Duration(days: tag.weekday - DateTime.monday));
}

MeasurementWeek _build(
  DateTime montag,
  List<Measurement> ms,
  BandGrid raster,
) {
  ms.sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

  // Ein Feld ist ein Tag mit einer Tageshälfte. Zwei Messungen kurz
  // hintereinander füllen dasselbe Feld — sie sind ein Messen.
  final felder = <String>{};
  for (final m in ms) {
    final band = raster.bandAt(TimeOfDayMinutes.of(m.measuredAt));
    felder.add('${m.measuredAt.day}-${band.name}');
  }

  final ersterTag = ms.first.measuredAt;
  final ohneErsten = [
    for (final m in ms)
      if (!_sameDay(m.measuredAt, ersterTag)) m,
  ];

  Average? mittel(List<Measurement> liste) => Average.of([
        for (final m in liste)
          Reading(
            measuredAt: m.measuredAt,
            systolic: m.systolic,
            diastolic: m.diastolic,
            pulse: m.pulse,
          ),
      ]);

  final nachBand = groupByBand(ms, raster);

  return MeasurementWeek(
    beginsAt: montag,
    measurements: List.unmodifiable(ms),
    filledFields: felder.length,
    average: mittel(ohneErsten),
    averageWithFirstDay: mittel(ms),
    morningAverage: mittel(nachBand[TimeBand.morgens] ?? const []),
    eveningAverage: mittel(nachBand[TimeBand.abends] ?? const []),
  );
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
