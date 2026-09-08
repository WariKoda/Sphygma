// Baut seinen Inhalt neu, wenn der Tag wechselt.
//
// Bildschirme, die „heute" oder „diese Woche" zeigen, hängen an einer Uhr,
// die niemand meldet: Der Steuerungsteil sagt Bescheid, wenn sich eine
// Messung ändert — nicht, wenn Mitternacht vorbei ist. Ohne eigenen Wecker
// zeigt eine über Nacht offene App weiter den gestrigen Tag, am Montag sogar
// die ganze Vorwoche als „diese Woche".
//
// Die Regel steht hier und nicht in jedem Bildschirm: Sie war schon einmal
// nur in „Sieben Tage" umgesetzt, und „Heute" bekam denselben Fehler prompt
// noch einmal.
import 'dart:async';

import 'package:flutter/widgets.dart';

class AtDayChange extends StatefulWidget {
  const AtDayChange({
    super.key,
    required this.builder,
    this.clock = DateTime.now,
  });

  /// Bekommt den Zeitpunkt, der gerade gilt.
  final Widget Function(BuildContext context, DateTime now) builder;

  /// Einsetzbar, damit Tests nicht vom Wochentag ihres Laufs abhängen.
  final DateTime Function() clock;

  @override
  State<AtDayChange> createState() => _AtDayChangeState();
}

class _AtDayChangeState extends State<AtDayChange> {
  Timer? _wecker;

  @override
  void initState() {
    super.initState();
    _stellen();
  }

  @override
  void dispose() {
    _wecker?.cancel();
    super.dispose();
  }

  void _stellen() {
    final jetzt = widget.clock();
    final morgen = DateTime(jetzt.year, jetzt.month, jetzt.day + 1);
    _wecker?.cancel();
    // difference() rechnet die echte Spanne — in der Umstellungsnacht sind
    // das 23 oder 25 Stunden, und genau die sollen es sein.
    _wecker = Timer(morgen.difference(jetzt), () {
      if (!mounted) return;
      setState(() {});
      _stellen();
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.clock());
}
