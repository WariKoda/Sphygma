import 'package:flutter/material.dart';

import '../../plan/plan_controller.dart';
import '../theme/sphygma_theme.dart';
import '../widgets/surface_panel.dart';
import '../widgets/panel_header.dart';
import 'plan_editor.dart';

class PlanTodayCard extends StatelessWidget {
  const PlanTodayCard({
    super.key,
    required this.planController,
    this.onOpenPlan,
  });
  final PlanController planController;
  final VoidCallback? onOpenPlan;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: planController,
    builder: (context, _) {
      final plan = planController;
      if (!plan.enabled ||
          plan.currentSlotPlan == null ||
          plan.currentSlotPlan!.plan.endedAt != null) {
        return const SizedBox.shrink();
      }
      final theme = SphygmaTheme.of(context);
      final count = plan.todayOccurrences
          .where((o) => plan.fulfillment.containsKey(o.key))
          .length;
      final next = plan.nextOccurrence;
      return SurfacePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelHeader(title: 'Messplan heute', icon: Icons.event_note),
            Text(
              '$count von ${plan.todayOccurrences.length} Terminen zugeordnet',
              style: TextStyle(
                color: theme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (next != null) ...[
              SizedBox(height: theme.gapSmall),
              Text(
                'Nächster Termin: ${formatPlanMinute(next.minuteOfDay)} Uhr · ${next.localDate}',
                style: TextStyle(color: theme.muted, fontSize: 13),
              ),
            ],
            if (onOpenPlan != null)
              TextButton(
                onPressed: onOpenPlan,
                child: const Text('Messplan öffnen'),
              ),
          ],
        ),
      );
    },
  );
}
