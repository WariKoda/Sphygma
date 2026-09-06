// Welche Messung zu welchem Lebensabschnitt gehört.
//
// Die Zuordnung ist abgeleitet, nicht gespeichert: Eine Messung fällt in die
// Phase, deren Zeitraum sie enthält. Gespeichert wird nur, wo der Mensch
// entschieden hat — und das überstimmt den Zeitraum.
//
// Der wunde Punkt dieses Konzepts ist die Geräteuhr. Eine Messung mit
// unglaubwürdigem Datum wird **nicht** über ihren Zeitstempel zugeordnet,
// sondern bleibt ungeklärt und nimmt an keinem Vergleich teil. Sie still in
// die laufende Phase fallen zu lassen hieße, den Vergleich auf eine erfundene
// Zeitachse zu stellen.
import '../db/app_database.dart';
import 'time_plausibility.dart';
import 'trend_stats.dart';

/// Eine Phase mit den Messungen, die zu ihr gehören.
class PhaseMembership {
  PhaseMembership({required this.phase, required List<Measurement> measurements})
      : measurements = List.unmodifiable(measurements);

  final Phase phase;

  /// Älteste zuerst.
  final List<Measurement> measurements;

  int get count => measurements.length;

  Average? get average => Average.of([
        for (final m in measurements)
          Reading(
            measuredAt: m.measuredAt,
            systolic: m.systolic,
            diastolic: m.diastolic,
            pulse: m.pulse,
          ),
      ]);
}

/// Das Ergebnis der Zuordnung — vollständig, ohne Restmenge.
///
/// Jede Messung steht in genau einer der drei Listen. „Nicht zugeordnet" und
/// „ungeklärt" sind echte Bestände, keine stillen Reste: Der Nutzer soll
/// sehen, wie viel außerhalb seiner Phasen liegt.
class PhaseGrouping {
  PhaseGrouping({
    required this.memberships,
    required List<Measurement> unassigned,
    required List<Measurement> unclear,
  })  : unassigned = List.unmodifiable(unassigned),
        unclear = List.unmodifiable(unclear);

  /// Neueste Phase zuerst.
  final List<PhaseMembership> memberships;

  /// Zeitlich außerhalb jeder Phase — oder vom Nutzer ausdrücklich
  /// herausgenommen.
  final List<Measurement> unassigned;

  /// Der Zeitstempel taugt nicht zur Zuordnung, und niemand hat entschieden.
  final List<Measurement> unclear;

  int get total =>
      memberships.fold<int>(0, (s, m) => s + m.count) +
      unassigned.length +
      unclear.length;
}

PhaseGrouping groupByPhase(
  List<Measurement> measurements, {
  required List<Phase> phases,
  required Map<int, int?> assignments,
  required DateTime now,
}) {
  final fraglich = {
    for (final m in questionableTimestamps(measurements, now: now))
      m.deviceSequence,
  };

  final nachPhase = <int, List<Measurement>>{
    for (final p in phases) p.id: <Measurement>[],
  };
  final ohne = <Measurement>[];
  final ungeklaert = <Measurement>[];

  final sortiert = [...measurements]
    ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

  for (final m in sortiert) {
    if (assignments.containsKey(m.deviceSequence)) {
      final id = assignments[m.deviceSequence];
      // Eine Entscheidung auf eine gelöschte Phase ist keine Zuordnung mehr.
      if (id != null && nachPhase.containsKey(id)) {
        nachPhase[id]!.add(m);
      } else {
        ohne.add(m);
      }
      continue;
    }

    if (fraglich.contains(m.deviceSequence)) {
      ungeklaert.add(m);
      continue;
    }

    final treffer = _phaseFuer(m.measuredAt, phases);
    if (treffer == null) {
      ohne.add(m);
    } else {
      nachPhase[treffer.id]!.add(m);
    }
  }

  final sortierte = [...phases]
    ..sort((a, b) => b.beginsAt.compareTo(a.beginsAt));

  return PhaseGrouping(
    memberships: [
      for (final p in sortierte)
        PhaseMembership(phase: p, measurements: nachPhase[p.id]!),
    ],
    unassigned: ohne,
    unclear: ungeklaert,
  );
}

/// Die Phase, in deren Zeitraum [at] fällt.
///
/// Überschneiden sich zwei Phasen, gewinnt die zuletzt begonnene: Dieses
/// Konzept erlaubt genau eine primäre Phase je Messung, sonst ginge dieselbe
/// Messung in konkurrierende Vergleiche ein. „Urlaub" während „Ramipril"
/// schlägt damit den laufenden Abschnitt — die speziellere Aussage gewinnt.
Phase? _phaseFuer(DateTime at, List<Phase> phases) {
  Phase? beste;
  for (final p in phases) {
    if (at.isBefore(p.beginsAt)) continue;
    final ende = p.endsAt;
    if (ende != null && !at.isBefore(ende)) continue;
    if (beste == null || p.beginsAt.isAfter(beste.beginsAt)) beste = p;
  }
  return beste;
}
