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
import 'intake_choice_sheet.dart';
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

  /// Koppelt, liest aus und fragt dann, was übernommen werden soll.
  ///
  /// **Die Reihenfolge ist der Punkt.** Erst das Gerät auslesen, dann fragen:
  /// Vorher weiß niemand, wie viele Messungen dort liegen, und „nur neue"
  /// hätte keine Grenze, an der es sich festmachen könnte. Die Messungen
  /// landen dabei vollständig in der Datenbank — sie bleibt reines Abbild des
  /// Geräts. Was die Wahl bewirkt, ist eine Grenze, keine Löschung.
  ///
  /// Schlägt das Koppeln fehl, wird nicht gefragt: Eine Grenze ohne Kopplung
  /// wäre eine Entscheidung über Daten, die es nicht gibt.
  Future<void> _koppelnUndFragen(AppController c) async {
    try {
      await c.pair();
    } catch (e) {
      // Ohne Kopplung wird nicht gefragt: Eine Grenze ohne Gerät wäre eine
      // Entscheidung über Daten, die es nicht gibt.
      debugPrint('[Sphygma] Koppeln fehlgeschlagen: $e');
      return;
    }
    try {
      await c.sync();
    } catch (e) {
      // Der Readout kann abbrechen, obwohl die Kopplung steht. Gefragt wird
      // **trotzdem**: „Koppeln" verschwindet danach aus dem Blatt, und ohne
      // diese Frage bliebe die Wahl beim Standard, ohne dass sie je gestellt
      // wurde. Zu entscheiden gibt es dann eben weniger.
      debugPrint('[Sphygma] Erster Abgleich fehlgeschlagen: $e');
    }
    if (!mounted) return;
    await showIntakeChoice(context, controller: c);
  }

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
        // Die Übernahme ist eine **Einstellung**, nicht nur ein Schritt beim
        // Koppeln. Sonst wäre sie nur nach erneutem Koppeln erreichbar — und
        // wer sein Gerät nicht zur Hand hat oder beim ersten Versuch einen
        // Verbindungsabbruch hatte, käme nie wieder an sie heran, obwohl das
        // Blatt verspricht, man könne später freigeben (Codex-Gegenblick
        // 09.09.2026).
        if (c.userSlot != null)
          SettingRow(
            label: 'Übernommen',
            value: c.intakeFloor == null
                ? 'alle Messungen'
                : 'ab Messung Nr. ${c.intakeFloor}',
          ),
        if (c.userSlot != null)
          SettingButton(
            label: 'Übernahme ändern',
            onPressed: c.busy
                ? null
                : () => showIntakeChoice(context, controller: c),
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
                : () => _koppelnUndFragen(c),
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

  /// Drei Achsen, drei Auswahlfelder.
  ///
  /// Als Radiolisten untereinander wäre das Blatt unlesbar: Sechs Formen,
  /// vier Farbwelten und die Schriften sind zusammen mehr Zeilen, als ein
  /// Abschnitt trägt. Je Achse ein Feld hält es auf drei Zeilen — und macht
  /// zugleich sichtbar, dass es **drei unabhängige** Entscheidungen sind und
  /// nicht eine Liste fertiger Gestaltungen.
  Widget _gestaltung(AppController c, SphygmaTheme t) => _Karte(
    titel: 'Gestaltung',
    children: [
      _Erklaerung(
        text:
            'Die Form bestimmt, wie getrennt und geordnet wird; die Farbwelt '
            'die Töne; die Schrift die Familie. Alle drei sind frei '
            'kombinierbar und ändern keine Messdaten.',
      ),
      _AchsenWahl<Characteristic>(
        label: 'Form',
        value: c.characteristic,
        werte: Characteristic.values,
        name: (v) => v.label,
        onChanged: c.setCharacteristic,
      ),
      _AchsenWahl<Palette>(
        label: 'Farbwelt',
        value: c.palette,
        werte: Palette.values,
        name: (v) => v.label,
        onChanged: c.setPalette,
      ),
      _AchsenWahl<Typeface>(
        label: 'Schrift',
        value: c.typeface,
        werte: Typeface.values,
        name: (v) => v.label,
        onChanged: c.setTypeface,
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

/// Ein Auswahlfeld für eine Achse der Gestaltung.
///
/// `DropdownMenu` statt `DropdownButton`: Es trägt seine Beschriftung selbst
/// und sieht aus wie ein Feld, nicht wie ein Knopf — bei drei Feldern
/// untereinander ist das der Unterschied zwischen einer Liste und einem
/// Formular.
class _AchsenWahl<T> extends StatelessWidget {
  const _AchsenWahl({
    required this.label,
    required this.value,
    required this.werte,
    required this.name,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> werte;
  final String Function(T) name;
  final void Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall),
      child: SizedBox(
        width: double.infinity,
        child: DropdownMenu<T>(
          initialSelection: value,
          // Beschriftung, Pfeil, Menüfläche und Rahmen nehmen ihre Farben aus
          // der Gestaltung, nicht aus dem Material-Standard. Auf der dunklen
          // Farbwelt „Nacht" stünde sonst dunkler Text auf dunklem Grund —
          // gefunden im Codex-Gegenblick am 09.09.2026.
          label: Text(label, style: TextStyle(color: t.muted)),
          trailingIcon: Icon(Icons.arrow_drop_down, color: t.muted),
          selectedTrailingIcon: Icon(Icons.arrow_drop_up, color: t.muted),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(t.panel(0)),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
          inputDecorationTheme: InputDecorationThemeData(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: t.line),
              borderRadius: BorderRadius.circular(t.chipRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: t.accent),
              borderRadius: BorderRadius.circular(t.chipRadius),
            ),
          ),
          expandedInsets: EdgeInsets.zero,
          textStyle: TextStyle(fontSize: 14, color: t.onSurface),
          // Eine leere Wahl gibt es nicht: Jede Achse hat immer einen Wert.
          // Der Rückfall auf `value` fängt nur das Schließen ohne Auswahl ab.
          onSelected: (gewaehlt) => onChanged(gewaehlt ?? value),
          dropdownMenuEntries: [
            for (final v in werte)
              DropdownMenuEntry<T>(
                value: v,
                label: name(v),
                // Auch die Einträge im aufgeklappten Menü nehmen ihre Farben
                // aus der Gestaltung. `menuStyle` färbt nur die Fläche; der
                // Text blieb im Material-Standard und war auf den dunklen
                // Farbwelten nicht zu lesen (am Gerät gefunden, 09.09.2026).
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(t.onSurface),
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: 14, color: t.onSurface),
                  ),
                  overlayColor: WidgetStatePropertyAll(
                    t.onSurface.withValues(alpha: 0.08),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
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
