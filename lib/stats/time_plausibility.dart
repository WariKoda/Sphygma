// Ist der Zeitstempel einer Messung glaubwürdig?
//
// Die Geräteuhr des HEM-6232T geht nachweislich falsch und lässt sich per
// Bluetooth weder stellen noch verlässlich lesen (docs/protocol/hem-6232t.md
// §8.2, §8.7). Die Messungsnummer dagegen kommt vom Zähler des Geräts, nicht
// von seiner Uhr — sie steigt monoton und ist damit die verlässlichere Achse.
//
// Daraus folgt die Prüfung: Wo der Zeitstempel der Ordnung der Nummern
// widerspricht, hat die Uhr falsch gestanden. Das ist rechenbar, also wird es
// gerechnet und nicht gespeichert.
//
// **Sphygma korrigiert nichts.** Diese Schicht stellt fest, mehr nicht. Ein
// verschobener Zeitstempel wäre schlimmer als ein erkennbar falscher: Er sähe
// aus wie eine Messung, ist aber eine Vermutung.
import '../db/app_database.dart';

/// Wie viel Vorlauf gegenüber der Telefonzeit noch als Gangungenauigkeit
/// durchgeht, bevor eine Messung als „aus der Zukunft" gilt.
const Duration _zukunftstoleranz = Duration(hours: 12);

/// Das Urteil über einen einzelnen Zeitstempel.
class TimestampVerdict {
  const TimestampVerdict.plausible()
      : isPlausible = true,
        reason = null;

  const TimestampVerdict.questionable(String this.reason) : isPlausible = false;

  final bool isPlausible;

  /// Warum der Zeitstempel fraglich ist — für die Anzeige beim Nutzer.
  /// Null genau dann, wenn nichts zu beanstanden ist.
  final String? reason;
}

/// Urteil über jeden Zeitstempel, aufgeschlüsselt nach Gerätenummer.
///
/// Eine Messung ist fraglich, wenn ihr Zeitstempel nicht zwischen die
/// Zeitstempel ihrer Nachbarn in der Nummernfolge passt — die Nummern steigen
/// monoton, also muss die Zeit es auch. Zusätzlich fraglich sind Zeitstempel
/// deutlich in der Zukunft.
///
/// Die erste und die letzte Messung haben nur einen Nachbarn. Für sie lässt
/// sich weniger beweisen, und sie gelten im Zweifel als plausibel: Ein
/// falscher Verdacht wäre schlimmer als ein übersehener, weil der Nutzer ihn
/// nicht widerlegen kann.
///
/// Wirft bei doppelten Gerätenummern. Die Nummer ist zusammen mit dem
/// Speicherplatz der Dedup-Schlüssel der Datenbank; doppelt kann sie nur sein,
/// wenn beim Einlesen etwas schiefgegangen ist.
Map<int, TimestampVerdict> judgeTimestamps(
  List<Measurement> measurements, {
  required DateTime now,
}) {
  final sortiert = [...measurements]
    ..sort((a, b) => a.deviceSequence.compareTo(b.deviceSequence));

  // Der Gerätezähler läuft je Speicherplatz: Nummer 500 auf Benutzer 1 und
  // Nummer 500 auf Benutzer 2 sind zwei verschiedene Messungen, und der
  // Dedup-Schlüssel der Datenbank ist entsprechend (userSlot, deviceSequence).
  // Ein Urteil über beide Plätze zugleich wäre bedeutungslos — die Zeitachse
  // eines Geräts hat nichts mit der des anderen zu tun.
  final slots = {for (final m in measurements) m.userSlot};
  if (slots.length > 1) {
    throw ArgumentError.value(
      slots.toList()..sort(),
      'measurements',
      'enthält mehrere Speicherplätze — die Zeitplausibilität gilt je Platz, '
          'weil der Gerätezähler je Platz läuft. Vorher nach Platz trennen.',
    );
  }

  for (var i = 1; i < sortiert.length; i++) {
    if (sortiert[i].deviceSequence == sortiert[i - 1].deviceSequence) {
      throw ArgumentError.value(
        sortiert[i].deviceSequence,
        'deviceSequence',
        'kommt innerhalb eines Speicherplatzes doppelt vor — zusammen mit '
            'dem Platz ist die Nummer der Dedup-Schlüssel und kann nur durch '
            'einen Fehler beim Einlesen doppelt sein',
      );
    }
  }

  // Welche Zeitstempel bilden zusammen eine stimmige Achse? Das ist die
  // längste Teilfolge, die in der Reihenfolge der Nummern auch zeitlich
  // aufsteigt. Alles außerhalb widerspricht der Mehrheit — und die Mehrheit
  // definiert, was als richtige Zeit gilt.
  //
  // Eine reine Nachbarschaftsprüfung reicht nicht: Liegen mehrere falsch
  // datierte Messungen hintereinander, sind beide Nachbarn Teil des Problems
  // und der Widerspruch fällt nicht auf.
  final stimmig = _longestConsistentRun(sortiert);

  final out = <int, TimestampVerdict>{};
  for (var i = 0; i < sortiert.length; i++) {
    final m = sortiert[i];
    if (m.measuredAt.isAfter(now.add(_zukunftstoleranz))) {
      out[m.deviceSequence] = const TimestampVerdict.questionable(
        'Der Zeitstempel liegt in der Zukunft.',
      );
    } else if (stimmig.contains(i)) {
      out[m.deviceSequence] = const TimestampVerdict.plausible();
    } else {
      out[m.deviceSequence] = const TimestampVerdict.questionable(
        'Der Zeitstempel passt nicht in die Reihenfolge der Messungsnummern — '
        'die Geräteuhr stand vermutlich falsch.',
      );
    }
  }
  return out;
}

