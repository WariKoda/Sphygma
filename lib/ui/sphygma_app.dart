// lib/ui/sphygma_app.dart
// Die Gestaltung liegt als Scope über allem; kein Bildschirm holt sich Farben
// woanders her. Diese Hülle hält das Fenster und die Meldungen des
// Steuerungsteils.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import 'app_home.dart';
import 'theme/sphygma_theme.dart';
import 'theme/material_theme.dart';

class SphygmaApp extends StatelessWidget {
  const SphygmaApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // Die komponierte Gestaltung, nicht die Diagonale: Sonst käme eine
        // freie Kombination — etwa Messinstrument auf Nacht — nie an, weil
        // `themeVariant` nur die Charakteristik zurückübersetzt.
        final theme = controller.theme;
        return MaterialApp(
          title: 'Sphygma',
          theme: materialThemeFor(theme),
          // Der Scope liegt über dem Navigator, nicht in `home`.
          //
          // Unter `home` wäre er nur ein Geschwister der geschobenen Routen:
          // Ein Detailblatt müsste die Gestaltung beim Öffnen mitnehmen und
          // hielte sie dann fest. Wer die Gestaltung ändert, während ein
          // solches Blatt offen ist, sähe die Änderung erst nach dem
          // Zurückgehen — genau das war der Fall im Einstellungsblatt selbst.
          builder: (context, child) {
            if (child == null) {
              throw StateError(
                'MaterialApp.builder ohne Kind — ohne Navigator gäbe es '
                'nichts, worüber der Scope liegen könnte.',
              );
            }
            return SphygmaThemeScope(theme: theme, child: child);
          },
          home: _Shell(controller: controller),
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
    builder: (context, _) => AppHome(controller: widget.controller),
  );
}
