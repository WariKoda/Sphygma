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
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/concepts/day_profile/day_profile_screen.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _rec(int seq, DateTime at, {int sys = 128, int dia = 87}) =>
    SlotRecord(
      userSlot: 1,
      record: BloodPressureRecord(
        systolic: sys,
        diastolic: dia,
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

  Future<void> boot() async {
    await keyStore.save(Uint8List(16));
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

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) =>
      tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(v),
          child: Scaffold(body: DayProfileScreen(controller: controller)),
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
      testWidgets('zeigt das Tagesmuster (${v.name})', (tester) async {
        await boot();
        final heute = DateTime.now();
        await repository.importAll([
          _rec(1, DateTime(heute.year, heute.month, heute.day - 2, 7), sys: 135),
          _rec(2, DateTime(heute.year, heute.month, heute.day - 2, 20), sys: 124),
          _rec(3, DateTime(heute.year, heute.month, heute.day - 1, 7), sys: 133),
        ]);
        await controller.refreshForTest();

        await pumpWith(tester, v);

        expect(find.textContaining('TAGESMUSTER'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('zeigt jeden Tagesabschnitt mit Messungen', (tester) async {
    await boot();
    final heute = DateTime.now();
    await repository.importAll([
      _rec(1, DateTime(heute.year, heute.month, heute.day - 1, 7), sys: 135),
      _rec(2, DateTime(heute.year, heute.month, heute.day - 1, 20), sys: 124),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('Morgens'), findsOneWidget);
    expect(find.text('Abends'), findsOneWidget);
    // Abschnitte ohne Messungen erscheinen nicht — sie wären leere Flächen.
    expect(find.text('Nachts'), findsNothing);
  });

  testWidgets('nennt den Unterschied zwischen den Abschnitten',
      (tester) async {
    await boot();
    final heute = DateTime.now();
    await repository.importAll([
      _rec(1, DateTime(heute.year, heute.month, heute.day - 1, 7), sys: 136),
      _rec(2, DateTime(heute.year, heute.month, heute.day - 1, 20), sys: 124),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    // Das ist die Aussage des Konzepts: wann der Druck hoch ist.
    expect(find.textContaining('mmHg'), findsWidgets);
  });

  testWidgets('ohne Messungen steht dort ein Satz, keine leere Fläche',
      (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Noch keine Messung'), findsOneWidget);
  });

  testWidgets('bei fraglicher Gerätezeit erscheint ein Hinweis',
      (tester) async {
    await boot();
    // Höchste Nummer, aber Datum von 2023: Die Uhr stand falsch.
    await repository.importAll([
      _rec(1, DateTime.now().subtract(const Duration(days: 2))),
      _rec(2, DateTime(2023, 4, 18, 11)),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Geräteuhr'), findsOneWidget);
  });
}
