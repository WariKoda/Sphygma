// Das Archiv zählt Situationen, nicht Zahlen.
//
// Eine Zeile steht für ein Messen; „2 Messungen" ist eine Eigenschaft davon,
// kein zweiter Eintrag.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../stats/occasion_grouping.dart';
import '../../../stats/target_range.dart';
import '../../theme/sphygma_theme.dart';
import '../../theme/zone_color.dart';
import 'occasion_detail_screen.dart';
import 'occasion_range_screen.dart';
import 'occasion_widgets.dart';

class OccasionArchiveScreen extends StatelessWidget {
  const OccasionArchiveScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final anlaesse = controller.occasions.reversed.toList();
        if (anlaesse.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(t.gapLarge),
            child: Text(
              'Noch kein Messen aufgezeichnet.',
              style: TextStyle(fontSize: 13, color: t.muted),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(t.gapLarge),
          children: [
            Text(
              '${anlaesse.length} '
              '${anlaesse.length == 1 ? "Messanlass" : "Messanlässe"} aus '
              '${controller.measurements.length} Rohmessungen',
              style: TextStyle(fontSize: 14, color: t.onSurface),
            ),
            SizedBox(height: t.gapSmall),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SphygmaThemeScope(
                      theme: t,
                      child: OccasionRangeScreen(controller: controller),
                    ),
                  ),
                ),
                child: const Text('Anlässe auswerten'),
              ),
            ),
            SizedBox(height: t.gapSmall),
            for (final o in anlaesse)
              _AnlassZeile(controller: controller, occasion: o),
          ],
        );
      },
    );
  }
}

class _AnlassZeile extends StatelessWidget {
  const _AnlassZeile({required this.controller, required this.occasion});

  final AppController controller;
  final MeasurementOccasion occasion;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final o = occasion;
    final anzahl = o.measurements.length;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SphygmaThemeScope(
            theme: t,
            child: OccasionDetailScreen(
              controller: controller,
              sequence: o.sequence,
            ),
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: t.rowGap),
        decoration: t.rowDivider,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    occasionWhen(o),
                    style: TextStyle(fontSize: 13, color: t.onSurface),
                  ),
                  Text(
                    '$anzahl ${anzahl == 1 ? "Messung" : "Messungen"} · '
                    '${occasionQuality(o)}'
                    '${o.state == OccasionState.zuPruefen ? " · zu prüfen" : ""}',
                    style: TextStyle(fontSize: 11, color: t.muted),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.only(right: t.gapSmall),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: zoneColor(
                  t,
                  TargetRange.heim.classify(
                    systolic: o.result.systolic,
                    diastolic: o.result.diastolic,
                  ),
                ),
              ),
            ),
            Text(
              '${o.result.systolic}/${o.result.diastolic}',
              style: TextStyle(
                fontSize: 16,
                color: t.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
