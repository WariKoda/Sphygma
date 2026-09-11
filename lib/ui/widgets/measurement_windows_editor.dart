import 'package:flutter/material.dart';

import '../../stats/measurement_windows.dart';
import '../theme/sphygma_theme.dart';
import 'surface_panel.dart';

class MeasurementWindowsEditor extends StatefulWidget {
  const MeasurementWindowsEditor({
    super.key,
    required this.initialValue,
    required this.onSave,
  });

  final MeasurementWindows initialValue;
  final Future<void> Function(MeasurementWindows) onSave;

  @override
  State<MeasurementWindowsEditor> createState() =>
      _MeasurementWindowsEditorState();
}

class _MeasurementWindowsEditorState extends State<MeasurementWindowsEditor> {
  late final List<int> _minutes = [
    widget.initialValue.morningStart,
    widget.initialValue.morningEnd,
    widget.initialValue.eveningStart,
    widget.initialValue.eveningEnd,
  ];
  bool _saving = false;
  String? _error;
  static const _labels = [
    'Morgen beginnt',
    'Morgen endet',
    'Abend beginnt',
    'Abend endet',
  ];
  static const _keys = [
    'morning-start',
    'morning-end',
    'evening-start',
    'evening-end',
  ];

  Future<void> _pick(int index) async {
    final minute = _minutes[index];
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
      helpText: _labels[index],
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
    setState(() {
      _minutes[index] = selected.hour * 60 + selected.minute;
      _error = null;
    });
  }

  Future<void> _save() async {
    late MeasurementWindows value;
    try {
      value = MeasurementWindows(
        morningStart: _minutes[0],
        morningEnd: _minutes[1],
        eveningStart: _minutes[2],
        eveningEnd: _minutes[3],
      );
    } on ArgumentError {
      setState(
        () => _error = 'Die Fenster dürfen sich nicht überschneiden. Beginn und Ende müssen verschieden sein.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(value);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = 'Speichern fehlgeschlagen: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: t.surface,
        appBar: AppBar(
          title: const Text('Morgen und Abend'),
          backgroundColor: t.surface,
          foregroundColor: t.onSurface,
        ),
        body: SafeArea(
          child: ListView(
            padding: t.listPadding,
            children: [
              SurfacePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Die Fenster gelten für Heute, Wochenraster und Verlauf. Messungen außerhalb bleiben in Listen und Gesamtauswertungen enthalten. Änderungen wirken rückwirkend nur auf die Anzeige; Messdaten und Erinnerungen bleiben unverändert.',
                      style: TextStyle(color: t.onSurface),
                    ),
                    SizedBox(height: t.gapSmall),
                    Text(
                      'Der Beginn zählt zum Fenster, das Ende nicht. Fenster dürfen über Mitternacht reichen.',
                      style: TextStyle(color: t.muted),
                    ),
                    for (var index = 0; index < 4; index++)
                      ListTile(
                        key: Key(_keys[index]),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _labels[index],
                          style: TextStyle(color: t.onSurface),
                        ),
                        subtitle: Text(
                          '${(_minutes[index] ~/ 60).toString().padLeft(2, '0')}:${(_minutes[index] % 60).toString().padLeft(2, '0')} Uhr',
                          style: TextStyle(color: t.muted),
                        ),
                        onTap: _saving ? null : () => _pick(index),
                      ),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() {
                              final value = MeasurementWindows.defaults;
                              _minutes.setAll(0, [
                                value.morningStart,
                                value.morningEnd,
                                value.eveningStart,
                                value.eveningEnd,
                              ]);
                              _error = null;
                            }),
                      child: const Text('Standardzeiten wiederherstellen'),
                    ),
                  ],
                ),
              ),
              if (_error != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Wird gespeichert …' : 'Speichern'),
              ),
              TextButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
