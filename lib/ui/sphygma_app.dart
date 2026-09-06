// lib/ui/sphygma_app.dart
// Die Gestaltung liegt als Scope über allem; kein Bildschirm holt sich Farben
// woanders her. Wie die App organisiert ist, bestimmt dagegen das Konzept —
// diese Hülle hält nur noch das Fenster und die Meldungen des Steuerungsteils.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import 'concepts/concept_home.dart';
import 'theme/sphygma_theme.dart';
import 'theme/variants.dart';

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
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) => conceptHome(
          concept: widget.controller.concept,
          controller: widget.controller,
        ),
      );
}
