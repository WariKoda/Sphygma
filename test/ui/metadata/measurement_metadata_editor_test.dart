import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/metadata/measurement_metadata_editor.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

import '../a3_test_support.dart';

void main() {
  late A3Harness harness;
  setUp(() async {
    harness = A3Harness();
    await harness.start();
    await harness.addMeasurement();
  });
  tearDown(() => harness.close());

  testWidgets('saves note and multiple tags without changing raw reading', (
    tester,
  ) async {
    final first = await harness.controller.createTag('Arbeit');
    final second = await harness.controller.createTag('Kaffee');
    final before = harness.controller.measurements.single;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => SphygmaThemeScope(
          theme: themeFor(ThemeVariant.instrument),
          child: child!,
        ),
        home: Scaffold(
          body: MeasurementMetadataEditor(
            controller: harness.controller,
            deviceSequence: 1,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '  Kontrollmessung  ');
    await tester.tap(find.byType(FilterChip).at(0));
    await tester.pump();
    await tester.tap(find.byType(FilterChip).at(1));
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    final metadata = (await harness.metadata.readSlot(1))[1]!;
    expect(metadata.note, 'Kontrollmessung');
    expect(metadata.tagIds, {first, second});
    final after = (await harness.measurements.allForSlot(1)).single;
    expect(after.systolic, before.systolic);
    expect(after.diastolic, before.diastolic);
    expect(after.rawBytes, before.rawBytes);
    expect(after.exportedAt, before.exportedAt);
  });

  testWidgets('cancel leaves metadata unchanged', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => SphygmaThemeScope(
          theme: themeFor(ThemeVariant.instrument),
          child: child!,
        ),
        home: Scaffold(
          body: MeasurementMetadataEditor(
            controller: harness.controller,
            deviceSequence: 1,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'nicht speichern');
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(await harness.metadata.readSlot(1), isEmpty);
  });
}
