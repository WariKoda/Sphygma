import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import 'home_screen.dart';
import 'measurements_screen.dart';
import 'trends_screen.dart';

class SphygmaApp extends StatelessWidget {
  const SphygmaApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sphygma',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF7A1F2B), useMaterial3: true),
      home: _Shell(controller: controller),
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

  @override
  Widget build(BuildContext context) {
    const titles = ['Sphygma', 'Messungen', 'Trend'];
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(titles[_index])),
        body: switch (_index) {
          0 => HomeScreen(controller: widget.controller),
          1 => MeasurementsScreen(controller: widget.controller),
          _ => TrendsScreen(controller: widget.controller),
        },
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Start'),
            NavigationDestination(icon: Icon(Icons.list_alt), label: 'Messungen'),
            NavigationDestination(icon: Icon(Icons.show_chart), label: 'Trend'),
          ],
        ),
      ),
    );
  }
}
