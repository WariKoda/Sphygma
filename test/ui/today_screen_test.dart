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
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/stats/measurement_week.dart';
import 'package:sphygma/ui/today_screen.dart';

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

  Future<AppController> boot({bool paired = true}) async {
    if (paired) await keyStore.save(Uint8List(16));
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
      tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              SphygmaThemeScope(theme: themeFor(v), child: child!),
          home: Scaffold(body: TodayScreen(controller: controller)),
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
      testWidgets('zeigt die letzte Messung (${v.name})', (tester) async {
        controller = await boot();
        await repository.importAll([_rec(1, DateTime.now())]);
        await controller.refreshForTest();

        await pumpWith(tester, v);

        expect(find.textContaining('128'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('ohne Messungen fordert er zum Messen auf, statt leer zu sein', (
    tester,
  ) async {
    controller = await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Noch keine Messung'), findsOneWidget);
  });

  testWidgets('ohne Kopplung erscheint ein Hinweis', (tester) async {
    controller = await boot(paired: false);

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Nicht gekoppelt'), findsOneWidget);
  });

  testWidgets('bei falscher Uhr steht der Hinweis samt Anleitung da', (
    tester,
  ) async {
    controller = await boot();
    // Ein Datum weit in der Vergangenheit loest die Pruefung aus.
    await repository.importAll([_rec(1, DateTime(2023, 4, 18))]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Geräteuhr'), findsOneWidget);

    await tester.tap(find.text('Anleitung anzeigen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Batterien'), findsOneWidget);
  });

  testWidgets('zeigt hoechstens fuenf der letzten Messungen', (tester) async {
    controller = await boot();
    final now = DateTime.now();
    await repository.importAll([
      for (var i = 0; i < 9; i++)
        _rec(i + 1, now.subtract(Duration(hours: i)), systolic: 120 + i),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    // Die aelteste (120) darf nicht mehr dabei sein.
    expect(find.textContaining('/87').evaluate().length, lessThanOrEqualTo(6));
  });

  testWidgets('zeigt die laufende Woche mit dem, was heute noch fehlt', (
    tester,
  ) async {
    // Das Wochenraster beantwortet die Frage, die der Verlauf nicht stellt:
    // nicht wie es war, sondern was noch aussteht. Deshalb steht es hier und
    // nicht bei den Kurven.
    final montag = previousMonday(mondayOf(DateTime.now()));
    DateTime tag(int versatz, int stunde) =>
        DateTime(montag.year, montag.month, montag.day + versatz, stunde);
    final jetzt = tag(4, 18);

    controller = await boot();
    await repository.importAll([
      _rec(1, tag(0, 7), systolic: 128),
      _rec(2, tag(0, 20), systolic: 124),
      _rec(3, tag(4, 7), systolic: 126),
    ]);
    await controller.refreshForTest();

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => SphygmaThemeScope(
          theme: themeFor(ThemeVariant.instrument),
          child: child!,
        ),
        home: Scaffold(
          body: TodayScreen(controller: controller, clock: () => jetzt),
        ),
      ),
    );

    expect(find.text('DIESE WOCHE'), findsOneWidget);
    expect(find.text('Mo'), findsOneWidget);
    expect(find.text('So'), findsOneWidget);
    // Freitag morgens gemessen, abends noch nicht.
    expect(find.text('Heute fehlt noch die Abendmessung.'), findsOneWidget);
  });

  testWidgets('über Mitternacht wandert die Wochenansicht mit', (tester) async {
    // Der Steuerungsteil meldet nichts, wenn nur das Datum wechselt. Ohne
    // eigenen Wecker bliebe „Heute fehlt noch…" beim gestrigen Tag stehen.
    final montag = previousMonday(mondayOf(DateTime.now()));
    DateTime tag(int versatz, int stunde, [int minute = 0]) => DateTime(
      montag.year,
      montag.month,
      montag.day + versatz,
      stunde,
      minute,
    );

    controller = await boot();
    await repository.importAll([
      _rec(1, tag(0, 7), systolic: 128),
      _rec(2, tag(0, 20), systolic: 124),
      _rec(3, tag(3, 7), systolic: 126),
      _rec(4, tag(3, 20), systolic: 122),
    ]);
    await controller.refreshForTest();

    // Donnerstag 23:59:30 — morgens und abends gemessen.
    var jetzt = tag(3, 23, 59);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => SphygmaThemeScope(
          theme: themeFor(ThemeVariant.instrument),
          child: child!,
        ),
        home: Scaffold(
          body: TodayScreen(controller: controller, clock: () => jetzt),
        ),
      ),
    );
    expect(find.text('Heute ist morgens und abends gemessen.'), findsOneWidget);

    // Freitag 00:00:30 — der neue Tag ist noch leer.
    jetzt = tag(4, 0, 0);
    await tester.pump(const Duration(minutes: 1));
    await tester.pump();

    expect(find.text('Heute fehlen noch beide Messungen.'), findsOneWidget);
  });
}
