// Jede Form trägt ihr Aufbau-Merkmal — und nur sie.
//
// Das ist der Kern des Umbaus vom 08./09.09.2026: Bis dahin unterschieden
// sich die sechs Formen nur in Radius, Abstand und Gewicht, und genau deshalb
// sahen vier von ihnen gleich aus. Dieser Test hält fest, welche Form welches
// Merkmal trägt — und dass die übrigen es nicht tun.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/stat_tiles.dart';

void main() {
  test('genau eine Form trägt jedes Merkmal', () {
    Iterable<Characteristic> mit(bool Function(Characteristic) hat) =>
        Characteristic.values.where(hat);

    expect(
      mit((c) => c.readingLayout == ReadingLayout.bloecke),
      [Characteristic.raster],
      reason: 'getrennte SYS/DIA-Blöcke gehören zu Raster',
    );
    expect(
      mit((c) => c.zoneDisplay == ZoneDisplay.flaeche),
      [Characteristic.band],
      reason: 'die eingefärbte Kopffläche gehört zu Band',
    );
    expect(
      mit((c) => c.statsLayout == StatsLayout.karten),
      [Characteristic.tagebuch],
      reason: 'Kennzahlen als Karten gehören zu Tagebuch',
    );
    expect(
      mit((c) => c.selectionStyle == SelectionStyle.chips),
      [Characteristic.material],
      reason: 'Chips gehören zu Material',
    );
  });

  test('jede Form unterscheidet sich von jeder anderen im Aufbau', () {
    // Der eigentliche Prüfstein: Zwei Formen, die in **allen**
    // Aufbau-Merkmalen übereinstimmen, sind nur noch andere Zahlen — und
    // damit genau das Problem, das dieser Umbau beheben sollte.
    //
    // Messinstrument und Luft trennen sich über `showDividers`: Der eine
    // gliedert mit Haarlinien, der andere mit Luft. Das ist Aufbau, kein Maß.
    String signatur(Characteristic c) =>
        '${c.readingLayout}|${c.zoneDisplay}|${c.statsLayout}|'
        '${c.selectionStyle}|${c.showDividers}|${c.hatKante}|'
        '${c.nutztAkzent}|${c.categoryRole}';

    final signaturen = <String, Characteristic>{};
    for (final c in Characteristic.values) {
      final s = signatur(c);
      expect(
        signaturen[s],
        isNull,
        reason:
            '${c.name} und ${signaturen[s]?.name} haben denselben Aufbau — '
            'sie unterscheiden sich nur noch in Zahlen',
      );
      signaturen[s] = c;
    }
  });

  testWidgets('Material zeigt Chips, die übrigen eine Leiste', (tester) async {
    // Geprüft am Baustein, nicht am ganzen Bildschirm: Die Bauform ist eine
    // Eigenschaft der Auswahl, nicht des Verlaufs.
    expect(
      themeFrom(
        characteristic: Characteristic.material,
        palette: Palette.flieder,
        typeface: Typeface.system,
      ).selectionStyle,
      SelectionStyle.chips,
    );
    expect(
      themeFrom(
        characteristic: Characteristic.messinstrument,
        palette: Palette.papier,
        typeface: Typeface.system,
      ).selectionStyle,
      SelectionStyle.leiste,
    );
  });

  testWidgets('Karten weichen Zeilen, wenn die Breite nicht reicht', (
    tester,
  ) async {
    // Nebeneinander taugt nur, solange jede Karte breiter bleibt als ihr
    // Inhalt. Eine feste Obergrenze an Einträgen reichte dafür nicht: Vier
    // Karten auf 360 Pixeln bei doppelter Schriftgröße brechen die Messwerte
    // mitten auseinander (Codex-Gegenblick 09.09.2026).
    Future<void> zeige({
      required int anzahl,
      required double breite,
      required double schrift,
    }) => tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(schrift)),
          child: SphygmaThemeScope(
            theme: themeFrom(
              characteristic: Characteristic.tagebuch,
              palette: Palette.himmel,
              typeface: Typeface.system,
            ),
            child: Scaffold(
              body: SizedBox(
                width: breite,
                child: StatTiles(
                  stats: [
                    for (var i = 0; i < anzahl; i++)
                      Stat(label: 'Wert $i', value: '14$i/9$i · 8$i'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    int karten() => tester.widgetList(find.byType(Expanded)).length;

    await zeige(anzahl: 2, breite: 400, schrift: 1.0);
    expect(karten(), 2, reason: 'zwei Zahlen auf breitem Schirm: Karten');

    await zeige(anzahl: 4, breite: 360, schrift: 2.0);
    expect(
      karten(),
      0,
      reason: 'vier Karten auf 360 Pixeln bei doppelter Schrift wären '
          'schmaler als ihr Inhalt — dann sind Zeilen richtig',
    );

    await zeige(anzahl: maxKarten + 1, breite: 1200, schrift: 1.0);
    expect(
      karten(),
      0,
      reason: 'auch auf breitem Schirm sind fünf Karten kein Überblick mehr',
    );
  });
}
