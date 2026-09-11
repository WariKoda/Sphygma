import 'package:flutter/material.dart';

import '../../app/app_controller.dart';

class TagPicker extends StatelessWidget {
  const TagPicker({
    super.key,
    required this.controller,
    required this.selected,
    required this.onChanged,
    required this.onError,
    required this.enabled,
  });

  final AppController controller;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;
  final ValueChanged<Object> onError;
  final bool enabled;

  Future<void> _create(BuildContext context) async {
    final input = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neuen Tag anlegen'),
        content: TextField(
          controller: input,
          maxLength: 40,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: const Text('Anlegen'),
          ),
        ],
      ),
    );
    input.dispose();
    if (name == null || !context.mounted) return;
    try {
      final id = await controller.createTag(name);
      onChanged({...selected, id});
    } catch (error) {
      onError(error);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Tags'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final tag in controller.tags)
            FilterChip(
              label: Text(tag.name),
              selected: selected.contains(tag.id),
              onSelected: enabled
                  ? (value) {
                      final next = {...selected};
                      value ? next.add(tag.id) : next.remove(tag.id);
                      onChanged(next);
                    }
                  : null,
            ),
          ActionChip(
            avatar: const Icon(Icons.add, size: 18),
            label: const Text('Tag anlegen'),
            onPressed: enabled ? () => _create(context) : null,
          ),
        ],
      ),
    ],
  );
}
