import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../stats/measurement_filter.dart';

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
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            'Verlauf filtern',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text('Tags'),
          CheckboxListTile(
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
              title: Text(tag.name),
              value: value.tagIds.contains(tag.id),
              onChanged: value.tags == MembershipFilter.unassigned
                  ? null
                  : (selected) => _tag(tag.id, selected ?? false),
            ),
          if (value.tagIds.length >= 2)
            SegmentedButton<MatchMode>(
              segments: const [
                ButtonSegment(
                  value: MatchMode.any,
                  label: Text('Mindestens eines'),
                ),
                ButtonSegment(value: MatchMode.all, label: Text('Alle')),
              ],
              selected: {value.tagMode},
              onSelectionChanged: (selection) => setState(
                () => value = value.copyWith(tagMode: selection.first),
              ),
            ),
          if (widget.controller.phasesEnabled) ...[
            const SizedBox(height: 16),
            const Text('Phasen'),
            CheckboxListTile(
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
                title: Text(phase.name),
                value: value.phaseIds.contains(phase.id),
                onChanged: value.phases == MembershipFilter.unassigned
                    ? null
                    : (selected) => _phase(phase.id, selected ?? false),
              ),
            if (value.phaseIds.length >= 2)
              SegmentedButton<MatchMode>(
                segments: const [
                  ButtonSegment(
                    value: MatchMode.any,
                    label: Text('Mindestens eine'),
                  ),
                  ButtonSegment(value: MatchMode.all, label: Text('Alle')),
                ],
                selected: {value.phaseMode},
                onSelectionChanged: (selection) => setState(
                  () => value = value.copyWith(phaseMode: selection.first),
                ),
              ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  widget.controller.resetHistoryFilter();
                  Navigator.pop(context);
                },
                child: const Text('Filter zurücksetzen'),
              ),
              const Spacer(),
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
