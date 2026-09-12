import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../plan/plan_controller.dart';
import '../../plan/reminder_gateway.dart';
import '../theme/sphygma_theme.dart';
import '../widgets/notice_card.dart';
import '../widgets/surface_panel.dart';
import 'occurrence_assignment_sheet.dart';
import 'plan_editor.dart';

class MeasurementPlanScreen extends StatelessWidget {
  const MeasurementPlanScreen({
    super.key,
    required this.planController,
    required this.controller,
  });
  final PlanController planController;
  final AppController controller;

  Future<void> _action(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  Future<void> _edit(BuildContext context) async {
    final slot = planController.userSlot;
    final current = planController.currentSlotPlan;
    final minutes = current?.plan.endedAt == null
        ? current?.minutes ?? <int>[]
        : <int>[];
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PlanEditor(
          initialMinutes: minutes,
          onSave: (values) async {
            if (!planController.enabled || planController.userSlot != slot) {
              throw StateError(
                'Der ausgewählte Messplan hat sich geändert. Bitte den Editor erneut öffnen.',
              );
            }
            await planController.saveTimes(values);
          },
        ),
      ),
    );
  }

  Future<void> _end(BuildContext context) async {
    final slot = planController.userSlot;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Messplan beenden?'),
        content: const Text(
          'Künftige Termine und Erinnerungen dieses Plans entfallen. Vorhandene Messungen und vergangene Termine bleiben erhalten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Beenden'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _action(context, () async {
      if (planController.userSlot != slot) {
        throw StateError('Der Speicherplatz hat sich geändert.');
      }
      await planController.endPlan();
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: planController,
    builder: (context, _) {
      final plan = planController;
      if (!plan.enabled) return const SizedBox.shrink();
      final theme = SphygmaTheme.of(context);
      final current = plan.currentSlotPlan;
      final active = current != null && current.plan.endedAt == null;
      final status = switch (plan.mode) {
        ReminderMode.off => 'Erinnerungen ausgeschaltet',
        ReminderMode.exact => 'Exakte Erinnerungen',
        ReminderMode.inexact => 'Ungenaue Erinnerungen',
        ReminderMode.blocked => 'Erinnerungen blockiert',
        ReminderMode.failed => 'Erinnerungen nicht bestätigt',
      };
      return SafeArea(
        child: ListView(
          padding: theme.listPadding,
          children: [
            if (plan.busy)
              const LinearProgressIndicator(
                semanticsLabel: 'Messplan wird aktualisiert',
              ),
            SurfacePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messplan · Speicherplatz ${plan.userSlot ?? 'nicht gewählt'}',
                    style: TextStyle(
                      color: theme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: theme.gapSmall),
                  if (active)
                    Text(
                      'Täglich ${current.minutes.map(formatPlanMinute).join(', ')} Uhr · bis du den Plan beendest',
                      style: TextStyle(color: theme.muted),
                    ),
                  if (!active)
                    Text(
                      current == null
                          ? 'Noch kein Messplan für diesen Speicherplatz.'
                          : 'Dieser Messplan ist beendet.',
                      style: TextStyle(color: theme.muted),
                    ),
                  TextButton.icon(
                    onPressed: plan.busy || plan.userSlot == null
                        ? null
                        : () => _edit(context),
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      active ? 'Uhrzeiten bearbeiten' : 'Messplan anlegen',
                    ),
                  ),
                  if (active)
                    TextButton(
                      onPressed: plan.busy ? null : () => _end(context),
                      child: const Text('Messplan beenden'),
                    ),
                ],
              ),
            ),
            SurfacePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      color: theme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (plan.mode == ReminderMode.inexact)
                    Text(
                      'Android kann die Erinnerung verzögert zustellen. Das Zuordnungsfenster bleibt bei ±15 Minuten.',
                      style: TextStyle(color: theme.muted),
                    ),
                  if (plan.mode == ReminderMode.blocked)
                    Text(
                      'Benachrichtigungen oder der Messplan-Kanal sind in Android ausgeschaltet.',
                      style: TextStyle(color: theme.muted),
                    ),
                  if (plan.mode == ReminderMode.inexact ||
                      plan.mode == ReminderMode.blocked)
                    TextButton(
                      onPressed: plan.busy
                          ? null
                          : () => _action(context, plan.requestAccess),
                      child: const Text('Berechtigungen prüfen'),
                    ),
                  if (plan.mode == ReminderMode.failed)
                    TextButton(
                      onPressed: plan.busy
                          ? null
                          : () => _action(context, plan.reconcileReminders),
                      child: const Text('Erneut abgleichen'),
                    ),
                ],
              ),
            ),
            if (plan.error != null)
              NoticeCard(
                title: 'Messplan konnte nicht vollständig aktualisiert werden',
                message: plan.error!,
              ),
            if (plan.todayOccurrences.isNotEmpty)
              SurfacePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Termine heute',
                      style: TextStyle(
                        color: theme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    for (final occurrence in plan.todayOccurrences)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${formatPlanMinute(occurrence.minuteOfDay)} Uhr',
                          style: TextStyle(color: theme.onSurface),
                        ),
                        subtitle: Text(
                          plan.fulfillment.containsKey(occurrence.key)
                              ? 'Messung zugeordnet'
                              : occurrence.timeAmbiguous
                              ? 'Zeit nicht eindeutig'
                              : 'Noch keine Messung zugeordnet',
                          style: TextStyle(color: theme.muted),
                        ),
                        onTap: plan.busy
                            ? null
                            : () => Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => OccurrenceAssignmentSheet(
                                    planController: plan,
                                    controller: controller,
                                    occurrence: occurrence,
                                  ),
                                ),
                              ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    },
  );
}
