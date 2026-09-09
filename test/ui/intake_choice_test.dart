// Die Wahl beim Koppeln: Was übernommen wird, und was verborgen bleibt.
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

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite w) async {}
  @override
  Future<void> deleteBloodPressure(String id) async {}
}

SlotRecord _rec(int seq, DateTime at) => SlotRecord(
  userSlot: 1,
  record: BloodPressureRecord(
    systolic: 140,
    diastolic: 90,
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
    await repository.importAll([
      for (var i = 1; i <= 5; i++) _rec(i, DateTime(2026, 7, 10 + i, 8)),
    ]);
    await controller.refreshForTest();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  test('„alles" lässt jede Messung stehen', () async {
    await controller.takeAll();
    expect(controller.measurements, hasLength(5));
    expect(controller.intakeFloor, isNull);
  });

  test('„nur neue" verbirgt alles Bekannte, ohne es zu löschen', () async {
    await controller.takeOnlyNew();

    expect(controller.measurements, isEmpty, reason: 'nichts mehr sichtbar');
    // Aber: Die Messungstabelle bleibt reines Abbild des Geräts.
    final roh = await db.select(db.measurements).get();
    expect(roh, hasLength(5), reason: 'gelöscht wird nichts');
    expect(await repository.highestSequenceFor(1), 5,
        reason: 'der Abgleich kennt weiter die höchste Nummer');
  });

  test('„ab Datum" übersetzt einmal in eine Messungsnummer', () async {
    await controller.takeFrom(DateTime(2026, 7, 13));

    expect(controller.intakeFloor, 3);
    // Der Steuerungsteil liefert neueste zuerst — die Reihenfolge ist seine
    // Sache, nicht die der Grenze.
    expect(controller.measurements.map((m) => m.deviceSequence), [5, 4, 3]);
  });

  test('was verborgen ist, geht auch nicht an Health Connect', () async {
    // Der eigentliche Zweck: Ausgeblendetes darf nicht in die
    // Gesundheitsakte. Eine Anzeigefilterung allein wäre zu wenig.
    await controller.takeFrom(DateTime(2026, 7, 14));

    final offen = await repository.pendingExport(1);
    expect(offen.map((m) => m.deviceSequence), [4, 5]);
  });

  test('die Wahl überlebt den Neustart', () async {
    await controller.takeOnlyNew();
    // Der erste Steuerungsteil wird im Abbau entsorgt — hier nur ein
    // zweiter daneben, der aus derselben Datenbank liest.

    final zweiter = AppController(
      settings: SettingsRepository(db),
      keyStore: InMemoryPairingKeyStore(),
      repository: repository,
      occasionRepository: OccasionRepository(db),
      syncService: SyncService(
        keyStore: InMemoryPairingKeyStore(),
        repository: repository,
      ),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await zweiter.init();
    addTearDown(zweiter.dispose);

    expect(zweiter.intakeFloor, 6);
    expect(zweiter.measurements, isEmpty);
  });

  test('ohne Speicherplatz wirft die Wahl, statt zu raten', () async {
    // Ein Standard wäre gefährlich: Er könnte die Messungen des falschen
    // Benutzers ausblenden oder freigeben.
    final ohne = AppController(
      settings: SettingsRepository(db),
      keyStore: InMemoryPairingKeyStore(),
      repository: repository,
      occasionRepository: OccasionRepository(db),
      syncService: SyncService(
        keyStore: InMemoryPairingKeyStore(),
        repository: repository,
      ),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    addTearDown(ohne.dispose);

    expect(ohne.takeOnlyNew, throwsStateError);
  });

  test('Ausblenden versperrt nicht den Rückweg aus Health Connect', () async {
    // Wurde eine Messung exportiert und erst danach ausgeblendet, ist sie in
    // der Gesundheitsakte bereits da. Fände `exported()` sie nicht mehr,
    // bliebe sie dort für immer — die App könnte sie nicht mehr entfernen.
    // Gefunden im Codex-Gegenblick am 09.09.2026.
    await controller.exportAll();
    expect(await repository.exported(1), hasLength(5));

    await controller.takeOnlyNew();

    expect(controller.measurements, isEmpty, reason: 'nichts mehr sichtbar');
    expect(
      await repository.exported(1),
      hasLength(5),
      reason: 'aber alles bleibt zurückziehbar',
    );
  });

  test('die Übernahme lässt sich ohne Gerät ändern', () async {
    // Das Auswahlblatt verspricht, später wieder freizugeben. Wäre es nur
    // nach erneutem Koppeln erreichbar, wäre das Versprechen leer — wer sein
    // Messgerät nicht zur Hand hat, käme nie wieder daran.
    await controller.takeOnlyNew();
    expect(controller.measurements, isEmpty);

    await controller.takeAll();
    expect(controller.measurements, hasLength(5));
    expect(controller.intakeFloor, isNull);
  });
}
