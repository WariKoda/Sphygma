import 'package:flutter/material.dart';

import '../../app/feature_flags.dart';
import '../../db/app_database.dart';
import '../../stats/measurement_windows.dart';
import '../theme/characteristic.dart';
import '../theme/sphygma_theme.dart';
import 'classification_scale.dart';
import 'blood_pressure_fields.dart';
import 'reading_panel.dart';
import 'surface_panel.dart';
import 'panel_header.dart';

class TodayVitals extends StatelessWidget {
  const TodayVitals({
    super.key,
    required this.measurements,
    this.windows,
    required this.latest,
    required this.now,
    required this.onOpenLatest,
    required this.onOpenToday,
  });

  final MeasurementWindows? windows;
  final List<Measurement> measurements;
  final Measurement? latest;
  final DateTime now;
  final VoidCallback? onOpenLatest;
  final VoidCallback? onOpenToday;

  @override
  Widget build(BuildContext context) {
    final selectedWindows = windows ?? MeasurementWindows.defaults;
    final today = measurements
        .where((measurement) => _sameDay(measurement.measuredAt, now))
        .toList();
    final morning = today
        .where(
          (measurement) => selectedWindows.isMorning(measurement.measuredAt),
        )
        .toList();
    final evening = today
        .where(
          (measurement) => selectedWindows.isEvening(measurement.measuredAt),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LatestAction(
          key: const ValueKey('latest-blood-pressure'),
          onTap: latest == null ? null : onOpenLatest,
          label: 'Letzten Blutdruck öffnen',
          child: ReadingPanel(
            systolic: latest?.systolic,
            diastolic: latest?.diastolic,
            child: _BloodPressureSection(
              latest: latest,
              morning: morning,
              evening: evening,
            ),
          ),
        ),
        _LatestAction(
          key: const ValueKey('latest-pulse'),
          onTap: latest == null ? null : onOpenLatest,
          label: 'Letzten Puls öffnen',
          child: SurfacePanel(
            child: _PulseSection(
              latest: latest,
              morning: morning,
              evening: evening,
            ),
          ),
        ),
        if (today.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onOpenToday,
              child: Text(
                'Alle ${today.length} ${today.length == 1 ? 'Messung' : 'Messungen'} ansehen',
              ),
            ),
          ),
      ],
    );
  }

  static bool _sameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

class _LatestAction extends StatelessWidget {
  const _LatestAction({
    super.key,
    required this.onTap,
    required this.label,
    required this.child,
  });
  final VoidCallback? onTap;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: label,
    onTap: onTap,
    child: InkWell(onTap: onTap, child: child),
  );
}

class _BloodPressureSection extends StatelessWidget {
  const _BloodPressureSection({
    required this.latest,
    required this.morning,
    required this.evening,
  });
  final Measurement? latest;
  final List<Measurement> morning, evening;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(title: 'Blutdruck', latest: latest),

        if (latest == null)
          const Text('Noch keine Messung')
        else ...[
          BloodPressureFields(
            systolic: latest!.systolic,
            diastolic: latest!.diastolic,
          ),

          if (escClassificationEnabled) ...[
            SizedBox(height: t.gapLarge),
            ClassificationScale.forReading(
              systolic: latest!.systolic,
              diastolic: latest!.diastolic,
            ),
          ],
        ],
        SizedBox(height: t.gapLarge),
        _BandMeans(
          morning: _Mean.of(morning),
          evening: _Mean.of(evening),
          value: (mean) => '${mean.systolic}/${mean.diastolic}',
        ),
      ],
    );
  }
}

class _PulseSection extends StatelessWidget {
  const _PulseSection({
    required this.latest,
    required this.morning,
    required this.evening,
  });
  final Measurement? latest;
  final List<Measurement> morning, evening;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(title: 'Puls', latest: latest),

