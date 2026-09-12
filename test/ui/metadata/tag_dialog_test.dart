import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/ui/metadata/tag_management_screen.dart';
import 'package:sphygma/ui/metadata/tag_picker.dart';
import 'package:sphygma/ui/theme/material_theme.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

import '../a3_test_support.dart';

void main() {
  late A3Harness harness;

  setUp(() async {
    harness = A3Harness();
    await harness.start();
  });

  tearDown(() => harness.close());

  Widget app(Widget child) {
    final theme = themeFor(ThemeVariant.instrument);
    return MaterialApp(
      theme: materialThemeFor(theme),
      builder: (context, child) =>
          SphygmaThemeScope(theme: theme, child: child!),
      home: Scaffold(body: child),
    );
  }

  testWidgets('Anlegen hält das Eingabefeld bis zum Ende der Rückanimation', (
    tester,
  ) async {
    var selected = <int>{};
    await tester.pumpWidget(
      app(
        TagPicker(
          controller: harness.controller,
          selected: selected,
          onChanged: (value) => selected = value,
          onError: (error) => fail('$error'),
          enabled: true,
        ),
      ),
    );

    await tester.tap(find.text('Tag anlegen'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Arbeit');
    await tester.tap(find.text('Anlegen'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();

    expect(harness.controller.tags.single.name, 'Arbeit');
    expect(selected, {harness.controller.tags.single.id});
    expect(tester.takeException(), isNull);
  });

  testWidgets('Abbrechen legt keinen Tag an', (tester) async {
    await tester.pumpWidget(
      app(
        TagPicker(
          controller: harness.controller,
          selected: const {},
          onChanged: (_) => fail('Auswahl darf sich nicht ändern'),
          onError: (error) => fail('$error'),
          enabled: true,
        ),
      ),
    );

    await tester.tap(find.text('Tag anlegen'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nicht speichern');
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(harness.controller.tags, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Umbenennen hält das Eingabefeld bis zum Ende der Rückanimation',
    (tester) async {
      await harness.controller.createTag('Alt');
      await tester.pumpWidget(
        app(TagManagementScreen(controller: harness.controller)),
      );

      await tester.tap(find.text('Alt'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Neu');
      await tester.tap(find.text('Speichern'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();

      expect(harness.controller.tags.single.name, 'Neu');
      expect(tester.takeException(), isNull);
    },
  );
}
