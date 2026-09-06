// Die Reiterhülle: Heute, Verlauf, Gerät.
//
// Sie ist die Organisation des Konzepts „Messung und Filter" — und die des
// Tagesprofils, das dieselbe Aufteilung übernimmt und nur den ersten Reiter
// anders füllt. Konzepte mit eigener Ordnung bringen stattdessen eine eigene
// Hülle mit; deshalb steht diese hier und nicht mehr in `sphygma_app.dart`.
import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/concept.dart';
import '../device_screen.dart';
import '../history_screen.dart';
import '../theme/sphygma_theme.dart';
import '../today_screen.dart';
import 'day_profile/day_profile_screen.dart';

class TabbedHome extends StatefulWidget {
  const TabbedHome({super.key, required this.controller});

  final AppController controller;

  @override
  State<TabbedHome> createState() => _TabbedHomeState();
}

class _TabbedHomeState extends State<TabbedHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final titles = [
      widget.controller.concept == AppConcept.tagesprofil ? 'Muster' : 'Heute',
      'Verlauf',
      'Gerät',
    ];

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => Scaffold(
        backgroundColor: t.surface,
        appBar: AppBar(
          title: Text(titles[_index]),
          backgroundColor: t.surface,
          foregroundColor: t.onSurface,
          elevation: 0,
        ),
        // Das Konzept bestimmt, was auf dem ersten Reiter steht. Der
        // Gerätebereich bleibt in jedem Konzept derselbe — dort geht es
        // zur Konzeptwahl.
        body: switch ((widget.controller.concept, _index)) {
          (AppConcept.tagesprofil, 0) =>
            DayProfileScreen(controller: widget.controller),
          (_, 0) => TodayScreen(controller: widget.controller),
          (_, 1) => HistoryScreen(controller: widget.controller),
          _ => DeviceScreen(controller: widget.controller),
        },
        bottomNavigationBar: NavigationBar(
          backgroundColor: t.surface,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              // Dieselbe Beschriftung wie oben in der Titelzeile: Ein Reiter,
              // der „Heute" heißt und das Muster aller Messungen zeigt, würde
              // einen Tagesfilter versprechen, den es dort nicht gibt.
              icon: const Icon(Icons.favorite_outline),
              label: titles[0],
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
