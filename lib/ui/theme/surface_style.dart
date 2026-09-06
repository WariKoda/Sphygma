// Die dritte Achse: Welche Form die Flächen haben, auf denen Inhalt steht.
//
// Konzept bestimmt, **wie die App organisiert ist**. Gestaltung bestimmt,
// **welche Farben und Maße** sie trägt. Beides sagte bisher nichts darüber,
// ob Inhalt in Karten, auf Bändern oder frei zwischen Haarlinien steht —
// dabei war genau das in den Entwürfen ausgearbeitet und der auffälligste
// Unterschied zwischen ihnen.
//
// Frei kombinierbar mit den anderen beiden Achsen: Die Vorgabe folgt dem
// Entwurf der jeweiligen Handschrift, die Wahl überstimmt sie.

import 'variants.dart';

enum SurfaceStyle {
  /// Keine Flächen. Gegliedert wird durch Haarlinien, Raster und Weißraum.
  /// So zeichnen „Messinstrument" und „Pulse Grid".
  linie(
    'Linie',
    'Keine Flächen. Haarlinien und Weißraum gliedern; nichts hebt sich vom '
        'Grund ab.',
  ),

  /// Abgesetzte Flächen mit Radius und Abstand. So zeichnen „Tagebuch",
  /// „Material 3" und „Aura".
  karte(
    'Karte',
    'Inhalt steht auf abgesetzten Flächen mit runden Ecken und Abstand '
        'dazwischen.',
  ),

  /// Ganzflächige Bänder ohne Rand, Radius oder Abstand. Ein Abschnitt endet,
  /// wo die Fläche ihren Ton wechselt. So zeichnet „Pegel".
  band(
    'Band',
    'Ganzflächige Streifen ohne Abstand. Ein Abschnitt endet, wo die Fläche '
        'ihren Ton wechselt.',
  );

  const SurfaceStyle(this.label, this.description);

  final String label;
  final String description;
}

const List<SurfaceStyle> allSurfaceStyles = SurfaceStyle.values;

/// Die Form, die der Entwurf für diese Handschrift vorsieht.
///
/// Sie ist die Vorgabe, nicht die Vorschrift: Die dritte Achse darf jede
/// Handschrift in jeder Form zeigen. Wer nichts wählt, bekommt aber das, was
/// gezeichnet wurde.
SurfaceStyle defaultSurfaceFor(ThemeVariant variant) => switch (variant) {
      // „Keine Flächen, keine Schatten, kein Radius über 3 px."
      ThemeVariant.instrument => SurfaceStyle.linie,
      // „Weiße Karten auf blaugrauem Grund, Radius 16–22 px, weicher Schatten."
      ThemeVariant.diary => SurfaceStyle.karte,
      // „Karten in Sekundär- und Oberflächenfarbe, Radius 12 px, kein Schatten."
      ThemeVariant.material => SurfaceStyle.karte,
      // „Flächen heben sich um eine Tonstufe vom Grund ab."
      ThemeVariant.aura => SurfaceStyle.karte,
      // „Fast keine Flächen. Gegliedert wird durch Spalten und Weißraum."
      ThemeVariant.pulseGrid => SurfaceStyle.linie,
      // „Ganzflächige Bänder ohne Rand, Schatten, Radius oder Abstand."
      ThemeVariant.pegel => SurfaceStyle.band,
    };
