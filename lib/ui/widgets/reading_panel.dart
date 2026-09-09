// Die Fläche, auf der der große Wert steht.
//
// Sie gibt es als eigenen Baustein, weil eine Form über sie mitentscheidet:
// „Band" färbt die **Kopffläche selbst** mit der Einordnung, statt eine Marke
// danebenzustellen. Stünde diese Entscheidung im Bildschirm, müsste „Heute"
// nach der Charakteristik verzweigen — und die Grenze fiele, dass kein
// Bildschirm die Gestaltung kennt.
//
// Eingefärbt wird nach dem **Zielbereich** der Heimmessung, nicht nach der
// ESC-Klassifikation: Die Farbe ist eine Tonleiter, die Klassifikation liegt
// hinter dem Compile-Time-Flag. Wer die Fläche an EscCategory hängt, zieht die
// regulatorische Frage in jeden Bildschirm (siehe zone_color.dart).
import 'package:flutter/material.dart';

import '../../stats/target_range.dart';
import '../theme/characteristic.dart';
import '../theme/sphygma_theme.dart';
import '../theme/zone_color.dart';
import 'surface_panel.dart';

class ReadingPanel extends StatelessWidget {
  const ReadingPanel({
    super.key,
    required this.child,
    required this.systolic,
    required this.diastolic,
  });

  final Widget child;

  /// Die Werte, aus denen sich die Tonstufe ergibt. Sie werden hier gebraucht
  /// und nicht außen berechnet, damit der Aufrufer nichts über Zonen wissen
  /// muss.
  ///
  /// **Null heißt: es gibt keine Messung** — nicht „null zu null". Ein
  /// Ersatzwert würde die Fläche einfärben, als läge ein Wert im Zielbereich,
  /// und ausgerechnet der leere Zustand sähe dann beruhigend aus.
  final int? systolic;
  final int? diastolic;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    final sys = systolic;
    final dia = diastolic;
    if (t.zoneDisplay != ZoneDisplay.flaeche || sys == null || dia == null) {
      return SurfacePanel(child: child);
    }

    final zone = TargetRange.heim.classify(systolic: sys, diastolic: dia);
    return SurfacePanel(tint: zoneColor(t, zone), child: child);
  }
}
