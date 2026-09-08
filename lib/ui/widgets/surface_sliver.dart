// Dieselbe Fläche wie [SurfacePanel] — aber für Listen, die lang werden.
//
// SurfacePanel nimmt ein gewöhnliches Widget entgegen. Wickelt man eine lange
// Messwertliste hinein, muss sie als Column gebaut werden, und damit entstehen
// alle Zeilen auf einmal: Bei „Alles" mit dem gesamten Bestand baut die App
// hunderte Zeilen, von denen drei sichtbar sind.
//
// Diese Fassung legt die Fläche als Sliver **hinter** die Liste, statt die
// Liste in die Fläche zu stecken. Die Virtualisierung bleibt erhalten.
import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

class SurfaceSliver extends StatelessWidget {
  const SurfaceSliver({
    super.key,
    required this.sliver,
    this.tone = 0,
  });

  /// Ein Sliver — typischerweise eine [SliverList].
  final Widget sliver;

  /// Wie bei [SurfacePanel]: 0 die Grundfläche, 1 eine Stufe abgesetzt.
  final int tone;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return DecoratedSliver(
      decoration: BoxDecoration(
        color: t.panel(tone),
        borderRadius: BorderRadius.circular(t.radius),
        border:
            t.panelBorder == null ? null : Border.all(color: t.panelBorder!),
        boxShadow: t.panelShadow,
      ),
      sliver: SliverPadding(
        padding: EdgeInsets.all(t.panelPadding),
        sliver: sliver,
      ),
    );
  }
}
