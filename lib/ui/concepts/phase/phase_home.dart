// Konzept „Phase": Die Einheit ist der benannte Lebensabschnitt.
//
// Zu Hause wird oft gemessen, um eine Veränderung zu beurteilen. „Ramipril
// 5 mg", „Urlaub", „nach der Umstellung" geben Messungen einen Zusammenhang,
// den ein Kalenderfilter nicht kennt.
//
// Vier Bereiche. „Zuordnen" ist eigener Ort, weil die falsche Geräteuhr für
// dieses Konzept kein Randproblem ist, sondern sein zentrales Risiko: Ein
// Vergleich ist nur so belastbar wie seine Zuordnung.
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../device_screen.dart';
import '../../theme/sphygma_theme.dart';
import 'current_phase_screen.dart';
import 'phase_assign_screen.dart';
import 'phase_list_screen.dart';

class PhaseHome extends StatefulWidget {
  const PhaseHome({super.key, required this.controller});

  final AppController controller;

  @override
  State<PhaseHome> createState() => _PhaseHomeState();
}

class _PhaseHomeState extends State<PhaseHome> {
  int _index = 0;

  static const _titel = ['Jetzt', 'Lebensabschnitte', 'Zeitzuordnung', 'Gerät'];

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final offen = widget.controller.phaseGrouping?.unclear.length ?? 0;

        return Scaffold(
          backgroundColor: t.surface,
          appBar: AppBar(
            title: Text(_titel[_index]),
            backgroundColor: t.surface,
            foregroundColor: t.onSurface,
            elevation: 0,
          ),
          body: switch (_index) {
            0 => CurrentPhaseScreen(
                controller: widget.controller,
                onAssign: () => setState(() => _index = 2),
              ),
            1 => PhaseListScreen(controller: widget.controller),
            2 => PhaseAssignScreen(controller: widget.controller),
            _ => DeviceScreen(controller: widget.controller),
          },
          bottomNavigationBar: NavigationBar(
            backgroundColor: t.surface,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.play_circle_outline),
                label: 'Jetzt',
              ),
              const NavigationDestination(
                icon: Icon(Icons.timeline),
                label: 'Phasen',
              ),
              NavigationDestination(
                icon: offen == 0
                    ? const Icon(Icons.help_outline)
                    : Badge(
                        label: Text('$offen'),
                        child: const Icon(Icons.help_outline),
                      ),
                label: 'Zuordnen',
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
