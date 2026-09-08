// Alles, was man einstellt — an einem Ort, hinter dem Zahnrad.
//
// Die Trennung zum Gerätebereich verläuft zwischen **einstellen** und **tun**:
// Welcher Speicherplatz gehört mir, wie ist gekoppelt, welches Konzept, welche
// Gestaltung — das wird einmal entschieden und steht hier. Abgleichen und
// übertragen sind Handlungen; die bleiben im Gerätebereich, zusammen mit dem
// Zustand, den sie betreffen.
import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/concept.dart';
import 'theme/sphygma_theme.dart';
import 'widgets/surface_panel.dart';
import 'theme/variants.dart';
import 'widgets/section_header.dart';
import 'widgets/setting_row.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Der Kopplungsteil samt Speicherplatzwahl. Im Alltag verdeckt — die Wahl
  /// fällt einmal beim Einrichten. Erreichbar bleibt er trotzdem: Nach einem
  /// Werksreset am Gerät oder einer Kopplung mit der Omron-App muss neu
  /// gekoppelt werden, und ein falsch gewählter Speicherplatz ließe sonst
  /// dauerhaft den falschen Benutzer auslesen.
  bool _pairingOpen = false;

  /// Startet eine Aktion des Steuerungsteils.
  ///
  /// [AppController] wirft nach dem Setzen von `status` erneut — die Meldung
  /// steht also schon fest und wird angezeigt. Ohne diesen Fang liefe der
  /// Fehler als unbeobachtete Ausnahme in die Zone.
  static void _start(Future<void> Function() action) {
    unawaited(
      action().catchError((Object e) {
        debugPrint('[Sphygma] Aktion fehlgeschlagen: $e');
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final c = widget.controller;
    final showPairing = !c.paired || _pairingOpen;

    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => Scaffold(
        backgroundColor: t.surface,
        appBar: AppBar(
          title: const Text('Einstellungen'),
          backgroundColor: t.surface,
          foregroundColor: t.onSurface,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: t.listPadding,
          child: SurfacePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Gerät'),
                SettingRow(
                  label: 'RS7 Intelli IT',
                  value: c.paired ? 'gekoppelt' : 'nicht gekoppelt',
                ),
                if (c.userSlot != null)
                  SettingRow(
                    label: 'Speicherplatz',
                    value: 'Benutzer ${c.userSlot}',
                  ),
                if (c.paired && !_pairingOpen)
                  SettingButton(
                    label: 'Neu koppeln',
                    onPressed: c.busy
                        ? null
                        : () => setState(() => _pairingOpen = true),
                  ),
                if (showPairing) ...[
                  SizedBox(height: t.gapSmall),
                  Text(
                    'Welcher Speicherplatz gehört dir am Gerät?',
                    style: TextStyle(fontSize: 12, color: t.muted),
                  ),
                  SizedBox(height: t.gapSmall),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('Benutzer 1')),
                      ButtonSegment(value: 2, label: Text('Benutzer 2')),
                    ],
                    // Ohne gewählten Slot ist nichts ausgewählt. Ein
                    // vorgetäuschtes „Benutzer 1" ließe sich nicht antippen:
                    // SegmentedButton meldet keinen Wechsel auf das bereits
                    // ausgewählte einzige Segment.
                    emptySelectionAllowed: true,
                    selected: c.userSlot == null
                        ? const <int>{}
                        : {c.userSlot!},
                    onSelectionChanged: (sel) =>
                        sel.isEmpty ? null : c.setUserSlot(sel.first),
                  ),
                  SizedBox(height: t.gapSmall),
                  Text(
                    'Zum Koppeln die Bluetooth-Taste am Gerät lange drücken, '
                    'bis "-P-" blinkt.',
                    style: TextStyle(fontSize: 12, color: t.muted),
                  ),
                  SettingButton(
                    label: 'Koppeln',
                    filled: true,
                    onPressed: c.busy || c.userSlot == null
                        ? null
                        : () => _start(c.pair),
                  ),
                ],
                const SectionHeader(title: 'Konzept'),
                _Erklaerung(
                  text:
                      'Andere Konzepte ordnen denselben Bestand neu. Keine '
                      'Messung wird dabei kopiert oder entfernt.',
                ),
                RadioGroup<AppConcept>(
                  groupValue: c.concept,
                  onChanged: (chosen) =>
                      chosen == null ? null : c.setConcept(chosen),
                  child: Column(
                    children: [
                      for (final k in allConcepts)
                        RadioListTile<AppConcept>(
                          value: k,
                          title: Text(
                            k.label,
                            style: TextStyle(fontSize: 14, color: t.onSurface),
                          ),
                          subtitle: Text(
                            '${k.unit} · ${k.description}',
                            style: TextStyle(fontSize: 11, color: t.muted),
                          ),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                    ],
                  ),
                ),
                const SectionHeader(title: 'Gestaltung'),
                _Erklaerung(
                  text:
                      'Ändert Typografie, Abstände und Tonstufen, nicht die '
                      'Messdaten.',
                ),
                RadioGroup<ThemeVariant>(
                  groupValue: c.themeVariant,
                  onChanged: (chosen) =>
                      chosen == null ? null : c.setThemeVariant(chosen),
                  child: Column(
                    children: [
                      for (final v in allVariants)
                        RadioListTile<ThemeVariant>(
                          value: v,
                          title: Text(
                            themeFor(v).name,
                            style: TextStyle(fontSize: 14, color: t.onSurface),
                          ),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Öffnet die Einstellungen und nimmt die Gestaltung mit — eine geschobene
/// Route liegt außerhalb des bisherigen Baums und fände den Scope sonst nicht.
///
/// **Ein Zugang je Konzept, oben rechts, überall an derselben Stelle.**
///
/// Die fünf Konzepte schließen einander aus — wer eines sieht, sieht die
/// anderen nicht. Ein Zahnrad je Hülle sind deshalb nicht fünf konkurrierende
/// Zugänge, sondern einer. Der Umweg über den Gerätebereich wäre der falsche
/// Ort gewesen: „Gerät und Übertragung" verspricht Kopplung und Datentransport,
/// nicht Typografie. Und wer mit einem Konzept unzufrieden ist, sucht die
/// Alternative dort, wo er sie sieht — nicht hinter Bluetooth.
Future<void> showSettings(
  BuildContext context, {
  required AppController controller,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SettingsScreen(controller: controller),
    ),
  );
}

class _Erklaerung extends StatelessWidget {
  const _Erklaerung({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: t.muted, height: 1.5),
      ),
    );
  }
}