/// Die Positionen der längsten zeitlich aufsteigenden Teilfolge.
///
/// Bei Gleichstand gewinnt die frühere Folge — das ist willkürlich, aber
/// deterministisch, und der Fall tritt nur auf, wenn genau die Hälfte der
/// Messungen falsch datiert ist. Dann hilft ohnehin nur der Blick aufs Gerät.
Set<int> _longestConsistentRun(List<Measurement> sortiert) {
  if (sortiert.isEmpty) return const {};

  final laenge = List<int>.filled(sortiert.length, 1);
  final vorgaenger = List<int>.filled(sortiert.length, -1);

  for (var i = 1; i < sortiert.length; i++) {
    for (var j = 0; j < i; j++) {
      if (!sortiert[i].measuredAt.isBefore(sortiert[j].measuredAt) &&
          laenge[j] + 1 > laenge[i]) {
        laenge[i] = laenge[j] + 1;
        vorgaenger[i] = j;
      }
    }
  }

  var beste = 0;
  for (var i = 1; i < sortiert.length; i++) {
    if (laenge[i] > laenge[beste]) beste = i;
  }

  final out = <int>{};
  for (var i = beste; i != -1; i = vorgaenger[i]) {
    out.add(i);
  }
  return out;
}

/// Geht die Uhr des Geräts falsch?
///
/// Maßgeblich ist die **zuletzt gemessene** Messung, und das ist die mit der
/// höchsten Gerätenummer — nicht die mit dem spätesten Datum. Genau darin
/// liegt der Fall: Bei falscher Uhr trägt die frischeste Messung ein altes
/// Datum und stünde in einer nach Datum sortierten Liste weit hinten.
bool deviceClockLooksWrong(
  List<Measurement> measurements, {
  required DateTime now,
}) {
  if (measurements.isEmpty) return false;

  final slots = {for (final m in measurements) m.userSlot};
  if (slots.length > 1) {
    throw ArgumentError.value(
      slots.toList()..sort(),
      'measurements',
      'enthält mehrere Speicherplätze — die höchste Gerätenummer wäre über '
          'zwei Zähler hinweg nicht aussagekräftig. Vorher nach Platz trennen.',
    );
  }

  var neueste = measurements.first;
  for (final m in measurements) {
    if (m.deviceSequence > neueste.deviceSequence) neueste = m;
  }

  return neueste.measuredAt.isAfter(now.add(const Duration(days: 1))) ||
      neueste.measuredAt.isBefore(now.subtract(const Duration(days: 365)));
}

/// Die Messungen, deren Zeitstempel fraglich ist — für Hinweise und Berichte.
List<Measurement> questionableTimestamps(
  List<Measurement> measurements, {
  required DateTime now,
}) {
  final urteil = judgeTimestamps(measurements, now: now);
  return [
    for (final m in measurements)
      if (urteil[m.deviceSequence]?.isPlausible == false) m,
  ];
}
