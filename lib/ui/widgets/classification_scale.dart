// Schmale Skala mit Zeiger. Hier - und nur hier - traegt Farbe Bedeutung.
import 'package:flutter/material.dart';

import '../../stats/esc_classification.dart';
import '../theme/sphygma_theme.dart';

class ClassificationScale extends StatelessWidget {
  const ClassificationScale({super.key, required this.category});

  final EscCategory category;

  /// Position des Zeigers: Mitte des jeweiligen Abschnitts.
  double get _position =>
      (category.index + 0.5) / EscCategory.values.length;

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
        Text(
          _label(category),
          style: TextStyle(fontSize: 13, color: t.onSurface),
        ),
      ],
    );
  }

  static String _label(EscCategory c) => switch (c) {
        EscCategory.optimal => 'Optimal',
        EscCategory.normal => 'Normal',
        EscCategory.highNormal => 'Hochnormal',
        EscCategory.grade1 => 'Bluthochdruck Grad 1',
        EscCategory.grade2 => 'Bluthochdruck Grad 2',
        EscCategory.grade3 => 'Bluthochdruck Grad 3',
      };
}
