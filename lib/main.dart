// Einstiegspunkt der App (M6). Baut die Schichten von unten nach oben
// zusammen (PLAN.md §4): DB -> Repositories -> Sync/Export -> Controller -> UI.
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';

import 'app/app_controller.dart';
import 'ble/pairing_key_store.dart';
import 'db/app_database.dart';
import 'db/measurement_repository.dart';
import 'db/occasion_repository.dart';
import 'db/settings_repository.dart';
import 'sync/export_service.dart';
import 'sync/health_connect_sink.dart';
import 'sync/sync_service.dart';
import 'ui/sphygma_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase(driftDatabase(name: 'sphygma'));
  final measurements = MeasurementRepository(database);
  final keyStore = SecureStoragePairingKeyStore();
  final controller = AppController(
    settings: SettingsRepository(database),
    keyStore: keyStore,
    repository: measurements,
    occasionRepository: OccasionRepository(database),
    syncService: SyncService(keyStore: keyStore, repository: measurements),
    exportService: ExportService(
      repository: measurements,
      sink: HealthConnectSink(),
    ),
  );
  await controller.init();

  runApp(SphygmaApp(controller: controller));
}
