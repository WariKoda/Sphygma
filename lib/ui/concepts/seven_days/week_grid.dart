// Das Wochenraster: sieben Spalten, zwei Zeilen, vierzehn Felder.
//
// Es ist die Hauptsache des Konzepts „Sieben Tage". Man sieht in einem Blick,
// was gemessen wurde, was fehlt und wo die Werte liegen. Leere Felder bleiben
// stehen — „hier wurde nicht gemessen" ist die halbe Aussage der Woche.
import 'package:flutter/material.dart';

import '../../../stats/measurement_week.dart';
import '../../../stats/target_range.dart';
import '../../../stats/time_of_day_band.dart';
import '../../theme/sphygma_theme.dart';
import '../../theme/zone_color.dart';

const List<String> _wochentage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

class WeekGrid extends StatelessWidget {
  const WeekGrid({super.key, required this.week, this.onFieldTap});

  final MeasurementWeek week;

  /// Der Weg zu einer einzelnen Messung führt in diesem Konzept über ihr
  /// Feld. Ohne Rückruf ist das Raster reine Anzeige.
  final void Function(WeekField field)? onFieldTap;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final tag in _wochentage)
              Expanded(
                child: Center(
                  child: Text(
                    tag,
                    style: TextStyle(fontSize: 11, color: t.muted),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: t.gapSmall),
        for (final band in const [TimeBand.morgens, TimeBand.abends]) ...[
          Text(
            band.label,
            style: TextStyle(fontSize: 11, color: t.muted),
          ),
          SizedBox(height: t.gapSmall / 2),
          Row(
            children: [
              for (var tag = DateTime.monday; tag <= DateTime.sunday; tag++)
                Expanded(
                  child: _Zelle(
                    field: week.fieldAt(weekday: tag, band: band),
                    onTap: onFieldTap,
                  ),
                ),
            ],
          ),
          SizedBox(height: t.gapSmall),
        ],
      ],
    );
  }
}

class _Zelle extends StatelessWidget {
  const _Zelle({required this.field, required this.onTap});

  final WeekField field;
  final void Function(WeekField field)? onTap;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final mittel = field.average;

    if (mittel == null) {
      return Semantics(
        label: '${_tagName(field.weekday)} ${field.band.label}: '
            'nicht gemessen',
        child: Container(
          height: 34,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(t.radius / 2),
          ),
        ),
      );
    }

    final zone = TargetRange.heim
        .classify(systolic: mittel.systolic, diastolic: mittel.diastolic);
    final grund = zoneColor(t, zone);

    return Semantics(
      label: '${_tagName(field.weekday)} ${field.band.label}: '
          '${mittel.systolic} zu ${mittel.diastolic}, ${zone.label}',
      button: onTap != null,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(field),
        child: Container(
          height: 34,
          margin: const EdgeInsets.all(1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Gefüllt, nicht umrandet: Farbe gehört den Daten. Wer im
            // Bildschirm Farbe sieht, sieht einen Messwert.
            color: grund.withValues(alpha: 0.22),
            border: Border.all(color: grund),
            borderRadius: BorderRadius.circular(t.radius / 2),
          ),
          child: Text(
            '${mittel.systolic}',
            style: TextStyle(
              fontSize: 13,
              color: t.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

String _tagName(int weekday) => const {
      DateTime.monday: 'Montag',
      DateTime.tuesday: 'Dienstag',
      DateTime.wednesday: 'Mittwoch',
      DateTime.thursday: 'Donnerstag',
      DateTime.friday: 'Freitag',
      DateTime.saturday: 'Samstag',
      DateTime.sunday: 'Sonntag',
    }[weekday]!;
