// Die Schriftachse: Jede Familie muss tragen, was Sphygma von ihr verlangt.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/theme/typeface.dart';

void main() {
  test('jede Schrift führt tabellarische Ziffern', () {
    // Ohne sie springen Messwerte in Listen — bei einem Blutdrucktagebuch
    // ist das kein Schönheitsfehler, sondern erschwert den Vergleich von
    // Spalten. IBM Plex Sans war als dritte Familie vorgesehen und ist am
    // 09.09.2026 genau daran gescheitert; geprüft wurde an der Schriftdatei
    // mit fonttools, nicht an einer Beschreibung.
    for (final t in Typeface.values) {
      expect(
        typefaceStyleFor(t).hasTabularFigures,
        isTrue,
        reason: '${t.name} führt keine tabellarischen Ziffern',
      );
    }
  });

  test('jede Rolle findet einen Schnitt', () {
    for (final t in Typeface.values) {
      final stil = typefaceStyleFor(t);
      for (final rolle in WeightRole.values) {
        expect(
          stil.availableWeights,
          contains(stil.weightFor(rolle)),
          reason: '${t.name} bildet ${rolle.name} auf keinen echten Schnitt ab',
        );
      }
    }
  });

  test('eine Schrift ohne tabellarische Ziffern wird abgewiesen', () {
    // Fail hard: Die Bedingung steht im Konstruktor, nicht in einem Kommentar.
    expect(
      () => TypefaceStyle(
        fontFamily: 'Erfunden',
        availableWeights: {FontWeight.w400},
        hasTabularFigures: false,
      ),
      throwsArgumentError,
    );
  });

  test('nur System bleibt ohne eigene Familie', () {
    // Die Systemschrift bettet nichts ein — sie ist der Standard und kostet
    // keine Paketgröße. Jede andere Achse nennt ihre Familie ausdrücklich.
    expect(typefaceStyleFor(Typeface.system).fontFamily, isNull);
    for (final t in Typeface.values.where((t) => t != Typeface.system)) {
      expect(typefaceStyleFor(t).fontFamily, isNotNull, reason: t.name);
    }
  });
}
