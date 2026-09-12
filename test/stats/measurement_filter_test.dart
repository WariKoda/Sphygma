import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/measurement_filter.dart';

Measurement measurement(int sequence) => Measurement(
  id: sequence,
  userSlot: 1,
  deviceSequence: sequence,
  measuredAt: DateTime(2026, 9, 11),
  systolic: 120,
  diastolic: 80,
  pulse: 70,
  arrhythmia: false,
  movement: false,
  rawBytes: Uint8List(14),
  importedAt: DateTime.utc(2026, 9, 11),
);

void main() {
  test('membership unterscheidet any, all und unassigned', () {
    expect(
      matchesMembership({1}, {1, 2}, MembershipFilter.selected, MatchMode.any),
      isTrue,
    );
    expect(
      matchesMembership({1}, {1, 2}, MembershipFilter.selected, MatchMode.all),
      isFalse,
    );
    expect(
      matchesMembership(
        {1, 2},
        {1, 2},
        MembershipFilter.selected,
        MatchMode.all,
      ),
      isTrue,
    );
    expect(
      matchesMembership({}, {}, MembershipFilter.unassigned, MatchMode.any),
      isTrue,
    );
  });

  test('verknüpft Tag- und Phasenfilter und zählt jede Messung einmal', () {
    final result = applyHistoryFilter(
      [measurement(1), measurement(2), measurement(3)],
      const HistoryFilter(
        tagIds: {10, 11},
        tags: MembershipFilter.selected,
        tagMode: MatchMode.all,
        phaseIds: {20},
        phases: MembershipFilter.selected,
      ),
      tagIdsBySequence: {
        1: {10, 11},
        2: {10},
        3: {10, 11},
      },
      phaseIdsBySequence: {
        1: {20, 21},
        2: {20},
        3: {},
      },
    );
    expect(result.map((m) => m.deviceSequence), [1]);
  });

  test('reset lässt Bestand unverändert und fehlende Zuordnung ist leer', () {
    final values = [measurement(1), measurement(2)];
    expect(
      applyHistoryFilter(
        values,
        const HistoryFilter(),
        tagIdsBySequence: const {},
        phaseIdsBySequence: const {},
      ),
      values,
    );
    expect(
      applyHistoryFilter(
        values,
        const HistoryFilter(tags: MembershipFilter.unassigned),
        tagIdsBySequence: const {},
        phaseIdsBySequence: const {},
      ),
      values,
    );
  });
}
