import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import 'history_screen.dart';
import 'phases/phase_management_screen.dart';
import 'plan/measurement_plan_screen.dart';
import 'settings_screen.dart';
import 'theme/sphygma_theme.dart';
import 'today_screen.dart';

class AppHome extends StatefulWidget {
  const AppHome({
    super.key,
    required this.controller,
    this.clock = DateTime.now,
  });
  final AppController controller;
  final DateTime Function() clock;
  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_updateNavigation);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateNavigation());
  }

  @override
  void didUpdateWidget(covariant AppHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_updateNavigation);
      widget.controller.addListener(_updateNavigation);
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateNavigation());
    }
  }

  void _updateNavigation() {
    if (!mounted) return;
    final plan = widget.controller.planController;
    final next = plan?.enabled != true && _index == 2
        ? 0
        : plan?.takeOpenPlanRequest() == true
        ? 2
        : _index;
    if (next != _index) setState(() => _index = next);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.controller.reconcilePlan());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_updateNavigation);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final theme = SphygmaTheme.of(context);
      final plan = widget.controller.planController;
      final showPlan = plan?.enabled == true;
      final index = !showPlan && _index == 2 ? 0 : _index;
      final title = switch (index) {
        0 => 'Heute',
        1 => 'Verlauf',
        _ => 'Messplan',
      };
      return Scaffold(
        backgroundColor: theme.surface,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: theme.surface,
          foregroundColor: theme.onSurface,
          elevation: 0,
          actions: [
            if (index == 1 && widget.controller.phasesEnabled)
              IconButton(
                tooltip: 'Phasen verwalten',
                icon: const Icon(Icons.timeline),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        PhaseManagementScreen(controller: widget.controller),
                  ),
                ),
              ),
            IconButton(
              tooltip: 'Einstellungen',
              icon: const Icon(Icons.settings),
              onPressed: () =>
                  showSettings(context, controller: widget.controller),
            ),
          ],
        ),
        body: switch (index) {
          0 => TodayScreen(
            controller: widget.controller,
            clock: widget.clock,
            onOpenPlan: showPlan ? () => setState(() => _index = 2) : null,
          ),
          1 => HistoryScreen(controller: widget.controller),
          _ => MeasurementPlanScreen(
            planController: plan!,
            controller: widget.controller,
          ),
        },
        bottomNavigationBar: NavigationBar(
          backgroundColor: theme.surface,
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              label: 'Heute',
            ),
            const NavigationDestination(
              icon: Icon(Icons.show_chart),
              label: 'Verlauf',
            ),
            if (showPlan)
              const NavigationDestination(
                icon: Icon(Icons.schedule),
                label: 'Messplan',
              ),
          ],
        ),
      );
    },
  );
}
