// Der Verlauf ist eine Folge benannter Abschnitte.
//
// „Nicht zugeordnet" steht als eigene Zeile in der Liste, nicht als Fußnote:
// Es ist ein echter Bestand, keine versteckte Restmenge.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../stats/phase_grouping.dart';
import '../../../stats/target_range.dart';
import '../../format.dart';
import '../../theme/sphygma_theme.dart';
import '../../theme/zone_color.dart';
import 'new_phase_sheet.dart';
import 'phase_measurements_screen.dart';

class PhaseListScreen extends StatelessWidget {
  const PhaseListScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final gruppen = controller.phaseGrouping;
        final phasen = gruppen?.memberships ?? const <PhaseMembership>[];

        return ListView(
          padding: EdgeInsets.all(t.gapLarge),
          children: [
            Text(
              '${controller.measurements.length} Messungen in '
              '${phasen.length} ${phasen.length == 1 ? "Phase" : "Phasen"}',
              style: TextStyle(fontSize: 12, color: t.muted),
            ),
            SizedBox(height: t.gapLarge),
            for (final m in phasen)
              _PhasenZeile(controller: controller, membership: m),
            if (gruppen != null && gruppen.unassigned.isNotEmpty)
              _Restzeile(
                label: 'Nicht zugeordnet',
                hint: 'außerhalb jeder Phase',
                count: gruppen.unassigned.length,
              ),
            if (gruppen != null && gruppen.unclear.isNotEmpty)
              _Restzeile(
                label: 'Zeitlich ungeklärt',
                hint: 'nimmt an keinem Vergleich teil',
                count: gruppen.unclear.length,
              ),
            SizedBox(height: t.gapLarge),
            FilledButton(
              onPressed: () =>
                  showNewPhaseSheet(context, controller: controller),
              child: const Text('Neue Phase beginnen'),
            ),
          ],
        );
      },
    );
  }
}

class _PhasenZeile extends StatelessWidget {
  const _PhasenZeile({required this.controller, required this.membership});

  final AppController controller;
  final PhaseMembership membership;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final p = membership.phase;
    final mittel = membership.average;
    final zeitraum = p.endsAt == null
        ? 'seit ${formatDay(p.beginsAt)}'
        : '${formatDay(p.beginsAt)} – ${formatDay(p.endsAt!)}';

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SphygmaThemeScope(
            theme: t,
            child: PhaseMeasurementsScreen(
              controller: controller,
              phaseId: p.id,
            ),
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: t.gapSmall),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(fontSize: 14, color: t.onSurface),
                  ),
                  Text(
                    '$zeitraum · ${membership.count} '
                    '${membership.count == 1 ? "Messung" : "Messungen"}',
                    style: TextStyle(fontSize: 11, color: t.muted),
                  ),
                ],
              ),
            ),
            if (mittel == null)
              Text('—', style: TextStyle(fontSize: 14, color: t.muted))
            else ...[
              Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(right: t.gapSmall),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: zoneColor(
                    t,
                    TargetRange.heim.classify(
                      systolic: mittel.systolic,
                      diastolic: mittel.diastolic,
                    ),
                  ),
                ),
              ),
              Text(
                '${mittel.systolic}/${mittel.diastolic}',
                style: TextStyle(
                  fontSize: 16,
                  color: t.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Restzeile extends StatelessWidget {
  const _Restzeile({
    required this.label,
    required this.hint,
    required this.count,
  });

  final String label;
  final String hint;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: t.gapSmall),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, color: t.muted)),
                Text(hint, style: TextStyle(fontSize: 11, color: t.muted)),
              ],
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              color: t.muted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
