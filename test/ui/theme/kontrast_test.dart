// Trägt der Text auf jeder Fläche, die eine Farbwelt anbietet?
//
// Die Tonleiter der Einordnung ist keine Zierde — sie trägt Bedeutung. Die
// Form „Band" färbt damit die **Kopffläche selbst**, und darauf steht der
// Messwert. Ob er dort lesbar bleibt, lässt sich rechnen, statt es am Gerät
// zu beurteilen: über den Kontrast nach WCAG 2.
//
// Anlass war die Aufnahme der Okabe-Ito-Farbwelten am 09.09.2026. Ihr Gelb
// (#F0E442) ist der hellste Ton der ganzen App; wäre irgendwo heller Text
// darauf gelandet, hätte es niemand gemerkt, bevor jemand mit dieser Farbwelt
// eine grenzwertige Messung anschaut.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/esc_classification.dart';
import 'package:sphygma/ui/theme/variants.dart';

/// Relative Luminanz nach WCAG 2, Definition von `relativeLuminance`.
double _luminanz(Color c) {
  double kanal(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * kanal(c.r) + 0.7152 * kanal(c.g) + 0.0722 * kanal(c.b);
}

/// Das Kontrastverhältnis zweier Farben — zwischen 1 (gleich) und 21.
double _kontrast(Color a, Color b) {
  final la = _luminanz(a);
  final lb = _luminanz(b);
  final hell = math.max(la, lb);
  final dunkel = math.min(la, lb);
  return (hell + 0.05) / (dunkel + 0.05);
}

void main() {
  test('Text trägt auf jeder Grundfläche jeder Farbwelt', () {
    for (final p in Palette.values) {
      for (final flaeche in [p.grund, p.flaeche, p.flaecheGehoben]) {
        expect(
          _kontrast(p.onSurface, flaeche),
          greaterThanOrEqualTo(4.5),
          reason:
              '${p.name}: Text auf einer Fläche unter WCAG AA '
              '(${_kontrast(p.onSurface, flaeche).toStringAsFixed(1)}:1)',
        );
      }
    }
  });

  test('Text trägt auf jeder eingefärbten Kopffläche', () {
    // Die Form „Band" nimmt die **Flächenrolle** der Kategorienfarbe: 18 %
    // Markierung im eigenen Grund. Sie muss den Messwert tragen — in jeder
    // Farbwelt und in jeder Stufe der Leiter.
    for (final p in Palette.values) {
      for (final stufe in EscCategory.values) {
        final flaeche = p.categoryFlaeche[stufe]!;
        expect(
          _kontrast(p.onSurface, flaeche),
          greaterThanOrEqualTo(4.5),
          reason:
              '${p.name}, Stufe ${stufe.name}: der Messwert auf der '
              'eingefärbten Kopffläche liegt unter WCAG AA '
              '(${_kontrast(p.onSurface, flaeche).toStringAsFixed(1)}:1)',
        );
      }
    }
  });

  test('der Nebentext trägt noch', () {
    // Nebensächliches darf blasser sein, aber nicht unlesbar: WCAG AA für
    // großen Text ist 3:1, und darunter geht Einheiten- und Zeitangabe unter.
    for (final p in Palette.values) {
      expect(
        _kontrast(p.muted, p.flaeche),
        greaterThanOrEqualTo(3.0),
        reason:
            '${p.name}: der Nebentext liegt bei '
            '${_kontrast(p.muted, p.flaeche).toStringAsFixed(1)}:1',
      );
    }
  });
}
