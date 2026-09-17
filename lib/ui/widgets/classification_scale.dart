// Einordnungsskala mit Zeiger und Erklärung der verwendeten Referenzen.
import 'package:flutter/material.dart';

import '../../stats/esc_classification.dart';
import '../../stats/low_blood_pressure.dart';
import '../theme/sphygma_theme.dart';

class ClassificationScale extends StatelessWidget {
  const ClassificationScale({
    super.key,
    required this.category,
    this.low = LowBloodPressure.none,
  });

  factory ClassificationScale.forReading({
    Key? key,
    required int systolic,
    required int diastolic,
  }) => ClassificationScale(
    key: key,
    category: classifyOffice(systolic: systolic, diastolic: diastolic),
    low: lowBloodPressure(systolic: systolic, diastolic: diastolic),
  );

  final EscCategory category;
  final LowBloodPressure low;

  /// Position des Zeigers: Mitte des jeweiligen Abschnitts.
  double get _position => (category.index + 0.5) / EscCategory.values.length;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: 12,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      for (final c in EscCategory.values)
                        Expanded(
                          child: Container(
                            height: 3,
                            color: t.categoryColors[c],
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * _position - 1,
                  top: 0,
                  child: Container(width: 2, height: 12, color: t.accent),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: t.gapSmall),
        Row(
          children: [
            Expanded(
              child: Text(
                category == EscCategory.low || low == LowBloodPressure.none
                    ? _label(category)
                    : '${_label(category)} · ${low.label}',
                style: TextStyle(fontSize: 13, color: t.onSurface),
              ),
            ),
            IconButton(
              tooltip: 'Einordnung erklären',
              onPressed: () => _showExplanation(context),
              icon: Icon(Icons.info_outline, size: 18, color: t.onSurface),
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> _showExplanation(BuildContext context) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Blutdruck einordnen'),
          content: const SingleChildScrollView(
            child: Text(
              'Niedriger Blutdruck (Hypotonie)\n'
              'Sphygma kennzeichnet systolisch unter 90 oder diastolisch unter 60 mmHg als niedrig. '
              'Bei gleichzeitig erhöhten Werten bleiben die obere Kategorie und der Hinweis auf die niedrige Komponente sichtbar.\n\n'
              'Diese Referenz folgt den Schwellen von NHS und NHLBI (unter 90/60 mmHg); '
              'Sphygma prüft beide Komponenten einzeln. Andere Quellen verwenden abweichende Grenzen. '
              'Ein niedriger Einzelwert ist keine Diagnose; Beschwerden und die persönliche Situation sind entscheidend.\n\n'
              'Optimal, Normal, Hochnormal und Bluthochdruck Grad 1–3 folgen der ESC/ESH-Tabelle von 2018 '
              'für Praxisblutdruck. „Niedrig“ ist eine ergänzende Kennzeichnung, keine ESC/ESH-Stufe. '
              'Für Heimmessungen gilt die separate obere Schwelle 135/85 mmHg, nach der die Messfelder eingefärbt werden.\n\n'
              'Quellen: NHS – Low blood pressure (hypotension), nhs.uk; '
              'NHLBI – Low Blood Pressure, nhlbi.nih.gov; '
              'ESC/ESH Guidelines 2018, Tabellen 3 und 9.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schließen'),
            ),
          ],
        ),
      );

  static String _label(EscCategory c) => switch (c) {
    EscCategory.low => 'Niedrig',
    EscCategory.optimal => 'Optimal',
    EscCategory.normal => 'Normal',
    EscCategory.highNormal => 'Hochnormal',
    EscCategory.grade1 => 'Bluthochdruck Grad 1',
    EscCategory.grade2 => 'Bluthochdruck Grad 2',
    EscCategory.grade3 => 'Bluthochdruck Grad 3',
  };
}
