import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../plan/plan_controller.dart';
import '../../plan/plan_models.dart';
import '../format.dart';
import '../theme/sphygma_theme.dart';
import '../widgets/surface_panel.dart';
import '../widgets/panel_header.dart';
import 'plan_editor.dart';

class OccurrenceAssignmentSheet extends StatefulWidget {
  const OccurrenceAssignmentSheet({
    super.key,
    required this.planController,
    required this.controller,
    required this.occurrence,
  });
  final PlanController planController;
  final AppController controller;
  final PlannedOccurrence occurrence;

  @override
  State<OccurrenceAssignmentSheet> createState() =>
      _OccurrenceAssignmentSheetState();
}

class _OccurrenceAssignmentSheetState extends State<OccurrenceAssignmentSheet> {
  bool _saving = false;
  String? _error;
  Future<void> _apply(Future<void> Function() action) async {
    if (!widget.planController.enabled ||
        widget.planController.userSlot != widget.occurrence.userSlot) {
      setState(
        () => _error = 'Der ausgewählte Messplan hat sich geändert. Bitte das Blatt erneut öffnen.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.controller, widget.planController]),
    builder: (context, _) {
      final theme = SphygmaTheme.of(context);
      final plan = widget.planController;
      final occurrence = widget.occurrence;
      final assigned = plan.fulfillment[occurrence.key];
      final measurements = widget.controller.measurements
          .where((m) => m.userSlot == occurrence.userSlot)
          .toList();
      final disabled =
          _saving ||
          plan.busy ||
          !plan.enabled ||
          plan.userSlot != occurrence.userSlot;
      return Scaffold(
        appBar: AppBar(title: const Text('Messung zuordnen')),
        body: SafeArea(
          child: ListView(
            padding: theme.listPadding,
            children: [
              SurfacePanel(
                child: PanelHeader(
                  title:
                      '${formatPlanMinute(occurrence.minuteOfDay)} Uhr · ${occurrence.localDate}',
                  icon: Icons.event_note,
                  subtitle: 'Wähle eine vorhandene Messung für diesen Termin. Die Gerätezeit und Messwerte bleiben unverändert.',
                ),
              ),
              if (_error != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (assigned != null) ...[
                TextButton(
                  onPressed: disabled
                      ? null
                      : () => _apply(() => plan.assign(assigned, null)),
                  child: const Text('Zuordnung aufheben'),
                ),
                TextButton(
                  onPressed: disabled
                      ? null
                      : () =>
                            _apply(() => plan.useAutomaticAssignment(assigned)),
                  child: const Text('Automatisch zuordnen'),
                ),
              ],
              if (measurements.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: theme.gapLarge),
                  child: Text(
                    'Für diesen Speicherplatz sind noch keine Messungen gespeichert.',
                    style: TextStyle(
                      color: theme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (measurements.isNotEmpty)
                const PanelHeader(
                  title: 'Vorhandene Messungen',
                  icon: Icons.assignment_outlined,
                ),
              for (final measurement in measurements)
                SurfacePanel(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${measurement.systolic}/${measurement.diastolic} mmHg · Puls ${measurement.pulse}',
                      style: TextStyle(
                        color: theme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${formatDayAndTime(measurement.measuredAt)} · Messung ${measurement.deviceSequence}',
                      style: TextStyle(
                        color: theme.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Zuordnung dieser Messung',
                      enabled: !disabled,
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'automatic',
                          child: Text('Automatisch zuordnen'),
                        ),
                        PopupMenuItem(
                          value: 'exclude',
                          child: Text('Nicht automatisch zuordnen'),
                        ),
                      ],
                      onSelected: (value) => _apply(() {
                        final key = (
                          userSlot: measurement.userSlot,
                          deviceSequence: measurement.deviceSequence,
                        );
                        return value == 'automatic'
                            ? plan.useAutomaticAssignment(key)
                            : plan.assign(key, null);
                      }),
                    ),
                    selected:
                        assigned?.deviceSequence == measurement.deviceSequence,
                    onTap: disabled
                        ? null
                        : () => _apply(
                            () => plan.assign((
                              userSlot: measurement.userSlot,
                              deviceSequence: measurement.deviceSequence,
                            ), occurrence.key),
                          ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
