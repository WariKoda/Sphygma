// Was gehört zu einem Messen?
//
// Wer nach Leitlinie misst, misst zweimal hintereinander. Heute stehen daraus
// zwei gleichberechtigte Einträge in der Liste, und der erste ist meist der
// schlechtere — der Körper hat sich noch nicht beruhigt. Ein Messanlass fasst
// zusammen, was zusammengehört: ein Ergebnis, mehrere Rohwerte darunter.
//
// Diese Schicht **schlägt vor**, sie entscheidet nicht. Grenzfälle bleiben
// offen und werden gemeldet, statt still gruppiert oder still getrennt zu
// werden — ein falsch gebildeter Mittelwert sähe aus wie eine Messung, wäre
// aber eine Vermutung. Bestätigte Entscheidungen des Nutzers überstimmen den
// Vorschlag; ihre Speicherung gehört in die Persistenzschicht.
import '../db/app_database.dart';
import 'trend_stats.dart';

/// Bis zu diesem Abstand gehören zwei Messungen sicher zusammen.
const Duration _sicherZusammen = Duration(minutes: 10);

/// Ab diesem Abstand gehören sie sicher nicht zusammen. Dazwischen liegt der
/// Graubereich, in dem der Nutzer gefragt wird.
const Duration _sicherGetrennt = Duration(minutes: 30);

/// Woher die Gruppierung eines Anlasses stammt.
enum OccasionState {
  /// Regel und Daten sind eindeutig.
  sicher('Sicher'),

  /// Der Abstand liegt im Graubereich — der Nutzer soll entscheiden.
  zuPruefen('Zu prüfen'),

  /// Der Nutzer hat entschieden.
  bestaetigt('Bestätigt');

  const OccasionState(this.label);

  final String label;
}

/// Ein Messanlass: eine oder mehrere Rohmessungen mit einem Ergebnis.
class MeasurementOccasion {
  MeasurementOccasion({
    required this.measurements,
    required this.usedMeasurements,
    required this.result,
    required this.state,
    required this.rule,
  });

  /// Alle Rohmessungen dieses Anlasses, älteste zuerst.
  final List<Measurement> measurements;

  /// Die Messungen, die in das Ergebnis eingeflossen sind.
  final List<Measurement> usedMeasurements;

  /// Das Ergebnis dieses Anlasses.
  final Average result;

  final OccasionState state;

  /// Wie das Ergebnis zustande kam — im Klartext, für die Anzeige.
  /// Ein Wert, dessen Herkunft man nicht nachlesen kann, ist keine Messung.
  final String rule;

  /// Die Gerätenummer, unter der dieser Anlass geführt wird: die erste.
  int get sequence => measurements.first.deviceSequence;

  bool get hasMovement => measurements.any((m) => m.movement);
  bool get hasArrhythmia => measurements.any((m) => m.arrhythmia);
}

/// Vorschläge, welche Messungen zu einem Anlass gehören.
///
/// Zwei Messungen gehören zusammen, wenn ihre Gerätenummern aufeinander folgen
/// **und** sie zeitlich nah beieinander liegen. Beides muss stimmen: Eine
/// Lücke in der Nummernfolge bedeutet, dass dazwischen gemessen wurde, und
/// darüber hinweg zu mitteln wäre falsch.
///
/// [confirmedJoins] und [confirmedSplits] tragen die Gerätenummern, für die
/// der Nutzer bereits entschieden hat: Die Messung wird an ihren Vorgänger
/// angeschlossen beziehungsweise von ihm getrennt. Sie überstimmen die Regel.
List<MeasurementOccasion> proposeOccasions(
  List<Measurement> measurements, {
  Set<int> confirmedJoins = const {},
  Set<int> confirmedSplits = const {},
}) {
  if (measurements.isEmpty) return const [];

  final slots = {for (final m in measurements) m.userSlot};
  if (slots.length > 1) {
    throw ArgumentError.value(
      slots.toList()..sort(),
      'measurements',
      'enthält mehrere Speicherplätze — der Gerätezähler läuft je Platz, '
          'anlassweise Gruppierung über Plätze hinweg wäre sinnlos',
    );
  }

  final widerspruch = confirmedJoins.intersection(confirmedSplits);
  if (widerspruch.isNotEmpty) {
    throw ArgumentError.value(
      widerspruch.toList()..sort(),
      'confirmedJoins/confirmedSplits',
      'dieselbe Messung kann nicht zugleich angeschlossen und getrennt sein',
    );
  }

  final sortiert = [...measurements]
    ..sort((a, b) => a.deviceSequence.compareTo(b.deviceSequence));

  final gruppen = <List<Measurement>>[];
  final zustaende = <OccasionState>[];
  var aktuell = <Measurement>[sortiert.first];
  var aktuellerZustand = OccasionState.sicher;

  for (var i = 1; i < sortiert.length; i++) {
    final vorher = sortiert[i - 1];
    final jetzt = sortiert[i];
    final entscheidung = _decide(vorher, jetzt, confirmedJoins, confirmedSplits);

    if (entscheidung.zusammen) {
      aktuell.add(jetzt);
      aktuellerZustand = _staerker(aktuellerZustand, entscheidung.state);
    } else {
      // Eine bestätigte Trennung betrifft beide Seiten: Der abgeschlossene
      // Anlass endet hier, weil der Nutzer es so entschieden hat, und trägt
      // das genauso wie der neu beginnende.
      gruppen.add(aktuell);
      zustaende.add(_staerker(aktuellerZustand, entscheidung.state));
      aktuell = [jetzt];
      aktuellerZustand = entscheidung.state == OccasionState.bestaetigt
          ? OccasionState.bestaetigt
          : OccasionState.sicher;
    }
  }
  gruppen.add(aktuell);
  zustaende.add(aktuellerZustand);

  return [
    for (var i = 0; i < gruppen.length; i++) _build(gruppen[i], zustaende[i]),
  ];
}

