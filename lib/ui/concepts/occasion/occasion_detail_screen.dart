// Ein Messanlass im Detail: Ergebnis, Regel, Rohwerte, Güte.
//
// Kennzeichen verändern die Güte, nicht die Historie. Kein Rohwert wird
// gelöscht; seine Rolle im Ergebnis wird erklärt.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../stats/occasion_grouping.dart';
import '../../measurement_sheet.dart';
import '../../theme/sphygma_theme.dart';
import '../../widgets/section_header.dart';
import 'occasion_widgets.dart';

class OccasionDetailScreen extends StatelessWidget {
  const OccasionDetailScreen({
    super.key,
    required this.controller,
    required this.sequence,
  });

  final AppController controller;

  /// Die Gerätenummer der ersten Rohmessung — die Identität des Anlasses.
  /// Nicht der Anlass selbst: Holt der Abgleich währenddessen eine weitere
  /// Messung, soll dieser Bildschirm sie mitnehmen.
  final int sequence;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          for (final o in controller.occasions) {
            if (o.sequence == sequence) return _inhalt(context, o);
          }
          return _fehlt(context);
        },
      );

  Widget _geruest(BuildContext context, Widget body) {
    final t = SphygmaTheme.of(context);
    return Scaffold(
      backgroundColor: t.surface,
      appBar: AppBar(
        title: const Text('Messanlass'),
        backgroundColor: t.surface,
        foregroundColor: t.onSurface,
        elevation: 0,
      ),
      body: body,
    );
  }

  Widget _fehlt(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return _geruest(
      context,
      Padding(
        padding: EdgeInsets.all(t.gapLarge),
        child: Text(
          'Dieser Anlass gehört nicht zum gewählten Speicherplatz.',
          style: TextStyle(fontSize: 13, color: t.muted),
        ),
      ),
    );
  }

  Widget _inhalt(BuildContext context, MeasurementOccasion o) {
    final t = SphygmaTheme.of(context);

    return _geruest(
      context,
      ListView(
        padding: EdgeInsets.all(t.gapLarge),
        children: [
          Text(
            occasionWhen(o),
            style: TextStyle(fontSize: 12, color: t.muted),
          ),
          SizedBox(height: t.gapSmall),
          OccasionResult(occasion: o),
          SizedBox(height: t.gapLarge),
          QualityChips(occasion: o),
          if (o.measurements.length > o.usedMeasurements.length) ...[
            SizedBox(height: t.gapLarge),
            Container(
              padding: EdgeInsets.all(t.gapSmall),
              decoration: BoxDecoration(
                border: Border.all(color: t.line),
                borderRadius: BorderRadius.circular(t.radius),
              ),
              child: Text(
                'Güte eingeschränkt: Das Gerät erkannte bei mindestens einer '
                'Messung Bewegung. Das Ergebnis nutzt deshalb nur die '
                'unauffälligen Messungen. Die anderen bleiben erhalten.',
                style: TextStyle(fontSize: 12, color: t.onSurface, height: 1.5),
              ),
            ),
          ],
          const SectionHeader(title: 'Rohwerte'),
          RawMeasurementList(
            occasion: o,
            onTap: (m) => showMeasurementSheet(
              context,
              controller: controller,
              measurementId: m.id,
            ),
          ),
          const SectionHeader(title: 'Regel dieses Anlasses'),
          Text(
            o.rule,
            style: TextStyle(fontSize: 13, color: t.onSurface, height: 1.5),
          ),
          SizedBox(height: t.gapSmall),
          Text(
            'Zustand: ${o.state.label}',
            style: TextStyle(fontSize: 11, color: t.muted),
          ),
          if (o.state == OccasionState.bestaetigt)
            TextButton(
              onPressed: () {
                final naht = o.measurements.length > 1
                    ? o.measurements.last.deviceSequence
                    : o.sequence;
                controller.clearOccasionDecision(naht);
              },
              child: const Text('Entscheidung zurücknehmen'),
            ),
        ],
      ),
    );
  }
}
