import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

/// Die Zäsur zwischen zwei Abschnitten eines Blattes.
///
/// Liegt hier und nicht in einem einzelnen Bildschirm, weil Einstellungen,
/// Anlässe und Phasen dieselbe Gliederung tragen müssen — Kopien liefen
/// auseinander, sobald eine davon angefasst wird.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.leadingGap = true});

  final String title;

  /// Der Abstand nach oben. Er trennt zwei Abschnitte **innerhalb** einer
  /// Flaeche. Steht der Titel dagegen als Erstes auf einer eigenen Karte,
  /// trennt die Karte schon — dann kaeme der Abstand doppelt.
  final bool leadingGap;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: leadingGap ? t.gapLarge : 0,
        bottom: t.gapSmall,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: t.muted),
      ),
    );
  }
}
