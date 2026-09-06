// F2 in der Sprache des Konzepts: Der Zeitraum beginnt und endet mit einem
// Messen.
//
// Willkürliche Uhrzeiten gibt es nicht — sie würden mitten in einen Anlass
// schneiden. Gemittelt werden die **Ergebnisse** der Anlässe: Ein Messen hat
// eine Stimme, gleich ob es aus einer oder drei Rohmessungen besteht.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../stats/occasion_grouping.dart';
import '../../../stats/target_range.dart';
import '../../../stats/trend_stats.dart';
import '../../theme/sphygma_theme.dart';
import '../../widgets/section_header.dart';
import 'occasion_detail_screen.dart';
import 'occasion_widgets.dart';

class OccasionRangeScreen extends StatefulWidget {
  const OccasionRangeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<OccasionRangeScreen> createState() => _OccasionRangeScreenState();
}

class _OccasionRangeScreenState extends State<OccasionRangeScreen> {
  /// Indizes in die aufsteigende Anlassliste.
  int? _vonIndex;
  int? _bisIndex;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final alle = widget.controller.occasions;
        if (alle.isEmpty) {
          return _geruest(
            Text(
              'Noch kein Messen zum Auswerten.',
              style: TextStyle(fontSize: 13, color: t.muted),
            ),
          );
        }

        final von = (_vonIndex ?? 0).clamp(0, alle.length - 1);
        final bis = (_bisIndex ?? alle.length - 1).clamp(von, alle.length - 1);
        final gewaehlt = alle.sublist(von, bis + 1);

        // Ein Messen, eine Stimme: gemittelt werden die Anlass-Ergebnisse,
        // nicht die Rohmessungen. Sonst zählte ein dreifach gemessener Anlass
        // dreifach — genau das, was dieses Konzept vermeiden will.
        final mittel = Average.of([
          for (final o in gewaehlt)
            Reading(
              measuredAt: o.measurements.first.measuredAt,
              systolic: o.result.systolic,
              diastolic: o.result.diastolic,
              pulse: o.result.pulse,
            ),
        ]);
        final rohwerte = gewaehlt.fold<int>(
          0,
          (summe, o) => summe + o.measurements.length,
        );
        final mitHinweis = gewaehlt
            .where((o) => o.hasMovement || o.hasArrhythmia)
            .length;

        return _geruest(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Der Zeitraum beginnt und endet mit einem Messen — eine freie '
                'Uhrzeit schnitte mitten in einen Anlass.',
                style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
              ),
              SizedBox(height: t.gapLarge),
              _Wahl(
                label: 'Erster Anlass',
                value: von,
                options: [for (var i = 0; i <= bis; i++) i],
                occasions: alle,
                onChanged: (i) => setState(() => _vonIndex = i),
              ),
              _Wahl(
                label: 'Letzter Anlass',
                value: bis,
                options: [for (var i = von; i < alle.length; i++) i],
                occasions: alle,
                onChanged: (i) => setState(() => _bisIndex = i),
              ),
              SizedBox(height: t.gapLarge),
              if (mittel == null)
                Text(
                  'Kein Ergebnis in diesem Bereich.',
                  style: TextStyle(fontSize: 13, color: t.onSurface),
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
                  'Mittel der Anlass-Ergebnisse · Puls ${mittel.pulse} · '
                  '${TargetRange.heim.classify(systolic: mittel.systolic, diastolic: mittel.diastolic).label}',
                  style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
                ),
              ],
              const SectionHeader(title: 'Umfang'),
              Text(
                '${gewaehlt.length} '
                '${gewaehlt.length == 1 ? "Anlass" : "Anlässe"} · '
                '$rohwerte Rohmessungen',
                style: TextStyle(fontSize: 14, color: t.onSurface),
              ),
              Text(
                '${gewaehlt.length - mitHinweis} unauffällig · '
                '$mitHinweis mit Hinweis des Geräts',
                style: TextStyle(fontSize: 11, color: t.muted),
              ),
              const SectionHeader(title: 'Veränderung'),
              _Veraenderung(occasions: gewaehlt),
              const SectionHeader(title: 'Enthaltene Anlässe'),
              for (final o in gewaehlt.reversed)
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SphygmaThemeScope(
                        theme: t,
                        child: OccasionDetailScreen(
                          controller: widget.controller,
                          sequence: o.sequence,
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
                            occasionWhen(o),
                            style: TextStyle(fontSize: 13, color: t.onSurface),
                          ),
                        ),
                        Text(
                          '${o.result.systolic}/${o.result.diastolic}',
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

  Widget _geruest(Widget child) {
    final t = SphygmaTheme.of(context);
    return Scaffold(
      backgroundColor: t.surface,
      appBar: AppBar(
        title: const Text('Anlässe auswerten'),
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

/// Erste gegen zweite Hälfte des Bereichs.
///
/// Der Vergleich des ersten mit dem letzten Anlass wäre die naheliegende
/// Rechnung und die schlechtere: Zwei einzelne Messungen schwanken so stark,
/// dass daraus jede beliebige Richtung ablesbar wäre.
class _Veraenderung extends StatelessWidget {
  const _Veraenderung({required this.occasions});

  final List<MeasurementOccasion> occasions;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    if (occasions.length < 4) {
      return Text(
        'Für einen Vergleich braucht es mindestens vier Anlässe.',
        style: TextStyle(fontSize: 12, color: t.muted),
      );
    }

    final schnitt = occasions.length ~/ 2;
    final frueh = _mittel(occasions.sublist(0, schnitt));
    final spaet = _mittel(occasions.sublist(schnitt));
    if (frueh == null || spaet == null) {
      return Text(
        'Kein Vergleich möglich.',
        style: TextStyle(fontSize: 12, color: t.muted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Erste Hälfte ($schnitt) gegen zweite Hälfte '
          '(${occasions.length - schnitt})',
          style: TextStyle(fontSize: 11, color: t.muted),
        ),
        SizedBox(height: t.gapSmall / 2),
        _Zeile(label: 'Systolisch', von: frueh.systolic, bis: spaet.systolic),
        _Zeile(label: 'Diastolisch', von: frueh.diastolic, bis: spaet.diastolic),
      ],
    );
  }

  static Average? _mittel(List<MeasurementOccasion> teil) => Average.of([
        for (final o in teil)
          Reading(
            measuredAt: o.measurements.first.measuredAt,
            systolic: o.result.systolic,
            diastolic: o.result.diastolic,
            pulse: o.result.pulse,
          ),
      ]);
}

class _Zeile extends StatelessWidget {
  const _Zeile({required this.label, required this.von, required this.bis});

  final String label;
  final int von;
  final int bis;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final delta = bis - von;
    final text = delta == 0
        ? 'unverändert'
        : '${delta < 0 ? "−" : "+"}${delta.abs()} mmHg';

    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall / 3),
      child: Row(
        children: [
          SizedBox(
            width: 108,
            child: Text(label, style: TextStyle(fontSize: 12, color: t.muted)),
          ),
          Text(text, style: TextStyle(fontSize: 14, color: t.onSurface)),
          SizedBox(width: t.gapSmall),
          Text(
            '$von → $bis',
            style: TextStyle(fontSize: 11, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _Wahl extends StatelessWidget {
  const _Wahl({
    required this.label,
    required this.value,
    required this.options,
    required this.occasions,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> options;
  final List<MeasurementOccasion> occasions;
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
            child: Text(label, style: TextStyle(fontSize: 12, color: t.muted)),
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
                      occasionWhen(occasions[i]),
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
