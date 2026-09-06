// Die Fläche, auf der Inhalt steht — in der Form, die die dritte Achse setzt.
//
// Alle Bildschirme wickeln ihre Abschnitte hierin ein, statt selbst Container
// zu bauen. Nur so kann die Flächenform eine Achse sein: Eine Entscheidung an
// einer Stelle, nicht dreißig verstreute Container, die man einzeln nachziehen
// müsste.
import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';
import '../theme/surface_style.dart';

class SurfacePanel extends StatelessWidget {
  const SurfacePanel({
    super.key,
    required this.child,
    this.tone = 0,
    this.padding,
  });

  final Widget child;

  /// Tonstufe der Fläche: 0 die Grundfläche, 1 eine Stufe abgesetzt.
  ///
  /// „Aura" braucht zwei Stufen (4,5 % und 2,5 % Weiß), „Pegel" wechselt den
  /// Ton, um einen Abschnitt zu beenden. Bei [SurfaceStyle.linie] bleibt die
  /// Stufe folgenlos — dort gibt es keine Flächen, die sich abheben könnten.
  final int tone;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return switch (t.surfaceStyle) {
      // Keine Fläche: Der Inhalt steht auf dem Grund, gegliedert wird durch
      // Haarlinien und Weißraum.
      SurfaceStyle.linie => Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),

      // Abgesetzte Fläche mit Radius und Abstand nach unten.
      SurfaceStyle.karte => Container(
          margin: EdgeInsets.only(bottom: t.gapSmall),
          padding: padding ?? EdgeInsets.all(t.gapLarge * 0.7),
          decoration: BoxDecoration(
            color: t.panel(tone),
            borderRadius: BorderRadius.circular(t.radius),
            border: t.panelBorder == null
                ? null
                : Border.all(color: t.panelBorder!),
            boxShadow: t.panelShadow,
          ),
          child: child,
        ),

      // Ganzflächiges Band: kein Radius, kein Rand, kein Abstand. Der
      // Tonwechsel ist die Zäsur.
      SurfaceStyle.band => Container(
          width: double.infinity,
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: t.gapLarge,
                vertical: t.gapLarge * 0.7,
              ),
          color: t.panel(tone),
          child: child,
        ),
    };
  }
}
