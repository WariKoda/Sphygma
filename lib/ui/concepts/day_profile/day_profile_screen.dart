// Konzept „Tagesprofil": Die Einheit ist die Tageszeit.
//
// Die Chronologie ist nicht mehr die Zugangsachse. Alle Messungen liegen
// übereinander auf einem Tag, und was sichtbar wird, ist ein Muster: wann der
// Druck hoch ist, nicht wie er gestern war. An eine einzelne Messung kommt
// man über ihren Tagesabschnitt, nicht über den Kalender.
//
// Dieses Konzept braucht keine Datenbankänderung — dieselben Messungen, nach
// Stunde gruppiert statt nach Datum.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/feature_flags.dart';
import '../../../stats/esc_classification.dart';
import '../../../stats/target_range.dart';
import '../../../stats/time_of_day_band.dart';
import '../../../stats/trend_stats.dart';
import '../../theme/sphygma_theme.dart';
import '../../widgets/classification_scale.dart';
import '../../widgets/notice_card.dart';
import 'band_detail_screen.dart';

class DayProfileScreen extends StatelessWidget {
  const DayProfileScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final messungen = controller.measurements;
        if (messungen.isEmpty) {
          return _Leer(paired: controller.paired);
        }

        final mittel = averagesByBand(messungen, BandGrid.fein);
        // Die Reihenfolge des Tages, nicht die der Häufigkeit: Ein Muster
        // liest man von morgens nach nachts.
        final abschnitte = [
          for (final band in _tagesfolge)
            if (mittel.containsKey(band)) band,
        ];

        return ListView(
          padding: EdgeInsets.all(t.gapLarge),
          children: [
            Text(
              'DEIN TAGESMUSTER',
              style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: t.muted),
            ),
            SizedBox(height: t.gapSmall),
            Text(
              '${messungen.length} Messungen nach Uhrzeit',
              style: TextStyle(fontSize: 13, color: t.onSurface),
            ),
            ..._hinweise(context),
            SizedBox(height: t.gapLarge),
            for (final band in abschnitte)
              _BandRow(
                controller: controller,
                band: band,
                average: mittel[band]!,
              ),
            SizedBox(height: t.gapLarge),
            _Unterschied(mittel: mittel),
            // F4 gehört auch hierher. Eingeordnet wird der höchste
            // Abschnittswert: Er ist der, um den es geht, wenn man ein
            // Tagesmuster liest.
            if (escClassificationEnabled && mittel.isNotEmpty) ...[
              SizedBox(height: t.gapLarge),
              ClassificationScale(
                category: classifyOffice(
                  systolic: _hoechster(mittel).systolic,
                  diastolic: _hoechster(mittel).diastolic,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Der Abschnitt mit dem höchsten systolischen Mittel.
  static Average _hoechster(Map<TimeBand, Average> mittel) => mittel.values
      .reduce((a, b) => a.systolic >= b.systolic ? a : b);

  static const List<TimeBand> _tagesfolge = [
    TimeBand.morgens,
    TimeBand.vormittags,
    TimeBand.nachmittags,
    TimeBand.abends,
    TimeBand.nachts,
  ];

  List<Widget> _hinweise(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final hinweise = <Widget>[];

    if (!controller.paired) {
      hinweise.add(const NoticeCard(
        title: 'Nicht gekoppelt',
        message: 'Ohne Kopplung kann Sphygma keine Messungen holen. '
            'Unter "Gerät" einrichten.',
      ));
    }

    if (controller.clockLooksWrong) {
      hinweise.add(const NoticeCard(
        title: 'Geräteuhr geht falsch',
        message: 'Dieses Konzept ordnet nach Uhrzeit — geht die Uhr des '
            'Geräts falsch, liegen die Messungen an der falschen Stelle des '
            'Tages. Sphygma verschiebt nichts; stellen lässt sich die Uhr nur '
            'am Gerät.',
      ));
    }

    return [
      for (final h in hinweise) ...[SizedBox(height: t.gapLarge), h],
    ];
  }
}

/// Ein Tagesabschnitt mit seinem Mittelwert. Antippen führt zu den Messungen.
class _BandRow extends StatelessWidget {
  const _BandRow({
    required this.controller,
    required this.band,
    required this.average,
  });

  final AppController controller;
  final TimeBand band;
  final Average average;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final zone = TargetRange.heim
        .classify(systolic: average.systolic, diastolic: average.diastolic);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SphygmaThemeScope(
            theme: t,
            child: BandDetailScreen(controller: controller, band: band),
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: t.gapSmall),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    band.label,
                    style: TextStyle(fontSize: 14, color: t.onSurface),
                  ),
                  Text(
                    '${average.count} Messungen · ${zone.label}',
                    style: TextStyle(fontSize: 11, color: t.muted),
                  ),
                ],
              ),
            ),
            Text(
              '${average.systolic}/${average.diastolic}',
              style: TextStyle(
                fontSize: 17,
                color: t.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Die eigentliche Aussage des Konzepts: der Unterschied über den Tag.
class _Unterschied extends StatelessWidget {
  const _Unterschied({required this.mittel});

  final Map<TimeBand, Average> mittel;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    if (mittel.length < 2) return const SizedBox.shrink();

    final werte = mittel.values.map((a) => a.systolic).toList()..sort();
    final spanne = werte.last - werte.first;

    final hoechster = mittel.entries
        .reduce((a, b) => a.value.systolic >= b.value.systolic ? a : b);

    return Text(
      'Am höchsten liegt der Druck ${hoechster.key.label.toLowerCase()}: '
      '${hoechster.value.systolic}/${hoechster.value.diastolic} mmHg. '
      'Über den Tag unterscheiden sich die Abschnitte um $spanne mmHg.',
      style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
    );
  }
}

class _Leer extends StatelessWidget {
  const _Leer({required this.paired});

  final bool paired;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.all(t.gapLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: t.gapLarge),
          Text(
            'Noch keine Messung',
            style: TextStyle(fontSize: 17, color: t.onSurface),
          ),
          SizedBox(height: t.gapSmall),
          Text(
            paired
                ? 'Miss am Gerät — Sphygma holt die Messung von selbst. Das '
                    'Tagesmuster entsteht, sobald zu verschiedenen Uhrzeiten '
                    'gemessen wurde.'
                : 'Zuerst unter "Gerät" koppeln.',
            style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}
