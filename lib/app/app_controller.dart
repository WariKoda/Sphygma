// Zustand und Aktionen der App (M6). Buendelt die Services der unteren
// Schichten; die UI beobachtet ihn per ListenableBuilder. Bewusst ohne
// State-Management-Paket - ein ChangeNotifier reicht fuer diese App.
import 'package:flutter/foundation.dart';

import '../ble/omron_session.dart';
import '../ble/pairing_key_store.dart';
import '../db/app_database.dart';
import '../db/measurement_repository.dart';
import '../db/settings_repository.dart';
import '../protocol/exceptions.dart';
import '../sync/export_service.dart';
import '../sync/sync_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.settings,
    required this.keyStore,
    required this.repository,
    required this.syncService,
    required this.exportService,
  });

  final SettingsRepository settings;
  final PairingKeyStore keyStore;
  final MeasurementRepository repository;
  final SyncService syncService;
  final ExportService exportService;

  int? userSlot;
  bool paired = false;
  bool busy = false;
  String? status;
  List<Measurement> measurements = const [];
  int pendingExport = 0;

  /// Deutet auf eine falsch gehende Geraeteuhr hin (Protokollreferenz §8.2):
  /// die neueste Messung liegt weit in der Vergangenheit oder in der Zukunft.
  bool clockLooksWrong = false;

  Future<void> init() async {
    userSlot = await settings.userSlot();
    paired = await keyStore.load() != null;
    await _refresh();
  }

  Future<void> setUserSlot(int slot) async {
    await settings.setUserSlot(slot);
    userSlot = slot;
    await _refresh();
  }

  Future<void> pair() => _run('Pairing…', () async {
        await syncService.pair(log: _log);
        paired = true;
        status = 'Pairing erfolgreich.';
      });

  Future<void> sync() => _run('Verbinde…', () async {
        try {
          final result = await syncService.sync(log: _log);
          status = result.newlyStored == 0
              ? 'Keine neuen Messungen (${result.readFromDevice} gelesen).'
              : '${result.newlyStored} neue Messungen.';
        } on NotPairedException {
          status = 'Noch nicht gepairt.';
          rethrow;
        } on ProtocolException catch (e) {
          // Entsperren mit dem gespeicherten Key abgelehnt -> Key im Geraet
          // passt nicht mehr (z. B. nach Neuinstallation, Risiko R-4).
          if (e.message.contains('Entsperren')) {
            paired = false;
            status = 'Das Geraet kennt diesen Key nicht mehr - bitte neu pairen.';
          }
          rethrow;
        }
      });

  Future<void> exportAll() => _run('Exportiere…', () async {
        final slot = _requireSlot();
        final n = await exportService.exportPending(userSlot: slot);
        status = '$n Messungen nach Health Connect geschrieben.';
      });

  Future<void> retractAll() => _run('Entferne…', () async {
        final slot = _requireSlot();
        final n = await exportService.retractExported(userSlot: slot);
        status = '$n Messungen aus Health Connect entfernt.';
      });

  Future<void> exportOne(Measurement m) => _run('Exportiere…', () async {
        await exportService.exportOne(m);
        status = 'Messung nach Health Connect geschrieben.';
      });

  Future<void> retractOne(Measurement m) => _run('Entferne…', () async {
        await exportService.retractOne(m);
        status = 'Messung aus Health Connect entfernt.';
      });

  int _requireSlot() {
    final slot = userSlot;
    if (slot == null) {
      throw StateError('Kein User-Slot gewaehlt.');
    }
    return slot;
  }

  void _log(String message) {
    debugPrint('[Sphygma] $message');
    status = message;
    notifyListeners();
  }

  Future<void> _run(String initial, Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    status = initial;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      debugPrint('[Sphygma] Fehler: $e');
      status = 'Fehler: $e';
      rethrow;
    } finally {
      busy = false;
      await _refresh();
    }
  }

  Future<void> _refresh() async {
    final slot = userSlot;
    if (slot == null) {
      measurements = const [];
      pendingExport = 0;
      clockLooksWrong = false;
    } else {
      measurements = (await repository.allForSlot(slot)).reversed.toList();
      pendingExport = (await repository.pendingExport(slot)).length;
      clockLooksWrong = _clockLooksWrong(measurements);
    }
    notifyListeners();
  }

  static bool _clockLooksWrong(List<Measurement> newestFirst) {
    if (newestFirst.isEmpty) return false;
    final newest = newestFirst.first.measuredAt;
    final now = DateTime.now();
    return newest.isAfter(now.add(const Duration(days: 1))) ||
        newest.isBefore(now.subtract(const Duration(days: 365)));
  }

  /// Nur zur Anzeige: erklaert die Ausnahme aus dem BLE-Scan.
  static String describe(Object error) {
    if (error is DeviceNotFoundException) {
      return 'Kein Omron gefunden. Bluetooth-Taste am Geraet kurz druecken '
          'und erneut versuchen.';
    }
    return error.toString();
  }
}
