// Eine Phase beginnt mit einer Herkunftsaussage.
//
// Zwei Schritte, weil zwei Dinge festzulegen sind: was beginnt, und ab wann.
// Der Zeitanker ist kein Detail — ein Datum ohne Herkunft würde Sicherheit
// vortäuschen, die dieses Gerät nicht hergibt.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../db/occasion_repository.dart';
import '../../format.dart';
import '../../theme/sphygma_theme.dart';

Future<void> showNewPhaseSheet(
  BuildContext context, {
  required AppController controller,
}) {
  final theme = SphygmaTheme.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: theme.surface,
    isScrollControlled: true,
    builder: (_) => SphygmaThemeScope(
      theme: theme,
      child: _NewPhaseSheet(controller: controller),
    ),
  );
}

class _NewPhaseSheet extends StatefulWidget {
  const _NewPhaseSheet({required this.controller});

  final AppController controller;

  @override
  State<_NewPhaseSheet> createState() => _NewPhaseSheetState();
}

class _NewPhaseSheetState extends State<_NewPhaseSheet> {
  final _name = TextEditingController();
  PhaseAnchor _anker = PhaseAnchor.jetzt;
  DateTime? _datum;
  String? _fehler;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _bereit =>
      _name.text.trim().isNotEmpty &&
      (_anker == PhaseAnchor.jetzt || _datum != null);

  Future<void> _speichern() async {
    try {
      await widget.controller.startPhase(
        name: _name.text,
        anchor: _anker,
        begin: _anker == PhaseAnchor.bestaetigt ? _datum : null,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Das Repository wehrt sich gegen einen leeren Namen und gegen ein
      // Datum ohne Anker. Die Meldung gehört an den Nutzer, nicht ins Log.
      if (mounted) setState(() => _fehler = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: t.gapLarge,
        right: t.gapLarge,
        top: t.gapLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom + t.gapLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Neue Phase',
            style: TextStyle(fontSize: 17, color: t.onSurface),
          ),
          SizedBox(height: t.gapLarge),
          Text('Was beginnt?', style: TextStyle(fontSize: 12, color: t.muted)),
          TextField(
            controller: _name,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ramipril 5 mg, Urlaub, nach der Umstellung',
            ),
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: t.gapLarge),
          Text(
            'Welcher Zeitanker gilt?',
            style: TextStyle(fontSize: 12, color: t.muted),
          ),
          RadioGroup<PhaseAnchor>(
            groupValue: _anker,
            onChanged: (a) => setState(() => _anker = a ?? _anker),
            child: Column(
              children: [
                RadioListTile<PhaseAnchor>(
                  value: PhaseAnchor.jetzt,
                  title: Text(
                    'Jetzt',
                    style: TextStyle(fontSize: 14, color: t.onSurface),
                  ),
                  subtitle: Text(
                    'Die Uhr des Telefons, unabhängig von der Geräteuhr.',
                    style: TextStyle(fontSize: 11, color: t.muted),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                RadioListTile<PhaseAnchor>(
                  value: PhaseAnchor.bestaetigt,
                  title: Text(
                    'Zu einem bestätigten Datum',
                    style: TextStyle(fontSize: 14, color: t.onSurface),
                  ),
                  subtitle: Text(
                    'Für eine rückwirkende Phase.',
                    style: TextStyle(fontSize: 11, color: t.muted),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
            ),
          ),
          if (_anker == PhaseAnchor.bestaetigt)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  final jetzt = DateTime.now();
                  final gewaehlt = await showDatePicker(
                    context: context,
                    initialDate: _datum ?? jetzt,
                    firstDate: DateTime(jetzt.year - 10),
                    lastDate: jetzt,
                  );
                  if (gewaehlt != null) setState(() => _datum = gewaehlt);
                },
                child: Text(
                  _datum == null
                      ? 'Datum wählen'
                      : 'Beginn: ${formatDay(_datum!)}',
                ),
              ),
            ),
          SizedBox(height: t.gapSmall),
          Text(
            'Neue Messungen werden nicht automatisch zugeordnet. Das Gerät '
            'kann alte Aufzeichnungen liefern; nur Messungen mit '
            'glaubwürdiger Gerätezeit fallen in die Phase.',
            style: TextStyle(fontSize: 11, color: t.muted, height: 1.5),
          ),
          if (_fehler != null) ...[
            SizedBox(height: t.gapSmall),
            Text(
              _fehler!,
              style: TextStyle(fontSize: 12, color: t.onSurface),
            ),
          ],
          SizedBox(height: t.gapLarge),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _bereit ? _speichern : null,
              child: const Text('Phase beginnen'),
            ),
          ),
        ],
      ),
    );
  }
}
