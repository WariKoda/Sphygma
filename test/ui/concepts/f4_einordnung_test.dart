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
import 'package:flutter/material.dart';
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
import 'package:sphygma/stats/measurement_week.dart';
import 'package:sphygma/ui/concepts/concept_home.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/classification_scale.dart';

/// Montag der Vorwoche — so liegt jede Messung in der Vergangenheit, egal
/// wann der Test läuft.
final _montag = previousMonday(mondayOf(DateTime.now()));

DateTime _tag(int versatz, int stunde) =>
    DateTime(_montag.year, _montag.month, _montag.day + versatz, stunde);

/// Freitag jener Woche: der Zeitpunkt, den die Oberfläche als „jetzt" sieht.
final _jetzt = _tag(4, 18);

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
      begin: DateTime(_montag.year, _montag.month, _montag.day - 30),
    );

    // Werte im Bluthochdruckbereich, damit die Einordnung etwas zu sagen hat.
    //
    // Die Messungen liegen an vier Tagen **einer** Woche, und der Bildschirm
    // bekommt den Freitag jener Woche als Uhr. Relativ zu DateTime.now()
    // gelegte Messungen wären wochentagsabhängig: An einem Montag läge alles
    // in der Vorwoche, die laufende Woche hätte höchstens einen Messtag — und
    // weil der Wochenwert den ersten Tag auslässt, gäbe es zu Recht nichts
    // einzuordnen. Der Test wäre montags rot, ohne dass etwas kaputt ist.
    await repository.importAll([
      _rec(1, _tag(0, 8), sys: 152),
      _rec(2, _tag(1, 8), sys: 146),
      _rec(3, _tag(2, 8), sys: 149),
      _rec(4, _tag(3, 8), sys: 147),
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
      await tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(ThemeVariant.instrument),
          child: conceptHome(
            concept: k,
            controller: controller,
            clock: () => _jetzt,
          ),
        ),
      ));
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
