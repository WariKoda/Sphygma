import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/ui/history_screen.dart';
import 'package:sphygma/ui/measurement_sheet.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/today_screen.dart';
import 'package:sphygma/ui/widgets/today_vitals.dart';

import 'a3_test_support.dart';

void main() {
  late A3Harness h;
  var now = DateTime(2026, 9, 1, 23, 59);
  setUp(() async {
    now = DateTime(2026, 9, 1, 23, 59);
    h = A3Harness();
    await h.start();
    await h.controller.setWeekPanelVisible(false);
    await h.controller.setRecentMeasurementsVisible(false);
    await h.measurements.importAll([
      for (final (seq, hour, minute, sys, dia, pulse) in [
        (528, 7, 26, 128, 92, 80),
        (529, 7, 28, 126, 86, 85),
        (530, 20, 40, 115, 84, 82),
        (531, 20, 42, 114, 85, 77),
      ])
        SlotRecord(
          userSlot: 1,
          rawBytes: Uint8List(14),
          record: BloodPressureRecord(
            sequence: seq,
            timestamp: DateTime(2026, 9, 1, hour, minute),
            systolic: sys,
            diastolic: dia,
            pulse: pulse,
            arrhythmiaFlag: false,
            movementFlag: false,
          ),
        ),
    ]);
    await h.controller.refreshForTest();
  });
  tearDown(() => h.close());
  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      builder: (context, child) =>
          SphygmaThemeScope(theme: themeFor(ThemeVariant.diary), child: child!),
      home: Scaffold(
        body: TodayScreen(controller: h.controller, clock: () => now),
      ),
    ),
  );
  testWidgets(
    'Heute mit letzten Messungen passt bei großer Schrift auf 360 Pixel',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await h.controller.setRecentMeasurementsVisible(true);
      await pump(tester);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('recent-measurements')),
        300,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Originalnah trennt Blutdruck und Puls und öffnet die Tagesliste',
    (tester) async {
      await pump(tester);
      expect(find.text('Blutdruck'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Puls'), 250);
      expect(find.text('Puls'), findsOneWidget);
      final link = find.text('Alle 4 Messungen ansehen');
      await tester.scrollUntilVisible(link, 250);
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.text('Messungen vom 01.09.2026'), findsOneWidget);
      expect(find.byType(MeasurementRow), findsNWidgets(4));
      await tester.tap(find.byType(MeasurementRow).first);
      await tester.pumpAndSettle();
      expect(find.byType(MeasurementSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Tagesmittel wechseln auch ohne Abgleich über Mitternacht', (
    tester,
  ) async {
    await pump(tester);
    await tester.scrollUntilVisible(find.text('Alle 4 Messungen ansehen'), 250);
    now = DateTime(2026, 9, 2);
    await tester.pump(const Duration(minutes: 1));
    await tester.pump();
    expect(find.text('Alle 4 Messungen ansehen'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Beide Messbereiche öffnen den angezeigten Wert bei Uhr-Rückstellung',
    (tester) async {
      await h.measurements.importAll([
        SlotRecord(
          userSlot: 1,
          rawBytes: Uint8List(14),
          record: BloodPressureRecord(
            sequence: 532,
            timestamp: DateTime(2026, 8, 31, 21),
            systolic: 150,
            diastolic: 100,
            pulse: 90,
            arrhythmiaFlag: false,
            movementFlag: false,
          ),
        ),
      ]);
      await h.controller.refreshForTest();
      await pump(tester);
      final expected = h.controller.latest!;
      expect(expected.deviceSequence, 531);
      expect(
        tester.widget<TodayVitals>(find.byType(TodayVitals)).latest!.id,
        expected.id,
      );
      for (final key in ['latest-blood-pressure', 'latest-pulse']) {
        final card = find.byKey(ValueKey(key));
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        await tester.tap(card, warnIfMissed: true);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<MeasurementSheet>(find.byType(MeasurementSheet))
              .measurementId,
          expected.id,
        );
        Navigator.of(tester.element(find.byType(MeasurementSheet))).pop();
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    },
  );
}
