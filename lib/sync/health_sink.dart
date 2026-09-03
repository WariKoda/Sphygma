// Senke fuer den Export nach Health Connect. Das Interface haelt die
// Export-Logik testbar; die Health-Connect-Anbindung selbst ist duennes
// Glue (health_connect_sink.dart).

/// Ein Blutdruck-Datensatz, wie er an Health Connect gehen soll.
class BloodPressureWrite {
  BloodPressureWrite({
    required this.clientRecordId,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.measuredAt,
    required this.movement,
    required this.arrhythmia,
  });

  /// Deterministisch aus Slot und Messungsnummer - Health Connect
  /// dedupliziert damit selbst (PLAN.md §4.1).
  final String clientRecordId;
  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime measuredAt;
  final bool movement;
  final bool arrhythmia;
}

abstract class HealthSink {
  /// Schreibt Blutdruck und Puls. Wirft bei jedem Fehler - ein stiller
  /// Teilerfolg wuerde die Export-Buchfuehrung verfaelschen.
  Future<void> writeBloodPressure(BloodPressureWrite write);
}
