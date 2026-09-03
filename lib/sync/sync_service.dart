// Sync-Schicht (PLAN.md §4): orchestriert Readout -> DB. Health Connect
// folgt in M5 als weiterer Schritt hinter der DB, nie davor.
import 'dart:typed_data';

import '../ble/omron_session.dart';
import '../ble/pairing_key_store.dart';
import '../db/measurement_repository.dart';
import '../protocol/readout.dart';

/// Wird geworfen, wenn noch kein Pairing-Key existiert.
class NotPairedException implements Exception {
  @override
  String toString() =>
      'NotPairedException: noch nicht mit dem Geraet gepairt.';
}

class SyncResult {
  SyncResult({required this.readFromDevice, required this.newlyStored});

  final int readFromDevice;
  final int newlyStored;
}

class SyncService {
  SyncService({required this.keyStore, required this.repository});

  final PairingKeyStore keyStore;
  final MeasurementRepository repository;

  /// Erstmaliges Pairing. Erzeugt und speichert einen neuen Zufallskey und
  /// schreibt ihn ins Geraet. Das Geraet muss im Pairing-Modus sein.
  Future<void> pair({void Function(String)? log}) async {
    final key = await keyStore.loadOrCreate();
    final session = await OmronSession.open(log: log);
    try {
      await session.pair(key, log: log);
    } finally {
      await session.close();
    }
  }

  /// Voll-Readout beider Slots in die lokale DB. Dedup erledigt die DB.
  Future<SyncResult> sync({void Function(String)? log}) async {
    final Uint8List? key = await keyStore.load();
    if (key == null) {
      throw NotPairedException();
    }
    final session = await OmronSession.open(log: log);
    try {
      final transport = await session.unlock(key);
      final records = await readAllRecords(transport);
      final inserted = await repository.importAll(records);
      return SyncResult(
        readFromDevice: records.length,
        newlyStored: inserted,
      );
    } finally {
      await session.close();
    }
  }
}
