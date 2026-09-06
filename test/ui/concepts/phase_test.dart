import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
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
import 'package:sphygma/ui/concepts/phase/phase_home.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _rec(int seq, DateTime at, {int sys = 124, int dia = 82}) =>
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

DateTime _vorTagen(int n) =>
    DateTime.now().subtract(Duration(days: n, hours: 3));

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late OccasionRepository occasions;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  Future<void> boot() async {
    await keyStore.save(Uint8List(16));
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      occasionRepository: occasions,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    await controller.setUserSlot(1);
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) =>
      tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(v),
          child: PhaseHome(controller: controller),
        ),
      ));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    occasions = OccasionRepository(db);
    keyStore = InMemoryPairingKeyStore();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  group('in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('baut ohne Fehler (${v.name})', (tester) async {
        await boot();

        await pumpWith(tester, v);

        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('ohne Phase erklärt der Einstieg, wozu eine gut ist',
      (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('Keine laufende Phase'), findsOneWidget);
    expect(find.text('Neue Phase beginnen'), findsOneWidget);
  });

  testWidgets('eine laufende Phase zeigt ihr Mittel und ihre Größe',
      (tester) async {
    await boot();
    await occasions.startPhase(
      name: 'Ramipril 5 mg',
      anchor: PhaseAnchor.bestaetigt,
      begin: _vorTagen(20),
    );
    await repository.importAll([
      _rec(1, _vorTagen(10), sys: 130, dia: 88),
      _rec(2, _vorTagen(9), sys: 126, dia: 84),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('Ramipril 5 mg'), findsOneWidget);
    expect(find.text('128 / 86'), findsOneWidget);
    expect(find.textContaining('2 zugeordnete Messungen'), findsOneWidget);
  });

  testWidgets('der Vergleich nennt sich ausdrücklich keinen Wirkungsnachweis',
      (tester) async {
    await boot();
    await occasions.startPhase(
      name: 'Ohne Medikament',
      anchor: PhaseAnchor.bestaetigt,
      begin: _vorTagen(40),
    );
    final alte = (await occasions.phases()).single;
    await occasions.endPhase(alte.id, at: _vorTagen(20));
    await occasions.startPhase(
      name: 'Ramipril 5 mg',
      anchor: PhaseAnchor.bestaetigt,
      begin: _vorTagen(20),
    );
    await repository.importAll([
      _rec(1, _vorTagen(30), sys: 140),
      _rec(2, _vorTagen(25), sys: 138),
      _rec(3, _vorTagen(10), sys: 124),
      _rec(4, _vorTagen(9), sys: 126),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Im Vergleich zur Phase davor'), findsOneWidget);
    expect(find.textContaining('kein Wirkungsnachweis'), findsOneWidget);
  });

  testWidgets('"nicht zugeordnet" steht als eigener Bestand in der Liste',
      (tester) async {
    await boot();
    await occasions.startPhase(
      name: 'Ramipril 5 mg',
      anchor: PhaseAnchor.bestaetigt,
      begin: _vorTagen(10),
    );
    await repository.importAll([
      _rec(1, _vorTagen(30), sys: 140),
      _rec(2, _vorTagen(5), sys: 124),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Phasen'));
    await tester.pumpAndSettle();

    // Keine versteckte Restmenge: Was außerhalb liegt, steht in der Liste.
    expect(find.text('Nicht zugeordnet'), findsOneWidget);
  });

  testWidgets('eine unglaubwürdig datierte Messung landet im Zuordnen-Bereich',
      (tester) async {
    await boot();
    await occasions.startPhase(
      name: 'Ramipril 5 mg',
      anchor: PhaseAnchor.bestaetigt,
      begin: _vorTagen(30),
    );
    await repository.importAll([
      _rec(1, _vorTagen(20), sys: 124),
      _rec(2, _vorTagen(19), sys: 126),
      // Höchste Nummer, Datum von 2023: Die Uhr stand falsch.
      _rec(3, DateTime(2023, 4, 18, 11), sys: 136),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.widgetWithText(Badge, '1'), findsOneWidget);

    await tester.tap(find.text('Zuordnen'));
    await tester.pumpAndSettle();

    expect(find.text('Messung Nr. 3'), findsOneWidget);
    expect(find.textContaining('Sphygma ändert den Zeitstempel nicht'),
        findsOneWidget);
    // Beide Zeiten stehen nebeneinander, keine wird zur Wahrheit erklärt.
    expect(find.text('Laut Gerät'), findsOneWidget);
    expect(find.text('Eingelesen'), findsOneWidget);
  });

  testWidgets('der Nutzer ordnet sie zu, ohne dass eine Zeit verschoben wird',
      (tester) async {
    await boot();
    await occasions.startPhase(
      name: 'Ramipril 5 mg',
      anchor: PhaseAnchor.bestaetigt,
      begin: _vorTagen(30),
    );
    await repository.importAll([
      _rec(1, _vorTagen(20), sys: 124),
      _rec(2, _vorTagen(19), sys: 126),
      _rec(3, DateTime(2023, 4, 18, 11), sys: 136),
    ]);
    await controller.refreshForTest();
    final vorher = controller.measurements
        .firstWhere((m) => m.deviceSequence == 3)
        .measuredAt;

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Zuordnen'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ramipril 5 mg'));
    await tester.pumpAndSettle();

    expect(controller.phaseGrouping!.unclear, isEmpty);
    expect(controller.phaseGrouping!.memberships.single.count, 3);
    // Die Zuordnung ist keine Zeitkorrektur.
    expect(
      controller.measurements
          .firstWhere((m) => m.deviceSequence == 3)
          .measuredAt,
      vorher,
    );
  });

  testWidgets('die Konzeptwahl ist über den Gerätereiter erreichbar',
      (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Gerät'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Konzept und Gestaltung ändern'));
    await tester.tap(find.text('Konzept und Gestaltung ändern'));
    await tester.pumpAndSettle();

    expect(find.text('KONZEPT'), findsOneWidget);
  });

  testWidgets('eine neue Phase entsteht mit Namen und Zeitanker',
      (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Neue Phase beginnen'));
    await tester.pumpAndSettle();

    expect(find.text('Neue Phase'), findsOneWidget);
    // Ein Datum ohne Herkunft würde Sicherheit vortäuschen.
    expect(find.text('Jetzt'), findsWidgets);
    expect(find.text('Zu einem bestätigten Datum'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Urlaub');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Phase beginnen'));
    await tester.pumpAndSettle();

    expect(controller.phases, hasLength(1));
    expect(controller.phases.single.name, 'Urlaub');
  });
}
