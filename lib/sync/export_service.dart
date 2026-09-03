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
  Future<int> exportPending({required int userSlot, int? limit}) async {
    var pending = await repository.pendingExport(userSlot);
    if (limit != null) {
      pending = pending.take(limit).toList();
    }
    var exported = 0;
    for (final m in pending) {
      await exportOne(m);
      exported++;
    }
    return exported;
  }

  /// Entfernt alle von Sphygma exportierten Messungen des Slots wieder aus
  /// der Senke und hebt die Markierung auf. Liefert die Anzahl.
  Future<int> retractExported({required int userSlot}) async {
    final exported = await repository.exported(userSlot);
    var retracted = 0;
    for (final m in exported) {
      await retractOne(m);
      retracted++;
    }
    return retracted;
  }

  /// Exportiert genau diese Messung.
  Future<void> exportOne(Measurement m) async {
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
  }

  /// Entfernt genau diese Messung aus der Senke.
  Future<void> retractOne(Measurement m) async {
    await sink.deleteBloodPressure(clientRecordIdFor(m));
    await repository.markUnexported([m.id]);
  }
}
