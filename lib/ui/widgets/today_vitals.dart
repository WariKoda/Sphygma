import 'package:flutter/material.dart';

import '../../app/feature_flags.dart';
import '../../db/app_database.dart';
import '../../stats/esc_classification.dart';
import '../../stats/measurement_windows.dart';
import '../theme/characteristic.dart';
import '../theme/sphygma_theme.dart';
import 'classification_scale.dart';
import 'reading_headline.dart';
import 'reading_panel.dart';
import 'surface_panel.dart';

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
              child: Text('Alle ${today.length} Messungen ansehen'),
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
        SizedBox(height: t.gapSmall),
        const _Kicker('LETZTE MESSUNG'),
        SizedBox(height: t.gapSmall),
        if (latest == null)
          const Text('Noch keine Messung')
        else ...[
          BloodPressureValue(
            systolic: latest!.systolic,
            diastolic: latest!.diastolic,
          ),
          SizedBox(height: t.gapSmall / 2),
          Text('mmHg', style: TextStyle(color: t.muted)),
          if (escClassificationEnabled) ...[
            SizedBox(height: t.gapLarge),
            ClassificationScale(
              category: classifyOffice(
                systolic: latest!.systolic,
                diastolic: latest!.diastolic,
              ),
            ),
          ],
        ],
        SizedBox(height: t.gapLarge),
        _BandMeans(
          morning: _Mean.of(morning),
          evening: _Mean.of(evening),
          value: (mean) => '${mean.systolic}/${mean.diastolic}',
          unit: 'mmHg',
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
        SizedBox(height: t.gapSmall),
        const _Kicker('DIESELBE MESSUNG'),
        SizedBox(height: t.gapSmall),
        if (latest == null)
          const Text('Noch keine Messung')
        else
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                '${latest!.pulse}',
                style: TextStyle(
                  fontSize: t.headlineSize,
                  height: 1,
                  fontWeight: t.headlineWeight,
                  color: t.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: t.gapSmall, bottom: 2),
                child: Text('bpm', style: TextStyle(color: t.muted)),
              ),
            ],
          ),
        SizedBox(height: t.gapLarge),
        _BandMeans(
          morning: _Mean.of(morning),
          evening: _Mean.of(evening),
          value: (mean) => '${mean.pulse}',
          unit: 'bpm',
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
    final t = SphygmaTheme.of(context);
    final value = latest;
    return Wrap(
      spacing: t.gapSmall,
      runSpacing: t.gapSmall / 2,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Wrap(
          spacing: t.gapSmall,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              title == 'Blutdruck'
                  ? Icons.favorite_outline
                  : Icons.monitor_heart_outlined,
              size: 19,
              color: t.onSurface,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: t.onSurface,
              ),
            ),
          ],
        ),
        if (value != null)
          Text(
            '${_date(value.measuredAt)} · ${_clock(value.measuredAt)}',
            style: TextStyle(fontSize: 12, color: t.muted),
          ),
      ],
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
  static String _date(DateTime value) =>
      '${_two(value.day)}.${_two(value.month)}.${value.year}';
  static String _clock(DateTime value) =>
      '${_two(value.hour)}:${_two(value.minute)}';
}

class _Kicker extends StatelessWidget {
  const _Kicker(this.value);
  final String value;
  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Text(
      value,
      style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: t.muted),
    );
  }
}

class _BandMeans extends StatelessWidget {
  const _BandMeans({
    required this.morning,
    required this.evening,
    required this.value,
    required this.unit,
  });
  final _Mean? morning, evening;
  final String Function(_Mean mean) value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final cards = [
      _MeanCard(
        label: 'Morgenmittelwert',
        mean: morning,
        value: value,
        unit: unit,
      ),
      _MeanCard(
        label: 'Abendmittelwert',
        mean: evening,
        value: value,
        unit: unit,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaler = MediaQuery.textScalerOf(context);
        double width(String text, double size, {FontWeight? weight}) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(
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
              width(unit, 12),
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
          return Row(
            children: [
              Expanded(child: cards.first),
              SizedBox(width: t.gapSmall),
              Expanded(child: cards.last),
            ],
          );
        }
        return Column(
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
    required this.unit,
  });
  final String label, unit;
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
          if (mean == null)
            Text(
              'Noch keine Messung',
              style: TextStyle(fontSize: 13, color: t.onSurface),
            )
          else ...[
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
            Text(unit, style: TextStyle(fontSize: 12, color: t.muted)),
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
