import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/esc_classification.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/classification_scale.dart';
import 'package:sphygma/ui/widgets/notice_card.dart';
import 'package:sphygma/ui/widgets/reading_headline.dart';

Widget _wrap(ThemeVariant v, Widget child) => MaterialApp(
      home: SphygmaThemeScope(
        theme: themeFor(v),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('ReadingHeadline in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('zeigt Werte und Puls (${v.name})', (tester) async {
        await tester.pumpWidget(_wrap(
          v,
          ReadingHeadline(
            systolic: 128,
            diastolic: 87,
            pulse: 82,
            measuredAt: DateTime(2026, 9, 5, 23, 57),
          ),
        ));

        expect(find.textContaining('128'), findsOneWidget);
        expect(find.textContaining('87'), findsOneWidget);
        expect(find.textContaining('82'), findsOneWidget);
      });
    }
  });

  group('ClassificationScale in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('baut ohne Fehler (${v.name})', (tester) async {
        await tester.pumpWidget(_wrap(
          v,
          const ClassificationScale(category: EscCategory.highNormal),
        ));

        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('NoticeCard zeigt Titel und Text', (tester) async {
    await tester.pumpWidget(_wrap(
      ThemeVariant.instrument,
      const NoticeCard(title: 'Geraeteuhr', message: 'Datum weicht ab.'),
    ));

    expect(find.text('Geraeteuhr'), findsOneWidget);
    expect(find.text('Datum weicht ab.'), findsOneWidget);
  });

  testWidgets('NoticeCard klappt Einzelheiten erst auf Tippen auf',
      (tester) async {
    await tester.pumpWidget(_wrap(
      ThemeVariant.instrument,
      const NoticeCard(
        title: 'Geraeteuhr',
        message: 'Datum weicht ab.',
        details: 'Batterien herausnehmen und wieder einlegen.',
      ),
    ));

    expect(find.textContaining('Batterien'), findsNothing);

    await tester.tap(find.text('Anleitung anzeigen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Batterien'), findsOneWidget);
  });
}
