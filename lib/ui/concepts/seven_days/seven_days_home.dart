// Konzept „Sieben Tage": Die Einheit ist die Messwoche.
//
// Ein einzelner Messwert sagt fast nichts, ein gleitender Schnitt mittelt über
// einen zufällig entstandenen Zeitraum. Aussagekraft hat die Messwoche —
// sieben Tage, morgens und abends, erster Tag verworfen, Zielwert 135/85.
// Deshalb ist die Woche hier kein Zeitfilter, sondern das zentrale Objekt.
//
// Ein Weg statt vier Reiter: Dieser Bildschirm ist der Einstieg, alles andere
// wird von hier aus aufgerufen. Heute, Verlauf und Gerät nebeneinander zu
// stellen hieße, zwei selten gebrauchte Bereiche dauerhaft mitzuführen.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../stats/measurement_week.dart';
import '../../../stats/target_range.dart';
import '../../../stats/time_of_day_band.dart';
import '../../device_screen.dart';
import '../../format.dart';
import '../../measurement_sheet.dart';
import '../../theme/sphygma_theme.dart';
import '../../widgets/notice_card.dart';
import 'earlier_weeks_screen.dart';
import 'week_detail_screen.dart';
import 'week_grid.dart';

class SevenDaysHome extends StatefulWidget {
  const SevenDaysHome({
    super.key,
    required this.controller,
    this.clock = DateTime.now,
  });

  final AppController controller;

  /// Die Uhr wird bei jedem Aufbau neu gelesen, nicht einmal beim Erzeugen:
  /// Eine App, die über Mitternacht offen bleibt, zeigt sonst weiter die
  /// Woche von gestern. Einsetzbar, damit Tests nicht davon abhängen, an
  /// welchem Wochentag sie laufen.
  final DateTime Function() clock;

  @override
  State<SevenDaysHome> createState() => _SevenDaysHomeState();
}

class _SevenDaysHomeState extends State<SevenDaysHome> {
  /// Weckt den Bildschirm zum nächsten Tageswechsel.
  ///
  /// Ohne ihn zeigte eine über Mitternacht geöffnete App weiter den gestrigen
  /// Wochentag — am Montag sogar die ganze Vorwoche als „diese Woche". Der
  /// Steuerungsteil meldet dafür nichts: Es hat sich keine Messung geändert,
  /// nur das Datum.
  Timer? _tageswechsel;

  @override
  void initState() {
    super.initState();
    _planeTageswechsel();
  }

  @override
  void dispose() {
    _tageswechsel?.cancel();
    super.dispose();
  }

