// Was von dem, was schon auf dem Gerät liegt, soll die App übernehmen?
//
// Die Frage stellt sich beim ersten Koppeln und bei jedem erneuten: Auf einem
// gebrauchten Messgerät stehen womöglich hundert Messungen, die einer anderen
// Person gehören oder aus einer Zeit stammen, die niemanden mehr interessiert.
// Sie ungefragt in die Gesundheitsakte zu übertragen wäre falsch.
//
// **Nichts wird gelöscht.** Die Messungen bleiben in der Datenbank — sie ist
// reines Abbild des Geräts, das ist eine harte Projektregel. Was hier gewählt
// wird, ist eine Grenze: Alles darunter wird nie angezeigt und nie nach Health
// Connect übertragen. Sie ist jederzeit widerrufbar, und ein späterer
// Voll-Readout ändert daran nichts.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import 'theme/sphygma_theme.dart';
import 'widgets/surface_panel.dart';
import 'widgets/panel_header.dart';

/// Fragt nach dem Koppeln, was übernommen werden soll.
///
/// Ein Abbruch lässt eine ausstehende Erstentscheidung offen. Der automatische
/// Export bleibt dann bis zur Auswahl in den Einstellungen gesperrt.
Future<void> showIntakeChoice(
  BuildContext context, {
  required AppController controller,
}) {
  if (!controller.canChooseIntake) {
    throw StateError(
      'Vor der Übernahme muss der erste Abgleich abgeschlossen sein.',
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: SphygmaTheme.of(context).surface,
    builder: (_) => _IntakeChoice(controller: controller),
  );
}

class _IntakeChoice extends StatefulWidget {
  const _IntakeChoice({required this.controller});

  final AppController controller;

  @override
  State<_IntakeChoice> createState() => _IntakeChoiceState();
}

class _IntakeChoiceState extends State<_IntakeChoice> {
  bool _laeuft = false;

  Future<void> _waehle(Future<void> Function() wahl) async {
    if (widget.controller.busy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte den laufenden Abgleich abwarten.')),
      );
      return;
    }
    setState(() => _laeuft = true);
    try {
      await wahl();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Der Fehler darf nicht verschwinden: Bliebe das Blatt einfach offen,
      // hielte der Nutzer die Wahl für getroffen.
      if (!mounted) rethrow;
      setState(() => _laeuft = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Wahl fehlgeschlagen: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final anzahl = widget.controller.measurements.length;

    return SafeArea(
      child: Padding(
        padding: t.listPadding,
        child: SurfacePanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelHeader(
                title: 'Was soll übernommen werden?',
                icon: Icons.download_outlined,
              ),
              Text(
                anzahl == 0
                    ? 'Auf dem Gerät steht bisher nichts.'
                    : 'Auf dem Gerät stehen $anzahl Messungen. Was du nicht '
                          'übernimmst, wird nie angezeigt und nie an Health '
                          'Connect übertragen — gelöscht wird nichts, und du '
                          'kannst es später wieder freigeben.',
                style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
              ),
              SizedBox(height: t.gapLarge),
              _Wahl(
                titel: 'Alles',
                erklaerung: 'Auch was vor heute gemessen wurde.',
                enabled: !_laeuft,
                onTap: () => _waehle(widget.controller.takeAll),
              ),
              _Wahl(
                titel: 'Ab einem Datum',
                erklaerung: 'Alles Ältere bleibt verborgen.',
                enabled: !_laeuft,
                onTap: () async {
                  final jetzt = DateTime.now();
                  final ab = await showDatePicker(
                    context: context,
                    initialDate: jetzt,
                    firstDate: DateTime(jetzt.year - 10),
                    lastDate: jetzt,
                    helpText: 'Ab wann übernehmen?',
                  );
                  if (ab == null) return;
                  await _waehle(() => widget.controller.takeFrom(ab));
                },
              ),
              _Wahl(
                titel: 'Nur neue Messungen',
                erklaerung: 'Alles, was jetzt schon da ist, bleibt verborgen.',
                enabled: !_laeuft,
                onTap: () => _waehle(widget.controller.takeOnlyNew),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Wahl extends StatelessWidget {
  const _Wahl({
    required this.titel,
    required this.erklaerung,
    required this.onTap,
    required this.enabled,
  });

  final String titel;
  final String erklaerung;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: enabled ? onTap : null,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(
              horizontal: t.gapLarge * 0.6,
              vertical: t.gapSmall + 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titel, style: TextStyle(fontSize: 15, color: t.onSurface)),
              SizedBox(height: t.gapSmall / 3),
              Text(erklaerung, style: TextStyle(fontSize: 12, color: t.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
