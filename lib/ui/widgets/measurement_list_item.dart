import 'package:flutter/material.dart';

import '../../db/app_database.dart';
import '../theme/characteristic.dart';
import '../theme/sphygma_theme.dart';

class MeasurementListItem extends StatelessWidget {
  const MeasurementListItem({
    super.key,
    required this.measurement,
    required this.timestamp,
    required this.onTap,
    this.compact = false,
  });

  final Measurement measurement;
  final String timestamp;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final m = measurement;
    final indicators = <Widget>[
      if (m.movement || m.arrhythmia)
        Icon(
          Icons.info_outline,
          size: 18,
          color: t.muted,
          semanticLabel: 'Messhinweise vorhanden',
        ),
      if (m.exportedAt != null)
        Icon(
          Icons.check_circle_outline,
          key: const ValueKey('exported-dot'),
          size: 18,
          color: t.muted,
          semanticLabel: 'Nach Health Connect exportiert',
        )
      else
        Icon(
          Icons.remove_circle_outline,
          size: 18,
          color: t.muted,
          semanticLabel: 'Nicht nach Health Connect übertragen',
        ),
    ];
    final time = Text(
      timestamp,
      style: TextStyle(
        fontSize: 13,
        color: t.muted,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.chipRadius),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: t.rowSpacing(t.gapSmall + (compact ? 0 : 4)),
          ),
          decoration: t.rowDivider,
          child: compact
              ? _MeasurementColumns(
                  time: time,
                  status: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: indicators,
                  ),
                  pressure: Text(
                    '${m.systolic}/${m.diastolic}',
                    semanticsLabel:
                        '${m.systolic} zu ${m.diastolic} Millimeter Quecksilbersäule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: t.headlineWeight,
                      color: t.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  pulse: Text(
                    '${m.pulse}',
                    semanticsLabel: 'Puls ${m.pulse} Schläge pro Minute',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: t.headlineWeight,
                      color: t.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: t.gapSmall,
                      runSpacing: t.gapSmall / 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [time, ...indicators],
                    ),
                    SizedBox(height: t.gapSmall),
                    MeasurementValues(
                      systolic: m.systolic,
                      diastolic: m.diastolic,
                      pulse: m.pulse,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class MeasurementTableHeader extends StatelessWidget {
  const MeasurementTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.gapSmall / 2),
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: t.muted,
        ),
        child: const _MeasurementColumns(
          time: Text('Uhrzeit'),
          status: SizedBox.shrink(),
          pressure: Text('Blutdruck · mmHg', textAlign: TextAlign.right),
          pulse: Text('Puls · bpm', textAlign: TextAlign.right),
        ),
      ),
    );
  }
}

/// Kopf und Zeilen teilen ihre Spalten auch ohne Übertragungsstatus.
class _MeasurementColumns extends StatelessWidget {
  const _MeasurementColumns({
    required this.time,
    required this.status,
    required this.pressure,
    required this.pulse,
  });

  final Widget time;
  final Widget status;
  final Widget pressure;
  final Widget pulse;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaler = MediaQuery.textScalerOf(context);
        final timeWidth = scaler.scale(46);
        final values = Row(
          children: [
            Expanded(
              flex: 3,
              child: Align(alignment: Alignment.centerRight, child: pressure),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Align(alignment: Alignment.centerRight, child: pulse),
            ),
          ],
        );
        final leading = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: timeWidth, child: time),
            SizedBox(width: 26, child: status),
          ],
        );
        if (constraints.maxWidth < scaler.scale(260)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [leading, const SizedBox(height: 4), values],
          );
        }
        return Row(
          children: [
            leading,
            const SizedBox(width: 8),
            Expanded(child: values),
          ],
        );
      },
    );
  }
}

/// Blutdruck und Puls bleiben auch bei großer Schrift getrennt lesbar.
class MeasurementValues extends StatelessWidget {
  const MeasurementValues({
    super.key,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    this.compact = false,
  });
  final int systolic;
  final int diastolic;
  final int pulse;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    Widget value(String text, String label) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: compact ? 20 : 24,
            fontWeight: t.headlineWeight,
            color: t.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: compact ? 11 : 12, color: t.muted),
        ),
      ],
    );
    return Wrap(
      spacing: compact ? t.gapSmall * 1.5 : t.gapLarge * 1.5,
      runSpacing: t.gapSmall,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        if (t.readingLayout == ReadingLayout.bloecke) ...[
          value('$systolic', 'SYS · mmHg'),
          value('$diastolic', 'DIA · mmHg'),
        ] else
          value('$systolic/$diastolic', 'mmHg'),
        value('$pulse', 'Puls · bpm'),
      ],
    );
  }
}
