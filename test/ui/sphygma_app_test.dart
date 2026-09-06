// test/ui/sphygma_app_test.dart
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/app/concept.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/concepts/day_profile/day_profile_screen.dart';
import 'package:sphygma/ui/device_screen.dart';
import 'package:sphygma/ui/history_screen.dart';
import 'package:sphygma/ui/sphygma_app.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/today_screen.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    keyStore = InMemoryPairingKeyStore();
    await keyStore.save(Uint8List(16));
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    await controller.setUserSlot(1);
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  testWidgets('startet auf Heute', (tester) async {
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('wechselt in die drei Bereiche', (tester) async {
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verlauf'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);

    await tester.tap(find.text('Gerät'));
    await tester.pumpAndSettle();
    expect(find.byType(DeviceScreen), findsOneWidget);

    await tester.tap(find.text('Heute'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('die gewählte Gestaltung liegt über dem Baum', (tester) async {
    await controller.setThemeVariant(ThemeVariant.diary);
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(TodayScreen));
    expect(
      SphygmaTheme.of(context).name,
      themeFor(ThemeVariant.diary).name,
    );
  });

  testWidgets('ein Gestaltungswechsel schlägt sofort durch', (tester) async {
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    await controller.setThemeVariant(ThemeVariant.material);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(TodayScreen));
    expect(
      SphygmaTheme.of(context).name,
      themeFor(ThemeVariant.material).name,
    );
  });

  testWidgets('das Konzept bestimmt den ersten Bildschirm', (tester) async {
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);

    await controller.setConcept(AppConcept.tagesprofil);
    await tester.pumpAndSettle();

    expect(find.byType(DayProfileScreen), findsOneWidget);
    expect(find.byType(TodayScreen), findsNothing);
  });

  testWidgets('der Gerätebereich bleibt in jedem Konzept erreichbar',
      (tester) async {
    // Dort wird das Konzept gewechselt — wäre er in einem Konzept
    // unerreichbar, käme man nicht mehr heraus.
    await controller.setConcept(AppConcept.tagesprofil);
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gerät'));
    await tester.pumpAndSettle();

    expect(find.byType(DeviceScreen), findsOneWidget);
  });

  testWidgets('eine Meldung des Steuerungsteils erscheint', (tester) async {
    await tester.pumpWidget(SphygmaApp(controller: controller));
    await tester.pumpAndSettle();

    // Ein Export ohne offene Messungen meldet "0 Messungen" - eine
    // Meldung ohne Geraet und ohne Fehler.
    await controller.exportAll();
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
