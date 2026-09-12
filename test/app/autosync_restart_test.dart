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
import 'package:sphygma/db/measurement_metadata_repository.dart';
import 'package:sphygma/db/phase_repository.dart';
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
      metadataRepository: MeasurementMetadataRepository(db),
      phaseRepository: PhaseRepository(db),
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () {
        abos++;
        return const Stream<OmronAdvertisedStatus>.empty();
      },
    );
    addTearDown(controller.dispose);

    await SettingsRepository(db).setRawSetting('auto_sync', 'true');
    await controller.init();
    await controller.setUserSlot(1);
    expect(abos, 1, reason: 'beim Start wird einmal gelauscht');

    // Ein Abgleich ohne Gerät schlägt fehl — das ist hier gerade richtig:
    // Auch ein **gescheiterter** Abgleich hat den Scan gestoppt, und danach
    // muss wieder gelauscht werden.
    await controller.sync().catchError((_) {});
    // Das Neulauschen läuft neben der Aktion — kurz Zeit lassen.
    await Future<void>.delayed(const Duration(milliseconds: 60));

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
      metadataRepository: MeasurementMetadataRepository(db),
      phaseRepository: PhaseRepository(db),
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

    await SettingsRepository(db).setRawSetting('auto_sync', 'true');
    await controller.init();
    await controller.sync().catchError((_) {});

    expect(abos, 0);
  });

  test('das alte Abo endet, bevor das neue beginnt', () async {
    // Sonst stoppt das `finally` des alten Datenstroms den **neuen** Scan:
    // `watchOmronStatus` beendet den Scan beim Abbestellen, und das läuft
    // asynchron. Der Autosync wäre wieder tot, nur über eine Race statt über
    // die Reihenfolge (Codex-Gegenblick 09.09.2026).
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MeasurementRepository(db);
    final keyStore = InMemoryPairingKeyStore();
    await keyStore.save(Uint8List(16));

    // Das Protokoll der Ereignisse in ihrer tatsächlichen Reihenfolge.
    final ablauf = <String>[];
    final offen = <StreamController<OmronAdvertisedStatus>>[];
    addTearDown(() async {
      for (final c in offen) {
        await c.close();
      }
    });
    final controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      metadataRepository: MeasurementMetadataRepository(db),
      phaseRepository: PhaseRepository(db),
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () {
        ablauf.add('start');
        final c = StreamController<OmronAdvertisedStatus>(
          // Ein verzögertes Aufräumen, wie es der echte Scan hat: Dort wartet
          // `stopScan()` auf die Plattform.
          onCancel: () async {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            ablauf.add('stopp');
          },
        );
        // Ohne dieses Schließen bliebe der Datenstrom offen, der Test-Isolate
        // endete nie, und der Testlauf brächte den Runner zum Absturz
        // („Cannot close sink while adding stream").
        offen.add(c);
        return c.stream;
      },
    );
    addTearDown(controller.dispose);

    await SettingsRepository(db).setRawSetting('auto_sync', 'true');
    await controller.init();
    await controller.setUserSlot(1);
    await controller.sync().catchError((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(
      ablauf,
      ['start', 'stopp', 'start'],
      reason:
          'die tatsächliche Reihenfolge war $ablauf — endet das alte Abo erst '
          'nach dem neuen Start, stoppt es den neuen Scan',
    );
  });
  test('überlappende Neustarts warten auf das Ende des alten Scans', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MeasurementRepository(db);
    final keys = InMemoryPairingKeyStore();
    await keys.save(Uint8List(16));
    await SettingsRepository(db).setRawSetting('auto_sync', 'true');
    final release = Completer<void>();
    final events = <String>[];
    final streams = <StreamController<OmronAdvertisedStatus>>[];
    final c = AppController(
      settings: SettingsRepository(db),
      keyStore: keys,
      repository: repository,
      metadataRepository: MeasurementMetadataRepository(db),
      phaseRepository: PhaseRepository(db),
      syncService: SyncService(keyStore: keys, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () {
        events.add('start');
        final stream = StreamController<OmronAdvertisedStatus>(
          onCancel: () async {
            await release.future;
            events.add('stop');
          },
        );
        streams.add(stream);
        return stream.stream;
      },
    );
    addTearDown(() async {
      if (!release.isCompleted) release.complete();
      c.dispose();
      await pumpEventQueue();
      for (final stream in streams) {
        await stream.close();
      }
    });
    await c.init();
    await c.setUserSlot(1);
    await c.exportAll();
    final second = c.exportAll();
    await pumpEventQueue();
    final beforeRelease = List<String>.of(events);
    release.complete();
    await second;
    await pumpEventQueue();
    expect(beforeRelease, ['start']);
    for (var i = 1; i < events.length; i++) {
      expect(events[i], isNot(events[i - 1]), reason: '$events');
    }
    expect(events.last, 'start');
  });
}
