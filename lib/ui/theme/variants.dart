// Die Diagonale bleibt für bestehende Aufrufer; freie Gestaltungen entstehen
// ausschließlich aus Form, Farbe und Schrift.
import 'package:flutter/widgets.dart';

import 'characteristic.dart';
import 'palette.dart';
import 'sphygma_theme.dart';
import 'typeface.dart';

export 'characteristic.dart';
export 'palette.dart';
export 'typeface.dart';

enum ThemeVariant { instrument, diary, material, aura, pulseGrid, pegel }

const List<ThemeVariant> allVariants = ThemeVariant.values;

typedef ThemeAxes = ({
  Characteristic characteristic,
  Palette palette,
  Typeface typeface,
});

ThemeAxes axesFor(ThemeVariant variant) => switch (variant) {
  ThemeVariant.instrument => (
    characteristic: Characteristic.messinstrument,
    palette: Palette.papier,
    typeface: Typeface.system,
  ),
  ThemeVariant.diary => (
    characteristic: Characteristic.tagebuch,
    palette: Palette.himmel,
    typeface: Typeface.system,
  ),
  ThemeVariant.material => (
    characteristic: Characteristic.material,
    palette: Palette.flieder,
    typeface: Typeface.system,
  ),
  ThemeVariant.aura => (
    characteristic: Characteristic.luft,
    palette: Palette.nacht,
    typeface: Typeface.system,
  ),
  ThemeVariant.pulseGrid => (
    characteristic: Characteristic.raster,
    palette: Palette.papier,
    typeface: Typeface.system,
  ),
  ThemeVariant.pegel => (
    characteristic: Characteristic.band,
    palette: Palette.papier,
    typeface: Typeface.system,
  ),
};

/// Das alte Auswahlblatt kennt nur die Form der Diagonale. Eine freie
/// Farbkombination lässt sich darin nicht ausdrücken.
ThemeVariant variantFor(Characteristic characteristic) =>
    switch (characteristic) {
      Characteristic.messinstrument => ThemeVariant.instrument,
      Characteristic.tagebuch => ThemeVariant.diary,
      Characteristic.material => ThemeVariant.material,
      Characteristic.luft => ThemeVariant.aura,
      Characteristic.raster => ThemeVariant.pulseGrid,
      Characteristic.band => ThemeVariant.pegel,
    };

SphygmaTheme themeFor(ThemeVariant variant) {
  final axes = axesFor(variant);
  return themeFrom(
    characteristic: axes.characteristic,
    palette: axes.palette,
    typeface: axes.typeface,
  );
}

SphygmaTheme themeFrom({
  required Characteristic characteristic,
  required Palette palette,
  required Typeface typeface,
}) {
  final font = typefaceStyleFor(typeface);
  return SphygmaTheme(
    name: characteristic.label,
    surface: palette.grund,
    onSurface: palette.onSurface,
    muted: palette.muted,
    line: palette.line,
    accent: characteristic.nutztAkzent ? palette.accent : palette.onSurface,
    categoryColors: switch (characteristic.categoryRole) {
      CategoryRole.markierung => palette.markierung,
      CategoryRole.flaeche => palette.categoryFlaeche,
    },
    radius: characteristic.radius,
    gapSmall: characteristic.gapSmall,
    gapLarge: characteristic.gapLarge,
    headlineSize: characteristic.headlineSize,
    headlineWeight: font.weightFor(characteristic.headlineWeight),
    fontFamily: font.fontFamily,
    readingLayout: characteristic.readingLayout,
    zoneDisplay: characteristic.zoneDisplay,
    statsLayout: characteristic.statsLayout,
    selectionStyle: characteristic.selectionStyle,
    showDividers: characteristic.showDividers,
    panelBase: palette.flaeche,
    panelRaised: palette.flaecheGehoben,
    panelBorder: characteristic.hatKante ? palette.line : null,
    panelShadow: characteristic.erhebung == 0
        ? null
        : [
            BoxShadow(
              color: palette.shadow,
              blurRadius: characteristic.erhebung * 2.5,
              offset: Offset(0, characteristic.erhebung),
            ),
          ],
  );
}
