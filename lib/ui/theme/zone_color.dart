// Die Tonstufe eines Messfelds.
//
// Jede Handschrift bringt eine Tonleiter von „gut" nach „hoch" mit
// ([SphygmaTheme.categoryColors]). Sie wird hier über den Zielbereich der
// **Heimmessung** angesprochen, nicht über die ESC-Klassifikation: Die Farbe
// ist eine Tonleiter, die Klassifikation ist das, was hinter dem
// Compile-Time-Flag liegt. Wer die drei Zonen an EscCategory hängt, zieht die
// regulatorische Frage in jedes Wochenraster.
import 'package:flutter/material.dart';

import '../../stats/esc_classification.dart';
import '../../stats/target_range.dart';
import 'sphygma_theme.dart';

Color zoneColor(SphygmaTheme theme, TargetZone zone) {
  final stufe = switch (zone) {
    TargetZone.imZielbereich => EscCategory.optimal,
    TargetZone.grenzwertig => EscCategory.highNormal,
    TargetZone.darueber => EscCategory.grade1,
  };
  final farbe = theme.categoryColors[stufe];
  if (farbe == null) {
    // Eine Handschrift ohne vollständige Tonleiter wäre ein Fehler in der
    // Gestaltung, kein Anlass für ein stilles Grau.
    throw StateError(
      'Der Gestaltung "${theme.name}" fehlt die Tonstufe $stufe.',
    );
  }
  return farbe;
}
