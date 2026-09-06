// F2 in der Sprache des Konzepts: Auswertung über zusammenhängende Wochen.
//
// Freie Tagesgrenzen gibt es hier nicht — sie würden die Vergleichseinheit
// zerschneiden. Was es gibt, ist der volle Funktionsumfang: gemeinsames
// Mittel, Trend und Abdeckung über jede Folge von Messwochen.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../stats/measurement_week.dart';
import '../../../stats/target_range.dart';
import '../../../stats/trend_stats.dart';
import '../../format.dart';
import '../../theme/sphygma_theme.dart';
import '../../widgets/section_header.dart';
import 'week_detail_screen.dart';

class WeekRangeScreen extends StatefulWidget {
  const WeekRangeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<WeekRangeScreen> createState() => _WeekRangeScreenState();
}

class _WeekRangeScreenState extends State<WeekRangeScreen> {
  /// Indizes in die Wochenliste, die neueste zuerst führt: [_vonIndex] ist
  /// die ältere Woche und damit der größere Index.
  int? _vonIndex;
  int? _bisIndex;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final wochen = buildWeeks(widget.controller.measurements);
        if (wochen.isEmpty) {
          return _geruest(
            child: Text(
              'Noch keine Woche zum Auswerten.',
              style: TextStyle(fontSize: 13, color: t.muted),
            ),
          );
        }

        // Vorgabe ist die längste ununterbrochene Folge bis zur jüngsten
        // Woche — genau das, was „zusammenhängende Messwochen" meint. Ein
        // Vorgabebereich über eine Lücke von Monaten hinweg wäre eine Zahl,
        // die niemand so hätte bilden wollen.
        final vorgabe = _letzteUnunterbrocheneFolge(wochen);
        final bis = (_bisIndex ?? 0).clamp(0, wochen.length - 1);
        final von = (_vonIndex ?? vorgabe).clamp(bis, wochen.length - 1);

        final gewaehlt = wochen.sublist(bis, von + 1);
        final mittel = Average.of([
          for (final w in gewaehlt)
            for (final m in w.measurementsWithoutFirstDay)
              Reading(
                measuredAt: m.measuredAt,
                systolic: m.systolic,
                diastolic: m.diastolic,
                pulse: m.pulse,
              ),
        ]);

        final spanne =
            weekSpan(wochen[von].beginsAt, wochen[bis].beginsAt);
        final belegt =
            gewaehlt.fold<int>(0, (summe, w) => summe + w.filledFields);
        final aelteste = wochen[von].average;
        final juengste = wochen[bis].average;

