import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/plan/occurrence_matching.dart';
import 'package:sphygma/plan/plan_models.dart';
import 'package:sphygma/stats/measurement_metadata.dart';

MeasurementKey key(int sequence, {int slot = 1}) =>
    (userSlot: slot, deviceSequence: sequence);

TimedMeasurement measurement(
  int sequence,
  DateTime localTime, {
  int slot = 1,
  bool plausible = true,
}) => TimedMeasurement(
  key: key(sequence, slot: slot),
  localTime: localTime,
  plausible: plausible,
);

PlannedOccurrence occurrence(
  String occurrenceKey,
  String localDate,
  int minuteOfDay, {
  int slot = 1,
  bool ambiguous = false,
}) => PlannedOccurrence(
  key: occurrenceKey,
  userSlot: slot,
  revisionId: 1,
  dueAt: ambiguous ? null : DateTime.utc(2026, 9, 11),
  localDate: localDate,
  minuteOfDay: minuteOfDay,
  zoneId: ambiguous ? null : 'Europe/Berlin',
  timeAmbiguous: ambiguous,
);

void main() {
  group('automatic matching', () {
    test(
      'includes both exact 15-minute boundaries and excludes beyond them',
      () {
        final planned = [occurrence('eight', '2026-09-11', 8 * 60)];

        Map<String, MeasurementKey> match(DateTime at) => matchOccurrences(
          [measurement(1, at)],
          planned,
          manualAssignments: const {},
        );

        expect(match(DateTime(2026, 9, 11, 7, 44, 59)), isEmpty);
        expect(match(DateTime(2026, 9, 11, 7, 45)), {'eight': key(1)});
        expect(match(DateTime(2026, 9, 11, 8, 15)), {'eight': key(1)});
        expect(match(DateTime(2026, 9, 11, 8, 15, 1)), isEmpty);
      },
    );

    test('measurement chooses only its nearest occurrence without spill', () {
      final matches = matchOccurrences(
        [measurement(1, DateTime(2026, 9, 11, 8, 10))],
        [
          occurrence('0800', '2026-09-11', 8 * 60),
          occurrence('0820', '2026-09-11', 8 * 60 + 20),
        ],
        manualAssignments: const {},
      );

      expect(matches, {'0800': key(1)});
    });

    test('occurrence key breaks a tie at the same civil time', () {
      final matches = matchOccurrences(
        [measurement(1, DateTime(2026, 9, 11, 8))],
        [
          occurrence('z-key', '2026-09-11', 8 * 60),
          occurrence('a-key', '2026-09-11', 8 * 60),
        ],
        manualAssignments: const {},
      );

      expect(matches, {'a-key': key(1)});
    });

    test('losing measurements do not spill into another occurrence', () {
      final matches = matchOccurrences(
        [
          measurement(1, DateTime(2026, 9, 11, 8, 1)),
          measurement(2, DateTime(2026, 9, 11, 8, 2)),
          measurement(3, DateTime(2026, 9, 11, 8, 3)),
        ],
        [
          occurrence('0800', '2026-09-11', 8 * 60),
          occurrence('0820', '2026-09-11', 8 * 60 + 20),
        ],
        manualAssignments: const {},
      );

      expect(matches, {'0800': key(1)});
    });

    test('winner tie uses earlier measurement then lower sequence', () {
      final planned = [occurrence('0800', '2026-09-11', 8 * 60)];

      expect(
        matchOccurrences(
          [
            measurement(9, DateTime(2026, 9, 11, 8, 5)),
            measurement(8, DateTime(2026, 9, 11, 7, 55)),
          ],
          planned,
          manualAssignments: const {},
        ),
        {'0800': key(8)},
      );
      expect(
        matchOccurrences(
          [
            measurement(9, DateTime(2026, 9, 11, 8, 5)),
            measurement(8, DateTime(2026, 9, 11, 8, 5)),
          ],
          planned,
          manualAssignments: const {},
        ),
        {'0800': key(8)},
      );
    });

    test(
      'matches civil components across midnight and ignores UTC semantics',
      () {
        final matches = matchOccurrences(
          [measurement(1, DateTime.utc(2026, 9, 12, 0, 5))],
          [occurrence('late', '2026-09-11', 23 * 60 + 58)],
          manualAssignments: const {},
        );

        expect(matches, {'late': key(1)});
      },
    );

    test('does not compare the measurement against dueAt', () {
      final planned = PlannedOccurrence(
        key: 'civil-eight',
        userSlot: 1,
        revisionId: 1,
        dueAt: DateTime.utc(2035, 1, 1),
        localDate: '2026-09-11',
        minuteOfDay: 8 * 60,
        zoneId: 'Europe/Berlin',
        timeAmbiguous: false,
      );

      expect(
        matchOccurrences(
          [measurement(1, DateTime(2026, 9, 11, 8))],
          [planned],
          manualAssignments: const {},
        ),
        {'civil-eight': key(1)},
      );
    });

    test('separates slots and ignores implausible measurements', () {
      final matches = matchOccurrences(
        [
          measurement(1, DateTime(2026, 9, 11, 8), plausible: false),
          measurement(2, DateTime(2026, 9, 11, 8), slot: 2),
        ],
        [occurrence('slot-1', '2026-09-11', 8 * 60)],
        manualAssignments: const {},
      );

      expect(matches, isEmpty);
    });

    test('ambiguous occurrence cannot be matched automatically', () {
      final matches = matchOccurrences(
        [measurement(1, DateTime(2026, 9, 11, 8))],
        [occurrence('ambiguous', '2026-09-11', 8 * 60, ambiguous: true)],
        manualAssignments: const {},
      );

      expect(matches, isEmpty);
    });

    test('uses device local time regardless of a later import', () {
      final matches = matchOccurrences(
        [measurement(1, DateTime(2026, 9, 10, 8))],
        [occurrence('today', '2026-09-11', 8 * 60)],
        manualAssignments: const {},
      );

      expect(matches, isEmpty);
    });
  });

  group('manual assignments', () {
    test('override automatic choice and may fulfill ambiguous occurrence', () {
      final matches = matchOccurrences(
        [measurement(1, DateTime(2026, 9, 11, 8), plausible: false)],
        [occurrence('ambiguous', '2026-09-11', 8 * 60, ambiguous: true)],
        manualAssignments: {key(1): 'ambiguous'},
      );

      expect(matches, {'ambiguous': key(1)});
    });

    test('null explicitly excludes measurement from automatic matching', () {
      final matches = matchOccurrences(
        [measurement(1, DateTime(2026, 9, 11, 8))],
        [occurrence('0800', '2026-09-11', 8 * 60)],
        manualAssignments: {key(1): null},
      );

      expect(matches, isEmpty);
    });

    test(
      'automatic candidate does not spill past manually occupied nearest term',
      () {
        final matches = matchOccurrences(
          [
            measurement(1, DateTime(2026, 9, 11, 8)),
            measurement(2, DateTime(2026, 9, 11, 8, 10)),
          ],
          [
            occurrence('0800', '2026-09-11', 8 * 60),
            occurrence('0820', '2026-09-11', 8 * 60 + 20),
          ],
          manualAssignments: {key(1): '0800'},
        );

        expect(matches, {'0800': key(1)});
      },
    );

    test('reject missing measurements and occurrences', () {
      expect(
        () => matchOccurrences(
          const [],
          [occurrence('0800', '2026-09-11', 8 * 60)],
          manualAssignments: {key(1): '0800'},
        ),
        throwsArgumentError,
      );
      expect(
        () => matchOccurrences(
          [measurement(1, DateTime(2026, 9, 11, 8))],
          [occurrence('0800', '2026-09-11', 8 * 60)],
          manualAssignments: {key(1): 'missing'},
        ),
        throwsArgumentError,
      );
    });

    test('rejects cross-slot and duplicate occurrence assignment', () {
      final measurements = [
        measurement(1, DateTime(2026, 9, 11, 8)),
        measurement(2, DateTime(2026, 9, 11, 8, 1)),
      ];
      final planned = [occurrence('slot-2', '2026-09-11', 8 * 60, slot: 2)];

      expect(
        () => matchOccurrences(
          measurements,
          planned,
          manualAssignments: {key(1): 'slot-2'},
        ),
        throwsArgumentError,
      );
      expect(
        () => matchOccurrences(
          measurements,
          [occurrence('0800', '2026-09-11', 8 * 60)],
          manualAssignments: {key(1): '0800', key(2): '0800'},
        ),
        throwsArgumentError,
      );
    });
  });

  group('model and input invariants', () {
    test('rejects invalid occurrence fields', () {
      expect(() => occurrence('', '2026-09-11', 480), throwsArgumentError);
      expect(
        () => occurrence('bad-slot', '2026-09-11', 480, slot: 3),
        throwsArgumentError,
      );
      expect(
        () => occurrence('bad-date', '2026-02-30', 480),
        throwsArgumentError,
      );
      expect(
        () => occurrence('negative', '2026-09-11', -1),
        throwsArgumentError,
      );
      expect(() => occurrence('late', '2026-09-11', 1440), throwsArgumentError);
      expect(
        () => PlannedOccurrence(
          key: 'partial-zone',
          userSlot: 1,
          revisionId: 1,
          dueAt: null,
          localDate: '2026-09-11',
          minuteOfDay: 480,
          zoneId: 'Europe/Berlin',
          timeAmbiguous: true,
        ),
        throwsArgumentError,
      );
      expect(
        () => PlannedOccurrence(
          key: 'unknown-but-certain',
          userSlot: 1,
          revisionId: 1,
          dueAt: null,
          localDate: '2026-09-11',
          minuteOfDay: 480,
          zoneId: null,
          timeAmbiguous: false,
        ),
        throwsArgumentError,
      );
      expect(
        () => PlannedOccurrence(
          key: 'local-due-at',
          userSlot: 1,
          revisionId: 1,
          dueAt: DateTime(2026, 9, 11, 8),
          localDate: '2026-09-11',
          minuteOfDay: 480,
          zoneId: 'Europe/Berlin',
          timeAmbiguous: false,
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate occurrence and measurement keys', () {
      expect(
        () => matchOccurrences(
          [measurement(1, DateTime(2026, 9, 11, 8))],
          [
            occurrence('same', '2026-09-11', 480),
            occurrence('same', '2026-09-12', 480),
          ],
          manualAssignments: const {},
        ),
        throwsArgumentError,
      );
      expect(
        () => matchOccurrences(
          [
            measurement(1, DateTime(2026, 9, 11, 8)),
            measurement(1, DateTime(2026, 9, 11, 8, 1)),
          ],
          [occurrence('0800', '2026-09-11', 480)],
          manualAssignments: const {},
        ),
        throwsArgumentError,
      );
    });
  });
}
