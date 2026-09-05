import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/stats/period.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _rec(int seq, DateTime at) => SlotRecord(
      userSlot: 1,
      record: BloodPressureRecord(
        systolic: 120,
        diastolic: 80,
        pulse: 70,
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
  late AppController controller;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    final keyStore = InMemoryPairingKeyStore();
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService:
          ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    await controller.setUserSlot(1);
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  test('der Standardzeitraum ist die Woche', () {
    expect(controller.period, Period.week);
  });

  test('setPeriod filtert die Messungen', () async {
    final now = DateTime.now();
    await repository.importAll([
      _rec(1, now.subtract(const Duration(days: 2))),
      _rec(2, now.subtract(const Duration(days: 40))),
    ]);
    await controller.refreshForTest();

    expect(controller.measurementsInPeriod, hasLength(1));

    await controller.setPeriod(Period.all);

    expect(controller.measurementsInPeriod, hasLength(2));
  });

  test('latest ist die neueste Messung, unabhaengig vom Zeitraum', () async {
    final now = DateTime.now();
    await repository.importAll([
      _rec(1, now.subtract(const Duration(days: 40))),
      _rec(2, now.subtract(const Duration(days: 1))),
    ]);
    await controller.refreshForTest();

    expect(controller.latest?.deviceSequence, 2);
  });

  test('latest ist null, solange nichts gespeichert ist', () {
    expect(controller.latest, isNull);
    expect(controller.latest, isNull);
  });

  test('die Gestaltung lässt sich wechseln und wird gespeichert', () async {
    expect(controller.themeVariant, ThemeVariant.instrument);

    await controller.setThemeVariant(ThemeVariant.diary);

    expect(controller.themeVariant, ThemeVariant.diary);
    expect(await SettingsRepository(db).themeVariant(), ThemeVariant.diary);
  });
}
