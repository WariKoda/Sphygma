// Der Einstieg: die laufende Phase.
//
// Nicht der einzelne Tag, sondern der Lebensabschnitt und sein Vergleich mit
// dem davor. Was ungeklärt ist, steht gleich sichtbar daneben — eine
// versteckte Restmenge würde den Vergleich unbemerkt verschieben.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/feature_flags.dart';
import '../../../stats/phase_grouping.dart';
import '../../../stats/esc_classification.dart';
import '../../../stats/target_range.dart';
import '../../format.dart';
import '../../theme/sphygma_theme.dart';
import '../../widgets/classification_scale.dart';
import '../../widgets/notice_card.dart';
import 'new_phase_sheet.dart';
import 'phase_compare_screen.dart';

class CurrentPhaseScreen extends StatelessWidget {
  const CurrentPhaseScreen({
    super.key,
    required this.controller,
    required this.onAssign,
  });

  final AppController controller;

  /// Führt in den Zuordnungsbereich.
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final gruppen = controller.phaseGrouping;
        final laufend = _laufende(gruppen);

        return ListView(
          padding: EdgeInsets.all(t.gapLarge),
          children: [
            if (laufend == null)
              _KeineLaufende(controller: controller)
            else
              _Laufende(
                controller: controller,
                laufend: laufend,
                davor: _davor(gruppen!, laufend),
              ),
            if (gruppen != null && gruppen.unclear.isNotEmpty) ...[
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
                      gruppen.unclear.length == 1
                          ? 'Eine Messung ist zeitlich ungeklärt'
                          : '${gruppen.unclear.length} Messungen sind zeitlich ungeklärt',
                      style: TextStyle(fontSize: 13, color: t.onSurface),
                    ),
                    Text(
                      'Sie nehmen an keinem Vergleich teil, solange nicht '
                      'entschieden ist, wohin sie gehören.',
                      style: TextStyle(fontSize: 11, color: t.muted),
                    ),
                    TextButton(
                      onPressed: onAssign,
                      child: const Text('Zeitzuordnung prüfen'),
                    ),
                  ],
                ),
              ),
            ],
            if (!controller.paired) ...[
              SizedBox(height: t.gapLarge),
              const NoticeCard(
                title: 'Nicht gekoppelt',
                message: 'Ohne Kopplung kann Sphygma keine Messungen holen. '
                    'Unter "Gerät" einrichten.',
              ),
            ],
          ],
        );
      },
    );
  }

  /// Die Phase ohne Ende ist die laufende. Gibt es mehrere, gilt die zuletzt
  /// begonnene — dieselbe Regel wie bei der Zuordnung.
  static PhaseMembership? _laufende(PhaseGrouping? gruppen) {
    if (gruppen == null) return null;
    for (final m in gruppen.memberships) {
      if (m.phase.endsAt == null) return m;
    }
    return null;
  }

  static PhaseMembership? _davor(
    PhaseGrouping gruppen,
    PhaseMembership laufend,
  ) {
    PhaseMembership? beste;
    for (final m in gruppen.memberships) {
      if (m.phase.id == laufend.phase.id) continue;
      if (!m.phase.beginsAt.isBefore(laufend.phase.beginsAt)) continue;
      if (beste == null || m.phase.beginsAt.isAfter(beste.phase.beginsAt)) {
        beste = m;
      }
    }
    return beste;
  }
}

class _Laufende extends StatelessWidget {
  const _Laufende({
    required this.controller,
    required this.laufend,
    required this.davor,
  });

