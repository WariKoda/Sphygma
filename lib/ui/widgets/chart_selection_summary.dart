import 'package:flutter/material.dart';

import '../../db/app_database.dart';
import '../theme/sphygma_theme.dart';

class ChartSelectionSummary extends StatelessWidget {
  const ChartSelectionSummary({
    super.key,
    required this.measurement,
    this.onPrevious,
    this.onNext,
  });

  final Measurement measurement;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = SphygmaTheme.of(context);
    final at = measurement.measuredAt;
    final date =
        '${_two(at.day)}.${_two(at.month)}.${at.year}, ${_two(at.hour)}:${_two(at.minute)}';
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: EdgeInsets.only(top: theme.gapSmall),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: theme.gapSmall,
          runSpacing: theme.gapSmall / 2,
          children: [
            IconButton(
              tooltip: 'Vorherige Messung',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '$date · ${measurement.systolic} / ${measurement.diastolic} mmHg · Puls ${measurement.pulse} /min',
              style: TextStyle(color: theme.onSurface),
            ),
            IconButton(
              tooltip: 'Nächste Messung',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

String _two(int value) => value.toString().padLeft(2, '0');
