// lib/ui/measurement_sheet.dart
// Alles zu einer einzelnen Messung. Die Massenaktionen bleiben im
// Geraetebereich; hier steht der Einzelexport, weil er zu genau dieser
// Messung gehoert (Spezifikation vom 2026-09-05).
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/feature_flags.dart';
import '../db/app_database.dart';
import '../stats/esc_classification.dart';
import 'format.dart';
import 'theme/sphygma_theme.dart';
import 'widgets/classification_scale.dart';
import 'widgets/reading_headline.dart';

Future<void> showMeasurementSheet(
  BuildContext context, {
  required AppController controller,
  required int measurementId,
}) {
  final theme = SphygmaTheme.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: theme.surface,
    isScrollControlled: true,
    builder: (_) => SphygmaThemeScope(
      theme: theme,
      child: MeasurementSheet(
        controller: controller,
        measurementId: measurementId,
      ),
    ),
  );
}

class MeasurementSheet extends StatelessWidget {
  const MeasurementSheet({
    super.key,
    required this.controller,
    required this.measurementId,
  });

  final AppController controller;

  /// Nicht die Messung selbst: Nach einem Export ist das alte Objekt
  /// veraltet. Die Nummer bleibt gueltig, der Zustand wird frisch geholt.
  final int measurementId;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final m = _require(controller.measurements, measurementId);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(t.gapLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReadingHeadline(
                  systolic: m.systolic,
                  diastolic: m.diastolic,
                  pulse: m.pulse,
                  measuredAt: m.measuredAt,
                ),
                if (escClassificationEnabled) ...[
                  SizedBox(height: t.gapLarge),
                  ClassificationScale(
                    category: classifyOffice(
                      systolic: m.systolic,
                      diastolic: m.diastolic,
                    ),
                  ),
                ],
                if (m.movement || m.arrhythmia) ...[
                  SizedBox(height: t.gapLarge),
                  if (m.movement)
                    const _Flag(text: 'Bewegung während der Messung'),
                  if (m.arrhythmia)
                    const _Flag(text: 'Unregelmäßiger Puls'),
                ],
                SizedBox(height: t.gapLarge),
                _Row(label: 'Messung Nr.', value: '${m.deviceSequence}'),
                _Row(label: 'Speicherplatz', value: 'Benutzer ${m.userSlot}'),
                _Row(
                  label: 'Eingelesen',
                  value: formatDayAndTime(m.importedAt),
                ),
                SizedBox(height: t.gapLarge),
                _HealthConnect(controller: controller, measurement: m),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Wirft, wenn die Messung fortgefallen ist. Ein leeres Blatt waere von
  /// einer geladenen Messung ohne Werte nicht zu unterscheiden.
  static Measurement _require(List<Measurement> all, int id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    throw StateError('Messung $id ist nicht (mehr) vorhanden.');
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: t.gapSmall),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 15, color: t.muted),
          SizedBox(width: t.gapSmall),
          Text(text, style: TextStyle(fontSize: 13, color: t.onSurface)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.gapSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: t.muted)),
          Text(value, style: TextStyle(fontSize: 13, color: t.onSurface)),
        ],
      ),
    );
  }
}

class _HealthConnect extends StatelessWidget {
  const _HealthConnect({required this.controller, required this.measurement});

  final AppController controller;
  final Measurement measurement;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final exported = measurement.exportedAt != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'HEALTH CONNECT',
          style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: t.muted),
        ),
        SizedBox(height: t.gapSmall),
        Text(
          exported
              ? 'Übertragen am ${formatDayAndTime(measurement.exportedAt!)}'
              : 'Noch nicht übertragen',
          style: TextStyle(fontSize: 13, color: t.onSurface),
        ),
        SizedBox(height: t.gapSmall),
        OutlinedButton(
          onPressed: controller.busy
              ? null
              : () => exported
                  ? controller.retractOne(measurement)
                  : controller.exportOne(measurement),
          child: Text(
            exported
                ? 'Aus Health Connect entfernen'
                : 'Nach Health Connect übertragen',
          ),
        ),
      ],
    );
  }
}
