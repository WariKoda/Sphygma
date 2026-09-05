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
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
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
          child: Scaffold(body: TodayScreen(controller: controller)),
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

  testWidgets('ohne Messungen fordert er zum Messen auf, statt leer zu sein',
      (tester) async {
    controller = await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Noch keine Messung'), findsOneWidget);
  });

  testWidgets('ohne Kopplung erscheint ein Hinweis', (tester) async {
    controller = await boot(paired: false);

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Nicht gekoppelt'), findsOneWidget);
  });

  testWidgets('bei falscher Uhr steht der Hinweis samt Anleitung da',
      (tester) async {
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
}
