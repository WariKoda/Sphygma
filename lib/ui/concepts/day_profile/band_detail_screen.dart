// Ein Tagesabschnitt im Detail — der Weg zu einer einzelnen Messung, wenn
// der Kalender nicht mehr die Zugangsachse ist.
//
// Die Messungen stehen hier nach Uhrzeit beisammen, quer über alle Tage. Ihr
// Datum tragen sie weiter, aber man kommt über die Tageszeit an sie heran.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../db/app_database.dart';
import '../../../stats/target_range.dart';
import '../../../stats/time_of_day_band.dart';
import '../../../stats/time_plausibility.dart';
import '../../format.dart';
import '../../measurement_sheet.dart';
import '../../theme/sphygma_theme.dart';

class BandDetailScreen extends StatelessWidget {
  const BandDetailScreen({
    super.key,
    required this.controller,
    required this.band,
  });

  final AppController controller;
  final TimeBand band;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final gruppen = groupByBand(controller.measurements, BandGrid.fein);
        final messungen = gruppen[band] ?? const <Measurement>[];
        final mittel = averagesByBand(controller.measurements, BandGrid.fein);
        final fraglich = {
          for (final m in questionableTimestamps(
            controller.measurements,
            now: DateTime.now(),
          ))
            m.deviceSequence,
        };

        return Scaffold(
          backgroundColor: t.surface,
          appBar: AppBar(
            title: Text(band.label),
            backgroundColor: t.surface,
            foregroundColor: t.onSurface,
            elevation: 0,
          ),
          body: ListView(
            padding: EdgeInsets.all(t.gapLarge),
            children: [
              if (mittel[band] case final a?) ...[
                Text(
                  '${a.systolic}/${a.diastolic}',
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
                  'Mittel aus ${a.count} Messungen · Puls ${a.pulse} · '
                  '${TargetRange.heim.classify(systolic: a.systolic, diastolic: a.diastolic).label}',
                  style: TextStyle(fontSize: 12, color: t.muted),
                ),
                SizedBox(height: t.gapLarge),
              ],
              Text(
                'MESSUNGEN UM DIESE ZEIT',
                style:
                    TextStyle(fontSize: 10, letterSpacing: 1.6, color: t.muted),
              ),
              // Neueste zuerst: Wer den Abschnitt öffnet, sucht meist zuerst
              // das Jüngste.
              for (final m in messungen.reversed)
                _Zeile(
                  controller: controller,
                  measurement: m,
                  fraglich: fraglich.contains(m.deviceSequence),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({
    required this.controller,
    required this.measurement,
    required this.fraglich,
  });

  final AppController controller;
  final Measurement measurement;
  final bool fraglich;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final m = measurement;

    return InkWell(
      onTap: () => showMeasurementSheet(
        context,
        controller: controller,
        measurementId: m.id,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: t.gapSmall),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${m.systolic}/${m.diastolic} · ${m.pulse}',
                style: TextStyle(
                  fontSize: 14,
                  color: t.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (m.movement || m.arrhythmia)
              Padding(
                padding: EdgeInsets.only(right: t.gapSmall),
                child: Icon(Icons.info_outline, size: 14, color: t.muted),
              ),
            Text(
              fraglich
                  ? '${formatDayAndTime(m.measuredAt)} ⚠'
                  : formatDayAndTime(m.measuredAt),
              style: TextStyle(fontSize: 12, color: t.muted),
            ),
          ],
        ),
      ),
    );
  }
}
