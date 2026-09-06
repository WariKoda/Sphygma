// Der Einstieg: das letzte Messen.
//
// Ein Anlass, ein Ergebnis. Die Liste der Rohwerte beweist, wie die Zahl
// entstanden ist — sie ist nicht Beiwerk, sondern der Grund, dem Ergebnis zu
// trauen.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../measurement_sheet.dart';
import '../../theme/sphygma_theme.dart';
import '../../widgets/notice_card.dart';
import '../../widgets/section_header.dart';
import 'occasion_widgets.dart';

class LastOccasionScreen extends StatelessWidget {
  const LastOccasionScreen({
    super.key,
    required this.controller,
    required this.onReview,
  });

  final AppController controller;

  /// Führt zum Prüfen-Bereich — der Grenzfall wird dort entschieden, nicht
  /// nebenbei in einem Dialog.
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final anlaesse = controller.occasions;
        if (anlaesse.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(t.gapLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: t.gapLarge),
                Text(
                  'Noch kein Messen',
                  style: TextStyle(fontSize: 17, color: t.onSurface),
                ),
                SizedBox(height: t.gapSmall),
                Text(
                  controller.paired
                      ? 'Miss am Gerät — Sphygma holt die Messung von selbst. '
                          'Wer zweimal hintereinander misst, bekommt einen '
                          'Anlass mit einem Ergebnis, nicht zwei Einträge.'
                      : 'Zuerst unter "Gerät" koppeln.',
                  style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
                ),
              ],
            ),
          );
        }

        // Die Anlässe kommen älteste zuerst — das jüngste Messen steht am Ende.
        final letzter = anlaesse.last;
        final offen = controller.openOccasions.length;

        return ListView(
          padding: EdgeInsets.all(t.gapLarge),
          children: [
            Text(
              occasionWhen(letzter),
              style: TextStyle(fontSize: 12, color: t.muted),
            ),
            SizedBox(height: t.gapSmall),
            OccasionResult(occasion: letzter),
            SizedBox(height: t.gapLarge),
            QualityChips(occasion: letzter),
            const SectionHeader(title: 'Rohwerte'),
            RawMeasurementList(
              occasion: letzter,
              onTap: (m) => showMeasurementSheet(
                context,
                controller: controller,
                measurementId: m.id,
              ),
            ),
            if (!controller.paired) ...[
              SizedBox(height: t.gapLarge),
              const NoticeCard(
                title: 'Nicht gekoppelt',
                message: 'Ohne Kopplung kann Sphygma keine Messungen holen. '
                    'Unter "Gerät" einrichten.',
              ),
            ],
            if (controller.clockLooksWrong) ...[
              SizedBox(height: t.gapLarge),
              const NoticeCard(
                title: 'Geräteuhr geht falsch',
                message: 'Zeitliche Nähe ist ein Teil der Gruppierung. Geht '
                    'die Uhr falsch, wird deshalb zusätzlich die '
                    'Messungsnummer geprüft. Sphygma verschiebt keine Zeiten; '
                    'stellen lässt sich die Uhr nur am Gerät.',
              ),
            ],
            if (offen > 0) ...[
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
                      offen == 1
                          ? 'Ein Grenzfall wartet auf eine Entscheidung'
                          : '$offen Grenzfälle warten auf eine Entscheidung',
                      style: TextStyle(fontSize: 13, color: t.onSurface),
                    ),
                    Text(
                      'Bis dahin fasst die App nichts still zusammen.',
                      style: TextStyle(fontSize: 11, color: t.muted),
                    ),
                    TextButton(
                      onPressed: onReview,
                      child: const Text('Gruppierung prüfen'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
