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

/// Eine Senke, die Schreibrechte kennt und danach gefragt werden kann.
///
/// Getrennt von [HealthSink], damit einfache Senken — etwa in Tests — davon
/// unberührt bleiben: Wer keine Rechte kennt, schreibt einfach.
///
/// Der **automatische** Export fragt hier nach, bevor er etwas versucht. Ein
/// Berechtigungsdialog, der von selbst aufgeht, während der Nutzer etwas
/// anderes tut, ist eine Zumutung — und er käme im ungünstigsten Fall nach
/// jeder Messung. Der Knopf von Hand fragt weiterhin.
abstract class PermissionAwareSink {
  /// Ob bereits geschrieben werden darf, **ohne zu fragen** — und wenn
  /// nicht, warum.
  Future<SinkReadiness> readiness();
}

/// Warum der automatische Export gerade nicht schreiben kann.
///
/// Die Unterscheidung ist kein Detail: „Erteile die Berechtigung" hilft
/// nicht, wenn Health Connect gar nicht installiert ist, und schickt den
/// Nutzer auf einen Weg, an dessen Ende nichts steht.
enum SinkReadiness {
  /// Es darf geschrieben werden.
  bereit,

  /// Die Rechte fehlen. Ein Export von Hand erteilt sie.
  keineRechte,

  /// Health Connect fehlt oder braucht ein Update. Von Hand hilft nicht.
  nichtVerfuegbar,

  /// Die Abfrage selbst ist gescheitert — Grund unbekannt.
  unklar;

  /// Was dem Nutzer dazu zu sagen ist, oder null, wenn alles bereit ist.
  String? get erklaerung => switch (this) {
    bereit => null,
    keineRechte =>
      'Health Connect hat keine Schreibrechte. Einmal von Hand übertragen '
          'erteilt sie.',
    nichtVerfuegbar =>
      'Health Connect ist auf diesem Gerät nicht verfügbar oder braucht ein '
          'Update.',
    unklar => 'Health Connect ließ sich nicht abfragen.',
  };
}

abstract class HealthSink {
  /// Schreibt Blutdruck und Puls. Wirft bei jedem Fehler - ein stiller
  /// Teilerfolg wuerde die Export-Buchfuehrung verfaelschen.
  Future<void> writeBloodPressure(BloodPressureWrite write);

  /// Loescht Blutdruck und Puls mit dieser [clientRecordId] wieder aus der
  /// Senke. Health Connect erlaubt das nur fuer eigene Datensaetze - genau
  /// die, die Sphygma geschrieben hat.
  Future<void> deleteBloodPressure(String clientRecordId);
}
