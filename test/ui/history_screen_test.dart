// test/ui/history_screen_test.dart
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/measurement_metadata_repository.dart';
import 'package:sphygma/db/phase_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/stats/period.dart';
import 'package:sphygma/stats/measurement_filter.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/history_screen.dart';
import 'package:sphygma/ui/measurement_sheet.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/trend_chart.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _rec(int seq, DateTime at, {int systolic = 128}) => SlotRecord(
  userSlot: 1,
  record: BloodPressureRecord(
    systolic: systolic,
    diastolic: 87,
    pulse: 82,
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

  Future<AppController> boot() async {
    await keyStore.save(Uint8List(16));
    final c = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      metadataRepository: MeasurementMetadataRepository(db),
      phaseRepository: PhaseRepository(db),
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await c.init();
    await c.setUserSlot(1);
    return c;
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) =>
      tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              SphygmaThemeScope(theme: themeFor(v), child: child!),
          home: Scaffold(body: HistoryScreen(controller: controller)),
        ),
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    keyStore = InMemoryPairingKeyStore();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  group('in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('zeigt Zeitraum, Kurve und Mittelwerte (${v.name})', (
        tester,
      ) async {
        controller = await boot();
        final now = DateTime.now();
        await repository.importAll([
          _rec(1, now.subtract(const Duration(days: 2)), systolic: 120),
          _rec(2, now.subtract(const Duration(hours: 2)), systolic: 130),
        ]);
        await controller.refreshForTest();

        await pumpWith(tester, v);

        expect(find.text('Woche'), findsOneWidget);
        expect(find.byType(TrendChart), findsOneWidget);
        expect(find.textContaining('125'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  for (final v in allVariants) {
    testWidgets('Verlauf ${v.name} bei 360px und doppelter Schrift bedienbar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      controller = await boot();
      await repository.importAll([_rec(1, DateTime.now())]);
      await controller.refreshForTest();
      await pumpWith(tester, v);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('Puls'), 200);
      await tester.ensureVisible(find.text('Puls'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Puls'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.byType(MeasurementRow), 250);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementRow));
      await tester.pumpAndSettle();
      expect(find.byType(MeasurementSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('der Zeitraumwechsel wirkt auf den Steuerungsteil', (
    tester,
  ) async {
    controller = await boot();
    await pumpWith(tester, ThemeVariant.instrument);

    await tester.tap(find.text('Monat'));
    await tester.pumpAndSettle();

    expect(controller.period, Period.month);
  });

  testWidgets('gruppiert die Liste nach Tagen', (tester) async {
    controller = await boot();
    final now = DateTime.now();
    await repository.importAll([
      _rec(1, now.subtract(const Duration(days: 2))),
      _rec(2, now.subtract(const Duration(hours: 3))),
      _rec(3, now.subtract(const Duration(hours: 2))),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    // Die Liste ist virtualisiert: Was nicht ins Fenster passt, ist noch
    // nicht gebaut. Ohne Scrollen prüfte der Test, was zufällig sichtbar ist
    // — und das ist bei einem größeren Bestand beliebig wenig.
    // Der Verlauf ist seit der Übernahme von Tageszeiten und Wochenwert
    // länger; die Messungen stehen unter beiden Blöcken.
    await tester.scrollUntilVisible(find.text('Messungen'), 200);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(MeasurementRow).last, 200);
    await tester.pumpAndSettle();

    // Zwei Tagesüberschriften, drei Zeilen.
    expect(find.byType(DayHeading), findsNWidgets(2));
    expect(find.byType(MeasurementRow), findsNWidgets(3));
  });

  testWidgets('ein Antippen öffnet das Detail-Blatt', (tester) async {
    controller = await boot();
    await repository.importAll([_rec(1, DateTime.now())]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.scrollUntilVisible(find.text('Messungen'), 200);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(MeasurementRow), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MeasurementRow));
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementSheet), findsOneWidget);
  });

  testWidgets('ohne Messungen im Zeitraum steht dort ein Satz, keine Leere', (
    tester,
  ) async {
    controller = await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Keine Messungen'), findsOneWidget);
    expect(find.byType(TrendChart), findsNothing);
  });

  testWidgets(
    'ein Tagfilter steuert Trefferzahl, Kennzahl und Liste gemeinsam',
    (tester) async {
      controller = await boot();
      final now = DateTime.now();
      await repository.importAll([
        _rec(1, now.subtract(const Duration(hours: 2)), systolic: 110),
        _rec(2, now.subtract(const Duration(hours: 1)), systolic: 150),
      ]);
      await controller.refreshForTest();
      final tagId = await controller.createTag('Ruhe');
      await controller.saveMeasurementMetadata(
        deviceSequence: 1,
        note: null,
        tagIds: {tagId},
      );
      controller.setHistoryFilter(
        HistoryFilter(tagIds: {tagId}, tags: MembershipFilter.selected),
      );

      await pumpWith(tester, ThemeVariant.instrument);

      expect(find.text('1 von 2 Messungen'), findsOneWidget);
      expect(find.textContaining('110'), findsWidgets);
      expect(find.textContaining('130'), findsNothing);
      await tester.scrollUntilVisible(find.text('Messungen'), 200);
      await tester.pumpAndSettle();
      expect(find.byType(MeasurementRow), findsOneWidget);
    },
  );

  testWidgets('übertragene Messungen tragen einen Punkt', (tester) async {
    controller = await boot();
    await repository.importAll([_rec(1, DateTime.now())]);
    await controller.refreshForTest();
    await controller.exportOne(controller.measurements.first);

    await pumpWith(tester, ThemeVariant.instrument);

    await tester.scrollUntilVisible(find.text('Messungen'), 200);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(MeasurementRow), 200);

    expect(find.byKey(const ValueKey('exported-dot')), findsOneWidget);
  });

  testWidgets('zeigt die Tageszeiten feiner als morgens und abends', (
    tester,
  ) async {
    // Aus dem aufgelösten Konzept „Tagesprofil" übernommen: Der Verlauf über
    // Tage sagt nichts über den Verlauf innerhalb eines Tages.
    controller = await boot();
    final now = DateTime.now();
    DateTime heute(int stunde) =>
        DateTime(now.year, now.month, now.day - 1, stunde);
    await repository.importAll([
      _rec(1, heute(7), systolic: 140),
      _rec(2, heute(10), systolic: 132),
      _rec(3, heute(15), systolic: 128),
      _rec(4, heute(20), systolic: 120),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.scrollUntilVisible(find.text('Nach Tageszeit'), 200);
    await tester.pumpAndSettle();

    expect(find.text('Vormittags'), findsOneWidget);
    expect(find.text('Nachmittags'), findsOneWidget);
    expect(
      find.textContaining('Am höchsten liegt der Druck morgens'),
      findsOneWidget,
    );
    expect(find.textContaining('20 mmHg'), findsOneWidget);
  });

  testWidgets('nennt bei „Woche" den Praxiswert ohne den ersten Tag', (
    tester,
  ) async {
    // Aus dem aufgelösten Konzept „Sieben Tage": Der Wochenwert lässt den
    // ersten Tag aus, so verlangt es die Leitlinie. Das ist nicht dasselbe
    // wie das Mittel der letzten sieben Tage.
    controller = await boot();
    // Gestern und vorgestern: sicher in der Vergangenheit und im Zeitraum
    // „Woche". Auf feste Wochentage gelegte Messungen lägen je nach Lauftag
    // in der Zukunft.
    final jetzt = DateTime.now();
    DateTime vorTagen(int n, int stunde) =>
        DateTime(jetzt.year, jetzt.month, jetzt.day - n, stunde);
    await repository.importAll([
      _rec(1, vorTagen(2, 7), systolic: 160),
      _rec(2, vorTagen(2, 20), systolic: 160),
      _rec(3, vorTagen(1, 7), systolic: 120),
      _rec(4, vorTagen(1, 20), systolic: 120),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.scrollUntilVisible(find.text('Ohne ersten Tag'), 200);
    await tester.pumpAndSettle();

    expect(find.text('Ohne ersten Tag'), findsOneWidget);
    expect(find.text('Felder'), findsOneWidget);
    // Wie viele Felder belegt sind, hängt davon ab, ob die beiden Tage in
    // dieselbe Kalenderwoche fallen — die Zahl selbst prüft
    // measurement_week_test.
    expect(find.textContaining(RegExp(r'[0-9]+ von 14')), findsOneWidget);
  });
}
