// lib/ui/history_screen.dart
// Verlauf: Zeitraum, Kurve, Mittelwerte, Liste. Der Bericht fuer die Praxis
// kommt mit dem Berichtsplan hinzu; ein Knopf ohne Wirkung stuende hier nur
// im Weg.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../db/app_database.dart';
import '../stats/period.dart';
import '../stats/period_averages.dart';
import '../stats/trend_stats.dart';
import 'format.dart';
import 'measurement_sheet.dart';
import 'theme/characteristic.dart';
import 'theme/sphygma_theme.dart';
import '../stats/measurement_week.dart';
import '../stats/time_of_day_band.dart';
import 'widgets/surface_panel.dart';
import 'widgets/stat_tiles.dart';
import 'widgets/surface_sliver.dart';
import 'widgets/trend_chart.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final inPeriod = controller.measurementsInPeriod;
        final averages = PeriodAverages.of(inPeriod);

        // CustomScrollView statt ListView: Die Messzeilen bleiben als
        // SliverList virtualisiert, die Fläche liegt als Sliver dahinter.
        // In eine Column gewickelt entstünden bei „Alles" alle Zeilen des
        // Bestands auf einmal, von denen drei sichtbar sind.
        final tage = groupByDay(inPeriod);
        final zeilen = <Widget>[
          for (final group in tage) ...[
            DayHeading(day: group.day),
            for (final m in group.measurements)
              MeasurementRow(controller: controller, measurement: m),
          ],
        ];

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: t.listPadding,
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: SurfacePanel(
                      child: _PeriodPicker(controller: controller),
                    ),
                  ),
                  if (inPeriod.isEmpty)
                    SliverToBoxAdapter(
                      child: SurfacePanel(
                        tone: 1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: t.gapLarge * 2,
                          ),
                          child: Text(
                            'Keine Messungen in diesem Zeitraum.',
                            style: TextStyle(fontSize: 14, color: t.muted),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: SurfacePanel(
                        tone: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TrendChart(measurements: inPeriod),
                            SizedBox(height: t.gapLarge),
                            const _Section(title: 'MITTELWERTE'),
                            // Der Praxiswert der Messwoche: sieben Tage,
                            // morgens und abends, **ohne den ersten Tag** —
                            // so verlangt es die Leitlinie für die
                            // Selbstmessung. Nur bei Zeitraum „Woche", weil
                            // die Zahl sonst nichts bedeutet.
                            StatTiles(
                              stats: [
                                Stat(
                                  label: 'Gesamt',
                                  value: formatAverage(averages.overall),
                                ),
                                if (controller.period == Period.week)
                                  ..._Wochenwert.stats(inPeriod),
                              ],
                            ),
                            const _Section(title: 'NACH TAGESZEIT'),
                            // Fünf Abschnitte statt zweier: Der Tagesverlauf
                            // ist eine eigene Aussage, die der Verlauf über
                            // Tage nicht gibt.
                            ..._Tageszeiten.zeilen(context, inPeriod),
                          ],
                        ),
                      ),
                    ),
                    SurfaceSliver(
                      sliver: SliverMainAxisGroup(
                        slivers: [
                          const SliverToBoxAdapter(
                            child: _Section(title: 'MESSUNGEN'),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => zeilen[i],
                              childCount: zeilen.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    // Die Form entscheidet über die Bauform der Auswahl. „Material" zeigt
    // Chips, die ihren Text tragen; alle übrigen eine Leiste gleich breiter
    // Felder. Der Bildschirm reicht nur die Möglichkeiten durch.
    if (t.selectionStyle == SelectionStyle.chips) {
      return Wrap(
        spacing: t.gapSmall,
        runSpacing: t.gapSmall,
        children: [
          for (final p in Period.values)
            FilterChip(
              label: Text(p.label),
              selected: p == controller.period,
              onSelected: (_) => controller.setPeriod(p),
              showCheckmark: false,
              side: BorderSide(color: t.line),
              backgroundColor: t.panel(0),
              selectedColor: t.accent,
              labelStyle: TextStyle(
                fontSize: 12,
                color: p == controller.period ? t.surface : t.onSurface,
              ),
            ),
        ],
      );
    }

    return Row(
      children: [
        for (final p in Period.values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: t.gapSmall),
              child: GestureDetector(
                onTap: () => controller.setPeriod(p),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: t.gapSmall),
                  decoration: BoxDecoration(
                    color: p == controller.period ? t.onSurface : null,
                    border: Border.all(color: t.line),
                    borderRadius: BorderRadius.circular(t.radius),
                  ),
                  child: Text(
                    p.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: p == controller.period ? t.surface : t.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall),
      child: Text(
        title,
        style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: t.muted),
      ),
    );
  }
}


class DayHeading extends StatelessWidget {
  const DayHeading({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: t.gapLarge, bottom: t.gapSmall),
      child: Text(
        formatDay(day),
        style: TextStyle(fontSize: 12, color: t.muted),
      ),
    );
  }
}

class MeasurementRow extends StatelessWidget {
  const MeasurementRow({
    super.key,
    required this.controller,
    required this.measurement,
  });

  final AppController controller;
  final Measurement measurement;

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
        padding: EdgeInsets.symmetric(vertical: t.rowGap),
        decoration: t.rowDivider,
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
            if (m.exportedAt != null)
              Padding(
                key: const ValueKey('exported-dot'),
                padding: EdgeInsets.only(right: t.gapSmall),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: t.muted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Text(
              formatTime(m.measuredAt),
              style: TextStyle(fontSize: 13, color: t.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Der Wochenwert nach Leitlinie — und wie vollständig die Woche ist.
class _Wochenwert {
  static List<Stat> stats(List<Measurement> messungen) {
    if (messungen.isEmpty) return const [];
    final wochen = buildWeeks(messungen);
    if (wochen.isEmpty) return const [];
    final woche = wochen.first;
    final a = woche.average;

    return [
      // Der Eintrag bleibt stehen, auch ohne Wert: Dass es den Praxiswert
      // gibt und warum er noch fehlt, ist eine Aussage — ihn wegzulassen
      // ließe den Eindruck, es gäbe ihn nicht.
      Stat(
        label: 'Ohne ersten Tag',
        value: a == null ? 'erst ab dem zweiten Messtag' : formatAverage(a),
      ),
      Stat(
        label: 'Felder',
        value: '${woche.filledFields} von $fieldsPerWeek',
      ),
    ];
  }
}

/// Die Mittelwerte je Tagesabschnitt und die Spanne dazwischen.
class _Tageszeiten {
  static const List<TimeBand> _folge = [
    TimeBand.morgens,
    TimeBand.vormittags,
    TimeBand.nachmittags,
    TimeBand.abends,
    TimeBand.nachts,
  ];

  static List<Widget> zeilen(
    BuildContext context,
    List<Measurement> messungen,
  ) {
    if (messungen.isEmpty) return const [];
    final mittel = averagesByBand(messungen, BandGrid.fein);
    if (mittel.isEmpty) return const [];

    final werte = mittel.values.map((a) => a.systolic).toList()..sort();
    final spanne = werte.last - werte.first;
    final hoechster = mittel.entries.reduce(
      (a, b) => a.value.systolic >= b.value.systolic ? a : b,
    );

    return [
      // Fünf Abschnitte liegen über der Kartengrenze — hier bleibt es auch
      // im „Tagebuch" bei Zeilen. Die Entscheidung trifft der Baustein.
      StatTiles(
        stats: [
          for (final band in _folge)
            if (mittel[band] case final a?)
              Stat(label: band.label, value: formatAverage(a)),
        ],
      ),
      if (mittel.length > 1)
        _Aussage(
          text:
              'Am höchsten liegt der Druck '
              '${hoechster.key.label.toLowerCase()}. Über den Tag '
              'unterscheiden sich die Abschnitte um $spanne mmHg.',
        ),
    ];
  }
}


class _Aussage extends StatelessWidget {
  const _Aussage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: t.gapSmall),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: t.muted, height: 1.5),
      ),
    );
  }
}

/// Ein Mittelwert als Text — oder ein Strich.
///
/// Null heißt: In diesem Zeitraum gab es dort keine Messung. Dann steht ein
/// Strich da, keine erfundene Null.
String formatAverage(Average? average) {
  final a = average;
  if (a == null) return '–';
  return '${a.systolic}/${a.diastolic} · ${a.pulse}';
}
