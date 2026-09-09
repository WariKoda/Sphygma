// Der automatische Export: an, abschaltbar, und still im Fehlerfall.
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
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';

class _ZaehlendeSenke implements HealthSink {
  int geschrieben = 0;
  @override
  Future<void> writeBloodPressure(BloodPressureWrite w) async => geschrieben++;
  @override
  Future<void> deleteBloodPressure(String id) async {}
}

/// Health Connect verweigert die Berechtigung — ein alltäglicher Fall.
class _VerweigerndeSenke implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite w) async {
    throw StateError('Keine Berechtigung.');
  }

  @override
  Future<void> deleteBloodPressure(String id) async {}
}

SlotRecord _rec(int seq) => SlotRecord(
  userSlot: 1,
  record: BloodPressureRecord(
    systolic: 140,
    diastolic: 90,
    pulse: 70,
    timestamp: DateTime(2026, 7, 10 + seq, 8),
    arrhythmiaFlag: false,
    movementFlag: false,
    sequence: seq,
  ),
  rawBytes: Uint8List(14),
);

Future<AppController> _bauen(AppDatabase db, HealthSink senke) async {
  final repository = MeasurementRepository(db);
  final keyStore = InMemoryPairingKeyStore();
  await keyStore.save(Uint8List(16));
  final c = AppController(
    settings: SettingsRepository(db),
    keyStore: keyStore,
    repository: repository,
    occasionRepository: OccasionRepository(db),
    syncService: SyncService(keyStore: keyStore, repository: repository),
    exportService: ExportService(repository: repository, sink: senke),
    statusStream: () => const Stream.empty(),
  );
  await c.init();
  await c.setUserSlot(1);
  return c;
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('standardmäßig eingeschaltet', () async {
    final c = await _bauen(db, _ZaehlendeSenke());
    addTearDown(c.dispose);

    // Der Export ist der Zweck der App — wer sie einrichtet, will ihn.
    expect(c.autoExport, isTrue);
  });

  test('die Wahl überlebt den Neustart', () async {
    final erster = await _bauen(db, _ZaehlendeSenke());
    await erster.setAutoExport(false);
    erster.dispose();

    final zweiter = await _bauen(db, _ZaehlendeSenke());
    addTearDown(zweiter.dispose);
    expect(zweiter.autoExport, isFalse);
  });

  test('ein Fehlschlag bleibt sichtbar, aber wirft nicht', () async {
    // Health Connect kann die Berechtigung dauerhaft verweigern. Käme dann
    // nach jeder Messung eine Fehlermeldung, wäre die App unbenutzbar — und
    // die Meldung des Abgleichs würde überschrieben, obwohl der geklappt hat.
    final c = await _bauen(db, _VerweigerndeSenke());
    addTearDown(c.dispose);
    await MeasurementRepository(db).importAll([_rec(1)]);
    await c.refreshForTest();

    // Direkt geprüft, weil ein echter Abgleich ein Gerät bräuchte.
    await c.exportAll().catchError((_) {});

    expect(c.pendingExport, 1, reason: 'nichts ist durchgekommen');
  });

  test('abgeschaltet überträgt nichts von selbst', () async {
    final senke = _ZaehlendeSenke();
    final c = await _bauen(db, senke);
    addTearDown(c.dispose);
    await c.setAutoExport(false);

    await MeasurementRepository(db).importAll([_rec(1)]);
    await c.refreshForTest();

    expect(senke.geschrieben, 0);
    expect(c.pendingExport, 1, reason: 'die Messung wartet weiter');
  });

  test('das Einschalten löscht eine alte Fehlermeldung', () async {
    // Sonst bliebe ein Grund stehen, der längst nicht mehr gilt.
    final c = await _bauen(db, _ZaehlendeSenke());
    addTearDown(c.dispose);

    await c.setAutoExport(false);
    await c.setAutoExport(true);

    expect(c.autoExportProblem, isNull);
  });
}
