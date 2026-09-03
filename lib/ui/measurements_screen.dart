import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/feature_flags.dart';
import '../db/app_database.dart';
import '../stats/esc_classification.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key, required this.controller});

  final AppController controller;

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _day(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';
  static String _time(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c.userSlot == null) {
      return const Center(child: Text('Bitte zuerst pairen und den User-Slot waehlen.'));
    }
    if (c.measurements.isEmpty) {
      return const Center(child: Text('Noch keine Messungen. Jetzt synchronisieren.'));
    }

    // Nach Tag gruppieren; die Liste ist neueste zuerst.
    final items = <Widget>[];
    String? currentDay;
    for (final m in c.measurements) {
      final day = _day(m.measuredAt);
      if (day != currentDay) {
        currentDay = day;
        items.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(day, style: Theme.of(context).textTheme.labelLarge),
        ));
      }
      items.add(_MeasurementTile(measurement: m, controller: c));
    }
    return ListView(children: items);
  }
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({required this.measurement, required this.controller});

  final Measurement measurement;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final m = measurement;
    final exported = m.exportedAt != null;
    final flags = <String>[
      if (m.movement) 'Bewegung',
      if (m.arrhythmia) 'unregelmaessiger Puls',
      if (escClassificationEnabled)
        _escLabel(classifyOffice(systolic: m.systolic, diastolic: m.diastolic)),
    ];
    return ListTile(
      title: Text('${m.systolic} / ${m.diastolic} mmHg  ·  ${m.pulse} /min'),
      subtitle: Text(
        [MeasurementsScreen._time(m.measuredAt), ...flags].join('  ·  '),
      ),
      trailing: IconButton(
        tooltip: exported ? 'Aus Health Connect entfernen' : 'Nach Health Connect senden',
        icon: Icon(exported ? Icons.cloud_done : Icons.cloud_upload_outlined),
        onPressed: controller.busy
            ? null
            : () async {
                try {
                  if (exported) {
                    await controller.retractOne(m);
                  } else {
                    await controller.exportOne(m);
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppController.describe(e))),
                  );
                }
              },
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
