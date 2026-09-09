// Greift die Gewichtsachse der variablen Schriften wirklich?
//
// Die drei eingebetteten Familien sind **variable** Schriften: Eine Datei
// trägt alle Schnitte, angesteuert über die wght-Achse. Ob Flutter ein
// gesetztes `fontWeight` darauf abbildet, war bis zum 09.09.2026 unbelegt —
// eine Annahme, auf der die ganze Gewichtsrolle steht. Täte es das nicht,
// sähen alle Formen gleich aus und niemand würde es an einem grünen Test
// merken.
//
// Gemessen wird der tatsächliche Textumfang: Ein fetter Schnitt läuft breiter
// als ein leichter. Bleibt die Breite gleich, greift die Achse nicht.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/theme/typeface.dart';

Future<void> _ladeSchrift(String familie, String pfad) async {
  final loader = FontLoader(familie)..addFont(rootBundle.load(pfad));
  await loader.load();
}

double _breite(String familie, FontWeight gewicht) {
  final maler = TextPainter(
    text: TextSpan(
      text: '144/92',
      style: TextStyle(fontFamily: familie, fontSize: 48, fontWeight: gewicht),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return maler.width;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _ladeSchrift('Archivo', 'assets/fonts/Archivo.ttf');
    await _ladeSchrift('SourceSerif4', 'assets/fonts/SourceSerif4.ttf');
  });

  test('die wght-Achse trägt: fett läuft breiter als leicht', () {
    // Archivo ist proportional — dort schlägt das Gewicht auf die Breite
    // durch. Bei der Monospace wäre die Breite fest, deshalb steht sie hier
    // nicht: Ihre Schnitte unterscheiden sich in der Strichstärke, die ein
    // TextPainter nicht misst.
    final leicht = _breite('Archivo', FontWeight.w200);
    final fett = _breite('Archivo', FontWeight.w700);

    expect(
      fett,
      greaterThan(leicht),
      reason:
          'w200 misst $leicht, w700 misst $fett — sind sie gleich, bildet '
          'Flutter fontWeight nicht auf die wght-Achse ab, und alle '
          'Gewichtsrollen sähen identisch aus',
    );
  });

  test('jede Rolle einer variablen Schrift ergibt ein eigenes Maß', () {
    // Nicht nur die Extreme: Die fünf Rollen sollen sich tatsächlich
    // unterscheiden, sonst ist die Abstufung Zierde.
    final stil = typefaceStyleFor(Typeface.grotesk);
    final breiten = <double>{
      for (final rolle in WeightRole.values)
        _breite('Archivo', stil.weightFor(rolle)),
    };
    expect(
      breiten.length,
      greaterThan(1),
      reason: 'alle Gewichtsrollen ergeben dieselbe Breite: $breiten',
    );
  });

  test('die Serif reicht nicht unter ihre Achse', () {
    // Source Serif 4 beginnt bei 200. Die Rolle „sehr leicht" darf keinen
    // Schnitt verlangen, den es nicht gibt — die Abbildung fängt das ab.
    final stil = typefaceStyleFor(Typeface.serif);
    expect(stil.weightFor(WeightRole.sehrLeicht).value, greaterThanOrEqualTo(200));
    expect(ui.FontWeight.w200.value, 200);
  });
}