        return _geruest(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nur zusammenhängende Messwochen — freie Tagesgrenzen würden '
                'die Vergleichseinheit zerschneiden.',
                style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
              ),
              SizedBox(height: t.gapLarge),
              _Wahl(
                label: 'Erste Woche',
                value: von,
                // Die erste Woche kann nicht jünger als die letzte sein.
                options: [
                  for (var i = bis; i < wochen.length; i++) i,
                ],
                wochen: wochen,
                onChanged: (i) => setState(() => _vonIndex = i),
              ),
              _Wahl(
                label: 'Letzte Woche',
                value: bis,
                options: [
                  for (var i = 0; i <= von; i++) i,
                ],
                wochen: wochen,
                onChanged: (i) => setState(() => _bisIndex = i),
              ),
              SizedBox(height: t.gapLarge),
              if (mittel == null)
                Text(
                  'In diesem Bereich bleibt nach dem Auslassen der ersten '
                  'Tage keine Messung übrig, aus der ein Wert gebildet '
                  'werden könnte.',
                  style: TextStyle(fontSize: 13, color: t.onSurface, height: 1.5),
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
                  'Gemeinsames Mittel aus ${gewaehlt.length} '
                  '${gewaehlt.length == 1 ? "Woche" : "Wochen"} · Puls '
                  '${mittel.pulse} · '
                  '${TargetRange.heim.classify(systolic: mittel.systolic, diastolic: mittel.diastolic).label}',
                  style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
                ),
              ],
              const SectionHeader(title: 'Trend'),
              if (aelteste == null || juengste == null || gewaehlt.length < 2)
                Text(
                  'Ein Trend braucht zwei Wochen mit Wochenwert.',
                  style: TextStyle(fontSize: 12, color: t.muted),
                )
              else ...[
                _TrendZeile(
                  label: 'Systolisch',
                  von: aelteste.systolic,
                  bis: juengste.systolic,
                ),
                _TrendZeile(
                  label: 'Diastolisch',
                  von: aelteste.diastolic,
                  bis: juengste.diastolic,
                ),
              ],
              const SectionHeader(title: 'Abdeckung'),
              Text(
                '$belegt von ${spanne * fieldsPerWeek} Feldern',
                style: TextStyle(fontSize: 14, color: t.onSurface),
              ),
              if (spanne > gewaehlt.length)
                Text(
                  '${spanne - gewaehlt.length} '
                  '${spanne - gewaehlt.length == 1 ? "Woche" : "Wochen"} im '
                  'Zeitraum ohne eine einzige Messung — sie zählen mit.',
                  style: TextStyle(fontSize: 11, color: t.muted, height: 1.5),
                ),
              const SectionHeader(title: 'Wochen dieses Bereichs'),
              for (final w in gewaehlt)
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SphygmaThemeScope(
                        theme: t,
                        child: WeekDetailScreen(
                          controller: widget.controller,
                          week: w,
                        ),
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
                          child: Text(
                            formatWeekRange(w.beginsAt),
                            style:
                                TextStyle(fontSize: 13, color: t.onSurface),
                          ),
                        ),
                        Text(
                          w.average == null
                              ? '${w.filledFields}/$fieldsPerWeek'
                              : '${w.average!.systolic}/${w.average!.diastolic}',
                          style: TextStyle(
                            fontSize: 13,
                            color: t.muted,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _geruest({required Widget child}) {
    final t = SphygmaTheme.of(context);
    return Scaffold(
      backgroundColor: t.surface,
      appBar: AppBar(
        title: const Text('Wochen auswerten'),
        backgroundColor: t.surface,
        foregroundColor: t.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(t.gapLarge),
        child: child,
      ),
    );
  }
}

/// Der Index der ältesten Woche, die ohne Lücke bis zur jüngsten reicht.
int _letzteUnunterbrocheneFolge(List<MeasurementWeek> wochen) {
  var i = 0;
  while (i + 1 < wochen.length &&
      wochen[i + 1].beginsAt == previousMonday(wochen[i].beginsAt)) {
    i++;
  }
  return i;
}

class _Wahl extends StatelessWidget {
  const _Wahl({
    required this.label,
    required this.value,
    required this.options,
    required this.wochen,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> options;
  final List<MeasurementWeek> wochen;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall),
      child: Row(
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: t.muted),
            ),
          ),
          Expanded(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              underline: Container(height: 1, color: t.line),
              items: [
                for (final i in options)
                  DropdownMenuItem<int>(
                    value: i,
                    child: Text(
                      formatWeekRange(wochen[i].beginsAt),
                      style: TextStyle(fontSize: 13, color: t.onSurface),
                    ),
                  ),
              ],
              onChanged: (i) => i == null ? null : onChanged(i),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendZeile extends StatelessWidget {
  const _TrendZeile({
    required this.label,
    required this.von,
    required this.bis,
  });

  final String label;
  final int von;
  final int bis;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final delta = bis - von;
    // Das Minuszeichen ist ein echtes, kein Bindestrich: −4 mmHg.
    final text = delta == 0
        ? 'unverändert'
        : '${delta < 0 ? "−" : "+"}${delta.abs()} mmHg';

    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall / 2),
      child: Row(
        children: [
          SizedBox(
            width: 108,
            child:
                Text(label, style: TextStyle(fontSize: 12, color: t.muted)),
          ),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: t.onSurface),
          ),
          SizedBox(width: t.gapSmall),
          Text(
            'von $von auf $bis',
            style: TextStyle(fontSize: 11, color: t.muted),
          ),
        ],
      ),
    );
  }
}
