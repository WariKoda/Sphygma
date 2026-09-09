// Die Fläche, auf der Inhalt steht.
//
// Alle Bildschirme wickeln ihre Abschnitte hierin ein, statt selbst Container
// zu bauen. Nur so bleibt die Gestaltung eine Entscheidung an einer Stelle:
// Wer Radius, Polster oder Kante einer Handschrift ändern will, ändert sie
// hier und im Theme — nicht in dreißig verstreuten Containern.
import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

class SurfacePanel extends StatelessWidget {
  const SurfacePanel({
    super.key,
    required this.child,
    this.tone = 0,
    this.padding,
    this.highlighted = false,
    this.tint,
  });

  final Widget child;

  /// Tonstufe der Fläche: 0 die Grundfläche, 1 eine Stufe abgesetzt.
  ///
  /// „Aura" trägt zwei Stufen (4,5 % und 2,5 % Weiß); die helleren
  /// Handschriften setzen die zweite Stufe gegen ihren Grund ab. Benachbarte
  /// Flächen sollten verschiedene Stufen tragen, damit die Gliederung auch
  /// dort trägt, wo die Handschrift wenig Kontrast hat.
  final int tone;

  final EdgeInsetsGeometry? padding;

  /// Ob die Fläche etwas trägt, das auffallen soll — eine offene Frage, ein
  /// Grenzfall, eine Entscheidung, die aussteht.
  ///
  /// Sie bekommt dann eine Kante, auch wenn die Handschrift sonst keine
  /// zeichnet. Ohne das stünde eine ausstehende Entscheidung als gewöhnlicher
  /// Inhalt zwischen anderem Inhalt.
  final bool highlighted;

  /// Ein Ton, der die Grundfläche ersetzt.
  ///
  /// Nur die Form „Band" nutzt ihn: Dort trägt die Fläche selbst die
  /// Einordnung. Null heißt „wie immer" — die Tonstufe aus der Gestaltung.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    // Bedienelemente wie ListTile malen ihre Tinteneffekte auf dem nächsten
    // Material-Vorfahren. Liegt eine gefärbte Fläche dazwischen, verschwinden
    // sie darunter — Flutter meldet das als Zusicherung.
    final inhalt = Material(type: MaterialType.transparency, child: child);

    return Container(
      margin: EdgeInsets.only(bottom: t.gapSmall),
      padding: padding ?? EdgeInsets.all(t.panelPadding),
      decoration: BoxDecoration(
        color: tint ?? t.panel(tone),
        borderRadius: BorderRadius.circular(t.radius),
        border: highlighted
            ? Border.all(color: t.onSurface.withValues(alpha: 0.35))
            : (t.panelBorder == null
                  ? null
                  : Border.all(color: t.panelBorder!)),
        boxShadow: t.panelShadow,
      ),
      child: inhalt,
    );
  }
}
