// Wo eine Messung hingehört, deren Zeit nicht stimmen kann.
//
// Unsicherheit ist ein Zustand, kein Fehler. Keine der beiden vorhandenen
// Zeiten wird still zur Wahrheit erklärt: Die Gerätezeit ist widersprüchlich,
// und der Importzeitpunkt taugt nicht als Messzeitpunkt, weil beim
// Voll-Readout jahrealte Aufzeichnungen gemeinsam ankommen.
//
// Sphygma ändert den Zeitstempel nicht. Es fragt, zu welchem Abschnitt die
// Messung gehört — das ist eine Zuordnung, keine Zeitkorrektur.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../db/app_database.dart';
import '../../../stats/phase_grouping.dart';
import '../../format.dart';
import '../../theme/sphygma_theme.dart';

class PhaseAssignScreen extends StatelessWidget {
  const PhaseAssignScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final gruppen = controller.phaseGrouping;
        final offen = gruppen?.unclear ?? const <Measurement>[];

        if (offen.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(t.gapLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: t.gapLarge),
                Text(
                  'Nichts zu klären',
                  style: TextStyle(fontSize: 17, color: t.onSurface),
                ),
                SizedBox(height: t.gapSmall),
                Text(
                  'Alle Messungen tragen ein Datum, das zu ihrer Reihenfolge '
                  'passt. Weicht die Geräteuhr ab, erscheinen die betroffenen '
                  'Messungen hier.',
                  style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(t.gapLarge),
          children: [
            Text(
              'Bei ${offen.length == 1 ? "einer Messung" : "${offen.length} Messungen"} '
              'widersprechen sich Gerätezeit und Reihenfolge. Sphygma ändert '
              'den Zeitstempel nicht — die Uhr wird am Gerät gestellt.',
              style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
            ),
            SizedBox(height: t.gapLarge),
            for (final m in offen)
              _Offen(
                controller: controller,
                measurement: m,
                phases: gruppen!.memberships,
              ),
          ],
        );
      },
    );
  }
}

class _Offen extends StatelessWidget {
  const _Offen({
    required this.controller,
    required this.measurement,
    required this.phases,
  });

  final AppController controller;
  final Measurement measurement;
  final List<PhaseMembership> phases;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final m = measurement;

    return Container(
      margin: EdgeInsets.only(bottom: t.gapLarge),
      padding: EdgeInsets.all(t.gapSmall),
      decoration: BoxDecoration(
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(t.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Messung Nr. ${m.deviceSequence}',
            style: TextStyle(fontSize: 11, color: t.muted),
          ),
          Text(
            '${m.systolic}/${m.diastolic} · Puls ${m.pulse}',
            style: TextStyle(
              fontSize: 17,
              color: t.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: t.gapSmall),
          _Herkunft(label: 'Laut Gerät', value: formatDayAndTime(m.measuredAt)),
          _Herkunft(label: 'Eingelesen', value: formatDayAndTime(m.importedAt)),
          SizedBox(height: t.gapSmall / 2),
          Text(
            'Der Importzeitpunkt ist kein Messzeitpunkt: Beim Voll-Readout '
            'kommen alte Aufzeichnungen gemeinsam an.',
            style: TextStyle(fontSize: 11, color: t.muted, height: 1.5),
          ),
          SizedBox(height: t.gapSmall),
          Text(
            'Zuordnung',
            style: TextStyle(fontSize: 12, color: t.muted),
          ),
          Wrap(
            spacing: t.gapSmall,
            runSpacing: t.gapSmall / 2,
            children: [
              for (final p in phases)
                OutlinedButton(
                  onPressed: () => controller.assignToPhase(
                    deviceSequence: m.deviceSequence,
                    phaseId: p.phase.id,
                  ),
                  child: Text(p.phase.name),
                ),
              TextButton(
                onPressed: () => controller.assignToPhase(
                  deviceSequence: m.deviceSequence,
                  phaseId: null,
                ),
                child: const Text('Keiner Phase'),
              ),
            ],
          ),
          if (phases.isEmpty)
            Text(
              'Es gibt noch keine Phase, der sie zugeordnet werden könnte.',
              style: TextStyle(fontSize: 11, color: t.muted),
            ),
        ],
      ),
    );
  }
}

class _Herkunft extends StatelessWidget {
  const _Herkunft({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall / 4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: TextStyle(fontSize: 11, color: t.muted)),
          ),
          Text(value, style: TextStyle(fontSize: 12, color: t.onSurface)),
        ],
      ),
    );
  }
}
