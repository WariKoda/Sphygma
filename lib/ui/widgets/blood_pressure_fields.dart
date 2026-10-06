import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

/// Getrennte Werte innerhalb einer Karte mit gemeinsamer Einheit im Kopf.
class BloodPressureFields extends StatelessWidget {
  const BloodPressureFields({
    super.key,
    required this.systolic,
    required this.diastolic,
  });

  final int systolic;
  final int diastolic;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final numberStyle = DefaultTextStyle.of(context).style.copyWith(
      fontFamily: t.fontFamily,
      fontSize: t.headlineSize * .82,
      height: 1,
      fontWeight: t.headlineWeight,
      color: t.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final labelStyle = DefaultTextStyle.of(context).style
        .copyWith(fontFamily: t.fontFamily, fontSize: 13, color: t.muted);
    Widget field(String label, int value) => Container(
      padding: EdgeInsets.all(t.gapSmall),
      decoration: BoxDecoration(
        color: t.panel(1),
        borderRadius: BorderRadius.circular(t.chipRadius),
        border: t.panelBorder == null
            ? null
            : Border.all(color: t.panelBorder!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: labelStyle),
          SizedBox(height: t.gapSmall / 2),
          Text(
            '$value',
            style: numberStyle,
            semanticsLabel: '$label $value Millimeter Quecksilbersäule',
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        double width(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final width = painter.width;
          painter.dispose();
          return width;
        }

        final minimum =
            [
              width('Systolisch', labelStyle),
              width('Diastolisch', labelStyle),
              width('$systolic', numberStyle),
              width('$diastolic', numberStyle),
            ].reduce((a, b) => a > b ? a : b) +
            t.gapSmall * 2;
        final sys = field('Systolisch', systolic);
        final dia = field('Diastolisch', diastolic);
        if (constraints.maxWidth >= minimum * 2 + t.gapSmall) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: sys),
              SizedBox(width: t.gapSmall),
              Expanded(child: dia),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            sys,
            SizedBox(height: t.gapSmall),
            dia,
          ],
        );
      },
    );
  }
}
