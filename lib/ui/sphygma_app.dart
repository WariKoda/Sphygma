// lib/ui/sphygma_app.dart
// Drei Bereiche: Heute, Verlauf, Geraet. Die Gestaltung liegt als Scope
// darueber; kein Bildschirm holt sich Farben woanders her.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/concept.dart';
import 'concepts/day_profile/day_profile_screen.dart';
import 'device_screen.dart';
import 'history_screen.dart';
import 'theme/sphygma_theme.dart';
import 'theme/variants.dart';
import 'today_screen.dart';

class SphygmaApp extends StatelessWidget {
  const SphygmaApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = themeFor(controller.themeVariant);
        return MaterialApp(
          title: 'Sphygma',
          theme: ThemeData(
            colorSchemeSeed: theme.accent,
            scaffoldBackgroundColor: theme.surface,
            useMaterial3: true,
          ),
          home: SphygmaThemeScope(
            theme: theme,
            child: _Shell(controller: controller),
          ),
        );
      },
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell({required this.controller});

  final AppController controller;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  /// Zuletzt angezeigte Meldung, damit dieselbe nicht bei jedem Neubau
  /// erneut aufpoppt.
  String? _shownStatus;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final status = widget.controller.status;
    if (status == null || status == _shownStatus) return;
    _shownStatus = status;
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(status)));
  }

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
        // Gerätebereich bleibt in jedem Konzept derselbe — dort wird das
        // Konzept ja auch gewechselt.
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              label: 'Heute',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart),
              label: 'Verlauf',
            ),
            NavigationDestination(
              icon: Icon(Icons.bluetooth),
              label: 'Gerät',
            ),
          ],
        ),
      ),
    );
  }
}
