import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/stats/measurement_week.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/concepts/seven_days/seven_days_home.dart';
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

/// Der Montag der **Vorwoche**: So liegt jede Messung des Testbestands in der
/// Vergangenheit, egal an welchem Wochentag und zu welcher Stunde der Test
/// läuft. Eine Messung in der Zukunft ließe die Prüfung der Geräteuhr
/// anschlagen und den Bildschirm anders aussehen.
final _montag = previousMonday(mondayOf(DateTime.now()));

DateTime _tag(int versatz, int stunde) =>
    DateTime(_montag.year, _montag.month, _montag.day + versatz, stunde);

/// Freitag 18 Uhr jener Woche — der Zeitpunkt, den die Oberfläche als „jetzt"
/// sieht.
final _jetzt = _tag(4, 18);

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  Future<void> boot({bool paired = true}) async {
    if (paired) await keyStore.save(Uint8List(16));
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    await controller.setUserSlot(1);
  }

  /// Montag bis Donnerstag morgens und abends, Freitag nur morgens.
  Future<void> teilwoche() async {
    final records = <SlotRecord>[];
    var seq = 1;
    for (var tag = 0; tag < 4; tag++) {
      records.add(_rec(seq++, _tag(tag, 7), sys: 121, dia: 80));
      records.add(_rec(seq++, _tag(tag, 20), sys: 128, dia: 86));
    }
    records.add(_rec(seq++, _tag(4, 7), sys: 122, dia: 81));
    await repository.importAll(records);
    await controller.refreshForTest();
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) =>
      tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(v),
          child: SevenDaysHome(controller: controller, clock: () => _jetzt),
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
      testWidgets('zeigt die laufende Woche (${v.name})', (tester) async {
        await boot();
        await teilwoche();

        await pumpWith(tester, v);

        expect(find.text('Diese Woche'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('das Wochenraster ist die Hauptsache', (tester) async {
    await boot();
    await teilwoche();

    await pumpWith(tester, ThemeVariant.instrument);

    for (final tag in ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']) {
      expect(find.text(tag), findsOneWidget, reason: tag);
    }
    expect(find.text('Morgens'), findsOneWidget);
    expect(find.text('Abends'), findsOneWidget);
  });

  testWidgets('es gibt keine Reiterleiste — ein Weg statt vier Reiter',
      (tester) async {
    await boot();
    await teilwoche();

    await pumpWith(tester, ThemeVariant.instrument);

    // Das ist die Organisationsaussage des Konzepts, nicht Geschmack:
    // Heute, Verlauf und Gerät dauerhaft nebeneinander führt zwei selten
    // gebrauchte Bereiche mit.
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('nennt den Stand der Woche und was heute noch fehlt',
      (tester) async {
    await boot();
    await teilwoche();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Tag 5 von 7'), findsOneWidget);
    expect(find.text('Heute fehlt noch die Abendmessung.'), findsOneWidget);
  });

  testWidgets('der Wochenwert lässt den ersten Tag aus', (tester) async {
    await boot();
    await teilwoche();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Mittel dieser Woche'), findsOneWidget);
  });

  testWidgets('führt zu früheren Wochen und zum Gerät', (tester) async {
    await boot();
    await teilwoche();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('Frühere Wochen'), findsOneWidget);
    expect(find.text('Gerät und Übertragung'), findsOneWidget);
  });

  testWidgets('die Einstellungen heißen hier Wochen-Einstellungen',
      (tester) async {
    await boot();
    await teilwoche();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    // F14 und F15 bleiben erreichbar — in der Sprache des Konzepts.
    expect(find.text('Wochen-Einstellungen'), findsOneWidget);
    expect(find.text('KONZEPT'), findsOneWidget);
    expect(find.text('GESTALTUNG'), findsOneWidget);
  });

  testWidgets('ein belegtes Feld führt zu seiner Messung', (tester) async {
    await boot();
    await teilwoche();

    await pumpWith(tester, ThemeVariant.instrument);
    // Montag morgens: 121.
    await tester.tap(find.text('121').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Speicherplatz'), findsWidgets);
  });

  testWidgets('ohne Messung steht dort ein Satz, keine leere Fläche',
      (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('Noch keine Messwoche'), findsOneWidget);
  });

  testWidgets('eine lange Pause nennt den Grund und den Weg zurück',
      (tester) async {
    await boot();
    // Acht Wochen vor dem Bezugszeitpunkt gemessen, seither nichts.
    var alt = _montag;
    for (var i = 0; i < 8; i++) {
      alt = previousMonday(alt);
    }
    await repository.importAll([
      _rec(1, DateTime(alt.year, alt.month, alt.day, 7)),
      _rec(2, DateTime(alt.year, alt.month, alt.day + 1, 7)),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Seit 8 Wochen keine Messung'), findsOneWidget);
    // Kein leeres Diagramm: Das Raster der letzten Woche steht da.
    expect(find.text('Morgens'), findsOneWidget);
  });

  testWidgets('ohne Kopplung sagt der Bildschirm, wo man koppelt',
      (tester) async {
    await boot(paired: false);

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('Nicht gekoppelt'), findsWidgets);
  });
}
