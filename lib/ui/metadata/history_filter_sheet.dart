import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../stats/measurement_filter.dart';
import '../theme/sphygma_theme.dart';
import '../widgets/panel_header.dart';
import '../widgets/section_header.dart';
import '../widgets/surface_panel.dart';

Future<void> showHistoryFilterSheet(
  BuildContext context, {
  required AppController controller,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _HistoryFilterSheet(controller: controller),
);

class _HistoryFilterSheet extends StatefulWidget {
  const _HistoryFilterSheet({required this.controller});
  final AppController controller;
  @override
  State<_HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<_HistoryFilterSheet> {
  late HistoryFilter value = widget.controller.historyFilter;

  void _tag(int id, bool selected) {
    final ids = {...value.tagIds};
    selected ? ids.add(id) : ids.remove(id);
    setState(
      () => value = value.copyWith(
        tagIds: ids,
        tags: ids.isEmpty
            ? MembershipFilter.unrestricted
            : MembershipFilter.selected,
      ),
    );
  }

  void _phase(int id, bool selected) {
    final ids = {...value.phaseIds};
    selected ? ids.add(id) : ids.remove(id);
    setState(
      () => value = value.copyWith(
        phaseIds: ids,
        phases: ids.isEmpty
            ? MembershipFilter.unrestricted
            : MembershipFilter.selected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return SafeArea(
      child: Padding(
        padding: t.listPadding,
        child: ListView(
          shrinkWrap: true,
          children: [
            const PanelHeader(
              title: 'Verlauf filtern',
              icon: Icons.filter_list,
              subtitle: 'Messungen nach Tags und Phasen eingrenzen',
            ),
            SurfacePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'Tags', leadingGap: false),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ohne Tags'),
                    value: value.tags == MembershipFilter.unassigned,
                    onChanged: (selected) => setState(
                      () => value = value.copyWith(
                        tagIds: const {},
                        tags: selected == true
                            ? MembershipFilter.unassigned
                            : MembershipFilter.unrestricted,
                      ),
                    ),
                  ),
                  for (final tag in widget.controller.tags)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(tag.name),
                      value: value.tagIds.contains(tag.id),
                      onChanged: value.tags == MembershipFilter.unassigned
                          ? null
                          : (selected) => _tag(tag.id, selected ?? false),
                    ),
                  if (value.tagIds.length >= 2)
                    _MatchModePicker(
                      value: value.tagMode,
                      anyLabel: 'Mindestens eines',
                      onChanged: (mode) =>
                          setState(() => value = value.copyWith(tagMode: mode)),
                    ),
                ],
              ),
            ),
            if (widget.controller.phasesEnabled) ...[
              SizedBox(height: t.gapLarge),
              SurfacePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(title: 'Phasen', leadingGap: false),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ohne Phase'),
                      value: value.phases == MembershipFilter.unassigned,
                      onChanged: (selected) => setState(
                        () => value = value.copyWith(
                          phaseIds: const {},
                          phases: selected == true
                              ? MembershipFilter.unassigned
                              : MembershipFilter.unrestricted,
                        ),
                      ),
                    ),
                    for (final phase in widget.controller.phases)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(phase.name),
                        value: value.phaseIds.contains(phase.id),
                        onChanged: value.phases == MembershipFilter.unassigned
                            ? null
                            : (selected) => _phase(phase.id, selected ?? false),
                      ),
                    if (value.phaseIds.length >= 2)
                      _MatchModePicker(
                        value: value.phaseMode,
                        anyLabel: 'Mindestens eine',
                        onChanged: (mode) => setState(
                          () => value = value.copyWith(phaseMode: mode),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            SizedBox(height: t.gapLarge),
            Wrap(
              spacing: t.gapSmall,
              runSpacing: t.gapSmall,
              alignment: WrapAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    widget.controller.resetHistoryFilter();
                    Navigator.pop(context);
                  },
                  child: const Text('Filter zurücksetzen'),
                ),
                FilledButton(
                  onPressed: () {
                    widget.controller.setHistoryFilter(value);
                    Navigator.pop(context);
                  },
                  child: const Text('Anwenden'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchModePicker extends StatelessWidget {
  const _MatchModePicker({
    required this.value,
    required this.anyLabel,
    required this.onChanged,
  });

  final MatchMode value;
  final String anyLabel;
  final ValueChanged<MatchMode> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      ChoiceChip(
        label: Text(anyLabel),
        selected: value == MatchMode.any,
        onSelected: (_) => onChanged(MatchMode.any),
      ),
      ChoiceChip(
        label: const Text('Alle'),
        selected: value == MatchMode.all,
        onSelected: (_) => onChanged(MatchMode.all),
      ),
    ],
  );
}
