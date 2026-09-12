import '../db/app_database.dart';

Set<int> resolvePhaseIds({
  required DateTime measuredAt,
  required bool timePlausible,
  required List<ScopedPhase> phases,
  required Set<int>? manualSelection,
}) {
  if (manualSelection != null) {
    final existing = phases.map((phase) => phase.id).toSet();
    if (!existing.containsAll(manualSelection)) {
      throw StateError('Manuelle Auswahl verweist auf fehlende Phase.');
    }
    return Set.unmodifiable(manualSelection);
  }
  if (!timePlausible) return const {};
  return Set.unmodifiable(
    phases
        .where(
          (phase) =>
              !measuredAt.isBefore(phase.beginsAt) &&
              (phase.endsAt == null || measuredAt.isBefore(phase.endsAt!)),
        )
        .map((phase) => phase.id),
  );
}
