// Der Bildschirm beim Oeffnen. Vorn steht der Wert, nicht die Technik.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../db/app_database.dart';
import 'theme/sphygma_theme.dart';
import 'widgets/notice_card.dart';
import 'widgets/reading_panel.dart';
import 'measurement_sheet.dart';
import 'history_screen.dart' show MeasurementRow;
import 'widgets/today_vitals.dart';
import 'widgets/at_day_change.dart';
import 'widgets/surface_panel.dart';
import 'widgets/this_week_panel.dart';
import 'plan/plan_today_card.dart';

/// Die Schritte aus dem Handbuch HEM-6232T-E. Die Uhr laesst sich nicht
/// per Bluetooth stellen (docs/protocol/hem-6232t.md §8.7), also bleibt
/// nur, sie zu erklaeren.
const String clockInstructions =
    'Batterien herausnehmen und wieder einlegen. Dann die Taste gedrückt '
    'halten, bis das Jahr blinkt. Jahr, Monat, Tag, Stunde und Minute '
    'nacheinander mit START/STOP bestätigen; die andere Taste ändert den '
    'Wert, gehalten springt sie schnell. Zum Schluss START/STOP drücken, '
    'um zu speichern.';

/// Wie viele der letzten Messungen unter dem grossen Wert erscheinen.
const int _recentCount = 5;

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.controller,
    this.clock = DateTime.now,
    this.onOpenPlan,
  });

  final AppController controller;
  final VoidCallback? onOpenPlan;

  /// Die Uhr wird bei jedem Aufbau gelesen: Die laufende Woche wechselt am
  /// Montag, und eine über Nacht offene App zeigte sonst weiter die alte.
  /// Einsetzbar, damit Tests nicht vom Wochentag ihres Laufs abhängen.
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final latest = controller.latest;
    return AtDayChange(
      clock: clock,
      builder: (context, now) => Container(
        color: t.surface,
        child: ListView(
          padding: t.listPadding,
          children: [
            ..._notices(),
            if (latest == null)
              ReadingPanel(
                systolic: null,
                diastolic: null,
                child: _EmptyState(paired: controller.paired),
              )
            else
              TodayVitals(
                latest: latest,
                windows: controller.measurementWindows,
                measurements: controller.measurements,
                now: now,
                onOpenLatest: () => showMeasurementSheet(
                  context,
                  controller: controller,
                  measurementId: latest.id,
                ),
                onOpenToday: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => _TodayMeasurements(
                      controller: controller,
                      day: now,
                      userSlot: controller.userSlot,
                    ),
                  ),
                ),
              ),
            if (controller.planController case final plan?)
              PlanTodayCard(planController: plan, onOpenPlan: onOpenPlan),
            if (controller.measurements.isNotEmpty &&
                controller.weekPanelVisible)
              SurfacePanel(
                child: ThisWeekPanel(
                  windows: controller.measurementWindows,
                  measurements: controller.measurements,
                  now: now,
                  onFieldTap: (field) {
                    if (field.measurements.isEmpty) return;
                    showMeasurementSheet(
                      context,
                      controller: controller,
                      measurementId: field.measurements.first.id,
                    );
                  },
                ),
              ),
            if (controller.recentMeasurementsVisible &&
                controller.measurements.length > 1)
              SurfacePanel(
                key: const ValueKey('recent-measurements'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LETZTE MESSUNGEN',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.6,
                        color: t.muted,
                      ),
                    ),
                    for (final m
                        in controller.measurements.skip(1).take(_recentCount))
                      _RecentRow(
                        measurement: m,
                        onTap: () => showMeasurementSheet(
                          context,
                          controller: controller,
                          measurementId: m.id,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Hinweise erscheinen nur, wenn es etwas zu sagen gibt.
  List<Widget> _notices() => [
    if (!controller.paired)
      const NoticeCard(
        title: 'Nicht gekoppelt',
        message:
            'Ohne Kopplung kann Sphygma keine Messungen holen. '
            'Oben rechts über das Zahnrad einrichten.',
      ),
    if (controller.clockLooksWrong)
      const NoticeCard(
        title: 'Geräteuhr geht falsch',
        message:
            'Die neueste Messung trägt ein unplausibles Datum. '
            'Sphygma kann die Uhr nicht stellen, das geht nur am Gerät.',
        details: clockInstructions,
      ),
  ];
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.paired});

  final bool paired;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.gapLarge * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Noch keine Messung',
            style: TextStyle(
              fontSize: 20,
              fontWeight: t.headlineWeight,
              color: t.onSurface,
            ),
          ),
          SizedBox(height: t.gapSmall),
          Text(
            paired
                ? 'Miss am Gerät. Über das Zahnrad kannst du die Messungen abgleichen.'
                : 'Zuerst koppeln — oben rechts über das Zahnrad.',
            style: TextStyle(fontSize: 13, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.measurement, required this.onTap});

  final Measurement measurement;
  final VoidCallback onTap;

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final m = measurement;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: t.rowSpacing(t.gapSmall + 2)),
        decoration: t.rowDivider,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: t.gapSmall,
          runSpacing: t.gapSmall / 2,
          children: [
            Text(
              '${m.systolic}/${m.diastolic} · ${m.pulse}',
              style: TextStyle(
                fontSize: 13,
                color: t.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              '${_two(m.measuredAt.day)}.${_two(m.measuredAt.month)}. '
              '${_two(m.measuredAt.hour)}:${_two(m.measuredAt.minute)}',
              style: TextStyle(fontSize: 12, color: t.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayMeasurements extends StatelessWidget {
  const _TodayMeasurements({
    required this.controller,
    required this.day,
    required this.userSlot,
  });
  final AppController controller;
  final DateTime day;
  final int? userSlot;

  @override
  Widget build(BuildContext context) {
    final date =
        '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year}';
    return Scaffold(
      appBar: AppBar(title: Text('Messungen vom $date')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.userSlot != userSlot) {
            return const Center(
              child: Text(
                'Der Speicherplatz hat sich geändert. Bitte die Tagesliste erneut öffnen.',
              ),
            );
          }
          final readings = controller.measurements
              .where(
                (m) =>
                    m.measuredAt.year == day.year &&
                    m.measuredAt.month == day.month &&
                    m.measuredAt.day == day.day,
              )
              .toList();
          return ListView(
            padding: SphygmaTheme.of(context).listPadding,
            children: [
              if (readings.isEmpty)
                const Text('Keine Messungen für diesen Tag.'),
              for (final m in readings)
                MeasurementRow(controller: controller, measurement: m),
            ],
          );
        },
      ),
    );
  }
}
