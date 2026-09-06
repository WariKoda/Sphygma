import 'dart:typed_data';

import 'package:drift/native.dart';
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
      occasionRepository: OccasionRepository(db),
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

  group('clockLooksWrong', () {
    // Die Anzeige sortiert nach Datum, diese Pruefung nach Messungsnummer.
    // Genau hier faellt das auseinander: Bei falsch gestellter Uhr traegt
    // die zuletzt gemessene Messung ein altes Datum und steht in der
    // Datumssortierung ganz hinten.
    test('erkennt die falsche Uhr an der zuletzt gemessenen Messung, '
        'auch wenn deren Datum weit zurueckliegt', () async {
      final now = DateTime.now();
      await repository.importAll([
        // Echte alte Messungen mit plausiblen Daten.
        _rec(100, now.subtract(const Duration(days: 40))),
        _rec(200, now.subtract(const Duration(days: 2))),
        // Zuletzt gemessen - hoechste Nummer, aber Geraeteuhr steht 2023.
        _rec(300, DateTime(2023, 4, 18, 11, 2)),
      ]);
      await controller.refreshForTest();

      expect(controller.clockLooksWrong, isTrue);
    });

    test('meldet nichts, wenn die zuletzt gemessene Messung plausibel ist',
        () async {
      final now = DateTime.now();
      await repository.importAll([
        // Eine echte alte Messung darf keine Warnung ausloesen.
        _rec(100, DateTime(2023, 4, 18, 11, 2)),
        _rec(300, now.subtract(const Duration(hours: 2))),
      ]);
      await controller.refreshForTest();

      expect(controller.clockLooksWrong, isFalse);
    });

    test('ohne Messungen gibt es nichts zu melden', () async {
      await controller.refreshForTest();

      expect(controller.clockLooksWrong, isFalse);
    });
  });

  test('die Gestaltung lässt sich wechseln und wird gespeichert', () async {
    expect(controller.themeVariant, ThemeVariant.instrument);

    await controller.setThemeVariant(ThemeVariant.diary);

    expect(controller.themeVariant, ThemeVariant.diary);
    expect(await SettingsRepository(db).themeVariant(), ThemeVariant.diary);
  });
}
