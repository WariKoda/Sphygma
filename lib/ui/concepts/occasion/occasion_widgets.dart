// Bausteine des Konzepts „Messanlass".
//
// Ein Anlass hat genau ein Ergebnis, eine nachvollziehbare Regel und eine
// Aussage über seine Güte. Diese drei Dinge gehören überall zusammen, wo ein
// Anlass gezeigt wird — deshalb liegen sie hier und nicht in je einem
// Bildschirm.
import 'package:flutter/material.dart';

import '../../../app/feature_flags.dart';
import '../../../db/app_database.dart';
import '../../../stats/esc_classification.dart';
import '../../../stats/occasion_grouping.dart';
import '../../../stats/target_range.dart';
import '../../format.dart';
import '../../widgets/classification_scale.dart';
import '../../theme/sphygma_theme.dart';

/// Das Ergebnis eines Anlasses, groß.
class OccasionResult extends StatelessWidget {
  const OccasionResult({super.key, required this.occasion, this.large = true});

  final MeasurementOccasion occasion;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final r = occasion.result;
    final zone = TargetRange.heim
        .classify(systolic: r.systolic, diastolic: r.diastolic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${r.systolic} / ${r.diastolic}',
          style: TextStyle(
            fontSize: large ? t.headlineSize : 24,
            fontWeight: t.headlineWeight,
            color: t.onSurface,
            height: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(height: t.gapSmall),
        Text(
          'Puls ${r.pulse} · ${zone.label}',
          style: TextStyle(fontSize: 12, color: t.muted),
        ),
        Text(
          occasion.rule,
          style: TextStyle(fontSize: 11, color: t.muted, height: 1.5),
        ),
        if (escClassificationEnabled) ...[
          SizedBox(height: t.gapLarge),
          ClassificationScale(
            category: classifyOffice(
              systolic: r.systolic,
              diastolic: r.diastolic,
            ),
          ),
        ],
      ],
    );
  }
}

/// Kennzeichen des Geräts. Sie beschreiben die Verlässlichkeit dieses
/// Messens — nicht bloß eine Zahl, und keine Diagnose.
class QualityChips extends StatelessWidget {
  const QualityChips({super.key, required this.occasion});

  final MeasurementOccasion occasion;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final texte = <String>[
      if (occasion.hasMovement)
        'Bewegung erkannt'
      else
        'keine Bewegung',
      if (occasion.hasArrhythmia)
        'unregelmäßiger Puls'
      else
        'Puls regelmäßig',
    ];

    return Wrap(
      spacing: t.gapSmall,
      runSpacing: t.gapSmall / 2,
      children: [
        for (final text in texte)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: t.gapSmall,
              vertical: t.gapSmall / 3,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(t.radius),
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: t.muted),
            ),
          ),
      ],
    );
  }
}

/// Die Rohwerte eines Anlasses — der Beweis, wie die Zahl entstanden ist.
///
/// Kein Rohwert wird gelöscht; gezeigt wird, welche Rolle er im Ergebnis
/// spielt.
class RawMeasurementList extends StatelessWidget {
  const RawMeasurementList({
    super.key,
    required this.occasion,
    this.onTap,
  });

  final MeasurementOccasion occasion;
  final void Function(Measurement)? onTap;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final genutzt = {for (final m in occasion.usedMeasurements) m.id};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < occasion.measurements.length; i++)
          _RohZeile(
            index: i + 1,
            measurement: occasion.measurements[i],
            used: genutzt.contains(occasion.measurements[i].id),
            showRole: occasion.measurements.length >
                occasion.usedMeasurements.length,
            onTap: onTap,
          ),
        SizedBox(height: t.gapSmall / 2),
      ],
    );
  }
}

class _RohZeile extends StatelessWidget {
  const _RohZeile({
    required this.index,
    required this.measurement,
    required this.used,
    required this.showRole,
    required this.onTap,
  });

  final int index;
  final Measurement measurement;
  final bool used;
  final bool showRole;
  final void Function(Measurement)? onTap;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final m = measurement;

    return InkWell(
      onTap: onTap == null ? null : () => onTap!(m),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: t.gapSmall / 2),
        decoration: t.rowDivider,
        child: Row(
          children: [
            SizedBox(
              width: 132,
              child: Text(
                '$index. Nr. ${m.deviceSequence} · ${formatTime(m.measuredAt)}',
                style: TextStyle(fontSize: 11, color: t.muted),
              ),
            ),
            Expanded(
              child: Text(
                '${m.systolic}/${m.diastolic} · ${m.pulse}',
                style: TextStyle(
                  fontSize: 13,
                  color: used ? t.onSurface : t.muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (showRole)
              Text(
                used ? 'verwendet' : 'nicht verwendet',
                style: TextStyle(fontSize: 10, color: t.muted),
              ),
          ],
        ),
      ),
    );
  }
}

/// Wann der Anlass stattfand — eine Spanne, wenn mehrfach gemessen wurde.
String occasionWhen(MeasurementOccasion o) {
  final erste = o.measurements.first.measuredAt;
  final letzte = o.measurements.last.measuredAt;
  if (o.measurements.length == 1) return formatDayAndTime(erste);
  return '${formatDayAndTime(erste)}–${formatTime(letzte)}';
}

/// Eine kurze Aussage über die Güte, für Listen.
String occasionQuality(MeasurementOccasion o) {
  if (o.hasMovement) return 'Bewegung';
  if (o.hasArrhythmia) return 'Puls-Hinweis';
  if (o.measurements.length > 1) return 'gute Güte';
  return 'ein Rohwert';
}
