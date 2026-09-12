import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../db/app_database.dart';
import '../format.dart';
import '../theme/sphygma_theme.dart';
import '../widgets/panel_header.dart';
import '../widgets/surface_panel.dart';

class PhaseManagementScreen extends StatefulWidget {
  const PhaseManagementScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<PhaseManagementScreen> createState() => _PhaseManagementScreenState();
}

class _PhaseManagementScreenState extends State<PhaseManagementScreen> {
  late final int? _slot;
  AppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _slot = controller.userSlot;
  }

  Future<void> _edit(BuildContext context, [ScopedPhase? phase]) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _PhaseDialog(controller: controller, phase: phase),
    );
  }

  Future<void> _delete(BuildContext context, ScopedPhase phase) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phase löschen?'),
        content: Text(
          '„${phase.name}“ wird aus den Zuordnungen entfernt. Messwerte bleiben erhalten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.deletePhase(phase.id);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      if (controller.userSlot != _slot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop();
        });
        return const SizedBox.shrink();
      }
      final t = SphygmaTheme.of(context);
      return Scaffold(
        appBar: AppBar(title: const Text('Phasen')),
        body: controller.phases.isEmpty
            ? ListView(
                padding: t.listPadding,
                children: const [
                  SurfacePanel(
                    child: PanelHeader(
                      title: 'Phasen',
                      icon: Icons.timeline_outlined,
                      subtitle: 'Noch keine Phasen angelegt.',
                    ),
                  ),
                ],
              )
            : ListView(
                padding: t.listPadding,
                children: [
                  const PanelHeader(
                    title: 'Phasen',
                    icon: Icons.timeline_outlined,
                    subtitle: 'Zeiträume für die Auswertung',
                  ),
                  for (final phase in controller.phases)
                    Padding(
                      padding: EdgeInsets.only(bottom: t.gapSmall),
                      child: SurfacePanel(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(phase.name),
                          subtitle: Text(
                            phase.endsAt == null
                                ? 'Seit ${formatDayAndTime(phase.beginsAt.toLocal())} · laufend'
                                : '${formatDayAndTime(phase.beginsAt.toLocal())} – '
                                      '${formatDayAndTime(phase.endsAt!.toLocal())}',
                          ),
                          onTap: () => _edit(context, phase),
                          trailing: IconButton(
                            tooltip: 'Phase löschen',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(context, phase),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context),
          icon: const Icon(Icons.add),
          label: const Text('Phase anlegen'),
        ),
      );
    },
  );
}

class _PhaseDialog extends StatefulWidget {
  const _PhaseDialog({required this.controller, required this.phase});

  final AppController controller;
  final ScopedPhase? phase;

  @override
  State<_PhaseDialog> createState() => _PhaseDialogState();
}

class _PhaseDialogState extends State<_PhaseDialog> {
  late final TextEditingController _name;
  late final TextEditingController _begin;
  late final TextEditingController _end;
  String? _error;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final phase = widget.phase;
    _name = TextEditingController(text: phase?.name);
    _begin = TextEditingController(
      text: (phase?.beginsAt ?? DateTime.now()).toIso8601String(),
    );
    _end = TextEditingController(text: phase?.endsAt?.toIso8601String());
  }

  @override
  void dispose() {
    _name.dispose();
    _begin.dispose();
    _end.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final beginsAt = DateTime.tryParse(_begin.text.trim());
    final endsAt = _end.text.trim().isEmpty
        ? null
        : DateTime.tryParse(_end.text.trim());
    if (beginsAt == null || (_end.text.trim().isNotEmpty && endsAt == null)) {
      setState(() => _error = 'Bitte gültige ISO-Zeitpunkte eingeben.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.controller.savePhase(
        id: widget.phase?.id,
        name: _name.text,
        begin: beginsAt,
        end: endsAt,
      );
      if (mounted) Navigator.pop(context);
    } catch (caught) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '$caught';
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.phase == null ? 'Phase anlegen' : 'Phase bearbeiten'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          enabled: !_saving,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _begin,
          enabled: !_saving,
          decoration: const InputDecoration(
            labelText: 'Beginn (ISO-Datum und Uhrzeit)',
          ),
        ),
        TextField(
          controller: _end,
          enabled: !_saving,
          decoration: const InputDecoration(labelText: 'Ende (optional)'),
        ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Abbrechen'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: const Text('Speichern'),
      ),
    ],
  );
}
