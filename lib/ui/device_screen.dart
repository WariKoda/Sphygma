// Alles Technische an einem Ort: Geraet, Abgleich, Health Connect,
// Gestaltung. Vorn auf "Heute" stoert es damit nicht mehr.
import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import 'theme/sphygma_theme.dart';
import 'theme/variants.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final c = controller;

    return Material(
      color: t.surface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(t.gapLarge),
        child: Column(
          children: [
            _Section(title: 'Geraet'),
            _Row(
              label: 'RS7 Intelli IT',
              value: c.paired ? 'gekoppelt' : 'nicht gekoppelt',
            ),
            if (c.userSlot != null)
              _Row(label: 'Speicherplatz', value: 'Benutzer ${c.userSlot}'),
            if (!c.paired) ...[
              SizedBox(height: t.gapSmall),
              Text(
                'Welcher Speicherplatz gehoert dir am Geraet?',
                style: TextStyle(fontSize: 12, color: t.muted),
              ),
              SizedBox(height: t.gapSmall),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('Benutzer 1')),
                  ButtonSegment(value: 2, label: Text('Benutzer 2')),
                ],
                // Ohne gewaehlten Slot ist nichts ausgewaehlt. Ein
                // vorgetaeuschtes "Benutzer 1" liesse sich nicht antippen:
                // SegmentedButton meldet keinen Wechsel auf das bereits
                // ausgewaehlte einzige Segment (segmented_button.dart:489).
                emptySelectionAllowed: true,
                selected: c.userSlot == null ? const <int>{} : {c.userSlot!},
                onSelectionChanged: (s) =>
                    s.isEmpty ? null : c.setUserSlot(s.first),
              ),
              SizedBox(height: t.gapSmall),
              Text(
                'Zum Koppeln die Bluetooth-Taste am Geraet lange druecken, '
                'bis "-P-" blinkt.',
                style: TextStyle(fontSize: 12, color: t.muted),
              ),
              _Button(
                label: 'Koppeln',
                filled: true,
                onPressed: c.busy || c.userSlot == null ? null : () => _start(c.pair),
              ),
            ],

            _Section(title: 'Abgleich'),
            _Row(
              label: 'Automatischer Abgleich',
              value: c.autoSyncActive ? 'wartet auf Messungen' : 'aus',
              dot: c.autoSyncActive,
            ),
            _Row(
              label: 'Gespeichert',
              value: '${c.measurements.length} Messungen',
            ),
            _Button(
              label: 'Jetzt abgleichen',
              filled: true,
              onPressed: c.busy || !c.paired ? null : () => _start(c.sync),
            ),
            if (c.status != null) ...[
              SizedBox(height: t.gapSmall),
              Text(c.status!, style: TextStyle(fontSize: 12, color: t.muted)),
            ],

            _Section(title: 'Health Connect'),
            _Row(
              label: 'Uebertragen',
              value:
                  '${c.measurements.length - c.pendingExport} '
                  'von ${c.measurements.length}',
            ),
            _Button(
              label: 'Alle uebertragen',
              onPressed:
                  c.busy || c.pendingExport == 0 ? null : () => _start(c.exportAll),
            ),
            _Button(
              label: 'Uebertragene entfernen',
              onPressed: c.busy ? null : () => _start(c.retractAll),
            ),

            _Section(title: 'Gestaltung'),
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
    );
  }

  /// Startet eine Aktion des Steuerungsteils.
  ///
  /// [AppController] wirft nach dem Setzen von `status` erneut - die Meldung
  /// steht also schon fest und wird angezeigt. Ohne diesen Fang liefe der
  /// Fehler als unbeobachtete Ausnahme in die Zone und ruecke damit nirgends
  /// mehr in Sicht.
  static void _start(Future<void> Function() action) {
    unawaited(action().catchError((Object e) {
      debugPrint('[Sphygma] Aktion fehlgeschlagen: $e');
    }));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: t.gapLarge, bottom: t.gapSmall),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: t.muted),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.dot = false});

  final String label;
  final String value;

  /// Gruener Punkt vor dem Text - zeigt einen laufenden Zustand an.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: t.gapSmall + 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (dot) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.categoryColors.values.first,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(label, style: TextStyle(fontSize: 13, color: t.onSurface)),
            ],
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: t.gapSmall),
      child: SizedBox(
        width: double.infinity,
        child: filled
            ? FilledButton(onPressed: onPressed, child: Text(label))
            : OutlinedButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}