class _Decision {
  const _Decision(this.zusammen, this.state);
  final bool zusammen;
  final OccasionState state;
}

_Decision _decide(
  Measurement vorher,
  Measurement jetzt,
  Set<int> joins,
  Set<int> splits,
) {
  if (splits.contains(jetzt.deviceSequence)) {
    return const _Decision(false, OccasionState.bestaetigt);
  }
  if (joins.contains(jetzt.deviceSequence)) {
    return const _Decision(true, OccasionState.bestaetigt);
  }

  // Eine Lücke in der Nummernfolge trennt immer: Dazwischen wurde gemessen.
  if (jetzt.deviceSequence != vorher.deviceSequence + 1) {
    return const _Decision(false, OccasionState.sicher);
  }

  final abstand = jetzt.measuredAt.difference(vorher.measuredAt).abs();
  if (abstand <= _sicherZusammen) {
    return const _Decision(true, OccasionState.sicher);
  }
  if (abstand >= _sicherGetrennt) {
    return const _Decision(false, OccasionState.sicher);
  }
  // Graubereich: getrennt vorgeschlagen, aber zur Prüfung gemeldet.
  return const _Decision(false, OccasionState.zuPruefen);
}

/// „Zu prüfen" schlägt „sicher": Sobald ein Übergang unklar ist, ist es der
/// ganze Anlass. „Bestätigt" schlägt beides — der Nutzer hat gesprochen.
OccasionState _staerker(OccasionState a, OccasionState b) {
  if (a == OccasionState.bestaetigt || b == OccasionState.bestaetigt) {
    return OccasionState.bestaetigt;
  }
  if (a == OccasionState.zuPruefen || b == OccasionState.zuPruefen) {
    return OccasionState.zuPruefen;
  }
  return OccasionState.sicher;
}

MeasurementOccasion _build(List<Measurement> gruppe, OccasionState state) {
  // Bewegung während der Messung macht den Wert unzuverlässig — solche
  // Messungen fallen aus dem Ergebnis. Trügen alle das Kennzeichen, bliebe
  // nichts übrig; dann zählen alle, mit einem Hinweis darauf.
  final ohneBewegung = [for (final m in gruppe) if (!m.movement) m];
  final genutzt = ohneBewegung.isEmpty ? gruppe : ohneBewegung;

  final regel = gruppe.length == 1
      ? 'Einzelne Messung.'
      : ohneBewegung.isEmpty
          ? 'Mittel über alle ${gruppe.length} Messungen — jede trägt das '
              'Bewegungskennzeichen, deshalb bleibt keine übrig.'
          : genutzt.length == gruppe.length
              ? 'Mittel über alle ${gruppe.length} Messungen.'
              : 'Mittel über ${genutzt.length} von ${gruppe.length} Messungen, '
                  'ohne Bewegung.';

  final ergebnis = Average.of([
    for (final m in genutzt)
      Reading(
        measuredAt: m.measuredAt,
        systolic: m.systolic,
        diastolic: m.diastolic,
        pulse: m.pulse,
      ),
  ]);
  if (ergebnis == null) {
    throw StateError(
      'Ein Anlass ohne Messungen kann nicht entstehen — die Gruppierung '
      'legt jede Gruppe mit mindestens einer Messung an',
    );
  }

  return MeasurementOccasion(
    measurements: List.unmodifiable(gruppe),
    usedMeasurements: List.unmodifiable(genutzt),
    result: ergebnis,
    state: state,
    rule: regel,
  );
}
