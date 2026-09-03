// Widget-Tests der App-Oberflaeche (M6) gegen In-Memory-DB und Fake-Senke.
// Bluetooth wird hier nie beruehrt: SyncService wird konstruiert, aber
// nicht aufgerufen.
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
import 'package:sphygma/ui/sphygma_app.dart';

class FakeHealthSink implements HealthSink {
  final List<String> written = [];
  final List<String> deleted = [];

  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async =>
      written.add(write.clientRecordId);

  @override
  Future<void> deleteBloodPressure(String clientRecordId) async =>
      deleted.add(clientRecordId);
}

class _Harness {
  _Harness()
      : db = AppDatabase(NativeDatabase.memory()),
        keyStore = InMemoryPairingKeyStore(),
        sink = FakeHealthSink() {
    repository = MeasurementRepository(db);
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: sink),
    );
  }

  final AppDatabase db;
  final InMemoryPairingKeyStore keyStore;
  final FakeHealthSink sink;
  late final MeasurementRepository repository;
  late final AppController controller;

  Future<void> importOne({int slot = 1, int seq = 7}) => repository.importAll([
        SlotRecord(
          userSlot: slot,
          record: BloodPressureRecord(
            systolic: 128,
            diastolic: 82,
            pulse: 66,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            arrhythmiaFlag: false,
            movementFlag: true,
            sequence: seq,
          ),
          rawBytes: Uint8List(14),
        ),
      ]);
}

void main() {
  testWidgets('ungepairt: Status sichtbar, Sync deaktiviert', (tester) async {
    final h = _Harness();
    await h.controller.init();

    await tester.pumpWidget(SphygmaApp(controller: h.controller));
    await tester.pumpAndSettle();

    expect(find.text('Nicht gepairt'), findsOneWidget);
    final sync = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Jetzt synchronisieren'),
    );
    expect(sync.onPressed, isNull);
    await h.db.close();
  });

  testWidgets('Messungen des gewaehlten Slots werden gelistet, Export per Tipp',
      (tester) async {
    final h = _Harness();
    await h.keyStore.loadOrCreate();
    await h.importOne(slot: 1);
    await h.importOne(slot: 2, seq: 8);
    await h.controller.init();
    await h.controller.setUserSlot(1);

    await tester.pumpWidget(SphygmaApp(controller: h.controller));
    await tester.pumpAndSettle();
    expect(find.text('Gepairt'), findsOneWidget);

    await tester.tap(find.text('Messungen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('128 / 82 mmHg'), findsOneWidget);
    expect(find.textContaining('Bewegung'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.cloud_upload_outlined));
    await tester.pumpAndSettle();

    expect(h.sink.written, ['sphygma-slot1-seq7']);
    expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    await h.db.close();
  });

  testWidgets('Trend zeigt 7-Tage-Mittel ohne Bewertung', (tester) async {
    final h = _Harness();
    await h.keyStore.loadOrCreate();
    await h.importOne();
    await h.controller.init();
    await h.controller.setUserSlot(1);

    await tester.pumpWidget(SphygmaApp(controller: h.controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trend'));
    await tester.pumpAndSettle();

    expect(find.textContaining('128 / 82 mmHg'), findsWidgets);
    expect(find.textContaining('Hypertonie'), findsNothing);
    await h.db.close();
  });
}
