// Export lokale DB -> Health Connect (M5). Die DB bleibt Source of Truth;
// exportiert wird ausschliesslich der vom Nutzer gewaehlte User-Slot
// (PLAN.md M5), weil Health Connect die Akte EINER Person ist.
import '../db/app_database.dart';
import '../db/measurement_repository.dart';
import 'health_sink.dart';

class ExportService {
  ExportService({required this.repository, required this.sink});

  final MeasurementRepository repository;
  final HealthSink sink;

  static String clientRecordIdFor(Measurement m) =>
      'sphygma-slot${m.userSlot}-seq${m.deviceSequence}';

  /// Schreibt alle noch nicht exportierten Messungen des Slots und markiert
  /// jede einzelne erst nach erfolgreichem Schreiben. Liefert die Anzahl.
  /// Scheitert die Senke, bleibt der betroffene Datensatz unexportiert und
  /// der Fehler wird durchgereicht.
  Future<int> exportPending({required int userSlot}) async {
    final pending = await repository.pendingExport(userSlot);
    var exported = 0;
    for (final m in pending) {
      await sink.writeBloodPressure(
        BloodPressureWrite(
          clientRecordId: clientRecordIdFor(m),
          systolic: m.systolic,
          diastolic: m.diastolic,
          pulse: m.pulse,
          measuredAt: m.measuredAt,
          movement: m.movement,
          arrhythmia: m.arrhythmia,
        ),
      );
      await repository.markExported([m.id], DateTime.now());
      exported++;
    }
    return exported;
  }
}
