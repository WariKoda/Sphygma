// Kennzahlen — untereinander als Zeilen oder nebeneinander als Karten.
//
// Welche der beiden Anordnungen gilt, entscheidet die Form: „Tagebuch" legt
// sie nebeneinander, alle übrigen untereinander. Der Baustein trifft die
// Entscheidung, nicht der Bildschirm — sonst müsste der Verlauf nach der
// Charakteristik verzweigen.
//
// Nebeneinander taugt nur, solange **jede Karte breiter bleibt als ihr
// Inhalt**. Ob das so ist, hängt an drei Dingen: wie viele Einträge es gibt,
// wie breit der Schirm ist und wie groß der Nutzer die Schrift gestellt hat.
//
// Eine feste Obergrenze an Einträgen reicht dafür nicht — sie war der erste
// Versuch und ist am 09.09.2026 im Codex-Gegenblick gefallen: Vier Karten auf
// 360 Pixeln bei doppelter Schriftgröße brechen die Messwerte mitten
// auseinander. Deshalb rechnet der Baustein die Kartenbreite aus und fällt
// auf Zeilen zurück, wenn sie nicht reicht.
import 'package:flutter/material.dart';

import '../theme/characteristic.dart';
import '../theme/sphygma_theme.dart';

/// Eine Kennzahl: Beschriftung und Wert.
@immutable
class Stat {
  const Stat({required this.label, required this.value});

  final String label;

  /// Bereits formatiert. Ein Strich steht für „hier gab es keine Messung" —
  /// die Entscheidung darüber trifft der Aufrufer, nicht dieser Baustein.
  final String value;
}

/// Wie viele Zeichen ein Messwert breit ist: „144/92 · 89".
///
/// Die längste Form, die vorkommt — dreistellig, zweistellig, zweistellig.
/// Kürzere Werte passen erst recht.
const int _zeichenProWert = 12;

/// Der Faktor von Schriftgröße auf Zeichenbreite bei tabellarischen Ziffern.
///
/// Grob, aber in die sichere Richtung: Ziffern laufen schmaler als das
/// Gemittel einer Schrift, und wer zu früh auf Zeilen fällt, verliert nur
/// eine Anordnung — wer zu spät fällt, zerbricht die Zahlen.
const double _breiteJeZeichen = 0.62;

/// Ab wie vielen Einträgen Karten in keinem Fall mehr taugen.
///
/// Auch auf einem breiten Schirm: Sechs Karten nebeneinander sind keine
/// Übersicht mehr, sondern ein Streifen.
const int maxKarten = 4;

class StatTiles extends StatelessWidget {
  const StatTiles({super.key, required this.stats});

  final List<Stat> stats;

  /// Ob die Karten bei dieser Breite und Schriftgröße noch tragen.
  bool _tragen(BuildContext context, double breite, SphygmaTheme t) {
    if (t.statsLayout != StatsLayout.karten) return false;
    if (stats.isEmpty || stats.length > maxKarten) return false;

    // Was einer Karte an Inhalt bleibt: die Gesamtbreite ohne die Lücken
    // dazwischen und ohne das Polster in jeder Karte.
    final luecken = t.gapSmall * (stats.length - 1);
    final polster = t.gapSmall * 2 * stats.length;
    final jeKarte = (breite - luecken - polster) / stats.length;

    // Was der Inhalt braucht: die Zahl in der Schriftgröße, die der Nutzer
    // eingestellt hat.
    final schrift = MediaQuery.textScalerOf(context).scale(18);
    final noetig = _zeichenProWert * schrift * _breiteJeZeichen;

    return jeKarte >= noetig;
  }

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_tragen(context, constraints.maxWidth, t)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final s in stats) _Zeile(stat: s)],
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: t.gapSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in stats) ...[
                if (s != stats.first) SizedBox(width: t.gapSmall),
                Expanded(child: _Karte(stat: s)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({required this.stat});

  final Stat stat;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.gapSmall),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final label = Text(
            stat.label,
            style: TextStyle(fontSize: 14, color: t.muted),
          );
          final value = Text(
            stat.value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: t.headlineWeight,
              color: t.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          );
          if (constraints.maxWidth <
              MediaQuery.textScalerOf(context).scale(320)) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label,
                SizedBox(height: t.gapSmall / 2),
                value,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: label),
              SizedBox(width: t.gapSmall),
              Flexible(child: value),
            ],
          );
        },
      ),
    );
  }
}

class _Karte extends StatelessWidget {
  const _Karte({required this.stat});

  final Stat stat;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Container(
      padding: EdgeInsets.all(t.gapSmall),
      decoration: BoxDecoration(
        color: t.panel(1),
        borderRadius: BorderRadius.circular(t.chipRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: t.headlineWeight,
              color: t.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: t.gapSmall / 2),
          Text(stat.label, style: TextStyle(fontSize: 13, color: t.muted)),
        ],
      ),
    );
  }
}
