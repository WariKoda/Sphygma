import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/phases/phase_selection_editor.dart';

import '../a3_test_support.dart';

void main() {
  late A3Harness harness;
  setUp(() async {
    harness = A3Harness();
    await harness.start();
    await harness.addMeasurement();
  });
  tearDown(() => harness.close());

  testWidgets('supports multiple, empty and automatic phase selection', (
    tester,
  ) async {
    final now = DateTime.now();
    final first = await harness.controller.savePhase(
      name: 'Therapie',
      begin: now.subtract(const Duration(days: 2)),
      end: null,
    );
    final second = await harness.controller.savePhase(
      name: 'Urlaub',
      begin: now.subtract(const Duration(days: 1)),
      end: null,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhaseSelectionEditor(
            controller: harness.controller,
            deviceSequence: 1,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Phasenauswahl speichern'));
    await tester.pumpAndSettle();
    expect((await harness.phases.selections(1))[1], {first, second});

    await tester.tap(find.text('Therapie'));
    await tester.tap(find.text('Urlaub'));
    await tester.tap(find.text('Phasenauswahl speichern'));
    await tester.pumpAndSettle();
    expect((await harness.phases.selections(1))[1], isEmpty);

    await tester.tap(find.text('Automatisch zuordnen'));
    await tester.pumpAndSettle();
    expect(await harness.phases.selections(1), isEmpty);
  });
}
