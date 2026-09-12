// lib/ui/measurement_sheet.dart
// Alles zu einer einzelnen Messung. Die Massenaktionen bleiben im
// Geraetebereich; hier steht der Einzelexport, weil er zu genau dieser
// Messung gehoert (Spezifikation vom 2026-09-05).
import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/feature_flags.dart';
import '../db/app_database.dart';
import '../db/measurement_repository.dart';
import '../stats/esc_classification.dart';
import 'format.dart';
import 'theme/sphygma_theme.dart';
import 'widgets/classification_scale.dart';
import 'widgets/panel_header.dart';
import 'widgets/reading_headline.dart';
import 'widgets/surface_panel.dart';
import 'metadata/measurement_metadata_editor.dart';
import 'phases/phase_selection_editor.dart';

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
    builder: (_) =>
        MeasurementSheet(controller: controller, measurementId: measurementId),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(t.gapLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SurfacePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PanelHeader(
                          title: 'Messwert',
                          icon: Icons.monitor_heart_outlined,
                        ),
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
                      ],
                    ),
                  ),
                  SizedBox(height: t.gapLarge),
                  SurfacePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PanelHeader(
                          title: 'Messungsdetails',
                          icon: Icons.info_outline,
                        ),
                        SizedBox(height: t.gapSmall),
                        _Row(
                          label: 'Messung Nr.',
                          value: '${m.deviceSequence}',
                        ),
                        _Row(
                          label: 'Speicherplatz',
                          value: 'Benutzer ${m.userSlot}',
                        ),
                        _Row(
                          label: 'Eingelesen',
                          value: formatDayAndTime(m.importedAt),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: t.gapLarge),
                  SurfacePanel(
                    child: _HealthConnect(
                      controller: controller,
                      measurement: m,
                    ),
                  ),
                  SizedBox(height: t.gapLarge),
                  SurfacePanel(
                    child: MeasurementMetadataEditor(
                      controller: controller,
                      deviceSequence: m.deviceSequence,
                    ),
                  ),
                  if (controller.phasesEnabled) ...[
                    SizedBox(height: t.gapLarge),
                    SurfacePanel(
                      child: PhaseSelectionEditor(
                        controller: controller,
                        deviceSequence: m.deviceSequence,
                      ),
                    ),
                  ],
                ],
              ),
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
      child: Wrap(
        spacing: t.gapLarge,
        runSpacing: t.gapSmall / 2,
        alignment: WrapAlignment.spaceBetween,
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

  /// Wie im Geraetebereich: [AppController] wirft nach dem Setzen von
  /// `status` erneut. Ohne diesen Fang liefe der Fehler als unbeobachtete
  /// Ausnahme in die Zone, statt als Meldung sichtbar zu werden.
  static void _start(Future<void> Function() action) {
    unawaited(
      action().catchError((Object e) {
        debugPrint('[Sphygma] Aktion fehlgeschlagen: $e');
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final exported = measurement.exportedAt != null;
    final state = controller.exportStates[measurement.id];
    final canRetract =
        exported ||
        state == MeasurementExportState.pendingWrite ||
        state == MeasurementExportState.pendingRetraction ||
        state == MeasurementExportState.legacyUnknown;
    final description = switch (state) {
      MeasurementExportState.legacyUnknown =>
        'Übertragungsstatus aus früherer Version unbekannt',
      MeasurementExportState.pendingWrite =>
        'Übertragung nicht vollständig bestätigt',
      MeasurementExportState.pendingRetraction =>
        'Entfernung noch nicht bestätigt',
      MeasurementExportState.retracted => 'Aus Health Connect entfernt',
      _ =>
        exported
            ? 'Übertragen am ${formatDayAndTime(measurement.exportedAt!)}'
            : 'Noch nicht übertragen',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PanelHeader(
          title: 'Health Connect',
          icon: Icons.health_and_safety_outlined,
        ),
        SizedBox(height: t.gapSmall),
        Text(description, style: TextStyle(fontSize: 13, color: t.onSurface)),
        SizedBox(height: t.gapSmall),
        if (!exported)
          OutlinedButton(
            onPressed: controller.busy || controller.intakeDecisionPending
                ? null
                : () => _start(() => controller.exportOne(measurement)),
            child: const Text('Nach Health Connect übertragen'),
          ),
        if (canRetract)
          OutlinedButton(
            onPressed: controller.busy
                ? null
                : () => _start(() => controller.retractOne(measurement)),
            child: const Text('Aus Health Connect entfernen'),
          ),
      ],
    );
  }
}
