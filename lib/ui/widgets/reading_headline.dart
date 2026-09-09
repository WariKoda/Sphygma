// Die grosse Wertdarstellung. Steht auf "Heute" und im Detail-Blatt.
//
// **Der Baustein kennt die Bauform, nicht der Bildschirm.** Die Form „Raster"
// zeigt SYS und DIA als zwei gleichwertige Blöcke statt als Bruch — der
// Entwurf verlangt es ausdrücklich. Diese Entscheidung hier zu treffen hält
// die Bildschirme frei: „Heute" und das Detail-Blatt rufen weiterhin
// denselben Baustein und wissen nichts von Charakteristiken.
import 'package:flutter/material.dart';

import '../theme/characteristic.dart';
import '../theme/sphygma_theme.dart';

class ReadingHeadline extends StatelessWidget {
  const ReadingHeadline({
    super.key,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.measuredAt,
  });

  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime measuredAt;

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final zeit =
        '${_twoDigits(measuredAt.day)}.'
        '${_twoDigits(measuredAt.month)}.${measuredAt.year}, '
        '${_twoDigits(measuredAt.hour)}:${_twoDigits(measuredAt.minute)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          zeit,
          style: TextStyle(fontSize: 11, letterSpacing: 1.4, color: t.muted),
        ),
        SizedBox(height: t.gapSmall),
        switch (t.readingLayout) {
          ReadingLayout.bruch => _Bruch(
            systolic: systolic,
            diastolic: diastolic,
          ),
          ReadingLayout.bloecke => _Bloecke(
            systolic: systolic,
            diastolic: diastolic,
          ),
        },
        SizedBox(height: t.gapSmall / 2),
        Text(
          'mmHg · Puls $pulse',
          style: TextStyle(fontSize: 12, color: t.muted),
        ),
      ],
    );
  }
}

/// „144/92" — der gewachsene Aufbau, und der Standard.
class _Bruch extends StatelessWidget {
  const _Bruch({required this.systolic, required this.diastolic});

  final int systolic;
  final int diastolic;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Text(
      '$systolic/$diastolic',
      style: TextStyle(
        fontSize: t.headlineSize,
        height: 1,
        fontWeight: t.headlineWeight,
        letterSpacing: -1.5,
        color: t.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Zwei gleichwertige Blöcke mit Beschriftung darunter.
///
/// Der Bruch stellt den systolischen Wert voran und macht ihn damit zur
/// Hauptzahl. Nebeneinander sind beide gleich wichtig — was der Sache näher
/// kommt: Für die Einordnung zählt der **höhere** der beiden Werte, nicht der
/// erste.
class _Bloecke extends StatelessWidget {
  const _Bloecke({required this.systolic, required this.diastolic});

  final int systolic;
  final int diastolic;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Block(wert: systolic, kuerzel: 'SYS'),
        SizedBox(width: t.gapLarge),
        _Block(wert: diastolic, kuerzel: 'DIA'),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.wert, required this.kuerzel});

  final int wert;
  final String kuerzel;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$wert',
          style: TextStyle(
            // Etwas kleiner als der Bruch: Zwei Zahlen nebeneinander
            // brauchen mehr Breite als eine mit Schrägstrich.
            fontSize: t.headlineSize * 0.82,
            height: 1,
            fontWeight: t.headlineWeight,
            letterSpacing: -1.5,
            color: t.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(height: t.gapSmall / 2),
        Text(
          kuerzel,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.6,
            color: t.muted,
          ),
        ),
      ],
    );
  }
}
