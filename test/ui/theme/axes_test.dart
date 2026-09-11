import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/esc_classification.dart';
import 'package:sphygma/ui/theme/variants.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

void main() {
  test('die Diagonale bewahrt Form, Farbwelt und Gewichte', () {
    // Der Name eines komponierten Themes ist der **Formname**, nicht der der
    // alten Gestaltung: Seit dem 09.09.2026 heißt die Form von „Aura" Luft,
    // die von „Pulse Grid" Raster, die von „Pegel" Band. Sichtbar ist der
    // Name ohnehin nirgends mehr — er steht nur noch in einer Fehlermeldung
    // in zone_color.dart.
    const characteristics = Characteristic.values;
    const palettes = [
      Palette.papier,
      Palette.himmel,
      Palette.flieder,
      Palette.nacht,
      Palette.papier,
      Palette.papier,
    ];
    const names = [
      'Messinstrument',
      'Tagebuch',
      'Material',
      'Luft',
      'Raster',
      'Band',
    ];
    const weights = [
      FontWeight.w300,
      FontWeight.w700,
      FontWeight.w400,
      FontWeight.w200,
      FontWeight.w400,
      FontWeight.w500,
    ];
    const radii = [3.0, 18.0, 12.0, 18.0, 2.0, 0.0];
    // Die Diagonale steht auf den vier Farbwelten, aus denen die alten
    // Gestaltungen stammen. Wie viele daneben zur Wahl stehen, ist offen —
    // am 09.09.2026 kamen die beiden Okabe-Ito-Welten dazu.
    expect(Palette.values.length, greaterThanOrEqualTo(4));
    // Die Diagonale steht auf der Systemschrift: Sie soll die alten
    // Gestaltungen reproduzieren, und die hatten keine eigene Familie.
    // Welche Schriften daneben zur Wahl stehen, prüft typeface_test.
    expect(Typeface.values, contains(Typeface.system));
    for (var i = 0; i < allVariants.length; i++) {
      final old = themeFor(allVariants[i]);
      final composed = themeFrom(
        characteristic: characteristics[i],
        palette: palettes[i],
        typeface: Typeface.system,
      );
      expect(old.name, names[i]);
      expect(old.radius, radii[i]);
      expect(old.headlineWeight, weights[i]);
      expect(old.surface, composed.surface);
      expect(old.accent, composed.accent);
      expect(old.panelBase, composed.panelBase);
      expect(old.categoryColors, composed.categoryColors);
    }
  });

  for (final palette in Palette.values) {
    test('Luft bekommt fertige Flächen von $palette', () {
      final air = themeFrom(
        characteristic: Characteristic.luft,
        palette: palette,
        typeface: Typeface.system,
      );
      final card = themeFrom(
        characteristic: Characteristic.material,
        palette: palette,
        typeface: Typeface.system,
      );
      expect(air.panelBase, card.panelBase);
      expect(air.panelRaised, card.panelRaised);
      expect(air.panelBase, isNot(air.surface));
      expect(air.panelBase, isNot(air.panelRaised));
      expect(air.showDividers, isFalse);
      expect(air.panelBorder, air.line);
    });
    test('Messinstrument unterdrückt nur den Akzent von $palette', () {
      final instrument = themeFrom(
        characteristic: Characteristic.messinstrument,
        palette: palette,
        typeface: Typeface.system,
      );
      final diary = themeFrom(
        characteristic: Characteristic.tagebuch,
        palette: palette,
        typeface: Typeface.system,
      );
      expect(instrument.accent, instrument.onSurface);
      expect(diary.accent, isNot(diary.onSurface));
      expect(instrument.categoryColors, diary.categoryColors);
      expect(instrument.panelShadow, isNull);
      expect(diary.panelShadow, isNotEmpty);
    });
    test('Band auf $palette hat lesbare Kategorienflächen', () {
      final band = themeFrom(
        characteristic: Characteristic.band,
        palette: palette,
        typeface: Typeface.system,
      );
      final marks = themeFrom(
        characteristic: Characteristic.raster,
        palette: palette,
        typeface: Typeface.system,
      );
      for (final category in EscCategory.values) {
        final fill = band.categoryColors[category]!;
        expect(fill, isNot(marks.categoryColors[category]));
        expect(contrast(band.onSurface, fill), greaterThanOrEqualTo(4.5));
      }
      for (final surface in [band.surface, band.panelBase, band.panelRaised]) {
        expect(contrast(band.onSurface, surface), greaterThanOrEqualTo(4.5));
      }
    });
  }

  test('eine Schrift ohne ExtraLight ordnet sehrLeicht ausdrücklich zu', () {
    final font = TypefaceStyle(
      fontFamily: 'Prüfschrift',
      availableWeights: {FontWeight.w400, FontWeight.w700},
      hasTabularFigures: true,
    );
    expect(font.weightFor(WeightRole.sehrLeicht), FontWeight.w400);
    expect(font.weightFor(WeightRole.fett), FontWeight.w700);
    for (final role in WeightRole.values) {
      expect(font.availableWeights, contains(font.weightFor(role)));
    }
  });
  test('Schrift ohne Schnitte oder tabellarische Ziffern ist ungültig', () {
    expect(
      () => TypefaceStyle(
        fontFamily: 'Leer',
        availableWeights: {},
        hasTabularFigures: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => TypefaceStyle(
        fontFamily: 'Proportional',
        availableWeights: {FontWeight.w400},
        hasTabularFigures: false,
      ),
      throwsArgumentError,
    );
    expect(typefaceStyleFor(Typeface.system).hasTabularFigures, isTrue);
  });

  test('kein Formname trägt den Namen einer alten Gestaltung', () {
    // Bis zum 09.09.2026 hießen drei Formen noch „Aura", „Pulse Grid" und
    // „Pegel" — die Namen ganzer Gestaltungen, die in Form und Farbwelt
    // zerfallen sind. Im Auswahlfeld versprach das eine Farbwelt, die die
    // Form nicht liefert; zwei davon gibt es überhaupt nicht mehr.
    const zerfallen = {'Aura', 'Pulse Grid', 'Pegel'};
    for (final c in Characteristic.values) {
      expect(
        zerfallen.contains(c.label),
        isFalse,
        reason:
            '${c.name} heißt „${c.label}" — das ist eine Gestaltung, '
            'keine Form',
      );
    }
  });
}
