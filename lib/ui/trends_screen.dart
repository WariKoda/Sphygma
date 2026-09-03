import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/feature_flags.dart';
import '../stats/esc_classification.dart';
import '../stats/trend_stats.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final readings = controller.measurements
        .map((m) => Reading(
              measuredAt: m.measuredAt,
              systolic: m.systolic,
              diastolic: m.diastolic,
              pulse: m.pulse,
            ))
        .toList();
    final stats = TrendStats.compute(readings, now: DateTime.now());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AverageCard(title: 'Letzte 7 Tage', average: stats.last7Days),
        _AverageCard(title: 'Morgens (vor 12 Uhr)', average: stats.morning),
        _AverageCard(title: 'Abends (ab 18 Uhr)', average: stats.evening),
        const SizedBox(height: 8),
        const Text(
          'Mittelwerte der letzten 7 Tage laut Geraeteuhr. Keine medizinische '
          'Bewertung.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _AverageCard extends StatelessWidget {
  const _AverageCard({required this.title, required this.average});

  final String title;
  final Average? average;

  @override
  Widget build(BuildContext context) {
    final a = average;
    final String value;
    final String? esc;
    if (a == null) {
      value = 'keine Messungen';
      esc = null;
    } else {
      value = '${a.systolic} / ${a.diastolic} mmHg  ·  ${a.pulse} /min  '
          '(${a.count} Messungen)';
      esc = escClassificationEnabled
          ? _escLabel(classifyOffice(systolic: a.systolic, diastolic: a.diastolic))
          : null;
    }
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(esc == null ? value : '$value\nESC/ESH 2018: $esc'),
        isThreeLine: esc != null,
      ),
    );
  }

  static String _escLabel(EscCategory category) => switch (category) {
        EscCategory.optimal => 'optimal',
        EscCategory.normal => 'normal',
        EscCategory.highNormal => 'hochnormal',
        EscCategory.grade1 => 'Hypertonie Grad 1',
        EscCategory.grade2 => 'Hypertonie Grad 2',
        EscCategory.grade3 => 'Hypertonie Grad 3',
      };
}
