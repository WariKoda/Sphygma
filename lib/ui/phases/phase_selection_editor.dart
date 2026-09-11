import 'package:flutter/material.dart';

import '../../app/app_controller.dart';

class PhaseSelectionEditor extends StatefulWidget {
  const PhaseSelectionEditor({
    super.key,
    required this.controller,
    required this.deviceSequence,
  });

  final AppController controller;
  final int deviceSequence;

  @override
  State<PhaseSelectionEditor> createState() => _PhaseSelectionEditorState();
}

class _PhaseSelectionEditorState extends State<PhaseSelectionEditor> {
  late final int? _slot;
  late Set<int> _selected;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _slot = widget.controller.userSlot;
    _selected = {
      ...?widget.controller.phaseIdsBySequence[widget.deviceSequence],
    };
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.userSlot != _slot) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Phasen'),
        for (final phase in widget.controller.phases)
          CheckboxListTile(
            value: _selected.contains(phase.id),
            onChanged: _saving
                ? null
                : (selected) => setState(() {
                    selected == true
                        ? _selected.add(phase.id)
                        : _selected.remove(phase.id);
                  }),
            title: Text(phase.name),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        Row(
          children: [
            TextButton(
              onPressed: _saving
                  ? null
                  : () => _run(
                      () => widget.controller.useAutomaticPhases(
                        widget.deviceSequence,
                      ),
                    ),
              child: const Text('Automatisch zuordnen'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saving
                  ? null
                  : () => _run(
                      () => widget.controller.selectPhases(
                        widget.deviceSequence,
                        _selected,
                      ),
                    ),
              child: const Text('Phasenauswahl speichern'),
            ),
          ],
        ),
      ],
    );
  }
}