        if (latest == null)
          const Text('Noch keine Messung')
        else
          Text(
            '${latest!.pulse}',
            semanticsLabel: 'Puls ${latest!.pulse} Schläge pro Minute',
            style: TextStyle(
              fontSize: t.headlineSize,
              height: 1,
              fontWeight: t.headlineWeight,
              color: t.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        SizedBox(height: t.gapLarge),
        _BandMeans(
          morning: _Mean.of(morning),
          evening: _Mean.of(evening),
          value: (mean) => '${mean.pulse}',
        ),
      ],
    );
  }
}

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.title, required this.latest});
  final String title;
  final Measurement? latest;

  @override
  Widget build(BuildContext context) {
    final value = latest;
    return PanelHeader(
      title: title,
      unit: title == 'Blutdruck' ? 'mmHg' : 'bpm',
      inlineSubtitle: true,
      icon: title == 'Blutdruck'
          ? Icons.favorite_outline
          : Icons.monitor_heart_outlined,
      subtitle: value == null
          ? null
          : '${_date(value.measuredAt)} · ${_clock(value.measuredAt)}',
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
  static String _date(DateTime value) =>
      '${_two(value.day)}.${_two(value.month)}.${value.year}';
  static String _clock(DateTime value) =>
      '${_two(value.hour)}:${_two(value.minute)}';
}

class _BandMeans extends StatelessWidget {
  const _BandMeans({
    required this.morning,
    required this.evening,
    required this.value,
  });
  final _Mean? morning, evening;
  final String Function(_Mean mean) value;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final cards = [
      _MeanCard(label: 'Morgenmittelwert', mean: morning, value: value),
      _MeanCard(label: 'Abendmittelwert', mean: evening, value: value),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaler = MediaQuery.textScalerOf(context);
        double width(String text, double size, {FontWeight? weight}) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: size,
                fontWeight: weight,
                fontFamily: t.fontFamily,
              ),
            ),
            textDirection: TextDirection.ltr,
            textScaler: scaler,
          )..layout();
          final result = painter.width;
          painter.dispose();
          return result;
        }

        double cardWidth(String label, _Mean? mean) {
          final count = mean == null
              ? '2 Messungen'
              : '${mean.count} ${mean.count == 1 ? 'Messung' : 'Messungen'}';
          final texts = <double>[
            width(label, 14),
            if (mean == null)
              width('Noch keine Messung', 13)
            else ...[
              width(value(mean), 27, weight: t.headlineWeight),
              width(count, 12),
              width(mean.timeRange, 12),
            ],
          ];
          final content = texts.reduce(
            (left, right) => left > right ? left : right,
          );
          return content +
              (t.statsLayout == StatsLayout.karten ? t.gapSmall * 2 : 0);
        }

        final minimum =
            cardWidth('Morgenmittelwert', morning) >
                cardWidth('Abendmittelwert', evening)
            ? cardWidth('Morgenmittelwert', morning)
            : cardWidth('Abendmittelwert', evening);
        final sideBySide =
            constraints.maxWidth >= minimum * 2 + t.gapSmall ||
            (scaler.scale(14) <= 14 && constraints.maxWidth >= 280);
        if (sideBySide) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards.first),
                SizedBox(width: t.gapSmall),
                Expanded(child: cards.last),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cards.first,
            SizedBox(height: t.gapSmall),
            cards.last,
          ],
        );
      },
    );
  }
}

class _MeanCard extends StatelessWidget {
  const _MeanCard({
    required this.label,
    required this.mean,
    required this.value,
  });
  final String label;
  final _Mean? mean;
  final String Function(_Mean mean) value;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final content = Padding(
      padding: EdgeInsets.symmetric(vertical: t.gapSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: t.muted)),
          SizedBox(height: t.gapSmall / 2),
          if (mean == null) ...[
            Text(
              '—',
              style: TextStyle(fontSize: 27, height: 1, color: t.onSurface),
            ),
            SizedBox(height: t.gapSmall / 2),
            Text(
              'Noch keine Messung',
              style: TextStyle(fontSize: 13, color: t.onSurface),
            ),
          ] else ...[
            Text(
              value(mean!),
              style: TextStyle(
                fontSize: 27,
                height: 1,
                fontWeight: t.headlineWeight,
                color: t.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(height: t.gapSmall / 2),
            Wrap(
              spacing: t.gapSmall,
              runSpacing: t.gapSmall / 2,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  '${mean!.count} '
                  '${mean!.count == 1 ? 'Messung' : 'Messungen'}',
                  style: TextStyle(fontSize: 12, color: t.muted),
                ),
                Text(
                  mean!.timeRange,
                  style: TextStyle(fontSize: 12, color: t.muted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
    if (t.statsLayout == StatsLayout.karten) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: t.panel(1),
          borderRadius: BorderRadius.circular(t.chipRadius),
          border: t.panelBorder == null
              ? null
              : Border.all(color: t.panelBorder!),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: t.gapSmall),
          child: content,
        ),
      );
    }
    return DecoratedBox(decoration: t.rowDivider, child: content);
  }
}

class _Mean {
  const _Mean(
    this.systolic,
    this.diastolic,
    this.pulse,
    this.count,
    this.firstAt,
    this.lastAt,
  );
  final int systolic, diastolic, pulse, count;
  final DateTime firstAt, lastAt;

  String get timeRange {
    final first = _clock(firstAt);
    final last = _clock(lastAt);
    return first == last ? first : '$first–$last';
  }

  static _Mean? of(List<Measurement> values) {
    if (values.isEmpty) return null;
    int mean(int Function(Measurement) field) =>
        (values.fold<int>(0, (sum, item) => sum + field(item)) / values.length)
            .round();
    return _Mean(
      mean((m) => m.systolic),
      mean((m) => m.diastolic),
      mean((m) => m.pulse),
      values.length,
      values
          .map((measurement) => measurement.measuredAt)
          .reduce((left, right) => left.isBefore(right) ? left : right),
      values
          .map((measurement) => measurement.measuredAt)
          .reduce((left, right) => left.isAfter(right) ? left : right),
    );
  }

  static String _clock(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}
