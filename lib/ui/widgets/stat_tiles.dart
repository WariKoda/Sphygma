// Kennzahlen — untereinander als Zeilen oder nebeneinander als Karten.
//
// Welche der beiden Anordnungen gilt, entscheidet die Form: „Tagebuch" legt
// sie nebeneinander, alle übrigen untereinander. Der Baustein trifft die
// Entscheidung, nicht der Bildschirm — sonst müsste der Verlauf nach der
// Charakteristik verzweigen.
//
// Nebeneinander taugt nur für **wenige** Zahlen. Deshalb nimmt der Baustein
// die Anordnung nicht blind: Ab einer Handvoll Einträgen bleibt er bei
// Zeilen, weil Karten dann schmaler würden als ihr Inhalt.
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

/// Ab wie vielen Einträgen Karten nicht mehr taugen.
///
/// Vier Karten nebeneinander sind auf einem Telefon schon eng; bei fünf
/// Tagesabschnitten plus Gesamtwert bliebe je Karte kaum mehr Platz als für
/// die Zahl. Dann sind Zeilen die ehrlichere Anordnung — auch für „Tagebuch".
const int maxKarten = 4;

class StatTiles extends StatelessWidget {
  const StatTiles({super.key, required this.stats});

  final List<Stat> stats;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final alsKarten =
        t.statsLayout == StatsLayout.karten && stats.length <= maxKarten;

    if (!alsKarten) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(stat.label, style: TextStyle(fontSize: 13, color: t.muted)),
          Flexible(
            child: Text(
              stat.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: t.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
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
        color: t.panel(0),
        borderRadius: BorderRadius.circular(t.chipRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: t.headlineWeight,
              color: t.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: t.gapSmall / 2),
          Text(stat.label, style: TextStyle(fontSize: 10, color: t.muted)),
        ],
      ),
    );
  }
}
