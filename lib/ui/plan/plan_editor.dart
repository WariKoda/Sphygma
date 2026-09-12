import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';
import '../widgets/surface_panel.dart';
import '../widgets/panel_header.dart';

String formatPlanMinute(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';

class PlanEditor extends StatefulWidget {
  const PlanEditor({
    super.key,
    required this.initialMinutes,
    required this.onSave,
  });
  final List<int> initialMinutes;
  final Future<void> Function(List<int>) onSave;

  @override
  State<PlanEditor> createState() => _PlanEditorState();
}

class _PlanEditorState extends State<PlanEditor> {
  late final List<int> _minutes = List.of(widget.initialMinutes)..sort();
  bool _saving = false;
  String? _error;

  Future<void> _pick([int? index]) async {
    final initial = index == null ? 480 : _minutes[index];
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
      helpText: 'Uhrzeit wählen',
      cancelText: 'Abbrechen',
      confirmText: 'Übernehmen',
      hourLabelText: 'Stunde',
      minuteLabelText: 'Minute',
      errorInvalidText: 'Bitte eine gültige Uhrzeit eingeben.',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (selected == null || !mounted) return;
    final minute = selected.hour * 60 + selected.minute;
    if (_minutes.indexed.any(
      (entry) => entry.$1 != index && entry.$2 == minute,
    )) {
      setState(() => _error = 'Diese Uhrzeit ist bereits im Messplan.');
      return;
    }
    setState(() {
      if (index == null) {
        _minutes.add(minute);
      } else {
        _minutes[index] = minute;
      }
      _minutes.sort();
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_minutes.isEmpty) {
      setState(() => _error = 'Bitte mindestens eine Uhrzeit hinzufügen.');
      return;
    }
    if (_minutes.toSet().length != _minutes.length ||
        _minutes.any((m) => m < 0 || m >= 1440)) {
      setState(
        () => _error = 'Bitte gültige, unterschiedliche Uhrzeiten wählen.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(List.unmodifiable(_minutes));
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SphygmaTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tägliche Uhrzeiten')),
      body: SafeArea(
        child: ListView(
          padding: theme.listPadding,
          children: [
            SurfacePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PanelHeader(
                    title: 'Jeden Tag zu diesen Zeiten',
                    icon: Icons.schedule,
                    subtitle: 'Der Messplan läuft, bis du ihn beendest. Änderungen gelten für zukünftige Termine.',
                  ),
                  for (final entry in _minutes.indexed)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${formatPlanMinute(entry.$2)} Uhr',
                        style: TextStyle(
                          color: theme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: _saving ? null : () => _pick(entry.$1),
                      trailing: IconButton(
                        tooltip: '${formatPlanMinute(entry.$2)} entfernen',
                        onPressed: _saving
                            ? null
                            : () => setState(() {
                                _minutes.removeAt(entry.$1);
                                _error = null;
                              }),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: _saving ? null : _pick,
                    icon: const Icon(Icons.add),
                    label: const Text('Uhrzeit hinzufügen'),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: EdgeInsets.only(bottom: theme.gapSmall),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Wird gespeichert …' : 'Speichern'),
            ),
            TextButton(
              onPressed: _saving
                  ? null
                  : () => Navigator.of(context).maybePop(),
              child: const Text('Abbrechen'),
            ),
          ],
        ),
      ),
    );
  }
}
