import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_metadata_repository.dart';
import 'package:sphygma/db/measurement_plan_repository.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/phase_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/plan/plan_controller.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/app_home.dart';
import 'package:sphygma/ui/plan/measurement_plan_screen.dart';
import 'package:sphygma/ui/settings_screen.dart';
import 'package:sphygma/ui/sphygma_app.dart';
import 'package:sphygma/ui/today_screen.dart';

import '../../plan/plan_controller_test.dart' show FakeReminderGateway;
import '../a3_test_support.dart' show NoopSink;

void main() {
  late AppDatabase db;
  late PlanController plan;
  late AppController app;
  late FakeReminderGateway gateway;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final measurements = MeasurementRepository(db);
    final settings = SettingsRepository(db);
    await settings.setUserSlot(1);
    final keys = InMemoryPairingKeyStore();
    gateway = FakeReminderGateway(DateTime.now);
    plan = PlanController(
      repository: MeasurementPlanRepository(db),
      measurements: measurements,
      gateway: gateway,
    );
    app = AppController(
      settings: settings,
      keyStore: keys,
      repository: measurements,
      metadataRepository: MeasurementMetadataRepository(db),
      phaseRepository: PhaseRepository(db),
      syncService: SyncService(keyStore: keys, repository: measurements),
      exportService: ExportService(repository: measurements, sink: NoopSink()),
      planController: plan,
      statusStream: () => const Stream.empty(),
    );
    await app.init();
  });
  tearDown(() async {
    app.dispose();
    plan.dispose();
    await db.close();
  });

  testWidgets('Konfiguration schaltet Tab vollständig ein und aus', (
    tester,
  ) async {
    await tester.pumpWidget(SphygmaApp(controller: app));
    await tester.pumpAndSettle();
    expect(find.byType(AppHome), findsOneWidget);
    expect(find.text('Messplan'), findsNothing);
    expect(gateway.accessRequests, 0);
    await tester.runAsync(() => plan.setEnabled(true));
    await tester.pumpAndSettle();
    expect(find.text('Messplan'), findsOneWidget);
    await tester.tap(find.text('Messplan'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsNothing);
    await tester.runAsync(() => plan.setEnabled(false));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('Messplan'), findsNothing);
  });

  testWidgets(
    'Einstellungen bieten globalen Messplan-Schalter samt Fehlerstatus',
    (tester) async {
      await tester.pumpWidget(SphygmaApp(controller: app));
      await tester.tap(find.byTooltip('Einstellungen'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      final toggle = find.byKey(const Key('measurement-plan-enabled'));
      await tester.scrollUntilVisible(toggle, 350);
      expect(toggle, findsOneWidget);
      gateway.fail = true;
      await tester.runAsync(() async {
        final settled = Completer<void>();
        void observe() {
          if (!plan.busy && plan.error != null && !settled.isCompleted) {
            settled.complete();
          }
        }

        plan.addListener(observe);
        try {
          await tester.tap(toggle);
          await settled.future.timeout(const Duration(seconds: 5));
        } finally {
          plan.removeListener(observe);
        }
      });
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Native Planung fehlgeschlagen'),
        findsWidgets,
      );
    },
  );

  test(
    'Appinitialisierung und Slotwechsel aktualisieren PlanController',
    () async {
      expect(gateway.snapshots, isNotEmpty);
      expect(plan.userSlot, 1);
      await app.setUserSlot(2);
      expect(plan.userSlot, 2);
    },
  );
  testWidgets(
    'Benachrichtigungsstart öffnet Messplan bereits beim ersten Aufbau',
    (tester) async {
      await tester.runAsync(() async {
        await plan.setEnabled(true);
        gateway.openPlan = true;
        await plan.reconcileReminders();
        gateway.openPlan = false;
      });
      await tester.pumpWidget(SphygmaApp(controller: app));
      await tester.pumpAndSettle();
      expect(find.byType(MeasurementPlanScreen), findsOneWidget);
    },
  );
}
