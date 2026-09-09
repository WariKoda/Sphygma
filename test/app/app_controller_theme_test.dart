import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/occasion_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
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

void main() {
  late AppDatabase db;
  late SettingsRepository settings;
  late AppController controller;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsRepository(db);
    final repository = MeasurementRepository(db);
    final keyStore = InMemoryPairingKeyStore();
    controller = AppController(
      settings: settings,
      keyStore: keyStore,
      repository: repository,
      occasionRepository: OccasionRepository(db),
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
  });
  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  for (final variant in allVariants) {
    test('init übernimmt die migrierte Diagonale $variant', () async {
      await settings.setRawSetting('theme_variant', variant.name);
      await controller.init();
      final axes = axesFor(variant);
      expect(controller.characteristic, axes.characteristic);
      expect(controller.palette, axes.palette);
      expect(controller.typeface, axes.typeface);
      expect(controller.themeVariant, variant);
    });
  }

  test('Setter speichern unabhängig und melden die Änderung', () async {
    await controller.init();
    var notifications = 0;
    controller.addListener(() => notifications++);
    await controller.setCharacteristic(Characteristic.band);
    expect(notifications, 1);
    expect(controller.characteristic, Characteristic.band);
    expect(await settings.characteristic(), Characteristic.band);
    expect(controller.palette, Palette.papier);
    await controller.setPalette(Palette.nacht);
    expect(notifications, 2);
    expect(controller.palette, Palette.nacht);
    expect(await settings.palette(), Palette.nacht);
    expect(controller.characteristic, Characteristic.band);
    await controller.setTypeface(Typeface.system);
    expect(notifications, 3);
    expect(controller.typeface, Typeface.system);
    expect(await settings.typeface(), Typeface.system);
    expect(controller.theme.surface, Palette.nacht.grund);
    expect(controller.theme.radius, 0);
    expect(controller.themeVariant, ThemeVariant.pegel);
    await controller.init();
    expect(controller.characteristic, Characteristic.band);
    expect(controller.palette, Palette.nacht);
  });

  test('alte Auswahl ersetzt alle Achsen in einer Benachrichtigung', () async {
    await controller.init();
    await controller.setPalette(Palette.flieder);
    var notifications = 0;
    controller.addListener(() => notifications++);
    await controller.setThemeVariant(ThemeVariant.aura);
    expect(notifications, 1);
    expect(controller.characteristic, Characteristic.luft);
    expect(controller.palette, Palette.nacht);
    expect(controller.typeface, Typeface.system);
    expect(controller.themeVariant, ThemeVariant.aura);
    expect(await settings.characteristic(), Characteristic.luft);
    expect(await settings.palette(), Palette.nacht);
  });
}
