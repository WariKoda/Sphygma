// Die Messungen einer Phase — und der Weg zu einer einzelnen.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/feature_flags.dart';
import '../../../stats/esc_classification.dart';
import '../../../stats/phase_grouping.dart';
import '../../format.dart';
import '../../measurement_sheet.dart';
import '../../theme/sphygma_theme.dart';
import '../../widgets/classification_scale.dart';
import '../../widgets/section_header.dart';

class PhaseMeasurementsScreen extends StatelessWidget {
  const PhaseMeasurementsScreen({
    super.key,
    required this.controller,
    required this.phaseId,
  });

  final AppController controller;
  final int phaseId;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        PhaseMembership? treffer;
        for (final m in controller.phaseGrouping?.memberships ??
            const <PhaseMembership>[]) {
          if (m.phase.id == phaseId) treffer = m;
        }

        if (treffer == null) {
          return Scaffold(
            backgroundColor: t.surface,
            appBar: AppBar(
              title: const Text('Phase'),
              backgroundColor: t.surface,
              foregroundColor: t.onSurface,
              elevation: 0,
            ),
            body: Padding(
              padding: EdgeInsets.all(t.gapLarge),
              child: Text(
                'Diese Phase gibt es nicht mehr.',
                style: TextStyle(fontSize: 13, color: t.muted),
              ),
            ),
          );
        }

        final p = treffer.phase;
        final mittel = treffer.average;

        return Scaffold(
          backgroundColor: t.surface,
          appBar: AppBar(
            title: Text(p.name),
            backgroundColor: t.surface,
            foregroundColor: t.onSurface,
            elevation: 0,
            actions: [
              if (p.endsAt == null)
                TextButton(
                  onPressed: () =>
                      controller.endPhase(p.id, at: DateTime.now()),
                  child: const Text('Beenden'),
                ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.all(t.gapLarge),
            children: [
              Text(
                p.endsAt == null
                    ? 'seit ${formatDay(p.beginsAt)} · läuft'
                    : '${formatDay(p.beginsAt)} – ${formatDay(p.endsAt!)}',
                style: TextStyle(fontSize: 12, color: t.muted),
              ),
              SizedBox(height: t.gapSmall),
              if (mittel != null) ...[
                Text(
                  '${mittel.systolic} / ${mittel.diastolic}',
                  style: TextStyle(
                    fontSize: t.headlineSize,
                    fontWeight: FontWeight.w300,
                    color: t.onSurface,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  'Mittel aus ${treffer.count} Messungen · Puls ${mittel.pulse}',
                  style: TextStyle(fontSize: 12, color: t.muted),
                ),
                if (escClassificationEnabled) ...[
                  SizedBox(height: t.gapLarge),
                  ClassificationScale(
                    category: classifyOffice(
                      systolic: mittel.systolic,
                      diastolic: mittel.diastolic,
                    ),
                  ),
                ],
              ] else
                Text(
                  'Dieser Phase ist keine Messung zugeordnet.',
                  style: TextStyle(fontSize: 13, color: t.onSurface),
                ),
              const SectionHeader(title: 'Zugeordnete Messungen'),
              for (final m in treffer.measurements.reversed)
                InkWell(
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
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                        Text(
                          formatDayAndTime(m.measuredAt),
                          style: TextStyle(fontSize: 12, color: t.muted),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
