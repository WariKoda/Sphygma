// Eine Woche im Detail: das Raster groß, die Messungen darunter.
//
// Der Wochenwert lässt den ersten Tag aus — das steht hier dabei, statt
// versteckt zu sein. Eine Zahl, deren Zustandekommen man nicht sieht, ist in
// der Sprechstunde nichts wert.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../db/app_database.dart';
import '../../../stats/measurement_week.dart';
import '../../../stats/target_range.dart';
import '../../../stats/time_plausibility.dart';
import '../../format.dart';
import '../../measurement_sheet.dart';
import '../../theme/sphygma_theme.dart';
import '../../widgets/section_header.dart';
import 'week_grid.dart';

class WeekDetailScreen extends StatelessWidget {
  const WeekDetailScreen({
    super.key,
    required this.controller,
    required this.weekStart,
  });

  final AppController controller;

  /// Der Montag der Woche — nicht die Woche selbst. Ein mitgereichtes
  /// Wochenobjekt wäre ein Schnappschuss: Holt der automatische Abgleich
  /// währenddessen eine Messung, zeigte dieser Bildschirm weiter die alten
  /// Felder und Mittelwerte.
  final DateTime weekStart;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final wochen = buildWeeks(controller.measurements);
          for (final w in wochen) {
            if (w.beginsAt == weekStart) return _inhalt(context, w);
          }
          return _keineWoche(context);
        },
      );

  Widget _keineWoche(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Scaffold(
      backgroundColor: t.surface,
      appBar: AppBar(
        title: Text(formatWeekRange(weekStart)),
        backgroundColor: t.surface,
        foregroundColor: t.onSurface,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(t.gapLarge),
        child: Text(
          'Für diese Woche liegt keine Messung des gewählten Speicherplatzes '
          'vor.',
          style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
        ),
      ),
    );
  }

  Widget _inhalt(BuildContext context, MeasurementWeek week) {
    final t = SphygmaTheme.of(context);
    final fraglich = {
      for (final m in questionableTimestamps(
        controller.measurements,
        now: DateTime.now(),
      ))
        m.deviceSequence,
    };

    return Scaffold(
      backgroundColor: t.surface,
      appBar: AppBar(
        title: Text(formatWeekRange(week.beginsAt)),
        backgroundColor: t.surface,
        foregroundColor: t.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(t.gapLarge),
        children: [
          Text(
            week.isComplete
                ? 'Vollständig gemessen'
                : '${week.filledFields} von $fieldsPerWeek Feldern',
            style: TextStyle(fontSize: 12, color: t.muted),
          ),
          SizedBox(height: t.gapSmall),
          if (week.average case final a?) ...[
            Text(
              '${a.systolic} / ${a.diastolic}',
              style: TextStyle(
                fontSize: t.headlineSize,
                fontWeight: FontWeight.w300,
                color: t.onSurface,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(height: t.gapSmall),
            Text(
              'Mittel ohne den ersten Tag, so rechnet die Praxis · '
              '${TargetRange.heim.classify(systolic: a.systolic, diastolic: a.diastolic).label}',
              style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
            ),
            if (week.averageWithFirstDay case final voll?)
              Text(
                'Über alle sieben Tage: ${voll.systolic}/${voll.diastolic}',
                style: TextStyle(fontSize: 11, color: t.muted),
              ),
          ] else
            Text(
              'Diese Woche hat nur einen gemessenen Tag. Der Wochenwert lässt '
              'den ersten Tag aus — es bleibt nichts übrig, aus dem er '
              'gebildet werden könnte.',
              style: TextStyle(fontSize: 13, color: t.onSurface, height: 1.5),
            ),
          SizedBox(height: t.gapLarge),
          WeekGrid(
            week: week,
            onFieldTap: (feld) {
              if (feld.measurements.isEmpty) return;
              showMeasurementSheet(
                context,
                controller: controller,
                measurementId: feld.measurements.first.id,
              );
            },
          ),
          SizedBox(height: t.gapSmall),
          Row(
            children: [
              if (week.morningAverage case final m?)
                Expanded(
                  child: _Halbtag(label: 'Morgens', text: '${m.systolic}/${m.diastolic}'),
                ),
              if (week.eveningAverage case final a?)
                Expanded(
                  child: _Halbtag(label: 'Abends', text: '${a.systolic}/${a.diastolic}'),
                ),
            ],
          ),
          const SectionHeader(title: 'Alle Messungen dieser Woche'),
          for (final m in week.measurements)
            _Zeile(
              controller: controller,
              measurement: m,
              fraglich: fraglich.contains(m.deviceSequence),
            ),
        ],
      ),
    );
  }
}

class _Halbtag extends StatelessWidget {
  const _Halbtag({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: t.muted)),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: t.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({
    required this.controller,
    required this.measurement,
    required this.fraglich,
  });

  final AppController controller;
  final Measurement measurement;
  final bool fraglich;

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
        padding: EdgeInsets.symmetric(vertical: t.gapSmall),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
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
            Text(
              fraglich
                  ? '${formatDayAndTime(m.measuredAt)} ⚠'
                  : formatDayAndTime(m.measuredAt),
              style: TextStyle(fontSize: 12, color: t.muted),
            ),
          ],
        ),
      ),
    );
  }
}
