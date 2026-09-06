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
    this.highlighted = false,
  });

  final Widget child;

  /// Tonstufe der Fläche: 0 die Grundfläche, 1 eine Stufe abgesetzt.
  ///
  /// „Aura" braucht zwei Stufen (4,5 % und 2,5 % Weiß), „Pegel" wechselt den
  /// Ton, um einen Abschnitt zu beenden. Bei [SurfaceStyle.linie] bleibt die
  /// Stufe folgenlos — dort gibt es keine Flächen, die sich abheben könnten.
  ///
  /// **Zwei Flächen direkt untereinander müssen verschiedene Stufen tragen.**
  /// Bänder laufen ohne Abstand ineinander; bei gleichem Ton verschmelzen sie
  /// zu einer Fläche, und das Abschnittsende wird unsichtbar — genau die
  /// Aussage, für die „Pegel" gezeichnet wurde. `surface_style_test.dart`
  /// prüft das für jeden Bildschirm.
  final int tone;

  final EdgeInsetsGeometry? padding;

  /// Ob die Fläche etwas trägt, das auffallen soll — eine offene Frage, ein
  /// Grenzfall, eine Entscheidung, die aussteht.
  ///
  /// Sie bekommt dann auch dort eine Kante, wo die Form keine Flächen kennt.
  /// Ohne das verlöre der Prüfbereich im Modus „Linie" seine Kacheln und
  /// damit die Aussage „hier ist etwas offen" — sie stünde als bloßer Text
  /// zwischen anderem Text.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    // Bedienelemente wie ListTile malen ihre Tinteneffekte auf dem nächsten
    // Material-Vorfahren. Liegt eine gefärbte Fläche dazwischen, verschwinden
    // sie darunter — Flutter meldet das als Zusicherung. Ein durchsichtiges
    // Material innerhalb der Fläche fängt sie wieder auf.
    final inhalt = Material(type: MaterialType.transparency, child: child);

    return switch (t.surfaceStyle) {
      // Keine Fläche: Der Inhalt steht auf dem Grund, gegliedert wird durch
      // Haarlinien und Weißraum. Der Abstand nach unten ist deshalb kein
      // Beiwerk, sondern die Gliederung selbst — ohne ihn stießen zwei
      // Abschnitte übergangslos aneinander, weil hier keine Fläche und kein
      // Strich sie trennt.
      SurfaceStyle.linie => Container(
          margin: EdgeInsets.only(bottom: t.gapLarge),
          padding: highlighted
              ? (padding ?? EdgeInsets.all(t.gapSmall))
              : (padding ?? EdgeInsets.zero),
          decoration: highlighted
              ? BoxDecoration(
                  border: Border.all(color: t.line),
                  borderRadius: BorderRadius.circular(t.radius),
                )
              : null,
          child: inhalt,
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
          child: inhalt,
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
          child: inhalt,
        ),
    };
  }
}