  void _planeTageswechsel() {
    final jetzt = widget.clock();
    final morgen = DateTime(jetzt.year, jetzt.month, jetzt.day + 1);
    _tageswechsel?.cancel();
    // difference() rechnet die echte Spanne — in der Umstellungsnacht sind
    // das 23 oder 25 Stunden, und genau die sollen es sein.
    _tageswechsel = Timer(morgen.difference(jetzt), () {
      if (!mounted) return;
      setState(() {});
      _planeTageswechsel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final messungen = widget.controller.measurements;
        final wochen = messungen.isEmpty
            ? const <MeasurementWeek>[]
            : buildWeeks(messungen);
        final jetzt = widget.clock();
        final montag = mondayOf(jetzt);
        MeasurementWeek? laufende;
        for (final w in wochen) {
          if (w.beginsAt == montag) {
            laufende = w;
            break;
          }
        }

        return Scaffold(
          backgroundColor: t.surface,
          appBar: AppBar(
            title: const Text('Diese Woche'),
            backgroundColor: t.surface,
            foregroundColor: t.onSurface,
            elevation: 0,
          ),
          body: ListView(
            padding: EdgeInsets.all(t.gapLarge),
            children: [
              _Statuszeile(controller: widget.controller),
              SizedBox(height: t.gapLarge),
              if (wochen.isEmpty)
                _NochNichtsGemessen(paired: widget.controller.paired)
              else if (laufende == null)
                _LangePause(
                  controller: widget.controller,
                  letzte: wochen.first,
                  jetzt: jetzt,
                )
              else
                _LaufendeWoche(
                  controller: widget.controller,
                  week: laufende,
                  jetzt: jetzt,
                ),
              ..._hinweise(context),
              SizedBox(height: t.gapLarge),
              _Verweis(
                label: 'Frühere Wochen',
                hint: wochen.isEmpty
                    ? 'noch keine'
                    : '${wochen.length} ${wochen.length == 1 ? "Woche" : "Wochen"}',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SphygmaThemeScope(
                      theme: t,
                      child: EarlierWeeksScreen(controller: widget.controller),
                    ),
                  ),
                ),
              ),
              _Verweis(
                label: 'Gerät und Übertragung',
                hint: widget.controller.pendingExport == 0
                    ? 'alles übertragen'
                    : '${widget.controller.pendingExport} offen',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SphygmaThemeScope(
                      theme: t,
                      child: Scaffold(
                        backgroundColor: t.surface,
                        appBar: AppBar(
                          title: const Text('Gerät und Übertragung'),
                          backgroundColor: t.surface,
                          foregroundColor: t.onSurface,
                          elevation: 0,
                        ),
                        body: DeviceScreen(controller: widget.controller),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _hinweise(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final hinweise = <Widget>[];

    if (!widget.controller.paired) {
      hinweise.add(const NoticeCard(
        title: 'Nicht gekoppelt',
        message: 'Ohne Kopplung kann Sphygma keine Messungen holen. Unter '
            '"Gerät und Übertragung" einrichten.',
      ));
    }

    if (widget.controller.clockLooksWrong) {
      hinweise.add(const NoticeCard(
        title: 'Geräteuhr geht falsch',
        message: 'Einzelne Messungen tragen ein Datum, das nicht stimmen '
            'kann, und fallen damit in die falsche Woche. Sphygma verschiebt '
            'keine Zeiten; stellen lässt sich die Uhr nur am Gerät.',
      ));
    }

    return [
      for (final h in hinweise) ...[SizedBox(height: t.gapLarge), h],
    ];
  }
}

/// Was das Gerät gerade tut — die Meldungen des Steuerungsteils haben in
/// diesem Konzept keinen eigenen Reiter, an dem man sie ablesen könnte.
class _Statuszeile extends StatelessWidget {
  const _Statuszeile({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final c = controller;

    final text = switch ((c.paired, c.autoSyncActive)) {
      (false, _) => 'Nicht gekoppelt',
      (true, true) => 'RS7 gekoppelt · hört auf neue Messungen',
      (true, false) => 'RS7 gekoppelt',
    };

    return Row(
      children: [
        Icon(
          c.paired ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
          size: 14,
          color: t.muted,
        ),
        SizedBox(width: t.gapSmall / 2),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: t.muted),
          ),
        ),
        if (c.busy)
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: t.muted),
          ),
      ],
    );
  }
}

class _LaufendeWoche extends StatelessWidget {
  const _LaufendeWoche({
    required this.controller,
    required this.week,
    required this.jetzt,
  });

  final AppController controller;
  final MeasurementWeek week;
  final DateTime jetzt;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final mittel = week.average;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tag ${jetzt.weekday} von 7 · ${week.measurements.length} '
          '${week.measurements.length == 1 ? "Messung" : "Messungen"} seit Montag',
          style: TextStyle(fontSize: 12, color: t.muted),
        ),
        SizedBox(height: t.gapSmall),
        if (mittel == null)
          Text(
            'Der Wochenwert lässt den ersten Tag aus — ab morgen steht hier '
            'eine Zahl.',
            style: TextStyle(fontSize: 14, color: t.onSurface, height: 1.5),
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
            'Mittel dieser Woche · Puls ${mittel.pulse} · '
            '${TargetRange.heim.classify(systolic: mittel.systolic, diastolic: mittel.diastolic).label}',
            style: TextStyle(fontSize: 12, color: t.muted),
          ),
        ],
        SizedBox(height: t.gapLarge),
        WeekGrid(
          week: week,
          onFieldTap: (feld) {
            if (feld.measurements.isEmpty) return;
            showMeasurementSheet(
              context,
              controller: controller,
              measurementId: feld.measurements.first.id,
            );
          },
        ),
        Text(
          _heuteOffen(week, jetzt),
          style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
        ),
        SizedBox(height: t.gapSmall),
        _ZuletztZeile(controller: controller),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SphygmaThemeScope(
                  theme: t,
                  child: WeekDetailScreen(
                    controller: controller,
                    weekStart: week.beginsAt,
                  ),
                ),
              ),
            ),
            child: const Text('Diese Woche im Detail'),
          ),
        ),
      ],
    );
  }
}

