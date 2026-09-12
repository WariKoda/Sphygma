import '../stats/measurement_metadata.dart';
import 'plan_models.dart';

const Duration occurrenceMatchingWindow = Duration(minutes: 15);

Map<String, MeasurementKey> matchOccurrences(
  List<TimedMeasurement> measurements,
  List<PlannedOccurrence> occurrences, {
  required Map<MeasurementKey, String?> manualAssignments,
}) {
  final measurementsByKey = _uniqueMeasurements(measurements);
  final occurrencesByKey = _uniqueOccurrences(occurrences);
  _validateManualAssignments(
    manualAssignments,
    measurementsByKey,
    occurrencesByKey,
  );

  final matches = <String, MeasurementKey>{};
  for (final assignment in manualAssignments.entries) {
    final occurrenceKey = assignment.value;
    if (occurrenceKey != null) {
      matches[occurrenceKey] = assignment.key;
    }
  }

  final candidatesByOccurrence = <String, List<_Candidate>>{};
  for (final measurement in measurements) {
    if (!measurement.plausible ||
        manualAssignments.containsKey(measurement.key)) {
      continue;
    }

    _Candidate? nearest;
    for (final occurrence in occurrences) {
      if (occurrence.userSlot != measurement.key.userSlot ||
          occurrence.timeAmbiguous) {
        continue;
      }
      final candidate = _candidate(measurement, occurrence);
      if (candidate.distance > occurrenceMatchingWindow) continue;
      if (nearest == null || _compareForMeasurement(candidate, nearest) < 0) {
        nearest = candidate;
      }
    }
    if (nearest != null) {
      candidatesByOccurrence
          .putIfAbsent(nearest.occurrence.key, () => [])
          .add(nearest);
    }
  }

  for (final occurrence in occurrences) {
    if (matches.containsKey(occurrence.key)) continue;
    final candidates = candidatesByOccurrence[occurrence.key];
    if (candidates == null) continue;
    candidates.sort(_compareForOccurrence);
    matches[occurrence.key] = candidates.first.measurement.key;
  }
  return matches;
}

Map<MeasurementKey, TimedMeasurement> _uniqueMeasurements(
  List<TimedMeasurement> measurements,
) {
  final byKey = <MeasurementKey, TimedMeasurement>{};
  for (final measurement in measurements) {
    if (byKey.containsKey(measurement.key)) {
      throw ArgumentError.value(
        measurement.key,
        'measurements',
        'enthält einen doppelten Messungsschlüssel',
      );
    }
    byKey[measurement.key] = measurement;
  }
  return byKey;
}

Map<String, PlannedOccurrence> _uniqueOccurrences(
  List<PlannedOccurrence> occurrences,
) {
  final byKey = <String, PlannedOccurrence>{};
  for (final occurrence in occurrences) {
    if (byKey.containsKey(occurrence.key)) {
      throw ArgumentError.value(
        occurrence.key,
        'occurrences',
        'enthält einen doppelten Terminschlüssel',
      );
    }
    byKey[occurrence.key] = occurrence;
  }
  return byKey;
}

void _validateManualAssignments(
  Map<MeasurementKey, String?> assignments,
  Map<MeasurementKey, TimedMeasurement> measurements,
  Map<String, PlannedOccurrence> occurrences,
) {
  final assignedOccurrences = <String>{};
  for (final assignment in assignments.entries) {
    final measurement = measurements[assignment.key];
    if (measurement == null) {
      throw ArgumentError.value(
        assignment.key,
        'manualAssignments',
        'verweist auf keine vorhandene Messung',
      );
    }
    final occurrenceKey = assignment.value;
    if (occurrenceKey == null) continue;
    final occurrence = occurrences[occurrenceKey];
    if (occurrence == null) {
      throw ArgumentError.value(
        occurrenceKey,
        'manualAssignments',
        'verweist auf keinen vorhandenen Termin',
      );
    }
    if (measurement.key.userSlot != occurrence.userSlot) {
      throw ArgumentError.value(
        occurrenceKey,
        'manualAssignments',
        'Messung und Termin gehören zu verschiedenen Speicherplätzen',
      );
    }
    if (!assignedOccurrences.add(occurrenceKey)) {
      throw ArgumentError.value(
        occurrenceKey,
        'manualAssignments',
        'mehrere Messungen dürfen nicht denselben Termin belegen',
      );
    }
  }
}

_Candidate _candidate(
  TimedMeasurement measurement,
  PlannedOccurrence occurrence,
) {
  final measured = measurement.localTime;
  final measurementCivil = DateTime.utc(
    measured.year,
    measured.month,
    measured.day,
    measured.hour,
    measured.minute,
    measured.second,
    measured.millisecond,
    measured.microsecond,
  );
  final date = parseLocalDate(occurrence.localDate);
  final occurrenceCivil = DateTime.utc(
    date.year,
    date.month,
    date.day,
    occurrence.minuteOfDay ~/ 60,
    occurrence.minuteOfDay % 60,
  );
  return _Candidate(
    measurement: measurement,
    occurrence: occurrence,
    measurementCivil: measurementCivil,
    occurrenceCivil: occurrenceCivil,
    distance: measurementCivil.difference(occurrenceCivil).abs(),
  );
}

int _compareForMeasurement(_Candidate left, _Candidate right) {
  final byDistance = left.distance.compareTo(right.distance);
  if (byDistance != 0) return byDistance;
  final byOccurrenceTime = left.occurrenceCivil.compareTo(
    right.occurrenceCivil,
  );
  if (byOccurrenceTime != 0) return byOccurrenceTime;
  return left.occurrence.key.compareTo(right.occurrence.key);
}

int _compareForOccurrence(_Candidate left, _Candidate right) {
  final byDistance = left.distance.compareTo(right.distance);
  if (byDistance != 0) return byDistance;
  final byMeasurementTime = left.measurementCivil.compareTo(
    right.measurementCivil,
  );
  if (byMeasurementTime != 0) return byMeasurementTime;
  return left.measurement.key.deviceSequence.compareTo(
    right.measurement.key.deviceSequence,
  );
}

class _Candidate {
  const _Candidate({
    required this.measurement,
    required this.occurrence,
    required this.measurementCivil,
    required this.occurrenceCivil,
    required this.distance,
  });

  final TimedMeasurement measurement;
  final PlannedOccurrence occurrence;
  final DateTime measurementCivil;
  final DateTime occurrenceCivil;
  final Duration distance;
}
