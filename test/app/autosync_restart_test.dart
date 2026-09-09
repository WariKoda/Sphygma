// Der Autosync muss einen Abgleich überleben.
//
// Ein Abgleich verbindet sich mit dem Gerät, und dafür startet
// `OmronSession.scan()` einen eigenen Scan — der ersetzt den Dauerscan des
// Autosyncs und wird danach beendet. Danach läuft kein Scan mehr: Das Abo
// steht noch, bekommt aber nie wieder ein Advertising.
//
// Das Symptom am Gerät: Wer die App offen lässt und misst, bekommt nichts
// übertragen; nach einem Neustart der App klappt es. Genau einmal, dann
// wieder nicht.
import 'dart:async';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/omron_advertising.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/occasion_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite w) async {}
  @override
  Future<void> deleteBloodPressure(String id) async {}
}

void main() {
  test('nach einem Abgleich wird wieder gelauscht', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MeasurementRepository(db);
    final keyStore = InMemoryPairingKeyStore();
    await keyStore.save(Uint8List(16));

    // Zählt, wie oft der Datenstrom neu abonniert wurde. Der Scan lebt genau
    // so lange wie ein Abo — wird nach dem Abgleich nicht neu abonniert,
    // lauscht niemand mehr.
    var abos = 0;
    final controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      occasionRepository: OccasionRepository(db),
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () {
        abos++;
        return const Stream<OmronAdvertisedStatus>.empty();
      },
    );
    addTearDown(controller.dispose);

    await controller.init();
    await controller.setUserSlot(1);
    expect(abos, 1, reason: 'beim Start wird einmal gelauscht');

    // Ein Abgleich ohne Gerät schlägt fehl — das ist hier gerade richtig:
    // Auch ein **gescheiterter** Abgleich hat den Scan gestoppt, und danach
    // muss wieder gelauscht werden.
    await controller.sync().catchError((_) {});

    expect(
      abos,
      greaterThan(1),
      reason:
          'nach dem Abgleich wurde nicht neu gelauscht — der Autosync wäre '
          'tot, bis die App neu startet',
    );
  });

  test('ohne Kopplung wird nicht gelauscht', () async {
    // Ohne Key gibt es nichts zu holen; ein Scan wäre reine Akkulast.
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MeasurementRepository(db);
    var abos = 0;
    final controller = AppController(
      settings: SettingsRepository(db),
      keyStore: InMemoryPairingKeyStore(),
      repository: repository,
      occasionRepository: OccasionRepository(db),
      syncService: SyncService(
        keyStore: InMemoryPairingKeyStore(),
        repository: repository,
      ),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () {
        abos++;
        return const Stream<OmronAdvertisedStatus>.empty();
      },
    );
    addTearDown(controller.dispose);

    await controller.init();
    await controller.sync().catchError((_) {});

    expect(abos, 0);
  });
}
