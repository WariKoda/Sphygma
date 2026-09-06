// test/ui/history_screen_test.dart
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
import 'package:sphygma/stats/period.dart';
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
      occasionRepository: OccasionRepository(db),
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await c.init();
    await c.setUserSlot(1);
    return c;
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) =>
      tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(v),
          child: Scaffold(body: HistoryScreen(controller: controller)),
        ),
      ));

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
      testWidgets('zeigt Zeitraum, Kurve und Mittelwerte (${v.name})',
          (tester) async {
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

  testWidgets('der Zeitraumwechsel wirkt auf den Steuerungsteil',
      (tester) async {
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

    // Zwei Tagesüberschriften, drei Zeilen.
    expect(find.byType(DayHeading), findsNWidgets(2));
    expect(find.byType(MeasurementRow), findsNWidgets(3));
  });

  testWidgets('ein Antippen öffnet das Detail-Blatt', (tester) async {
    controller = await boot();
    await repository.importAll([_rec(1, DateTime.now())]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.byType(MeasurementRow));
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementSheet), findsOneWidget);
  });

  testWidgets('ohne Messungen im Zeitraum steht dort ein Satz, keine Leere',
      (tester) async {
    controller = await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Keine Messungen'), findsOneWidget);
    expect(find.byType(TrendChart), findsNothing);
  });

  testWidgets('übertragene Messungen tragen einen Punkt', (tester) async {
    controller = await boot();
    await repository.importAll([_rec(1, DateTime.now())]);
    await controller.refreshForTest();
    await controller.exportOne(controller.measurements.first);

    await pumpWith(tester, ThemeVariant.instrument);

    expect(
      find.byKey(const ValueKey('exported-dot')),
      findsOneWidget,
    );
  });
}
