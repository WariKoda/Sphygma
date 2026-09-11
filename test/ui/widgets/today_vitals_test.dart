import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/app/feature_flags.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/reading_panel.dart';
import 'package:sphygma/ui/widgets/classification_scale.dart';
import 'package:sphygma/ui/widgets/surface_panel.dart';
import 'package:sphygma/ui/widgets/today_vitals.dart';

Measurement reading(int sequence, DateTime at, int sys, int dia, int pulse) =>
    Measurement(
      id: sequence,
      userSlot: 1,
      deviceSequence: sequence,
      measuredAt: at,
      systolic: sys,
      diastolic: dia,
      pulse: pulse,
      arrhythmia: false,
      movement: false,
      rawBytes: Uint8List(14),
      importedAt: DateTime.utc(2026, 9, 11),
    );

void main() {
  final now = DateTime(2026, 9, 11, 21);
  final values = [
    reading(1, DateTime(2026, 9, 11, 7), 120, 80, 70),
    reading(2, DateTime(2026, 9, 11, 9), 130, 90, 80),
    reading(3, DateTime(2026, 9, 11, 18), 110, 70, 60),
    reading(4, DateTime(2026, 9, 10, 20, 42), 140, 95, 90),
  ];

  Future<void> pump(
    WidgetTester tester, {
    required ThemeVariant variant,
    List<Measurement>? measurements,
    Measurement? latestMeasurement,
    bool noLatest = false,
    VoidCallback? latest,
    VoidCallback? today,
    double textScale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: SphygmaThemeScope(theme: themeFor(variant), child: child!),
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: TodayVitals(
              measurements: measurements ?? values,
              latest: noLatest ? null : latestMeasurement ?? values.last,
              now: now,
              onOpenLatest: latest,
              onOpenToday: today,
            ),
          ),
        ),
      ),
    );
  }

  for (final variant in allVariants) {
    testWidgets('rendert ${variant.name} bei 360px und Textfaktor 2', (
      tester,
    ) async {
      await pump(tester, variant: variant, textScale: 2);

      expect(find.byType(ReadingPanel), findsOneWidget);
      expect(find.byType(SurfacePanel), findsWidgets);
      expect(find.text('Blutdruck'), findsOneWidget);
      expect(find.text('Puls'), findsOneWidget);
      expect(find.textContaining('140'), findsWidgets);
      expect(find.textContaining('90'), findsWidgets);
      expect(
        find.byType(ClassificationScale),
        escClassificationEnabled ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('zeigt Datum der explizit letzten Messung auch von gestern', (
    tester,
  ) async {
    await pump(tester, variant: ThemeVariant.instrument);

    expect(find.textContaining('10.09.2026'), findsNWidgets(2));
    expect(find.textContaining('20:42'), findsNWidgets(2));
  });

  testWidgets('verwendet latest statt selbst nach Sequenz auszuwählen', (
    tester,
  ) async {
    await pump(
      tester,
      variant: ThemeVariant.instrument,
      measurements: [values.last, values.first],
      latestMeasurement: values.first,
    );

    expect(find.textContaining('11.09.2026'), findsNWidgets(2));
    expect(find.textContaining('07:00'), findsNWidgets(4));
    expect(find.textContaining('10.09.2026'), findsNothing);
  });

  testWidgets('mittelt nur heutige Morgen- und Abendwerte samt Anzahl', (
    tester,
  ) async {
    await pump(tester, variant: ThemeVariant.instrument);

    expect(find.textContaining('125/85'), findsOneWidget);
    expect(find.text('75'), findsOneWidget);
    expect(find.text('2 Messungen'), findsNWidgets(2));
    expect(find.textContaining('110/70'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('1 Messung'), findsNWidgets(2));
    expect(find.text('07:00–09:00'), findsNWidgets(2));
    expect(find.text('18:00'), findsNWidgets(2));
    expect(find.text('Alle 3 Messungen ansehen'), findsOneWidget);
  });

  testWidgets('leere Bänder zeigen keine erfundenen Nullwerte', (tester) async {
    await pump(
      tester,
      variant: ThemeVariant.instrument,
      measurements: [values.last],
      noLatest: true,
    );

    expect(find.text('Noch keine Messung'), findsNWidgets(6));
    expect(find.textContaining('0 Mess'), findsNothing);
    expect(find.textContaining('Alle '), findsNothing);
  });

  testWidgets('Mittelwert und Leertext verwenden die Nacht-Schriftfarbe', (
    tester,
  ) async {
    final night = themeFor(ThemeVariant.aura);
    await pump(
      tester,
      variant: ThemeVariant.aura,
      measurements: [values.first],
      latestMeasurement: values.first,
    );

    for (final mean in tester.widgetList<Text>(find.text('120/80'))) {
      expect(mean.style?.color, night.onSurface);
    }
    for (final empty in tester.widgetList<Text>(
      find.text('Noch keine Messung'),
    )) {
      expect(empty.style?.color, night.onSurface);
    }
  });

  testWidgets('beide letzte Werte und der Tageslink sind bedienbar', (
    tester,
  ) async {
    var latest = 0;
    var today = 0;
    await pump(
      tester,
      variant: ThemeVariant.instrument,
      latest: () => latest++,
      today: () => today++,
    );

    await tester.tap(find.byKey(const ValueKey('latest-blood-pressure')));
    await tester.tap(find.byKey(const ValueKey('latest-pulse')));
    await tester.ensureVisible(find.text('Alle 3 Messungen ansehen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alle 3 Messungen ansehen'));

    expect(latest, 2);
    expect(today, 1);
  });

  testWidgets('Band färbt nur Blutdruck und lässt Puls neutral', (
    tester,
  ) async {
    await pump(tester, variant: ThemeVariant.pegel);

    final panels = tester
        .widgetList<SurfacePanel>(find.byType(SurfacePanel))
        .toList();
    expect(panels.first.tint, isNotNull);
    expect(panels[1].tint, isNull);
  });

  testWidgets(
    'Mittelwerte stehen normal nebeneinander und bei Text 2 gestapelt',
    (tester) async {
      await pump(tester, variant: ThemeVariant.diary);
      var morning = tester.getTopLeft(find.text('Morgenmittelwert').first);
      var evening = tester.getTopLeft(find.text('Abendmittelwert').first);
      expect((morning.dy - evening.dy).abs(), lessThan(1));

      await pump(tester, variant: ThemeVariant.diary, textScale: 2);
      morning = tester.getTopLeft(find.text('Morgenmittelwert').first);
      evening = tester.getTopLeft(find.text('Abendmittelwert').first);
      expect(evening.dy, greaterThan(morning.dy));
    },
  );
}
