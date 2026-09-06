// Zwei Lebensabschnitte nebeneinander.
//
// Der Vergleich ist die Aussage dieses Konzepts — und seine Gefahr. Er
// beschreibt einen Unterschied, er beweist keine Wirkung. Stichprobengröße
// und Zuordnungsstand stehen deshalb direkt daneben, nicht im Kleingedruckten.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../stats/phase_grouping.dart';
import '../../format.dart';
import '../../theme/sphygma_theme.dart';
import '../../widgets/section_header.dart';

class PhaseCompareScreen extends StatefulWidget {
  const PhaseCompareScreen({
    super.key,
    required this.controller,
    required this.initialA,
    required this.initialB,
  });

  final AppController controller;

  /// Phasen-IDs der Vorauswahl.
  final int initialA;
  final int initialB;

  @override
  State<PhaseCompareScreen> createState() => _PhaseCompareScreenState();
}

class _PhaseCompareScreenState extends State<PhaseCompareScreen> {
  int? _a;
  int? _b;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final gruppen = widget.controller.phaseGrouping;
        final alle = gruppen?.memberships ?? const <PhaseMembership>[];
        if (alle.length < 2) {
          return _geruest(
            Text(
              'Für einen Vergleich braucht es zwei Phasen.',
              style: TextStyle(fontSize: 13, color: t.muted),
            ),
          );
        }

        final a = _finde(alle, _a ?? widget.initialA);
        final b = _finde(alle, _b ?? widget.initialB);

        return _geruest(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Wahl(
                label: 'Davor',
                value: a.phase.id,
                memberships: alle,
                onChanged: (id) => setState(() => _a = id),
              ),
              _Wahl(
                label: 'Danach',
                value: b.phase.id,
                memberships: alle,
                onChanged: (id) => setState(() => _b = id),
              ),
              SizedBox(height: t.gapLarge),
              if (a.phase.id == b.phase.id)
                Text(
                  'Zwei verschiedene Phasen wählen.',
                  style: TextStyle(fontSize: 13, color: t.onSurface),
                )
              else ...[
                Text(
                  '${a.phase.name} → ${b.phase.name}',
                  style: TextStyle(fontSize: 15, color: t.onSurface),
                ),
                SizedBox(height: t.gapLarge),
                _Vergleich(a: a, b: b),
                const SectionHeader(title: 'Grundlage'),
                Text(
                  '${a.count} gegen ${b.count} Messungen',
                  style: TextStyle(fontSize: 13, color: t.onSurface),
                ),
                Text(
                  'Verglichen werden nur Messungen mit geklärter '
                  'Zeitzuordnung. '
                  '${gruppen!.unclear.isEmpty ? "Es sind keine offen." : "${gruppen.unclear.length} sind noch ungeklärt und bleiben außen vor."}',
                  style: TextStyle(fontSize: 11, color: t.muted, height: 1.5),
                ),
                SizedBox(height: t.gapLarge),
                Container(
                  padding: EdgeInsets.all(t.gapSmall),
                  decoration: BoxDecoration(
                    border: Border.all(color: t.line),
                    borderRadius: BorderRadius.circular(t.radius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kein Beweis für eine Wirkung',
                        style: TextStyle(fontSize: 13, color: t.onSurface),
                      ),
                      Text(
                        'Jahreszeit, Messanlass, Tageszeit und Zufall können '
                        'den Unterschied mitverursachen. Der Vergleich gehört '
                        'in die Sprechstunde, nicht in eine eigene '
                        'Schlussfolgerung.',
                        style: TextStyle(
                          fontSize: 11,
                          color: t.muted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static PhaseMembership _finde(List<PhaseMembership> alle, int id) {
    for (final m in alle) {
      if (m.phase.id == id) return m;
    }
    return alle.first;
  }

  Widget _geruest(Widget child) {
    final t = SphygmaTheme.of(context);
    return Scaffold(
      backgroundColor: t.surface,
      appBar: AppBar(
        title: const Text('Phasen vergleichen'),
        backgroundColor: t.surface,
        foregroundColor: t.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(t.gapLarge),
        child: child,
      ),
    );
  }
}

class _Vergleich extends StatelessWidget {
  const _Vergleich({required this.a, required this.b});

  final PhaseMembership a;
  final PhaseMembership b;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final va = a.average;
    final vb = b.average;

    if (va == null || vb == null) {
      return Text(
        'Mindestens eine der beiden Phasen hat keine zugeordnete Messung.',
        style: TextStyle(fontSize: 13, color: t.onSurface, height: 1.5),
      );
    }

    return Column(
      children: [
        _Zeile(label: 'Systolisch', von: va.systolic, bis: vb.systolic),
        _Zeile(label: 'Diastolisch', von: va.diastolic, bis: vb.diastolic),
        _Zeile(label: 'Puls', von: va.pulse, bis: vb.pulse, einheit: '/min'),
      ],
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({
    required this.label,
    required this.von,
    required this.bis,
    this.einheit = 'mmHg',
  });

  final String label;
  final int von;
  final int bis;
  final String einheit;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final delta = bis - von;

    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall / 2),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: TextStyle(fontSize: 12, color: t.muted)),
          ),
          Expanded(
            child: Text(
              '$von → $bis',
              style: TextStyle(
                fontSize: 15,
                color: t.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Text(
            delta == 0
                ? 'unverändert'
                : '${delta < 0 ? "−" : "+"}${delta.abs()} $einheit',
            style: TextStyle(fontSize: 13, color: t.onSurface),
          ),
        ],
      ),
    );
  }
}

class _Wahl extends StatelessWidget {
  const _Wahl({
    required this.label,
    required this.value,
    required this.memberships,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<PhaseMembership> memberships;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(label, style: TextStyle(fontSize: 12, color: t.muted)),
          ),
          Expanded(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              underline: Container(height: 1, color: t.line),
              items: [
                for (final m in memberships)
                  DropdownMenuItem<int>(
                    value: m.phase.id,
                    child: Text(
                      '${m.phase.name} · ab ${formatDay(m.phase.beginsAt)}',
                      style: TextStyle(fontSize: 13, color: t.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (i) => i == null ? null : onChanged(i),
            ),
          ),
        ],
      ),
    );
  }
}
