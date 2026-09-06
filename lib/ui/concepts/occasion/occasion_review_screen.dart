// Grenzfälle bleiben offen, bis der Mensch entscheidet.
//
// Die Automatik macht hier keinen Anlass fertig. Eine zugedeckte Frage ist
// schlimmer als eine unbeantwortete: Der Nutzer erführe nicht einmal, dass
// es sie gibt.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../db/app_database.dart';
import '../../../stats/occasion_grouping.dart';
import '../../format.dart';
import '../../theme/sphygma_theme.dart';

class OccasionReviewScreen extends StatelessWidget {
  const OccasionReviewScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final offen = controller.occasions
            .where((o) => o.state == OccasionState.zuPruefen)
            .toList()
            .reversed
            .toList();

        if (offen.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(t.gapLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: t.gapLarge),
                Text(
                  'Nichts zu prüfen',
                  style: TextStyle(fontSize: 17, color: t.onSurface),
                ),
                SizedBox(height: t.gapSmall),
                Text(
                  'Alle Anlässe sind eindeutig. Ein Grenzfall entsteht, wenn '
                  'zwei aufeinanderfolgende Messungen zeitlich weder klar '
                  'zusammen noch klar getrennt liegen.',
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
              '${offen.length} ${offen.length == 1 ? "Grenzfall" : "Grenzfälle"}. '
              'Bis zur Entscheidung bleiben die Messungen getrennt — die App '
              'fasst nichts still zusammen.',
              style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
            ),
            SizedBox(height: t.gapLarge),
            for (final o in offen)
              _Grenzfall(controller: controller, occasion: o),
          ],
        );
      },
    );
  }
}

class _Grenzfall extends StatelessWidget {
  const _Grenzfall({required this.controller, required this.occasion});

  final AppController controller;
  final MeasurementOccasion occasion;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final naht = occasion.openSeam;
    if (naht == null) return const SizedBox.shrink();

    // Die Messung, um die es geht, gehört bereits zum nächsten Anlass.
    final folge = _folgemessung(naht);
    final letzte = occasion.measurements.last;
    final abstand = folge?.measuredAt.difference(letzte.measuredAt).abs();

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
            'Gehören diese zusammen?',
            style: TextStyle(fontSize: 15, color: t.onSurface),
          ),
          if (abstand != null)
            Text(
              'Der Abstand von ${abstand.inMinutes} Minuten liegt im '
              'Grenzbereich. Die Nummern folgen aufeinander.',
              style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
            ),
          SizedBox(height: t.gapSmall),
          _Zeile(measurement: letzte),
          if (folge != null) _Zeile(measurement: folge),
          SizedBox(height: t.gapSmall),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.confirmSplit(naht),
                  child: const Text('Zwei getrennte'),
                ),
              ),
              SizedBox(width: t.gapSmall),
              Expanded(
                child: FilledButton(
                  onPressed: () => controller.confirmJoin(naht),
                  child: const Text('Ein Anlass'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Die Messung mit der offenen Nummer — sie steht im nächsten Anlass.
  Measurement? _folgemessung(int naht) {
    for (final m in controller.measurements) {
      if (m.deviceSequence == naht) return m;
    }
    return null;
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({required this.measurement});

  final Measurement measurement;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final m = measurement;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.gapSmall / 3),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            child: Text(
              'Nr. ${m.deviceSequence} · ${formatTime(m.measuredAt)}',
              style: TextStyle(fontSize: 11, color: t.muted),
            ),
          ),
          Expanded(
            child: Text(
              '${m.systolic}/${m.diastolic} · ${m.pulse}',
              style: TextStyle(
                fontSize: 13,
                color: t.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (m.movement)
            Text('Bewegung', style: TextStyle(fontSize: 10, color: t.muted)),
        ],
      ),
    );
  }
}
