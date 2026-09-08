// Dieselbe Fläche wie [SurfacePanel] — aber für Listen, die lang werden.
//
// SurfacePanel nimmt ein gewöhnliches Widget entgegen. Wickelt man eine lange
// Messwertliste hinein, muss sie als Column gebaut werden, und damit entstehen
// alle Zeilen auf einmal: Bei „Alles" mit dem gesamten Bestand baut die App
// hunderte Zeilen, von denen drei sichtbar sind. Vorher hielt die ListView
// unsichtbare Zeilen zurück.
//
// Diese Fassung legt die Fläche als Sliver **hinter** die Liste, statt die
// Liste in die Fläche zu stecken. Die Virtualisierung bleibt damit erhalten.
import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';
import '../theme/surface_style.dart';

class SurfaceSliver extends StatelessWidget {
  const SurfaceSliver({
    super.key,
    required this.sliver,
    this.tone = 0,
  });

  /// Ein Sliver — typischerweise eine [SliverList].
  final Widget sliver;

  /// Wie bei [SurfacePanel]: 0 die Grundfläche, 1 eine Stufe abgesetzt.
  /// Benachbarte Flächen müssen verschiedene Stufen tragen.
  final int tone;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return switch (t.surfaceStyle) {
      // Keine Fläche: Die Liste steht auf dem Grund.
      SurfaceStyle.linie => sliver,

      SurfaceStyle.karte => DecoratedSliver(
          decoration: BoxDecoration(
            color: t.panel(tone),
            borderRadius: BorderRadius.circular(t.radius),
            border: t.panelBorder == null
                ? null
                : Border.all(color: t.panelBorder!),
            boxShadow: t.panelShadow,
          ),
          sliver: SliverPadding(
            padding: EdgeInsets.all(t.gapLarge * 0.7),
            sliver: sliver,
          ),
        ),

      SurfaceStyle.band => DecoratedSliver(
          decoration: BoxDecoration(color: t.panel(tone)),
          sliver: SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: t.gapLarge,
              vertical: t.gapLarge * 0.7,
            ),
            sliver: sliver,
          ),
        ),
    };
  }
}
