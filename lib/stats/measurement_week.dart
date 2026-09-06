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

/// Ein einzelnes Feld des Wochenrasters: ein Wochentag, eine Tageshälfte.
///
/// Es gibt immer alle vierzehn — ein leeres Feld ist die Aussage „hier wurde
/// nicht gemessen" und muss im Raster sichtbar bleiben.
class WeekField {
  WeekField({
    required this.weekday,
    required this.band,
    required List<Measurement> measurements,
  }) : measurements = List.unmodifiable(measurements);

  /// [DateTime.monday] bis [DateTime.sunday].
  final int weekday;

  /// Nur [TimeBand.morgens] oder [TimeBand.abends] — die Woche kennt zwei
  /// Tageshälften, nicht fünf Abschnitte.
  final TimeBand band;

  /// Mehrere Messungen kurz hintereinander sind ein Messen und stehen
  /// deshalb zusammen in einem Feld.
  final List<Measurement> measurements;

  bool get isFilled => measurements.isNotEmpty;

  Average? get average => _mittel(measurements);
}

/// Eine Kalenderwoche mit ihren Messungen.
class MeasurementWeek {
  MeasurementWeek({
    required this.beginsAt,
    required this.measurements,
    required this.measurementsWithoutFirstDay,
    required this.fields,
    required this.average,
    required this.averageWithFirstDay,
    required this.morningAverage,
    required this.eveningAverage,
  });

  /// Montag, 00:00 — Wochen laufen von Montag bis Sonntag.
  final DateTime beginsAt;

  DateTime get endsAt =>
      DateTime(beginsAt.year, beginsAt.month, beginsAt.day + 7);

  /// Alle Messungen dieser Woche, älteste zuerst.
  final List<Measurement> measurements;

  /// Dieselben Messungen ohne den ersten gemessenen Tag — die Grundlage von
  /// [average]. Öffentlich, damit ein Bereich aus mehreren Wochen sein
  /// gemeinsames Mittel aus den Rohwerten bilden kann statt aus schon
  /// gerundeten Wochenwerten.
  final List<Measurement> measurementsWithoutFirstDay;

  /// Die vierzehn Felder in Tagesreihenfolge, je Tag erst morgens, dann
  /// abends. Immer vollzählig, auch die leeren.
  final List<WeekField> fields;

  /// Wie viele der vierzehn Felder belegt sind — gezählt an denselben
  /// Feldern, die das Raster zeichnet, damit Zahl und Bild nicht
  /// auseinanderlaufen können.
  int get filledFields => fields.where((f) => f.isFilled).length;

  /// Der Wochenwert ohne den ersten Tag. Null, wenn danach nichts übrig
  /// bleibt — eine Woche aus einem Tag hat keinen Wochenwert.
  final Average? average;

  /// Derselbe Wert über alle sieben Tage, damit die Zahl nachvollziehbar ist.
  final Average? averageWithFirstDay;

  final Average? morningAverage;
  final Average? eveningAverage;

  bool get isComplete => filledFields == fieldsPerWeek;

  /// Das Feld eines Tages, auch wenn dort nichts steht.
  WeekField fieldAt({required int weekday, required TimeBand band}) =>
      fields.firstWhere((f) => f.weekday == weekday && f.band == band);
}

Average? _mittel(List<Measurement> liste) => Average.of([
      for (final m in liste)
        Reading(
          measuredAt: m.measuredAt,
          systolic: m.systolic,
          diastolic: m.diastolic,
          pulse: m.pulse,
        ),
    ]);

/// Bildet Messwochen von Montag bis Sonntag, die jüngste zuerst.
///
/// [schnitt] bestimmt, wo morgens endet und abends beginnt — standardmäßig um
/// 12 Uhr, verschiebbar für Schichtdienst.
///
/// Bewusst **nur der Schnittpunkt**, kein ganzes [BandGrid]: Die vierzehn
/// Felder einer Woche sind sieben Tage mal zwei Tageshälften. Ein feineres
/// Raster würde weitere Bänder zählen, während [MeasurementWeek.isComplete]
/// weiter auf vierzehn prüft, und Messungen fielen aus beiden Bandmitteln
/// heraus. Was nicht übergeben werden kann, kann auch nicht falsch sein.
List<MeasurementWeek> buildWeeks(
  List<Measurement> measurements, {
  TimeOfDayMinutes? schnitt,
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

  final raster =
      schnitt == null ? BandGrid.grob : BandGrid.grobMit(schnitt: schnitt);

  final nachWoche = <DateTime, List<Measurement>>{};
  for (final m in measurements) {
    nachWoche.putIfAbsent(mondayOf(m.measuredAt), () => []).add(m);
  }

  final montage = nachWoche.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final montag in montage) _build(montag, nachWoche[montag]!, raster),
  ];
}

