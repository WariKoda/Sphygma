import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../plan/plan_controller.dart';
import '../../plan/reminder_gateway.dart';
import '../theme/sphygma_theme.dart';
import '../widgets/notice_card.dart';
import '../widgets/surface_panel.dart';
import '../widgets/panel_header.dart';
import 'occurrence_assignment_sheet.dart';
import 'plan_editor.dart';
import '../settings_screen.dart';
import '../format.dart';

enum _ReminderHelpAction { permissions, retry, edit, settings }

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

  Future<void> _explainReminders(
    BuildContext context,
    ReminderMode mode,
  ) async {
    final current = planController.currentSlotPlan;
    final active = current != null && current.plan.endedAt == null;
    final missingSlot = planController.userSlot == null;
    final action = await showDialog<_ReminderHelpAction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Wann werde ich erinnert?'),
        scrollable: true,
        content: Text(switch (mode) {
          ReminderMode.exact =>
            'Du erhältst Erinnerungen zu den Uhrzeiten deines Messplans. '
                'Android erlaubt Sphygma, diese Uhrzeiten möglichst genau einzuhalten. '
                'Du musst nichts weiter einstellen.',
          ReminderMode.inexact =>
            'Die Erinnerungen sind eingerichtet. Android darf sie jedoch später anzeigen, '
                'zum Beispiel um Akku zu sparen. Tippe auf „Berechtigungen prüfen“ und '
                'erlaube dort, sofern verfügbar, „Alarme und Erinnerungen“. '
                'Ohne diese Erlaubnis bleiben die Erinnerungen aktiv, können aber später kommen.',
          ReminderMode.off =>
            missingSlot
                ? 'Wähle zuerst in den Einstellungen deinen Speicherplatz. '
                      'Danach kannst du einen Messplan mit deinen Uhrzeiten anlegen.'
                : active
                ? 'Zurzeit sind keine Erinnerungen eingerichtet. Prüfe deine Uhrzeiten '
                      'und speichere den Messplan erneut.'
                : 'Zurzeit sind keine Erinnerungen eingerichtet. Lege einen Messplan '
                      'mit deinen Uhrzeiten an, um dich erinnern zu lassen.',
          ReminderMode.blocked =>
            'Android lässt die Benachrichtigungen von Sphygma derzeit nicht zu. '
                'Tippe auf „Berechtigungen prüfen“ und erlaube Benachrichtigungen für '
                'Sphygma. Falls einzelne Bereiche angezeigt werden, aktiviere auch den Messplan.',
          ReminderMode.failed =>
            'Die Einrichtung der Erinnerungen wurde nicht bestätigt. '
                'Tippe auf „Erneut einrichten“, um die gespeicherten Uhrzeiten noch einmal '
                'an Android zu übergeben. Dein Messplan und deine Messungen bleiben erhalten. '
                'Falls das erneut scheitert, zeigt Sphygma den Fehler an.',
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Verstanden'),
          ),
          if (mode == ReminderMode.inexact || mode == ReminderMode.blocked)
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _ReminderHelpAction.permissions),
              child: const Text('Berechtigungen prüfen'),
            ),
          if (mode == ReminderMode.failed)
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _ReminderHelpAction.retry),
              child: const Text('Erneut einrichten'),
            ),
          if (mode == ReminderMode.off)
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                missingSlot
                    ? _ReminderHelpAction.settings
                    : _ReminderHelpAction.edit,
              ),
              child: Text(
                missingSlot
                    ? 'Einstellungen öffnen'
                    : active
                    ? 'Uhrzeiten bearbeiten'
                    : 'Messplan anlegen',
              ),
            ),
        ],
      ),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _ReminderHelpAction.permissions:
        await _action(context, planController.openAccessSettings);
      case _ReminderHelpAction.retry:
        await _action(context, planController.reconcileReminders);
      case _ReminderHelpAction.edit:
        await _edit(context);
      case _ReminderHelpAction.settings:
        await showSettings(context, controller: controller);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([planController, controller]),
    builder: (context, _) {
      final plan = planController;
      if (!plan.enabled) return const SizedBox.shrink();
      final theme = SphygmaTheme.of(context);
      final measurementsByKey = {
        for (final measurement in controller.measurements)
          (
            userSlot: measurement.userSlot,
            deviceSequence: measurement.deviceSequence,
          ): measurement,
      };
      final current = plan.currentSlotPlan;
      final active = current != null && current.plan.endedAt == null;
      final status = switch (plan.mode) {
        ReminderMode.off => 'Erinnerungen ausgeschaltet',
        ReminderMode.exact => 'Erinnerungen aktiv',
        ReminderMode.inexact => 'Erinnerungen können später kommen',
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
                  PanelHeader(
                    title: 'Messplan',
                    icon: Icons.event_note,
                    subtitle:
                        'Speicherplatz ${plan.userSlot ?? 'nicht gewählt'}',
                  ),
                  if (active)
                    Text(
                      'Täglich ${current.minutes.map(formatPlanMinute).join(', ')} Uhr · bis du den Plan beendest',
                      style: TextStyle(
                        color: theme.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  if (!active)
                    Text(
                      current == null
                          ? 'Noch kein Messplan für diesen Speicherplatz.'
                          : 'Dieser Messplan ist beendet.',
                      style: TextStyle(
                        color: theme.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
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
                  InkWell(
                    onTap: () => _explainReminders(context, plan.mode),
                    child: PanelHeader(
                      title: status,
                      icon: Icons.notifications_outlined,
                    ),
                  ),
                  if (plan.mode == ReminderMode.inexact)
                    Text(
                      'Android kann die Erinnerung später anzeigen als zur eingestellten Uhrzeit.',
                      style: TextStyle(
                        color: theme.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  if (plan.mode == ReminderMode.blocked)
                    Text(
                      'Benachrichtigungen oder der Messplan-Kanal sind in Android ausgeschaltet.',
                      style: TextStyle(
                        color: theme.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => _explainReminders(context, plan.mode),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Was bedeutet das?'),
                  ),
                  if (plan.mode == ReminderMode.inexact ||
                      plan.mode == ReminderMode.blocked)
                    TextButton(
                      onPressed: plan.busy
                          ? null
                          : () => _action(context, plan.openAccessSettings),
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
                    const PanelHeader(
                      title: 'Termine heute',
                      icon: Icons.schedule,
                    ),
                    for (final occurrence in plan.todayOccurrences)
                      ListTile(
                        leading: Icon(
                          plan.fulfillment.containsKey(occurrence.key)
                              ? Icons.check_circle_outline
                              : Icons.remove_circle_outline,
                          color: theme.muted,
                          size: 24,
                          semanticLabel:
                              plan.fulfillment.containsKey(occurrence.key)
                              ? 'Messung zugeordnet'
                              : 'Keine Messung zugeordnet',
                        ),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${formatPlanMinute(occurrence.minuteOfDay)} Uhr',
                          style: TextStyle(
                            color: theme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          plan.fulfillment.containsKey(occurrence.key)
                              ? switch (measurementsByKey[plan
                                    .fulfillment[occurrence.key]]) {
                                  final measurement? =>
                                    '${formatTime(measurement.measuredAt)} Uhr · '
                                        '${measurement.systolic}/${measurement.diastolic} mmHg · '
                                        'Puls ${measurement.pulse} bpm',
                                  null => 'Zugeordnete Messung wird geladen…',
                                }
                              : occurrence.timeAmbiguous
                              ? 'Zeit nicht eindeutig'
                              : 'Noch keine Messung zugeordnet',
                          style: TextStyle(
                            color: theme.muted,
                            fontSize: 13,
                            height: 1.4,
                          ),
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
