// Zustand und Handlungen: Was das Gerät gerade tut, und was man auslösen
// kann.
//
// Was man einstellt — Kopplung, Speicherplatz, Konzept, Gestaltung — steht
// hinter dem Zahnrad. Die Grenze verläuft zwischen einstellen und tun.
import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import 'theme/sphygma_theme.dart';
import 'widgets/surface_panel.dart';
import 'widgets/section_header.dart';
import 'widgets/setting_row.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final c = widget.controller;

    return Material(
      color: t.surface,
      child: SingleChildScrollView(
        padding: t.listPadding,
        child: SurfacePanel(
          child: Column(
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
              // Kopplung und Speicherplatzwahl stehen in den Einstellungen:
              // Hier geht es um den Zustand und um Handlungen, dort um das,
              // was man einmal entscheidet.

              const SectionHeader(title: 'Abgleich'),
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
              if (c.status != null) ...[
                SizedBox(height: t.gapSmall),
                Text(c.status!, style: TextStyle(fontSize: 12, color: t.muted)),
              ],

              const SectionHeader(title: 'Health Connect'),
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
          ),
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
    unawaited(
      action().catchError((Object e) {
        debugPrint('[Sphygma] Aktion fehlgeschlagen: $e');
      }),
    );
  }
}
