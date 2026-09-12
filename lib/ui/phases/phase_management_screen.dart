import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../db/app_database.dart';

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
    final name = TextEditingController(text: phase?.name);
    final begin = TextEditingController(
      text: (phase?.beginsAt ?? DateTime.now()).toIso8601String(),
    );
    final end = TextEditingController(text: phase?.endsAt?.toIso8601String());
    String? error;
    var saving = false;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(phase == null ? 'Phase anlegen' : 'Phase bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                enabled: !saving,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: begin,
                enabled: !saving,
                decoration: const InputDecoration(
                  labelText: 'Beginn (ISO-Datum und Uhrzeit)',
                ),
              ),
              TextField(
                controller: end,
                enabled: !saving,
                decoration: const InputDecoration(labelText: 'Ende (optional)'),
              ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final beginsAt = DateTime.tryParse(begin.text.trim());
                      final endsAt = end.text.trim().isEmpty
                          ? null
                          : DateTime.tryParse(end.text.trim());
                      if (beginsAt == null ||
                          (end.text.trim().isNotEmpty && endsAt == null)) {
                        setState(
                          () =>
                              error = 'Bitte gültige ISO-Zeitpunkte eingeben.',
                        );
                        return;
                      }
                      setState(() {
                        saving = true;
                        error = null;
                      });
                      try {
                        await controller.savePhase(
                          id: phase?.id,
                          name: name.text,
                          begin: beginsAt,
                          end: endsAt,
                        );
                        if (context.mounted) Navigator.pop(context);
                      } catch (caught) {
                        setState(() {
                          saving = false;
                          error = '$caught';
                        });
                      }
                    },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    begin.dispose();
    end.dispose();
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
      return Scaffold(
        appBar: AppBar(title: const Text('Phasen')),
        body: controller.phases.isEmpty
            ? const Center(child: Text('Noch keine Phasen.'))
            : ListView(
                children: [
                  for (final phase in controller.phases)
                    ListTile(
                      title: Text(phase.name),
                      subtitle: Text(
                        '${phase.beginsAt.toLocal()} – '
                        '${phase.endsAt?.toLocal() ?? 'laufend'}',
                      ),
                      onTap: () => _edit(context, phase),
                      trailing: IconButton(
                        tooltip: 'Phase löschen',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, phase),
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
