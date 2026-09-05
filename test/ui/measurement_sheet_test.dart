// test/ui/measurement_sheet_test.dart
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
import 'package:sphygma/ui/measurement_sheet.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _RecordingSink implements HealthSink {
  final written = <String>[];
  final removed = <String>[];

  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {
    written.add(write.clientRecordId);
  }

  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {
    removed.add(clientRecordId);
  }
}

SlotRecord _rec(
  int seq,
  DateTime at, {
  bool movement = false,
  bool arrhythmia = false,
}) =>
    SlotRecord(
      userSlot: 1,
      record: BloodPressureRecord(
        systolic: 128,
        diastolic: 87,
        pulse: 82,
        timestamp: at,
        arrhythmiaFlag: arrhythmia,
        movementFlag: movement,
        sequence: seq,
      ),
      rawBytes: Uint8List(14),
    );

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late InMemoryPairingKeyStore keyStore;
  late _RecordingSink sink;
  late AppController controller;

  Future<AppController> boot() async {
    await keyStore.save(Uint8List(16));
    final c = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: sink),
      statusStream: () => const Stream.empty(),
    );
    await c.init();
    await c.setUserSlot(1);
    return c;
  }

  Future<int> firstId() async {
    await controller.refreshForTest();
    return controller.measurements.first.id;
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v, int id) =>
      tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(v),
          child: Scaffold(
            body: MeasurementSheet(controller: controller, measurementId: id),
          ),
        ),
      ));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    keyStore = InMemoryPairingKeyStore();
    sink = _RecordingSink();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  group('in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('zeigt Werte, Nummer und Import (${v.name})', (tester) async {
        controller = await boot();
        await repository.importAll([_rec(545, DateTime(2026, 9, 5, 23, 57))]);
        final id = await firstId();

        await pumpWith(tester, v, id);

        expect(find.textContaining('128'), findsWidgets);
        expect(find.textContaining('545'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('nennt Bewegung und unregelmäßigen Puls', (tester) async {
    controller = await boot();
    await repository.importAll([
      _rec(1, DateTime(2026, 9, 5, 8), movement: true, arrhythmia: true),
    ]);
    final id = await firstId();

    await pumpWith(tester, ThemeVariant.instrument, id);

    expect(find.textContaining('Bewegung'), findsOneWidget);
    expect(find.textContaining('Unregelmäßiger Puls'), findsOneWidget);
  });

  testWidgets('ohne Kennzeichen steht nichts davon da', (tester) async {
    controller = await boot();
    await repository.importAll([_rec(1, DateTime(2026, 9, 5, 8))]);
    final id = await firstId();

    await pumpWith(tester, ThemeVariant.instrument, id);

    expect(find.textContaining('Bewegung'), findsNothing);
  });

  testWidgets('überträgt einzeln und zeigt den neuen Zustand',
      (tester) async {
    controller = await boot();
    await repository.importAll([_rec(1, DateTime(2026, 9, 5, 8))]);
    final id = await firstId();

    await pumpWith(tester, ThemeVariant.instrument, id);
    expect(find.text('Nach Health Connect übertragen'), findsOneWidget);

    await tester.tap(find.text('Nach Health Connect übertragen'));
    await tester.pumpAndSettle();

    expect(sink.written, hasLength(1));
    expect(find.text('Aus Health Connect entfernen'), findsOneWidget);
  });

  testWidgets('nimmt einzeln zurück', (tester) async {
    controller = await boot();
    await repository.importAll([_rec(1, DateTime(2026, 9, 5, 8))]);
    final id = await firstId();
    await controller.exportOne(controller.measurements.first);

    await pumpWith(tester, ThemeVariant.instrument, id);
    await tester.tap(find.text('Aus Health Connect entfernen'));
    await tester.pumpAndSettle();

    expect(sink.removed, hasLength(1));
    expect(find.text('Nach Health Connect übertragen'), findsOneWidget);
  });

  testWidgets('eine unbekannte Nummer wirft, statt leer zu bleiben',
      (tester) async {
    controller = await boot();

    await pumpWith(tester, ThemeVariant.instrument, 999);

    expect(tester.takeException(), isA<StateError>());
  });

  testWidgets('showMeasurementSheet öffnet das Blatt', (tester) async {
    controller = await boot();
    await repository.importAll([_rec(1, DateTime(2026, 9, 5, 8))]);
    final id = await firstId();

    await tester.pumpWidget(MaterialApp(
      home: SphygmaThemeScope(
        theme: themeFor(ThemeVariant.instrument),
        child: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showMeasurementSheet(
                context,
                controller: controller,
                measurementId: id,
              ),
              child: const Text('öffnen'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('öffnen'));
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementSheet), findsOneWidget);
  });
}
