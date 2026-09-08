// Die Reiterhülle: Heute, Verlauf, Gerät.
//
// Sie ist die Organisation des Konzepts „Messung und Filter" — und die des
// Tagesprofils, das dieselbe Aufteilung übernimmt und nur den ersten Reiter
// anders füllt. Konzepte mit eigener Ordnung bringen stattdessen eine eigene
// Hülle mit; deshalb steht diese hier und nicht mehr in `sphygma_app.dart`.
import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../device_screen.dart';
import '../history_screen.dart';
import '../settings_screen.dart';
import '../theme/sphygma_theme.dart';
import '../today_screen.dart';

class TabbedHome extends StatefulWidget {
  const TabbedHome({
    super.key,
    required this.controller,
    this.clock = DateTime.now,
  });

  final AppController controller;

  /// Wird an „Heute" weitergereicht: Dort steht die laufende Woche, und die
  /// wechselt am Montag.
  final DateTime Function() clock;

  @override
  State<TabbedHome> createState() => _TabbedHomeState();
}

class _TabbedHomeState extends State<TabbedHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    const titles = ['Heute', 'Verlauf', 'Gerät'];

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => Scaffold(
        backgroundColor: t.surface,
        appBar: AppBar(
          title: Text(titles[_index]),
          backgroundColor: t.surface,
          foregroundColor: t.onSurface,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Einstellungen',
              icon: const Icon(Icons.settings),
              onPressed: () =>
                  showSettings(context, controller: widget.controller),
            ),
          ],
        ),
        // Das Konzept bestimmt, was auf dem ersten Reiter steht. Der
        // Gerätebereich bleibt in jedem Konzept derselbe — dort geht es
        // zur Konzeptwahl.
        body: switch (_index) {
          0 => TodayScreen(controller: widget.controller, clock: widget.clock),
          1 => HistoryScreen(controller: widget.controller),
          _ => DeviceScreen(controller: widget.controller),
        },
        bottomNavigationBar: NavigationBar(
          backgroundColor: t.surface,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              label: 'Heute',
            ),
            const NavigationDestination(
              icon: Icon(Icons.show_chart),
              label: 'Verlauf',
            ),
            const NavigationDestination(
              icon: Icon(Icons.bluetooth),
              label: 'Gerät',
            ),
          ],
        ),
      ),
    );
  }
}
