// Alles, was man einstellt und auslöst — an einem Ort, hinter dem Zahnrad.
//
// Bis zum 08.09.2026 lag die Technik an zwei Stellen: Kopplung und Auswahl
// hier, Abgleich und Übertragung in einem eigenen Reiter „Gerät". Die Grenze
// „einstellen gegen tun" klang sauber, war aber keine, die jemand sucht: Wer
// die App aufräumt, sucht beides hinter dem Zahnrad. Der Reiter ist deshalb
// aufgelöst und sein Inhalt hierher gewandert.
//
// **Ein Abschnitt, eine Karte, und die Reihenfolge folgt der Häufigkeit.**
// Abgleich und Übertragung kommen im Alltag vor; Kopplung und Speicherplatz
// entscheidet man beim Einrichten; Ansicht, Konzept und Gestaltung stellt man
// einmal ein und lässt sie. Was selten angefasst wird, steht unten — nicht,
// weil es unwichtig wäre, sondern weil es sonst jedes Mal im Weg steht.
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
        body: ListView(
          padding: t.listPadding,
          children: [
            _abgleich(c, t),
            _healthConnect(c),
            _geraet(c, t),
            _ansicht(c),
            _konzept(c, t),
            _gestaltung(c, t),
          ],
        ),
      ),
    );
  }

  /// Was von selbst passiert, und was man von Hand auslösen kann.
  Widget _abgleich(AppController c, SphygmaTheme t) => _Karte(
    titel: 'Abgleich',
    children: [
      SettingRow(
        label: 'Automatischer Abgleich',
        value: c.autoSyncActive ? 'wartet auf Messungen' : 'aus',
        dot: c.autoSyncActive,
      ),
      SettingRow(
        label: 'Gespeichert',
        value: '${c.measurements.length} Messungen',
      ),
      SettingButton(
        label: 'Jetzt abgleichen',
        filled: true,
        onPressed: c.busy || !c.paired ? null : () => _start(c.sync),
      ),
      // Die Meldung gehört zur Handlung, die sie erzeugt hat.
      if (c.status != null) ...[
        SizedBox(height: t.gapSmall),
        Text(c.status!, style: TextStyle(fontSize: 12, color: t.muted)),
      ],
    ],
  );

  Widget _healthConnect(AppController c) => _Karte(
    titel: 'Health Connect',
    children: [
      SettingRow(
        label: 'Übertragen',
        value:
            '${c.measurements.length - c.pendingExport} '
            'von ${c.measurements.length}',
      ),
      SettingButton(
        label: 'Alle übertragen',
        onPressed: c.busy || c.pendingExport == 0
            ? null
            : () => _start(c.exportAll),
      ),
      SettingButton(
        label: 'Übertragene entfernen',
        onPressed: c.busy || c.userSlot == null
            ? null
            : () => _start(c.retractAll),
      ),
    ],
  );

  Widget _geraet(AppController c, SphygmaTheme t) {
    final showPairing = !c.paired || _pairingOpen;

    return _Karte(
      titel: 'Gerät',
      children: [
        SettingRow(
          label: 'RS7 Intelli IT',
          value: c.paired ? 'gekoppelt' : 'nicht gekoppelt',
        ),
        if (c.userSlot != null)
          SettingRow(label: 'Speicherplatz', value: 'Benutzer ${c.userSlot}'),
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
            // Ohne gewählten Slot ist nichts ausgewählt. Ein vorgetäuschtes
            // „Benutzer 1" ließe sich nicht antippen: SegmentedButton meldet
            // keinen Wechsel auf das bereits ausgewählte einzige Segment.
            emptySelectionAllowed: true,
            selected: c.userSlot == null ? const <int>{} : {c.userSlot!},
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
      ],
    );
  }

  /// Was auf „Heute" zu sehen ist.
  ///
  /// Das Wochenraster stammt aus dem aufgelösten Konzept „Sieben Tage". Wer
  /// eine Woche lang zweimal täglich misst, braucht es; wer gelegentlich
  /// einen Wert nimmt, sieht dort vierzehn leere Felder als Vorwurf.
  Widget _ansicht(AppController c) => _Karte(
    titel: 'Ansicht',
    children: [
      _Erklaerung(
        text:
            'Das Wochenraster zeigt, welche der vierzehn Messungen einer '
            'Woche noch fehlen. Es blendet keine Messung aus.',
      ),
      SwitchListTile(
        value: c.weekPanelVisible,
        onChanged: c.setWeekPanelVisible,
        title: Text(
          'Wochenraster auf „Heute"',
          style: TextStyle(
            fontSize: 14,
            color: SphygmaTheme.of(context).onSurface,
          ),
        ),
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    ],
  );

  Widget _konzept(AppController c, SphygmaTheme t) => _Karte(
    titel: 'Konzept',
    children: [
      _Erklaerung(
        text:
            'Andere Konzepte ordnen denselben Bestand neu. Keine '
            'Messung wird dabei kopiert oder entfernt.',
      ),
      RadioGroup<AppConcept>(
        groupValue: c.concept,
        onChanged: (chosen) => chosen == null ? null : c.setConcept(chosen),
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
    ],
  );

  Widget _gestaltung(AppController c, SphygmaTheme t) => _Karte(
    titel: 'Gestaltung',
    children: [
      _Erklaerung(
        text: 'Ändert Typografie, Abstände und Tonstufen, nicht die Messdaten.',
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
  );
}

/// Ein Abschnitt der Einstellungen: eigene Fläche, eigene Überschrift.
///
/// Die Überschrift trägt keinen Abstand nach oben — den bringt die Karte
/// schon mit, und doppelt sähe er nach einer Lücke aus.
class _Karte extends StatelessWidget {
  const _Karte({required this.titel, required this.children});

  final String titel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: titel, leadingGap: false),
          ...children,
        ],
      ),
    );
  }
}

/// Öffnet die Einstellungen und nimmt die Gestaltung mit — eine geschobene
/// Route liegt außerhalb des bisherigen Baums und fände den Scope sonst nicht.
///
/// **Ein Zugang je Konzept, oben rechts, überall an derselben Stelle.**
///
/// Die Konzepte schließen einander aus — wer eines sieht, sieht die anderen
/// nicht. Ein Zahnrad je Hülle sind deshalb nicht drei konkurrierende
/// Zugänge, sondern einer.
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
