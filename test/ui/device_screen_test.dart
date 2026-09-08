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
import 'package:sphygma/ui/device_screen.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

/// Health Connect verweigert die Berechtigung - ein alltaeglicher Fall.
class _FailingSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {
    throw StateError('Keine Berechtigung.');
  }

  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {
    throw StateError('Keine Berechtigung.');
  }
}

void main() {
  late AppDatabase db;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  Future<void> boot({
    bool paired = true,
    bool withSlot = true,
    HealthSink? sink,
  }) async {
    if (paired) await keyStore.save(Uint8List(16));
    final repository = MeasurementRepository(db);
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      occasionRepository: OccasionRepository(db),
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(
        repository: repository,
        sink: sink ?? _NoopSink(),
      ),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    if (withSlot) await controller.setUserSlot(1);
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) =>
      tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              SphygmaThemeScope(theme: themeFor(v), child: child!),
          home: Scaffold(body: DeviceScreen(controller: controller)),
        ),
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
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

  testWidgets('zeigt den Zustand des automatischen Abgleichs', (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Automatischer Abgleich'), findsOneWidget);
  });

  testWidgets('eine fehlschlagende Aktion meldet, statt unbeobachtet zu '
      'scheitern', (tester) async {
    await boot(sink: _FailingSink());
    await MeasurementRepository(db).importAll([
      SlotRecord(
        userSlot: 1,
        record: BloodPressureRecord(
          systolic: 128,
          diastolic: 87,
          pulse: 82,
          timestamp: DateTime.now(),
          arrhythmiaFlag: false,
          movementFlag: false,
          sequence: 1,
        ),
        rawBytes: Uint8List(14),
      ),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.ensureVisible(find.text('Alle übertragen'));
    await tester.tap(find.text('Alle übertragen'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(controller.status, contains('Fehler'));
  });

  testWidgets('ohne Speicherplatz ist "Übertragene entfernen" abgeschaltet', (
    tester,
  ) async {
    await boot(withSlot: false);

    await pumpWith(tester, ThemeVariant.instrument);

    final button = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Übertragene entfernen'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(button.onPressed, isNull);
  });
}
