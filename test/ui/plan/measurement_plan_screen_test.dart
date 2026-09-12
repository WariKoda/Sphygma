import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/measurement_plan_repository.dart';
import 'package:sphygma/plan/plan_controller.dart';
import 'package:sphygma/plan/reminder_gateway.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/ui/plan/occurrence_assignment_sheet.dart';
import 'package:sphygma/ui/plan/measurement_plan_screen.dart';
import 'package:sphygma/ui/plan/plan_editor.dart';
import 'package:sphygma/ui/plan/plan_today_card.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

import '../../plan/plan_controller_test.dart' show FakeReminderGateway;
import '../a3_test_support.dart';

void main() {
  late A3Harness harness;
  late PlanController plan;
  late FakeReminderGateway gateway;
  final now = DateTime.utc(2024, 3, 15, 7, 30);
  setUp(() async {
    harness = A3Harness();
    await harness.start();
    gateway = FakeReminderGateway(() => now);
    plan = PlanController(
      repository: MeasurementPlanRepository(harness.db, now: () => now),
      measurements: harness.measurements,
      gateway: gateway,
      now: () => now,
    );
    await plan.setUserSlot(1);
  });
  tearDown(() async {
    plan.dispose();
    await harness.close();
  });
  Widget wrap(
    Widget child, {
    ThemeVariant variant = ThemeVariant.instrument,
    double scale = 1,
  }) => MaterialApp(
    builder: (context, navigator) => SphygmaThemeScope(
      theme: themeFor(variant),
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: navigator!,
      ),
    ),
    home: Scaffold(body: child),
  );
  for (final mode in [
    ReminderMode.off,
    ReminderMode.inexact,
    ReminderMode.blocked,
    ReminderMode.failed,
  ]) {
    testWidgets('Erinnerungshilfe $mode bietet wirksamen nächsten Schritt', (
      tester,
    ) async {
      await tester.runAsync(() => plan.setEnabled(true));
      if (mode != ReminderMode.off) {
        await tester.runAsync(() => plan.saveTimes([480]));
      }
      plan.mode = mode;
      await tester.pumpWidget(
        wrap(
          MeasurementPlanScreen(
            planController: plan,
            controller: harness.controller,
          ),
        ),
      );
      await tester.scrollUntilVisible(find.text('Was bedeutet das?'), 180);
      await tester.ensureVisible(find.text('Was bedeutet das?'));
      await tester.pumpAndSettle();
      await tester.runAsync(() => tester.tap(find.text('Was bedeutet das?')));
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      final label = switch (mode) {
        ReminderMode.off => 'Messplan anlegen',
        ReminderMode.failed => 'Erneut einrichten',
        _ => 'Berechtigungen prüfen',
      };
      final button = find.descendant(of: dialog, matching: find.text(label));
      expect(button, findsOneWidget);
      final accesses = gateway.accessRequests;
      final snapshots = gateway.snapshots.length;
      await tester.tap(button);
      bool actionFinished() => switch (mode) {
        ReminderMode.off => find.byType(PlanEditor).evaluate().isNotEmpty,
        ReminderMode.failed =>
          !plan.busy && gateway.snapshots.length > snapshots,
        _ => !plan.busy && gateway.accessRequests > accesses,
      };
      final deadline = Stopwatch()..start();
      while (!actionFinished() &&
          deadline.elapsed < const Duration(seconds: 5)) {
        await tester.pump();
        // Dialoganimation läuft im Testtakt, SQLite antwortet im echten Isolat.
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 1)),
        );
      }
      await tester.pumpAndSettle();
      if (mode == ReminderMode.off) {
        expect(find.byType(PlanEditor), findsOneWidget);
      } else if (mode == ReminderMode.failed) {
        expect(gateway.snapshots.length, greaterThan(snapshots));
      } else {
        expect(gateway.accessRequests, accesses + 1);
        expect(gateway.calls, contains('openAccessSettings'));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ausgeschaltet zeigt weder Karte noch Einrichtung oder Prompt', (
    tester,
  ) async {
    await tester.runAsync(plan.load);
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            Expanded(
              child: MeasurementPlanScreen(
                planController: plan,
                controller: harness.controller,
              ),
            ),
            PlanTodayCard(planController: plan),
          ],
        ),
      ),
    );
    expect(find.text('Messplan anlegen'), findsNothing);
    expect(find.text('Uhrzeiten bearbeiten'), findsNothing);
    expect(gateway.accessRequests, 0);
  });
  testWidgets('aktiv ohne Plan öffnet Editor und weist leere Zeiten ab', (
    tester,
  ) async {
    await tester.runAsync(() => plan.setEnabled(true));
    await tester.pumpWidget(
      wrap(
        MeasurementPlanScreen(
          planController: plan,
          controller: harness.controller,
        ),
      ),
    );
    await tester.tap(find.text('Messplan anlegen'));
    await tester.pumpAndSettle();
    expect(find.byType(PlanEditor), findsOneWidget);
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(
      find.text('Bitte mindestens eine Uhrzeit hinzufügen.'),
      findsOneWidget,
    );
    expect(plan.currentSlotPlan, isNull);
  });
  testWidgets('drei und fünf tägliche Zeiten werden gespeichert', (
    tester,
  ) async {
    await tester.runAsync(() => plan.setEnabled(true));
    for (final minutes in [
      [480, 720, 1200],
      [480, 600, 720, 960, 1200],
    ]) {
      await tester.pumpWidget(
        wrap(
          PlanEditor(
            key: ValueKey(minutes.length),
            initialMinutes: minutes,
            onSave: plan.saveTimes,
          ),
        ),
      );
      await tester.runAsync(() async {
        await tester.tap(find.text('Speichern'));
        await plan.reconcileReminders();
      });
      await tester.pumpAndSettle();
      expect(plan.currentSlotPlan!.minutes, minutes);
      expect(plan.currentSlotPlan!.plan.endedAt, isNull);
    }
  });
  testWidgets('alle Formen tragen Status und vertragen große Systemschrift', (
    tester,
  ) async {
    await tester.runAsync(() => plan.setEnabled(true));
    await tester.runAsync(() => plan.saveTimes([480, 720, 1200]));
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final variant in allVariants) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        wrap(
          MeasurementPlanScreen(
            planController: plan,
            controller: harness.controller,
          ),
          variant: variant,
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Erinnerungen aktiv'), 180);
      expect(find.text('Erinnerungen aktiv'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Was bedeutet das?'), 180);
      await tester.ensureVisible(find.text('Was bedeutet das?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Was bedeutet das?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Uhrzeiten deines Messplans'), findsOneWidget);
      await tester.tap(find.text('Verstanden'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('20:00 Uhr'), 180);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets(
    'Heute nennt echte Zuordnungsanzahl ohne fehlende Messung zu behaupten',
    (tester) async {
      await tester.runAsync(() => plan.setEnabled(true));
      await tester.runAsync(() => plan.saveTimes([480, 720, 1200]));
      await tester.pumpWidget(wrap(PlanTodayCard(planController: plan)));
      expect(find.text('0 von 3 Terminen zugeordnet'), findsOneWidget);
      expect(find.textContaining('Nicht gemessen'), findsNothing);
    },
  );
  testWidgets(
    'offene Tagesliste zeigt erfüllte Termine und nachgeladene Messwerte',
    (tester) async {
      await tester.runAsync(() async {
        await plan.setEnabled(true);
        await plan.saveTimes([465, 720]);
      });
      await tester.pumpWidget(
        wrap(
          MeasurementPlanScreen(
            planController: plan,
            controller: harness.controller,
          ),
        ),
      );
      await tester.scrollUntilVisible(find.text('12:00 Uhr'), 180);
      expect(find.text('07:45 Uhr'), findsOneWidget);
      expect(find.text('Noch keine Messung zugeordnet'), findsNWidgets(2));
      expect(find.byIcon(Icons.remove_circle_outline), findsNWidgets(2));
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);

      final raw = Uint8List.fromList([
        0x55,
        0x6b,
        0x18,
        0x44,
        0x0d,
        0xe7,
        0x0a,
        0xa1,
        0,
        0,
        0,
        1,
        0,
        0,
      ]);
      final record = parseRecord(raw)!;
      // Beim Sync wird zuerst der Plan und erst danach die UI-Messungsliste geladen.
      await tester.runAsync(() async {
        await harness.measurements.importAll([
          SlotRecord(userSlot: 1, record: record, rawBytes: raw),
        ]);
        await plan.refreshAfterSync();
      });
      await tester.pumpAndSettle();
      expect(find.text('Zugeordnete Messung wird geladen…'), findsOneWidget);
      await tester.runAsync(() => harness.controller.refreshForTest());
      await tester.pumpAndSettle();
      expect(find.text('Zugeordnete Messung wird geladen…'), findsNothing);
      expect(
        find.textContaining('${record.systolic}/${record.diastolic} mmHg'),
        findsOneWidget,
      );
      expect(find.textContaining('Puls ${record.pulse} bpm'), findsOneWidget);
      expect(find.text('07:45 Uhr'), findsOneWidget);
      expect(find.text('12:00 Uhr'), findsOneWidget);
      expect(find.text('Noch keine Messung zugeordnet'), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Zeitpicker lehnt doppelte Uhrzeit ab', (tester) async {
    await tester.pumpWidget(
      wrap(PlanEditor(initialMinutes: const [480], onSave: (_) async {})),
    );
    await tester.tap(find.text('Uhrzeit hinzufügen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();
    expect(find.text('Diese Uhrzeit ist bereits im Messplan.'), findsOneWidget);
    expect(find.text('08:00 Uhr'), findsOneWidget);
  });
  testWidgets('vorhandene Messung wird manuell zugeordnet ohne Werteänderung', (
    tester,
  ) async {
    final raw = Uint8List.fromList([
      0x55,
      0x6b,
      0x18,
      0x44,
      0x0d,
      0xe7,
      0x0a,
      0xa1,
      0,
      0,
      0,
      1,
      0,
      0,
    ]);
    await tester.runAsync(() async {
      await plan.setEnabled(true);
      await plan.saveTimes([720]);
      await harness.measurements.importAll([
        SlotRecord(userSlot: 1, record: parseRecord(raw)!, rawBytes: raw),
      ]);
      await harness.controller.refreshForTest();
      await plan.refreshAfterSync();
    });
    final before = harness.controller.measurements.single;
    await tester.pumpWidget(
      wrap(
        MeasurementPlanScreen(
          planController: plan,
          controller: harness.controller,
        ),
      ),
    );
    await tester.ensureVisible(find.text('12:00 Uhr'));
    await tester.tap(find.text('12:00 Uhr'));
    await tester.pumpAndSettle();
    expect(find.byType(OccurrenceAssignmentSheet), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.textContaining('mmHg · Puls'));
      await plan.reconcileReminders();
    });
    await tester.pumpAndSettle();
    expect(plan.fulfillment.values.single, (userSlot: 1, deviceSequence: 1));
    final after = await tester.runAsync(
      () => harness.measurements.allForSlot(1),
    );
    expect(after!.single.rawBytes, before.rawBytes);
    expect(after.single.measuredAt, before.measuredAt);
    expect(after.single.exportedAt, before.exportedAt);
  });
  testWidgets('Beenden bestätigt den Vorgang und lässt neuen Plan zu', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await plan.setEnabled(true);
      await plan.saveTimes([480]);
    });
    await tester.pumpWidget(
      wrap(
        MeasurementPlanScreen(
          planController: plan,
          controller: harness.controller,
        ),
      ),
    );
    await tester.runAsync(() => tester.tap(find.text('Messplan beenden')));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Beenden'));
      await Future<void>.delayed(Duration.zero);
      await plan.reconcileReminders();
    });
    await tester.pumpAndSettle();
    expect(plan.currentSlotPlan!.plan.endedAt, isNotNull);
    expect(find.text('Messplan anlegen'), findsOneWidget);
    await tester.pumpWidget(wrap(PlanTodayCard(planController: plan)));
    expect(find.text('Messplan heute'), findsNothing);
  });
  testWidgets(
    'nativer Fehler bleibt sichtbar und erneuter Abgleich ist erreichbar',
    (tester) async {
      await tester.runAsync(() async {
        await plan.setEnabled(true);
        await plan.saveTimes([480]);
      });
      gateway.fail = true;
      await tester.runAsync(() async {
        await expectLater(
          plan.reconcileReminders(),
          throwsA(
            predicate<Object>(
              (error) =>
                  error.toString().contains('Native Planung fehlgeschlagen'),
            ),
          ),
        );
      });
      await tester.pumpWidget(
        wrap(
          MeasurementPlanScreen(
            planController: plan,
            controller: harness.controller,
          ),
        ),
      );
      expect(find.text('Erinnerungen nicht bestätigt'), findsOneWidget);
      expect(
        find.textContaining('Native Planung fehlgeschlagen'),
        findsOneWidget,
      );
      gateway.fail = false;
      await tester.runAsync(() async {
        await tester.tap(find.text('Erneut abgleichen'));
        await plan.reconcileReminders();
      });
      await tester.pumpAndSettle();
      expect(find.text('Erinnerungen aktiv'), findsOneWidget);
    },
  );
}