  final AppController controller;
  final PhaseMembership laufend;
  final PhaseMembership? davor;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final mittel = laufend.average;
    final tage = DateTime.now().difference(laufend.phase.beginsAt).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tage == 1 ? 'Laufende Phase seit einem Tag' : 'Laufende Phase seit $tage Tagen',
          style: TextStyle(fontSize: 11, color: t.muted),
        ),
        Text(
          laufend.phase.name,
          style: TextStyle(fontSize: 20, color: t.onSurface),
        ),
        Text(
          'Beginn ${laufend.phase.anchor == 'jetzt' ? "gesetzt" : "bestätigt"}: '
          '${formatDay(laufend.phase.beginsAt)}',
          style: TextStyle(fontSize: 11, color: t.muted),
        ),
        SizedBox(height: t.gapLarge),
        if (mittel == null)
          Text(
            'Dieser Phase ist noch keine Messung zugeordnet.',
            style: TextStyle(fontSize: 14, color: t.onSurface, height: 1.5),
          )
        else ...[
          Text(
            '${mittel.systolic} / ${mittel.diastolic}',
            style: TextStyle(
              fontSize: t.headlineSize,
              fontWeight: FontWeight.w300,
              color: t.onSurface,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: t.gapSmall),
          Text(
            '${laufend.count} zugeordnete '
            '${laufend.count == 1 ? "Messung" : "Messungen"} · Puls '
            '${mittel.pulse} · '
            '${TargetRange.heim.classify(systolic: mittel.systolic, diastolic: mittel.diastolic).label}',
            style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
          ),
          if (escClassificationEnabled) ...[
            SizedBox(height: t.gapLarge),
            ClassificationScale(
              category: classifyOffice(
                systolic: mittel.systolic,
                diastolic: mittel.diastolic,
              ),
            ),
          ],
        ],
        if (davor case final d? when d.average != null && mittel != null) ...[
          SizedBox(height: t.gapLarge),
          Text(
            'Im Vergleich zur Phase davor',
            style: TextStyle(fontSize: 11, color: t.muted),
          ),
          Text(
            '${d.phase.name}: ${d.average!.systolic}/${d.average!.diastolic} '
            'aus ${d.count} Messungen',
            style: TextStyle(fontSize: 13, color: t.onSurface),
          ),
          SizedBox(height: t.gapSmall / 2),
          Text(
            _unterschied(d.average!.systolic, mittel.systolic),
            style: TextStyle(fontSize: 13, color: t.onSurface),
          ),
          Text(
            'Eine Beobachtung in diesen Daten, kein Wirkungsnachweis.',
            style: TextStyle(fontSize: 11, color: t.muted),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SphygmaThemeScope(
                    theme: t,
                    child: PhaseCompareScreen(
                      controller: controller,
                      initialA: d.phase.id,
                      initialB: laufend.phase.id,
                    ),
                  ),
                ),
              ),
              child: const Text('Vergleich ansehen'),
            ),
          ),
        ],
        SizedBox(height: t.gapSmall),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => controller.endPhase(
              laufend.phase.id,
              at: DateTime.now(),
            ),
            child: const Text('Phase beenden'),
          ),
        ),
      ],
    );
  }

  static String _unterschied(int davor, int jetzt) {
    final delta = jetzt - davor;
    if (delta == 0) return 'Systolisch unverändert.';
    return 'Systolisch ${delta.abs()} mmHg '
        '${delta < 0 ? "niedriger" : "höher"} als davor.';
  }
}

class _KeineLaufende extends StatelessWidget {
  const _KeineLaufende({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: t.gapLarge),
        Text(
          'Keine laufende Phase',
          style: TextStyle(fontSize: 17, color: t.onSurface),
        ),
        SizedBox(height: t.gapSmall),
        Text(
          'Ein Lebensabschnitt gibt den Messungen einen Zusammenhang, den ein '
          'Kalenderfilter nicht kennt: „Ramipril 5 mg", „Urlaub", „nach der '
          'Umstellung".',
          style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
        ),
        SizedBox(height: t.gapLarge),
        FilledButton(
          onPressed: () => showNewPhaseSheet(context, controller: controller),
          child: const Text('Neue Phase beginnen'),
        ),
      ],
    );
  }
}
