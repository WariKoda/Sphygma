// F4 — „Einordnung des Werts" — muss in **jedem** Konzept erscheinen.
//
// Das Funktionsraster (docs/design/funktionsraster.md) führt fünfzehn
// Funktionen, die jedes Konzept abdecken muss. Bis zum 06.09.2026 prüfte das
// niemand: Es gab einen Test für ClassificationScale als Widget, aber keinen
// dafür, dass sie in einem Bildschirm auftaucht. Genau deshalb fehlte sie in
// „Sieben Tage", „Messanlass" und „Phase", ohne dass ein Test rot wurde.
//
// Der Test prüft **beide** Zustände des Compile-Time-Flags, denn beide sind
// Zusagen:
//   * mit SPHYGMA_ESC=true muss die Einordnung da sein (Funktionsraster),
//   * ohne das Flag darf sie nirgends erscheinen (PLAN.md §3.2, MDR).
// Ausgeführt wird er in beiden Modi:
//   flutter test
//   flutter test --dart-define=SPHYGMA_ESC=true
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/app/concept.dart';
import 'package:sphygma/app/feature_flags.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/occasion_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/sphygma_app.dart';
import 'package:sphygma/ui/widgets/classification_scale.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _rec(int seq, DateTime at, {int sys = 148, int dia = 94}) =>
    SlotRecord(
      userSlot: 1,
      record: BloodPressureRecord(
        systolic: sys,
        diastolic: dia,
        pulse: 78,
        timestamp: at,
        arrhythmiaFlag: false,
        movementFlag: false,
        sequence: seq,
      ),
      rawBytes: Uint8List(14),
    );

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    keyStore = InMemoryPairingKeyStore();
    await keyStore.save(Uint8List(16));
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      occasionRepository: OccasionRepository(db),
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    await controller.setUserSlot(1);
    // Ohne laufende Phase zeigt das Konzept „Phase" keinen Wert — und ohne
    // Wert gibt es nichts einzuordnen. Das ist richtig so; der Test muss ihm
    // deshalb einen Lebensabschnitt geben.
    await OccasionRepository(db).startPhase(
      name: 'Testabschnitt',
      anchor: PhaseAnchor.bestaetigt,
      begin: DateTime.now().subtract(const Duration(days: 30)),
    );

    // Werte im Bluthochdruckbereich, damit die Einordnung etwas zu sagen hat.
    final jetzt = DateTime.now();
    await repository.importAll([
      _rec(1, jetzt.subtract(const Duration(days: 2, hours: 12)), sys: 152),
      _rec(2, jetzt.subtract(const Duration(days: 2, hours: 2)), sys: 146),
      _rec(3, jetzt.subtract(const Duration(days: 1, hours: 12)), sys: 149),
      _rec(4, jetzt.subtract(const Duration(hours: 3)), sys: 147),
    ]);
    await controller.refreshForTest();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  for (final k in allConcepts) {
    testWidgets('${k.name}: die Einordnung folgt dem Flag', (tester) async {
      await controller.setConcept(k);
      await tester.pumpWidget(SphygmaApp(controller: controller));
      await tester.pumpAndSettle();

      if (escClassificationEnabled) {
        expect(
          find.byType(ClassificationScale),
          findsWidgets,
          reason: 'Konzept ${k.name} zeigt keine Einordnung — F4 fehlt',
        );
      } else {
        expect(
          find.byType(ClassificationScale),
          findsNothing,
          reason: 'Ohne SPHYGMA_ESC darf ${k.name} nichts klassifizieren '
              '(PLAN.md §3.2)',
        );
      }
    });
  }
}
