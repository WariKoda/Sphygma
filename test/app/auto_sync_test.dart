// Autosync: Der Controller lauscht auf das Advertising und synchronisiert
// von selbst, sobald das Geraet eine hoehere Messungsnummer meldet als die
// Datenbank kennt (docs/protocol/hem-6232t.md §2.1).
//
// Bluetooth wird hier nie beruehrt - die Advertising-Meldungen kommen aus
// einem eingespeisten Stream, der Sync selbst wird durch einen
// SyncService ersetzt, der nur mitzaehlt.
import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/omron_advertising.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';

const int _omron = 0x020e;

/// Baut Herstellerdaten mit [sequence] fuer Slot 1 und [sequence2] fuer
/// Slot 2. Aufbau wie im echten Advertising (§2.1), little-endian.
OmronAdvertisedStatus _status(
  int sequence, {
  int pointer = 1,
  int sequence2 = 0,
  int pointer2 = 0,
}) =>
    parseOmronStatus({
      _omron: [
        0x01, 0x01,
        sequence & 0xff, (sequence >> 8) & 0xff,
        pointer,
        sequence2 & 0xff, (sequence2 >> 8) & 0xff,
        pointer2,
      ],
    })!;

class _CountingSyncService implements SyncService {
  _CountingSyncService(this.keyStore, this.repository, {this.onSync});

  @override
  final PairingKeyStore keyStore;
  @override
  final MeasurementRepository repository;

  /// Wird bei jedem Sync aufgerufen; wirft, wenn der Test das will.
  final Future<void> Function()? onSync;
  int syncCount = 0;

  @override
  Future<void> pair({void Function(String)? log}) async {}

  @override
  Future<SyncResult> sync({void Function(String)? log}) async {
    syncCount++;
    if (onSync != null) await onSync!();
    return SyncResult(readFromDevice: 0, newlyStored: 0);
  }
}

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _record(int sequence) => SlotRecord(
      userSlot: 1,
      record: BloodPressureRecord(
        systolic: 120,
        diastolic: 80,
        pulse: 70,
        timestamp: DateTime(2026, 9, 4, 12),
        arrhythmiaFlag: false,
        movementFlag: false,
        sequence: sequence,
      ),
      rawBytes: Uint8List(14),
    );

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late InMemoryPairingKeyStore keyStore;
  late StreamController<OmronAdvertisedStatus> advertising;
  late _CountingSyncService syncService;

  Future<AppController> boot({bool paired = true}) async {
    if (paired) await keyStore.save(Uint8List(16));
    final controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      syncService: syncService,
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => advertising.stream,
    );
    await controller.init();
    await controller.setUserSlot(1);
    return controller;
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    keyStore = InMemoryPairingKeyStore();
    advertising = StreamController<OmronAdvertisedStatus>.broadcast();
    syncService = _CountingSyncService(keyStore, repository);
  });

  tearDown(() async {
    await advertising.close();
    await db.close();
  });

  test('synchronisiert, wenn das Geraet eine neue Nummer meldet', () async {
    await repository.importAll([_record(540)]);
    final controller = await boot();

    advertising.add(_status(541));
    await pumpEventQueue();

    expect(syncService.syncCount, 1);
    controller.dispose();
  });

  test('tut nichts, wenn die gemeldete Nummer bereits bekannt ist', () async {
    await repository.importAll([_record(541)]);
    final controller = await boot();

    advertising.add(_status(541));
    await pumpEventQueue();

    expect(syncService.syncCount, 0);
    controller.dispose();
  });

  test('synchronisiert nicht mehrfach fuer dieselbe Nummer', () async {
    // Das Geraet sendet mehrmals je Sekunde dasselbe Advertising.
    await repository.importAll([_record(540)]);
    final controller = await boot();

    advertising..add(_status(541))..add(_status(541))..add(_status(541));
    await pumpEventQueue();

    expect(syncService.syncCount, 1);
    controller.dispose();
  });

  test('lauscht nicht, solange kein Pairing besteht', () async {
    final controller = await boot(paired: false);

    advertising.add(_status(541));
    await pumpEventQueue();

    expect(syncService.syncCount, 0);
    controller.dispose();
  });

  test('ein Fehlschlag loest fuer dieselbe Nummer keinen zweiten Versuch aus',
      () async {
    syncService = _CountingSyncService(
      keyStore,
      repository,
      onSync: () async => throw StateError('Verbindung weg'),
    );
    await repository.importAll([_record(540)]);
    final controller = await boot();

    advertising..add(_status(541))..add(_status(541));
    await pumpEventQueue();

    expect(syncService.syncCount, 1);
    controller.dispose();
  });

  test('nach einem Fehlschlag wird bei einer neuen Nummer erneut versucht',
      () async {
    syncService = _CountingSyncService(
      keyStore,
      repository,
      onSync: () async => throw StateError('Verbindung weg'),
    );
    await repository.importAll([_record(540)]);
    final controller = await boot();

    advertising.add(_status(541));
    await pumpEventQueue();
    advertising.add(_status(542));
    await pumpEventQueue();

    expect(syncService.syncCount, 2);
    controller.dispose();
  });

  test('ein Scan-Fehler wird sichtbar und beendet das Lauschen', () async {
    final controller = await boot();
    expect(controller.autoSyncActive, isTrue);

    advertising.addError(StateError('Bluetooth aus'));
    await pumpEventQueue();

    expect(controller.autoSyncActive, isFalse);
    expect(controller.status, contains('nicht verfuegbar'));
    controller.dispose();
  });

  test('ein Fehler in einer Meldung blockiert die naechste nicht', () async {
    // Ohne Fehlerbehandlung je Glied wuerde die Kette dauerhaft
    // vergiftet und jede weitere Meldung stillschweigend uebersprungen.
    var first = true;
    syncService = _CountingSyncService(
      keyStore,
      repository,
      onSync: () async {
        if (first) {
          first = false;
          throw StateError('einmaliger Fehler');
        }
      },
    );
    await repository.importAll([_record(540)]);
    final controller = await boot();

    advertising.add(_status(541));
    await pumpEventQueue();
    advertising.add(_status(542));
    await pumpEventQueue();

    expect(syncService.syncCount, 2);
    controller.dispose();
  });

  test('ein Slotwechsel hebt den Vermerk auf', () async {
    // Slot 2 kann dieselbe Messungsnummer tragen wie Slot 1. Ohne
    // Ruecksetzen bliebe sein Sync aus.
    await repository.importAll([_record(540)]);
    final controller = await boot();

    advertising.add(_status(541, sequence2: 541));
    await pumpEventQueue();
    expect(syncService.syncCount, 1);

    await controller.setUserSlot(2);
    advertising.add(_status(541, sequence2: 541));
    await pumpEventQueue();

    expect(syncService.syncCount, 2);
    controller.dispose();
  });

  test('nach dem Verwerfen wird nicht mehr synchronisiert', () async {
    await repository.importAll([_record(540)]);
    final controller = await boot();
    controller.dispose();

    advertising.add(_status(541));
    await pumpEventQueue();

    expect(syncService.syncCount, 0);
  });
}