/// Der Montag der Woche, in der [at] liegt.
///
/// Öffentlich, weil die Oberfläche die **laufende** Woche finden muss und
/// nicht bloß die jüngste: Nach einer langen Pause ist die jüngste Woche
/// Monate alt, und ein Raster, das sie als „diese Woche" zeigt, lügt.
DateTime mondayOf(DateTime at) {
  // Kalenderarithmetik, nicht Duration: In der Woche einer Zeitumstellung
  // sind sieben Tage nicht 168 Stunden, und ein Abzug in Stunden landet dann
  // eine Stunde vor Mitternacht — also einen Tag zu früh. DateTime rechnet
  // einen überzähligen Tageswert selbst in den Vormonat um.
  final tag = DateTime(at.year, at.month, at.day);
  return DateTime(tag.year, tag.month, tag.day - (tag.weekday - DateTime.monday));
}

/// Der Montag der Vorwoche — dieselbe Kalenderarithmetik.
DateTime previousMonday(DateTime monday) =>
    DateTime(monday.year, monday.month, monday.day - 7);

/// Wie viele Kalenderwochen von [firstMonday] bis [lastMonday] reichen,
/// beide eingeschlossen.
///
/// Zählt **alle** Wochen des Zeitraums, auch die ohne eine einzige Messung.
/// Eine Abdeckung, die nur die vorhandenen Wochen als Nenner nimmt, sähe umso
/// besser aus, je länger man nicht gemessen hat.
int weekSpan(DateTime firstMonday, DateTime lastMonday) {
  if (lastMonday.isBefore(firstMonday)) {
    throw ArgumentError.value(
      lastMonday,
      'lastMonday',
      'liegt vor $firstMonday — ein Zeitraum läuft vorwärts',
    );
  }
  var zaehler = 1;
  var lauf = firstMonday;
  while (lauf.isBefore(lastMonday)) {
    lauf = DateTime(lauf.year, lauf.month, lauf.day + 7);
    zaehler++;
  }
  return zaehler;
}

MeasurementWeek _build(
  DateTime montag,
  List<Measurement> ms,
  BandGrid raster,
) {
  ms.sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

  final belegt = <int, Map<TimeBand, List<Measurement>>>{};
  for (final m in ms) {
    final band = raster.bandAt(TimeOfDayMinutes.of(m.measuredAt));
    belegt
        .putIfAbsent(m.measuredAt.weekday, () => {})
        .putIfAbsent(band, () => [])
        .add(m);
  }

  final felder = [
    for (var tag = DateTime.monday; tag <= DateTime.sunday; tag++)
      for (final band in const [TimeBand.morgens, TimeBand.abends])
        WeekField(
          weekday: tag,
          band: band,
          measurements: belegt[tag]?[band] ?? const [],
        ),
  ];

  final ersterTag = ms.first.measuredAt;
  final ohneErsten = [
    for (final m in ms)
      if (!_sameDay(m.measuredAt, ersterTag)) m,
  ];

  final nachBand = groupByBand(ms, raster);

  return MeasurementWeek(
    beginsAt: montag,
    measurements: List.unmodifiable(ms),
    measurementsWithoutFirstDay: List.unmodifiable(ohneErsten),
    fields: List.unmodifiable(felder),
    average: _mittel(ohneErsten),
    averageWithFirstDay: _mittel(ms),
    morningAverage: _mittel(nachBand[TimeBand.morgens] ?? const []),
    eveningAverage: _mittel(nachBand[TimeBand.abends] ?? const []),
  );
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
