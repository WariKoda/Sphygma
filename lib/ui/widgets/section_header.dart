import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

/// Die Zäsur zwischen zwei Abschnitten eines Blattes.
///
/// Liegt hier und nicht in einem einzelnen Bildschirm, weil Gerätebereich und
/// Einstellungen dieselbe Gliederung tragen müssen — zwei Kopien liefen
/// auseinander, sobald eine von beiden angefasst wird.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: t.gapLarge, bottom: t.gapSmall),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: t.muted),
      ),
    );
  }
}
