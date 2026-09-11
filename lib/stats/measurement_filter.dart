import '../db/app_database.dart';

enum MatchMode { any, all }

enum MembershipFilter { unrestricted, selected, unassigned }

class HistoryFilter {
  const HistoryFilter({
    this.tagIds = const {},
    this.tagMode = MatchMode.any,
    this.tags = MembershipFilter.unrestricted,
    this.phaseIds = const {},
    this.phaseMode = MatchMode.any,
    this.phases = MembershipFilter.unrestricted,
  });
  final Set<int> tagIds;
  final Set<int> phaseIds;
  final MatchMode tagMode;
  final MatchMode phaseMode;
  final MembershipFilter tags;
  final MembershipFilter phases;
  bool get isActive =>
      tags != MembershipFilter.unrestricted ||
      phases != MembershipFilter.unrestricted;
  HistoryFilter copyWith({
    Set<int>? tagIds,
    Set<int>? phaseIds,
    MatchMode? tagMode,
    MatchMode? phaseMode,
    MembershipFilter? tags,
    MembershipFilter? phases,
  }) => HistoryFilter(
    tagIds: tagIds ?? this.tagIds,
    phaseIds: phaseIds ?? this.phaseIds,
    tagMode: tagMode ?? this.tagMode,
    phaseMode: phaseMode ?? this.phaseMode,
    tags: tags ?? this.tags,
    phases: phases ?? this.phases,
  );
}

bool matchesMembership(
  Set<int> actual,
  Set<int> selected,
  MembershipFilter filter,
  MatchMode mode,
) => switch (filter) {
  MembershipFilter.unrestricted => true,
  MembershipFilter.unassigned => actual.isEmpty,
  MembershipFilter.selected =>
    selected.isNotEmpty &&
        (mode == MatchMode.all
            ? actual.containsAll(selected)
            : selected.any(actual.contains)),
};

List<Measurement> applyHistoryFilter(
  List<Measurement> inPeriod,
  HistoryFilter filter, {
  required Map<int, Set<int>> tagIdsBySequence,
  required Map<int, Set<int>> phaseIdsBySequence,
}) => [
  for (final measurement in inPeriod)
    if (matchesMembership(
          tagIdsBySequence[measurement.deviceSequence] ?? const {},
          filter.tagIds,
          filter.tags,
          filter.tagMode,
        ) &&
        matchesMembership(
          phaseIdsBySequence[measurement.deviceSequence] ?? const {},
          filter.phaseIds,
          filter.phases,
          filter.phaseMode,
        ))
      measurement,
];
