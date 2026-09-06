// Der Bildschirm beim Oeffnen. Vorn steht der Wert, nicht die Technik.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/feature_flags.dart';
import '../db/app_database.dart';
import '../stats/esc_classification.dart';
import 'theme/sphygma_theme.dart';
import 'widgets/classification_scale.dart';
import 'widgets/notice_card.dart';
import 'widgets/reading_headline.dart';

/// Die Schritte aus dem Handbuch HEM-6232T-E. Die Uhr laesst sich nicht
/// per Bluetooth stellen (docs/protocol/hem-6232t.md §8.7), also bleibt
/// nur, sie zu erklaeren.
const String clockInstructions =
    'Batterien herausnehmen und wieder einlegen. Dann die Taste gedrückt '
    'halten, bis das Jahr blinkt. Jahr, Monat, Tag, Stunde und Minute '
    'nacheinander mit START/STOP bestätigen; die andere Taste ändert den '
    'Wert, gehalten springt sie schnell. Zum Schluss START/STOP drücken, '
    'um zu speichern.';

/// Wie viele der letzten Messungen unter dem grossen Wert erscheinen.
const int _recentCount = 5;

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final latest = controller.latest;

    return Container(
      color: t.surface,
      child: ListView(
        padding: EdgeInsets.all(t.gapLarge),
        children: [
          if (latest == null)
            _EmptyState(paired: controller.paired)
          else ...[
            ReadingHeadline(
              systolic: latest.systolic,
              diastolic: latest.diastolic,
              pulse: latest.pulse,
              measuredAt: latest.measuredAt,
            ),
            if (escClassificationEnabled) ...[
              SizedBox(height: t.gapLarge),
              ClassificationScale(
                category: classifyOffice(
                  systolic: latest.systolic,
                  diastolic: latest.diastolic,
                ),
              ),
            ],
          ],
          ..._notices(),
          if (controller.measurements.length > 1) ...[
            SizedBox(height: t.gapLarge),
            Text(
              'LETZTE TAGE',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.6,
                color: t.muted,
              ),
            ),
            for (final m in controller.measurements.skip(1).take(_recentCount))
              _RecentRow(measurement: m),
          ],
        ],
      ),
    );
  }

  /// Hinweise erscheinen nur, wenn es etwas zu sagen gibt.
  List<Widget> _notices() => [
        if (!controller.paired)
          const NoticeCard(
            title: 'Nicht gekoppelt',
            message: 'Ohne Kopplung kann Sphygma keine Messungen holen. '
                'Unter "Gerät" einrichten.',
          ),
        if (controller.clockLooksWrong)
          const NoticeCard(
            title: 'Geräteuhr geht falsch',
            message: 'Die neueste Messung trägt ein unplausibles Datum. '
                'Sphygma kann die Uhr nicht stellen, das geht nur am Gerät.',
            details: clockInstructions,
          ),
        if (controller.paired && !controller.autoSyncActive)
          const NoticeCard(
            title: 'Kein automatischer Abgleich',
            message: 'Neue Messungen werden nicht von selbst geholt. '
                'Unter "Gerät" lässt sich der Abgleich von Hand auslösen.',
          ),
      ];
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.paired});

  final bool paired;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.gapLarge * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Noch keine Messung',
            style: TextStyle(
              fontSize: 20,
              fontWeight: t.headlineWeight,
              color: t.onSurface,
            ),
          ),
          SizedBox(height: t.gapSmall),
          Text(
            paired
                ? 'Miss am Gerät - Sphygma holt die Messung von selbst.'
                : 'Zuerst unter "Gerät" koppeln.',
            style: TextStyle(fontSize: 13, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.measurement});

  final Measurement measurement;

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final m = measurement;

    return Container(
      padding: EdgeInsets.symmetric(vertical: t.rowSpacing(t.gapSmall + 2)),
      decoration: t.rowDivider,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${m.systolic}/${m.diastolic} · ${m.pulse}',
            style: TextStyle(
              fontSize: 13,
              color: t.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            '${_two(m.measuredAt.day)}.${_two(m.measuredAt.month)}. '
            '${_two(m.measuredAt.hour)}:${_two(m.measuredAt.minute)}',
            style: TextStyle(fontSize: 12, color: t.muted),
          ),
        ],
      ),
    );
  }
}
