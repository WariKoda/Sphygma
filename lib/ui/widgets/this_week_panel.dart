// Die laufende Woche auf einen Blick — Raster und der nächste Schritt.
//
// Beantwortet die Frage, die der Verlauf nicht stellt: nicht wie es war,
// sondern **was noch fehlt**. Deshalb steht sie auf „Heute" und nicht bei den
// Kurven.
//
// Kam aus dem aufgelösten Konzept „Sieben Tage", wo die Woche das ganze
// Programm war; hier ist sie ein Abschnitt unter dem letzten Wert. Wer nicht
// nach Wochenplan misst, schaltet sie in den Einstellungen ab.
import 'package:flutter/material.dart';

import '../../db/app_database.dart';
import '../../stats/measurement_week.dart';
import '../../stats/measurement_windows.dart';
import '../../stats/time_of_day_band.dart';
import '../theme/sphygma_theme.dart';
import 'week_grid.dart';
import 'panel_header.dart';
import 'measurement_list_item.dart';

class ThisWeekPanel extends StatelessWidget {
  const ThisWeekPanel({
    super.key,
    required this.measurements,
    required this.now,
    this.onFieldTap,
    this.windows,
  });

  /// Alle Messungen eines Speicherplatzes; die laufende Woche wird daraus
  /// gebildet.
  final List<Measurement> measurements;

  /// Was als „jetzt" gilt. Einsetzbar, damit Tests nicht vom Wochentag ihres
  /// Laufs abhängen — und damit die Anzeige über Mitternacht wandert.
  final DateTime now;
  final MeasurementWindows? windows;

  final void Function(WeekField field)? onFieldTap;

  /// Die laufende Woche — nicht die jüngste.
  ///
  /// Nach einer langen Pause ist die jüngste Woche Monate alt; sie als „diese
  /// Woche" zu zeigen wäre gelogen. Null heißt: In dieser Woche wurde noch
  /// nicht gemessen.
  static MeasurementWeek? currentWeek(
    List<Measurement> measurements,
    DateTime now, {
    MeasurementWindows? windows,
  }) {
    if (measurements.isEmpty) return null;
    final montag = mondayOf(now);
    for (final w in buildWeeks(measurements, windows: windows)) {
      if (w.beginsAt == montag) return w;
    }
    return null;
  }

  /// Was heute noch aussteht — sachlich, ohne Mahnung.
  static String openToday(MeasurementWeek week, DateTime now) {
    final morgens = week
        .fieldAt(weekday: now.weekday, band: TimeBand.morgens)
        .isFilled;
    final abends = week
        .fieldAt(weekday: now.weekday, band: TimeBand.abends)
        .isFilled;

    return switch ((morgens, abends)) {
      (true, true) => 'Heute ist morgens und abends gemessen.',
      (true, false) => 'Heute fehlt noch die Abendmessung.',
      (false, true) => 'Heute fehlt noch die Morgenmessung.',
      (false, false) => 'Heute fehlen noch beide Messungen.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final woche = currentWeek(measurements, now, windows: windows);

    if (woche == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelHeader(
            title: 'Diese Woche',
            icon: Icons.calendar_today_outlined,
          ),
          Text(
            'In dieser Woche wurde noch nicht gemessen.',
            style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelHeader(
          title: 'Diese Woche',
          icon: Icons.calendar_today_outlined,
        ),
        if (woche.average case final a?) ...[
          Text('Wochenmittel', style: TextStyle(fontSize: 14, color: t.muted)),
          SizedBox(height: t.gapSmall),
          MeasurementValues(
            systolic: a.systolic,
            diastolic: a.diastolic,
            pulse: a.pulse,
          ),
          SizedBox(height: t.gapSmall),
          Text(
            'Ohne den ersten Tag.',
            style: TextStyle(fontSize: 13, color: t.muted),
          ),
          SizedBox(height: t.gapLarge),
        ],
        WeekGrid(week: woche, onFieldTap: onFieldTap),
        SizedBox(height: t.gapSmall),
        Text(
          openToday(woche, now),
          style: TextStyle(fontSize: 14, color: t.onSurface, height: 1.5),
        ),
      ],
    );
  }
}
