// Der Verlauf ist eine Liste von Wochen, keine Kurve über beliebige Zeiträume.
//
// Vollständige Wochen sind für die Praxis brauchbar; unvollständige stehen
// daneben und sagen, wie viel fehlt. Das ist die Meinung des Konzepts, und
// sie wird nicht durch eine geglättete Linie verdeckt.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../stats/measurement_week.dart';
import '../../../stats/target_range.dart';
import '../../format.dart';
import '../../theme/sphygma_theme.dart';
import '../../theme/zone_color.dart';
import 'week_detail_screen.dart';
import 'week_range_screen.dart';

class EarlierWeeksScreen extends StatelessWidget {
  const EarlierWeeksScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final wochen = buildWeeks(controller.measurements);

        return Scaffold(
          backgroundColor: t.surface,
          appBar: AppBar(
            title: const Text('Frühere Wochen'),
            backgroundColor: t.surface,
            foregroundColor: t.onSurface,
            elevation: 0,
            actions: [
              if (wochen.length > 1)
                IconButton(
                  tooltip: 'Wochen auswerten',
                  icon: const Icon(Icons.calculate_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SphygmaThemeScope(
                        theme: t,
                        child: WeekRangeScreen(controller: controller),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: wochen.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(t.gapLarge),
                  child: Text(
                    'Noch keine Woche. Sie entsteht, sobald gemessen wird.',
                    style: TextStyle(fontSize: 13, color: t.muted),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.all(t.gapLarge),
                  children: [
                    Text(
                      'Vollständige Wochen sind für die Praxis brauchbar.',
                      style: TextStyle(fontSize: 12, color: t.muted),
                    ),
                    SizedBox(height: t.gapLarge),
                    for (final w in wochen)
                      _WochenZeile(controller: controller, week: w),
                  ],
                ),
        );
      },
    );
  }
}

class _WochenZeile extends StatelessWidget {
  const _WochenZeile({required this.controller, required this.week});

  final AppController controller;
  final MeasurementWeek week;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final mittel = week.average;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SphygmaThemeScope(
            theme: t,
            child: WeekDetailScreen(controller: controller, weekStart: week.beginsAt),
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
                    formatWeekRange(week.beginsAt),
                    style: TextStyle(fontSize: 14, color: t.onSurface),
                  ),
                  Text(
                    '${week.filledFields} von $fieldsPerWeek',
                    style: TextStyle(fontSize: 11, color: t.muted),
                  ),
                ],
              ),
            ),
            if (mittel == null)
              Text(
                'kein Wochenwert',
                style: TextStyle(fontSize: 12, color: t.muted),
              )
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
