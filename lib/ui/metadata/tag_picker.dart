import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../widgets/name_dialog.dart';
import '../widgets/section_header.dart';

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
    final name = await showNameDialog(
      context,
      title: 'Neuen Tag anlegen',
      actionLabel: 'Anlegen',
    );
    if (name == null || !context.mounted) return;
    try {
      final id = await controller.createTag(name);
      if (!context.mounted) return;
      onChanged({...selected, id});
    } catch (error) {
      if (context.mounted) onError(error);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionHeader(title: 'Tags', leadingGap: false),
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
