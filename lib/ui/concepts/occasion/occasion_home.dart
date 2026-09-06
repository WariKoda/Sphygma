// Konzept „Messanlass": Die Einheit ist das einzelne Messen.
//
// Wer zweimal hintereinander misst, will nicht zwei gleichberechtigte
// Listeneinträge, sondern eine belastbarere Antwort. Messungsnummer und
// zeitliche Nähe liefern einen Vorschlag; bei Grenzfällen entscheidet der
// Mensch.
//
// Vier Bereiche, weil dieses Konzept einen eigenen Ort für offene Fragen
// braucht: „Prüfen" ist kein Untermenü, sondern eine sichtbare Aufgabe mit
// Anzahl. Sie zu verstecken hieße, sie zuzudecken.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../device_screen.dart';
import '../../theme/sphygma_theme.dart';
import 'last_occasion_screen.dart';
import 'occasion_archive_screen.dart';
import 'occasion_review_screen.dart';

class OccasionHome extends StatefulWidget {
  const OccasionHome({super.key, required this.controller});

  final AppController controller;

  @override
  State<OccasionHome> createState() => _OccasionHomeState();
}

class _OccasionHomeState extends State<OccasionHome> {
  int _index = 0;

  static const _titel = ['Letztes Messen', 'Archiv', 'Zu prüfen', 'Gerät'];

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final offen = widget.controller.openOccasions.length;

        return Scaffold(
          backgroundColor: t.surface,
          appBar: AppBar(
            title: Text(_titel[_index]),
            backgroundColor: t.surface,
            foregroundColor: t.onSurface,
            elevation: 0,
          ),
          body: switch (_index) {
            0 => LastOccasionScreen(
                controller: widget.controller,
                onReview: () => setState(() => _index = 2),
              ),
            1 => OccasionArchiveScreen(controller: widget.controller),
            2 => OccasionReviewScreen(controller: widget.controller),
            _ => DeviceScreen(controller: widget.controller),
          },
          bottomNavigationBar: NavigationBar(
            backgroundColor: t.surface,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.favorite_outline),
                label: 'Letztes',
              ),
              const NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                label: 'Archiv',
              ),
              NavigationDestination(
                // Die Zahl steht am Reiter, nicht in einem Hinweis: Eine
                // offene Frage, die man erst beim Hinsehen findet, ist so gut
                // wie zugedeckt.
                icon: offen == 0
                    ? const Icon(Icons.checklist_outlined)
                    : Badge(
                        label: Text('$offen'),
                        child: const Icon(Icons.checklist_outlined),
                      ),
                label: 'Prüfen',
              ),
              const NavigationDestination(
                icon: Icon(Icons.bluetooth),
                label: 'Gerät',
              ),
            ],
          ),
        );
      },
    );
  }
}
