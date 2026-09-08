// Zeile und Knopf der technischen Abschnitte.
//
// Alle Karten der Einstellungen zeigen dieselben Bauformen: eine Zeile mit
// Beschriftung links und Wert rechts, und einen Knopf über die volle Breite.
// Als Kopie je Abschnitt liefen sie auseinander, sobald eine angefasst wird.
import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.label,
    required this.value,
    this.dot = false,
  });

  final String label;
  final String value;

  /// Gruener Punkt vor dem Text - zeigt einen laufenden Zustand an.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: t.rowSpacing(t.gapSmall + 2)),
      decoration: t.rowDivider,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (dot) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.categoryColors.values.first,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(label, style: TextStyle(fontSize: 13, color: t.onSurface)),
            ],
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingButton extends StatelessWidget {
  const SettingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: t.gapSmall),
      child: SizedBox(
        width: double.infinity,
        child: filled
            ? FilledButton(onPressed: onPressed, child: Text(label))
            : OutlinedButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}
