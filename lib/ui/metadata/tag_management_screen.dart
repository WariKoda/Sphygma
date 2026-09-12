import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../db/app_database.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  late final int? _slot;
  AppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _slot = controller.userSlot;
  }

  Future<void> _rename(BuildContext context, MeasurementTag tag) async {
    final input = TextEditingController(text: tag.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tag umbenennen'),
        content: TextField(controller: input, maxLength: 40, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    input.dispose();
    if (name != null) await controller.renameTag(tag.id, name);
  }

  Future<void> _delete(BuildContext context, MeasurementTag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tag löschen?'),
        content: Text(
          '„${tag.name}“ wird von allen Messungen entfernt. Die Messwerte bleiben erhalten.',
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
    if (confirmed == true) await controller.deleteTag(tag.id);
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
        appBar: AppBar(title: const Text('Tags verwalten')),
        body: controller.tags.isEmpty
            ? const Center(child: Text('Noch keine Tags.'))
            : ListView(
                children: [
                  for (final tag in controller.tags)
                    ListTile(
                      title: Text(tag.name),
                      onTap: () => _rename(context, tag),
                      trailing: IconButton(
                        tooltip: 'Tag löschen',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, tag),
                      ),
                    ),
                ],
              ),
      );
    },
  );
}
