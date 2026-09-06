// Tageszeit als Ordnungsgröße — gemeinsame Grundlage mehrerer Konzepte.
//
// „Sieben Tage" braucht die grobe Teilung morgens/abends, um die vierzehn
// Felder einer Messwoche zu belegen. „Tagesprofil" braucht die feine, weil
// die Tageszeit dort die Zugangsachse ist. Beide kommen aus derselben Quelle;
// sonst driften sie auseinander, sobald jemand eine Grenze verschiebt.
//
// Die Grenzen sind einstellbar. Wer im Schichtdienst arbeitet, hat einen
// anderen Morgen als der Rest.
import '../db/app_database.dart';
import 'trend_stats.dart';

/// Ein Zeitpunkt innerhalb eines Tages, ohne Datum.
///
/// Wirft bei Werten außerhalb eines Tages: Eine Grenze bei „24:00" oder
/// „12:60" ist ein Programmierfehler und darf nicht stillschweigend auf
/// Mitternacht zusammenfallen.
class TimeOfDayMinutes implements Comparable<TimeOfDayMinutes> {
  TimeOfDayMinutes(this.hour, this.minute) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'muss zwischen 0 und 23 liegen');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(minute, 'minute', 'muss zwischen 0 und 59 liegen');
    }
  }

  final int hour;
  final int minute;

  /// Minuten seit Mitternacht — die Rechengröße hinter allen Vergleichen.
  int get sinceMidnight => hour * 60 + minute;

  static TimeOfDayMinutes of(DateTime at) =>
      TimeOfDayMinutes(at.hour, at.minute);

  @override
  int compareTo(TimeOfDayMinutes other) =>
      sinceMidnight.compareTo(other.sinceMidnight);

  @override
  bool operator ==(Object other) =>
      other is TimeOfDayMinutes && other.sinceMidnight == sinceMidnight;

  @override
  int get hashCode => sinceMidnight.hashCode;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Die Abschnitte, in die ein Tag zerfallen kann.
///
/// Nicht jedes Raster nutzt alle: Die grobe Teilung kennt nur `morgens` und
/// `abends`, weil die Messwoche genau zwei Felder je Tag hat.
enum TimeBand {
  nachts('Nachts'),
  morgens('Morgens'),
  vormittags('Vormittags'),
  nachmittags('Nachmittags'),
  abends('Abends');

  const TimeBand(this.label);

  final String label;
}

/// Eine Grenze: Ab diesem Zeitpunkt gilt dieser Abschnitt.
class BandBoundary {
  const BandBoundary(this.from, this.band);

  final TimeOfDayMinutes from;
  final TimeBand band;
}

/// Ein Raster aus Grenzen, das den Tag lückenlos aufteilt.
///
/// Der Abschnitt der letzten Grenze läuft über Mitternacht hinaus bis zur
/// ersten — deshalb ist die Nacht als einziger Abschnitt zusammenhängend,
/// obwohl sie den Tageswechsel überspannt.
class BandGrid {
  BandGrid(this.boundaries) {
    if (boundaries.isEmpty) {
      throw ArgumentError.value(
        boundaries,
        'boundaries',
        'ein Raster ohne Grenzen teilt nichts — mindestens eine wird gebraucht',
      );
    }
    for (var i = 1; i < boundaries.length; i++) {
      if (boundaries[i].from.compareTo(boundaries[i - 1].from) <= 0) {
        throw ArgumentError.value(
          boundaries,
          'boundaries',
          'Grenzen müssen aufsteigend und verschieden sein: '
              '${boundaries[i - 1].from} vor ${boundaries[i].from}',
        );
      }
    }
  }

  final List<BandBoundary> boundaries;

  /// Fünf Abschnitte, wie „Tagesprofil" sie braucht.
  static final BandGrid fein = BandGrid([
    BandBoundary(TimeOfDayMinutes(6, 0), TimeBand.morgens),
    BandBoundary(TimeOfDayMinutes(10, 0), TimeBand.vormittags),
    BandBoundary(TimeOfDayMinutes(12, 0), TimeBand.nachmittags),
    BandBoundary(TimeOfDayMinutes(18, 0), TimeBand.abends),
    BandBoundary(TimeOfDayMinutes(23, 0), TimeBand.nachts),
  ]);

  /// Zwei Abschnitte, wie „Sieben Tage" sie für die vierzehn Felder braucht.
  static final BandGrid grob = grobMit(schnitt: TimeOfDayMinutes(12, 0));

  /// Die grobe Teilung mit verschobenem Schnitt — für Schichtdienst.
  static BandGrid grobMit({required TimeOfDayMinutes schnitt}) {
    if (schnitt.sinceMidnight == 0) {
      throw ArgumentError.value(
        schnitt,
        'schnitt',
        'ein Schnitt um Mitternacht ergibt nur einen Abschnitt',
      );
    }
    return BandGrid([
      BandBoundary(TimeOfDayMinutes(0, 0), TimeBand.morgens),
      BandBoundary(schnitt, TimeBand.abends),
    ]);
  }

  /// Der Abschnitt, in den dieser Zeitpunkt fällt.
  TimeBand bandAt(TimeOfDayMinutes at) {
    BandBoundary treffer = boundaries.last;
    for (final b in boundaries) {
      if (at.compareTo(b.from) >= 0) {
        treffer = b;
      } else {
        break;
      }
    }
    return treffer.band;
  }

  /// Die Abschnitte dieses Rasters in der Reihenfolge des Tages.
  List<TimeBand> get bands => [for (final b in boundaries) b.band];
}

/// Messungen nach Tagesabschnitt, älteste zuerst je Abschnitt.
///
/// Leere Abschnitte fehlen in der Rückgabe. Ein Abschnitt ohne Messungen ist
/// kein Abschnitt mit einer leeren Liste — der Unterschied fällt auf, sobald
/// jemand daraus einen Mittelwert bilden will.
Map<TimeBand, List<Measurement>> groupByBand(
  List<Measurement> measurements,
  BandGrid grid,
) {
  final out = <TimeBand, List<Measurement>>{};
  for (final m in measurements) {
    final band = grid.bandAt(TimeOfDayMinutes.of(m.measuredAt));
    out.putIfAbsent(band, () => []).add(m);
  }
  for (final liste in out.values) {
    liste.sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
  }
  return out;
}

/// Mittelwerte je Tagesabschnitt. Abschnitte ohne Messungen fehlen.
Map<TimeBand, Average> averagesByBand(
  List<Measurement> measurements,
  BandGrid grid,
) {
  final out = <TimeBand, Average>{};
  groupByBand(measurements, grid).forEach((band, ms) {
    final mittel = Average.of([
      for (final m in ms)
        Reading(
          measuredAt: m.measuredAt,
          systolic: m.systolic,
          diastolic: m.diastolic,
          pulse: m.pulse,
        ),
    ]);
    if (mittel != null) out[band] = mittel;
  });
  return out;
}
