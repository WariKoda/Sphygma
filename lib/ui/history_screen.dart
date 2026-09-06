// lib/ui/history_screen.dart
// Verlauf: Zeitraum, Kurve, Mittelwerte, Liste. Der Bericht fuer die Praxis
// kommt mit dem Berichtsplan hinzu; ein Knopf ohne Wirkung stuende hier nur
// im Weg.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../db/app_database.dart';
import '../stats/period.dart';
import '../stats/period_averages.dart';
import '../stats/trend_stats.dart';
import 'format.dart';
import 'measurement_sheet.dart';
import 'theme/sphygma_theme.dart';
import 'widgets/trend_chart.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final inPeriod = controller.measurementsInPeriod;
        final averages = PeriodAverages.of(inPeriod);

        return ListView(
          padding: EdgeInsets.all(t.gapLarge),
          children: [
            _PeriodPicker(controller: controller),
            if (inPeriod.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: t.gapLarge * 2),
                child: Text(
                  'Keine Messungen in diesem Zeitraum.',
                  style: TextStyle(fontSize: 14, color: t.muted),
                ),
              )
            else ...[
              SizedBox(height: t.gapLarge),
              TrendChart(measurements: inPeriod),
              SizedBox(height: t.gapLarge),
              const _Section(title: 'MITTELWERTE'),
              _AverageRow(label: 'Gesamt', average: averages.overall),
              _AverageRow(label: 'Morgens', average: averages.morning),
              _AverageRow(label: 'Abends', average: averages.evening),
              SizedBox(height: t.gapLarge),
              const _Section(title: 'MESSUNGEN'),
              for (final group in groupByDay(inPeriod)) ...[
                DayHeading(day: group.day),
                for (final m in group.measurements)
                  MeasurementRow(controller: controller, measurement: m),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Row(
      children: [
        for (final p in Period.values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: t.gapSmall),
              child: GestureDetector(
                onTap: () => controller.setPeriod(p),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: t.gapSmall),
                  decoration: BoxDecoration(
                    color: p == controller.period ? t.onSurface : null,
                    border: Border.all(color: t.line),
                    borderRadius: BorderRadius.circular(t.radius),
                  ),
                  child: Text(
                    p.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: p == controller.period ? t.surface : t.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall),
      child: Text(
        title,
        style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: t.muted),
      ),
    );
  }
}

class _AverageRow extends StatelessWidget {
  const _AverageRow({required this.label, required this.average});

  final String label;

  /// Null heisst: in diesem Zeitraum gab es dort keine Messung. Dann steht
  /// ein Strich da, keine erfundene Null.
  final Average? average;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final a = average;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.gapSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: t.muted)),
          Text(
            a == null
                ? '–'
                : '${a.systolic}/${a.diastolic} · ${a.pulse}',
            style: TextStyle(
              fontSize: 13,
              color: t.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class DayHeading extends StatelessWidget {
  const DayHeading({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: t.gapLarge, bottom: t.gapSmall),
      child: Text(
        formatDay(day),
        style: TextStyle(fontSize: 12, color: t.muted),
      ),
    );
  }
}

class MeasurementRow extends StatelessWidget {
  const MeasurementRow({
    super.key,
    required this.controller,
    required this.measurement,
  });

  final AppController controller;
  final Measurement measurement;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final m = measurement;

    return InkWell(
      onTap: () => showMeasurementSheet(
        context,
        controller: controller,
        measurementId: m.id,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: t.rowGap),
        decoration: t.rowDivider,
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${m.systolic}/${m.diastolic} · ${m.pulse}',
                style: TextStyle(
                  fontSize: 14,
                  color: t.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (m.movement || m.arrhythmia)
              Padding(
                padding: EdgeInsets.only(right: t.gapSmall),
                child: Icon(Icons.info_outline, size: 14, color: t.muted),
              ),
            if (m.exportedAt != null)
              Padding(
                key: const ValueKey('exported-dot'),
                padding: EdgeInsets.only(right: t.gapSmall),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: t.muted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Text(
              formatTime(m.measuredAt),
              style: TextStyle(fontSize: 13, color: t.muted),
            ),
          ],
        ),
      ),
    );
  }
}
