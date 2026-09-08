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
import '../../stats/time_of_day_band.dart';
import '../theme/sphygma_theme.dart';
import 'week_grid.dart';

class ThisWeekPanel extends StatelessWidget {
  const ThisWeekPanel({
    super.key,
    required this.measurements,
    required this.now,
    this.onFieldTap,
  });

  /// Alle Messungen eines Speicherplatzes; die laufende Woche wird daraus
  /// gebildet.
  final List<Measurement> measurements;

  /// Was als „jetzt" gilt. Einsetzbar, damit Tests nicht vom Wochentag ihres
  /// Laufs abhängen — und damit die Anzeige über Mitternacht wandert.
  final DateTime now;

  final void Function(WeekField field)? onFieldTap;

  /// Die laufende Woche — nicht die jüngste.
  ///
  /// Nach einer langen Pause ist die jüngste Woche Monate alt; sie als „diese
  /// Woche" zu zeigen wäre gelogen. Null heißt: In dieser Woche wurde noch
  /// nicht gemessen.
  static MeasurementWeek? currentWeek(
    List<Measurement> measurements,
    DateTime now,
  ) {
    if (measurements.isEmpty) return null;
    final montag = mondayOf(now);
    for (final w in buildWeeks(measurements)) {
      if (w.beginsAt == montag) return w;
    }
    return null;
  }

  /// Was heute noch aussteht — sachlich, ohne Mahnung.
  static String openToday(MeasurementWeek week, DateTime now) {
    final morgens =
        week.fieldAt(weekday: now.weekday, band: TimeBand.morgens).isFilled;
    final abends =
        week.fieldAt(weekday: now.weekday, band: TimeBand.abends).isFilled;

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
    final woche = currentWeek(measurements, now);

    if (woche == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Ueberschrift(text: 'DIESE WOCHE'),
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
        const _Ueberschrift(text: 'DIESE WOCHE'),
        WeekGrid(week: woche, onFieldTap: onFieldTap),
        Text(
          openToday(woche, now),
          style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
        ),
        if (woche.average case final a?) ...[
          SizedBox(height: t.gapSmall / 2),
          Text(
            'Wochenwert ${a.systolic}/${a.diastolic} — ohne den ersten Tag, '
            'so rechnet die Praxis.',
            style: TextStyle(fontSize: 11, color: t.muted, height: 1.5),
          ),
        ],
      ],
    );
  }
}

class _Ueberschrift extends StatelessWidget {
  const _Ueberschrift({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: t.muted),
      ),
    );
  }
}
