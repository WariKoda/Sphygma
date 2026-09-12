import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../db/app_database.dart';
import '../theme/sphygma_theme.dart';
import '../widgets/name_dialog.dart';
import '../widgets/panel_header.dart';
import '../widgets/surface_panel.dart';

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
    final name = await showNameDialog(
      context,
      title: 'Tag umbenennen',
      actionLabel: 'Speichern',
      initialValue: tag.name,
    );
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
      final t = SphygmaTheme.of(context);
      return Scaffold(
        appBar: AppBar(title: const Text('Tags verwalten')),
        body: controller.tags.isEmpty
            ? ListView(
                padding: t.listPadding,
                children: const [
                  SurfacePanel(
                    child: PanelHeader(
                      title: 'Tags',
                      icon: Icons.sell_outlined,
                      subtitle: 'Noch keine Tags angelegt.',
                    ),
                  ),
                ],
              )
            : ListView(
                padding: t.listPadding,
                children: [
                  const PanelHeader(
                    title: 'Tags',
                    icon: Icons.sell_outlined,
                    subtitle: 'Antippen zum Umbenennen',
                  ),
                  for (final tag in controller.tags)
                    Padding(
                      padding: EdgeInsets.only(bottom: t.gapSmall),
                      child: SurfacePanel(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(tag.name),
                          onTap: () => _rename(context, tag),
                          trailing: IconButton(
                            tooltip: 'Tag löschen',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(context, tag),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      );
    },
  );
}