/// Der nächste Schritt, sachlich benannt — der Entwurf belohnt regelmäßiges
/// Messen und macht das Gegenteil sichtbar, soll dabei aber nicht mahnen.
String _heuteOffen(MeasurementWeek week, DateTime jetzt) {
  final morgens =
      week.fieldAt(weekday: jetzt.weekday, band: TimeBand.morgens).isFilled;
  final abends =
      week.fieldAt(weekday: jetzt.weekday, band: TimeBand.abends).isFilled;

  return switch ((morgens, abends)) {
    (true, true) => 'Heute ist morgens und abends gemessen.',
    (true, false) => 'Heute fehlt noch die Abendmessung.',
    (false, true) => 'Heute fehlt noch die Morgenmessung.',
    (false, false) => 'Heute fehlen noch beide Messungen.',
  };
}

class _ZuletztZeile extends StatelessWidget {
  const _ZuletztZeile({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final m = controller.latest;
    if (m == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () => showMeasurementSheet(
        context,
        controller: controller,
        measurementId: m.id,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: t.gapSmall / 2),
        child: Text(
          'Zuletzt ${formatDayAndTime(m.measuredAt)} · '
          '${m.systolic}/${m.diastolic} · Puls ${m.pulse}',
          style: TextStyle(fontSize: 12, color: t.muted),
        ),
      ),
    );
  }
}

/// Kein leeres Diagramm, sondern der Grund und der Weg zurück.
class _LangePause extends StatelessWidget {
  const _LangePause({
    required this.controller,
    required this.letzte,
    required this.jetzt,
  });

  final AppController controller;
  final MeasurementWeek letzte;
  final DateTime jetzt;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final wochen = weekSpan(letzte.beginsAt, mondayOf(jetzt)) - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          wochen == 1
              ? 'Seit einer Woche keine Messung'
              : 'Seit $wochen Wochen keine Messung',
          style: TextStyle(fontSize: 17, color: t.onSurface),
        ),
        SizedBox(height: t.gapSmall),
        Text(
          'Die letzte Woche blieb bei ${letzte.filledFields} von '
          '$fieldsPerWeek Feldern. Sieben Tage morgens und abends ergeben '
          'einen Wert, den die Praxis verwenden kann.',
          style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
        ),
        SizedBox(height: t.gapLarge),
        Text(
          formatWeekRange(letzte.beginsAt),
          style: TextStyle(fontSize: 11, color: t.muted),
        ),
        SizedBox(height: t.gapSmall),
        WeekGrid(week: letzte),
        _ZuletztZeile(controller: controller),
      ],
    );
  }
}

class _NochNichtsGemessen extends StatelessWidget {
  const _NochNichtsGemessen({required this.paired});

  final bool paired;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Noch keine Messwoche',
          style: TextStyle(fontSize: 17, color: t.onSurface),
        ),
        SizedBox(height: t.gapSmall),
        Text(
          paired
              ? 'Miss am Gerät — Sphygma holt die Messung von selbst. Eine '
                  'Woche gilt als vollständig, wenn an sieben Tagen morgens '
                  'und abends gemessen wurde.'
              : 'Zuerst unter "Gerät und Übertragung" koppeln.',
          style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
        ),
      ],
    );
  }
}

class _Verweis extends StatelessWidget {
  const _Verweis({
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: t.gapLarge / 2),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, color: t.onSurface),
              ),
            ),
            Text(hint, style: TextStyle(fontSize: 11, color: t.muted)),
            SizedBox(width: t.gapSmall / 2),
            Icon(Icons.chevron_right, size: 18, color: t.muted),
          ],
        ),
      ),
    );
  }
}
