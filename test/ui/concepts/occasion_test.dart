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
import 'package:sphygma/stats/occasion_grouping.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/concepts/occasion/occasion_home.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _rec(int seq, DateTime at, {int sys = 124, int dia = 82,
    bool bewegung = false}) =>
    SlotRecord(
      userSlot: 1,
      record: BloodPressureRecord(
        systolic: sys,
        diastolic: dia,
        pulse: 78,
        timestamp: at,
        arrhythmiaFlag: false,
        movementFlag: bewegung,
        sequence: seq,
      ),
      rawBytes: Uint8List(14),
    );

/// Zwei Tage alt: sicher in der Vergangenheit, egal wann der Test läuft.
final _basis = DateTime.now().subtract(const Duration(days: 2));

DateTime _nach(Duration d) => _basis.add(d);

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  Future<void> boot() async {
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
  }

  /// Vier Anlässe, davon einer ein Grenzfall:
  /// [1,2] zusammen · [3] allein · [4] und [5] elf Minuten auseinander.
  Future<void> bestand() async {
    await repository.importAll([
      _rec(1, _basis, sys: 130),
      _rec(2, _nach(const Duration(minutes: 2)), sys: 126),
      _rec(3, _nach(const Duration(hours: 3)), sys: 122),
      _rec(4, _nach(const Duration(hours: 5)), sys: 128),
      _rec(5, _nach(const Duration(hours: 5, minutes: 11)), sys: 124),
    ]);
    await controller.refreshForTest();
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) =>
      tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(v),
          child: OccasionHome(controller: controller),
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
      testWidgets('zeigt das letzte Messen (${v.name})', (tester) async {
        await boot();
        await bestand();

        await pumpWith(tester, v);

        expect(find.text('Letztes Messen'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('ein Anlass, ein Ergebnis — die Rohwerte stehen daneben',
      (tester) async {
    await boot();
    await repository.importAll([
      _rec(1, _basis, sys: 130, dia: 88),
      _rec(2, _nach(const Duration(minutes: 2)), sys: 126, dia: 84),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    // Mittel aus 130/88 und 126/84.
    expect(find.text('128 / 86'), findsOneWidget);
    expect(find.text('ROHWERTE'), findsOneWidget);
    expect(find.textContaining('Mittel über alle 2 Messungen'), findsOneWidget);
  });

  testWidgets('das Archiv zählt Situationen, nicht Zahlen', (tester) async {
    await boot();
    await bestand();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Archiv'));
    await tester.pumpAndSettle();

    // Fünf Rohmessungen, vier Anlässe.
    expect(find.textContaining('4 Messanlässe aus 5 Rohmessungen'),
        findsOneWidget);
  });

  testWidgets('offene Grenzfälle stehen als Anzahl am Reiter', (tester) async {
    await boot();
    await bestand();

    await pumpWith(tester, ThemeVariant.instrument);

    // Eine offene Frage, die man erst beim Hinsehen findet, ist zugedeckt.
    expect(find.widgetWithText(Badge, '1'), findsOneWidget);
  });

  testWidgets('ein Grenzfall wird entschieden, nicht still zusammengefasst',
      (tester) async {
    await boot();
    await bestand();
    expect(controller.occasions, hasLength(4));
    expect(controller.openOccasions, hasLength(1));

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Prüfen'));
    await tester.pumpAndSettle();

    expect(find.text('Gehören diese zusammen?'), findsOneWidget);
    expect(find.textContaining('11 Minuten'), findsOneWidget);

    await tester.tap(find.text('Ein Anlass'));
    await tester.pumpAndSettle();

    expect(controller.occasions, hasLength(3));
    expect(controller.openOccasions, isEmpty);
    expect(find.text('Nichts zu prüfen'), findsOneWidget);
  });

  testWidgets('die Gegenentscheidung trennt dauerhaft', (tester) async {
    await boot();
    await bestand();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Prüfen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zwei getrennte'));
    await tester.pumpAndSettle();

    expect(controller.occasions, hasLength(4));
    expect(controller.openOccasions, isEmpty);
    // Die Entscheidung ist gespeichert, nicht flüchtig.
    expect(
      controller.occasions.any((o) => o.state == OccasionState.bestaetigt),
      isTrue,
    );
  });

  testWidgets('Bewegung entfernt einen Rohwert aus dem Ergebnis, nicht aus '
      'der Historie', (tester) async {
    await boot();
    await repository.importAll([
      _rec(1, _basis, sys: 160, dia: 100, bewegung: true),
      _rec(2, _nach(const Duration(minutes: 2)), sys: 120, dia: 80),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('120 / 80'), findsOneWidget);
    expect(find.text('nicht verwendet'), findsOneWidget);
    // Der Rohwert bleibt sichtbar.
    expect(find.textContaining('160/100'), findsOneWidget);
  });

  testWidgets('die Konzeptwahl sitzt oben rechts', (tester) async {
    await boot();
    await bestand();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Konzept und Gestaltung'), findsOneWidget);
    expect(find.text('KONZEPT'), findsOneWidget);
  });

  testWidgets('die Auswertung mittelt Anlässe, nicht Rohmessungen',
      (tester) async {
    await boot();
    // Ein dreifach gemessener Anlass und drei einzelne. Zählte man
    // Rohmessungen, hätte der erste Anlass dreifaches Gewicht.
    await repository.importAll([
      _rec(1, _basis, sys: 150),
      _rec(2, _nach(const Duration(minutes: 2)), sys: 150),
      _rec(3, _nach(const Duration(minutes: 4)), sys: 150),
      _rec(4, _nach(const Duration(hours: 2)), sys: 110),
      _rec(5, _nach(const Duration(hours: 4)), sys: 110),
      _rec(6, _nach(const Duration(hours: 6)), sys: 110),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Archiv'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anlässe auswerten'));
    await tester.pumpAndSettle();

    // Vier Anlässe: 150, 110, 110, 110 → 120. Über Rohmessungen wären es 130.
    expect(find.textContaining('120 / '), findsOneWidget);
    expect(find.textContaining('4 Anlässe · 6 Rohmessungen'), findsOneWidget);
  });

  testWidgets('eine Entscheidung lässt sich zurücknehmen und wirkt wirklich',
      (tester) async {
    await boot();
    await bestand();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Prüfen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ein Anlass'));
    await tester.pumpAndSettle();
    expect(controller.occasions, hasLength(3));

    // Über das Archiv in den bestätigten Anlass.
    await tester.tap(find.text('Archiv'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('2 Messungen · gute Güte').first);
    await tester.pumpAndSettle();

    // Der Knopf nennt die Nummer, unter der die Entscheidung steht — geraten
    // hätte er die falsche gelöscht und wäre wirkungslos geblieben.
    await tester.tap(find.textContaining('Entscheidung zu Nr. 5').first);
    await tester.pumpAndSettle();

    expect(controller.occasions, hasLength(4));
    expect(controller.openOccasions, hasLength(1));
  });
}
