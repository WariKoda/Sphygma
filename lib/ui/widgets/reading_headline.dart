// Die grosse Wertdarstellung. Steht auf "Heute" und im Detail-Blatt.
import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

class ReadingHeadline extends StatelessWidget {
  const ReadingHeadline({
    super.key,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.measuredAt,
  });

  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime measuredAt;

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final zeit = '${_twoDigits(measuredAt.day)}.'
        '${_twoDigits(measuredAt.month)}.${measuredAt.year}, '
        '${_twoDigits(measuredAt.hour)}:${_twoDigits(measuredAt.minute)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          zeit,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.4,
            color: t.muted,
          ),
        ),
        SizedBox(height: t.gapSmall),
        Text(
          '$systolic/$diastolic',
          style: TextStyle(
            fontSize: t.headlineSize,
            height: 1,
            fontWeight: FontWeight.w300,
            letterSpacing: -1.5,
            color: t.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(height: t.gapSmall / 2),
        Text(
          'mmHg · Puls $pulse',
          style: TextStyle(fontSize: 12, color: t.muted),
        ),
      ],
    );
  }
}
