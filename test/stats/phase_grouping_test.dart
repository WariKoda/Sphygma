import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/phase_grouping.dart';

Measurement _m(int seq, DateTime at, {int sys = 128}) => Measurement(
      id: seq,
      userSlot: 1,
      deviceSequence: seq,
      systolic: sys,
      diastolic: 84,
      pulse: 78,
      measuredAt: at,
      movement: false,
      arrhythmia: false,
      rawBytes: Uint8List(14),
      importedAt: DateTime(2026, 9, 5, 23, 58),
      exportedAt: null,
    );

Phase _p(int id, String name, DateTime von, {DateTime? bis}) => Phase(
      id: id,
      name: name,
      beginsAt: von,
      endsAt: bis,
      anchor: 'bestaetigt',
      createdAt: von,
    );

final _jetzt = DateTime(2026, 9, 6, 12);

void main() {
  group('Zuordnung über den Zeitraum', () {
    test('eine Messung fällt in die Phase, die sie enthält', () {
      final gruppen = groupByPhase(
        [
          _m(1, DateTime(2026, 8, 15, 8)),
          _m(2, DateTime(2026, 8, 20, 8)),
        ],
        phases: [_p(1, 'Ramipril 5 mg', DateTime(2026, 8, 12))],
        assignments: const {},
        now: _jetzt,
      );

      expect(gruppen.memberships.single.count, 2);
      expect(gruppen.unassigned, isEmpty);
      expect(gruppen.unclear, isEmpty);
    });

    test('vor dem Beginn liegt außerhalb', () {
      final gruppen = groupByPhase(
        [_m(1, DateTime(2026, 8, 1, 8))],
        phases: [_p(1, 'Ramipril 5 mg', DateTime(2026, 8, 12))],
        assignments: const {},
        now: _jetzt,
      );

      expect(gruppen.memberships.single.count, 0);
      expect(gruppen.unassigned, hasLength(1));
    });

    test('das Ende schließt nicht ein', () {
      final gruppen = groupByPhase(
        [_m(1, DateTime(2026, 8, 20))],
        phases: [
          _p(1, 'Urlaub', DateTime(2026, 8, 10), bis: DateTime(2026, 8, 20)),
        ],
        assignments: const {},
        now: _jetzt,
      );

      expect(gruppen.unassigned, hasLength(1));
    });

    test('bei Überschneidung gewinnt die zuletzt begonnene', () {
      // "Urlaub" während "Ramipril": die speziellere Aussage gewinnt, und
      // dieselbe Messung geht nicht in zwei Vergleiche ein.
      final gruppen = groupByPhase(
        [_m(1, DateTime(2026, 8, 20, 8))],
        phases: [
          _p(1, 'Ramipril 5 mg', DateTime(2026, 8, 12)),
          _p(2, 'Urlaub', DateTime(2026, 8, 18), bis: DateTime(2026, 8, 25)),
        ],
        assignments: const {},
        now: _jetzt,
      );

      final urlaub =
          gruppen.memberships.firstWhere((m) => m.phase.name == 'Urlaub');
      expect(urlaub.count, 1);
      expect(gruppen.total, 1, reason: 'keine Messung zählt doppelt');
    });
  });

  group('Die falsche Geräteuhr', () {
    test('eine unglaubwürdig datierte Messung bleibt ungeklärt', () {
      // Höchste Nummer, aber Datum von 2023: Die Uhr stand falsch. Sie still
      // in die laufende Phase fallen zu lassen, hieße den Vergleich auf eine
      // erfundene Zeitachse zu stellen.
      final gruppen = groupByPhase(
        [
          _m(1, DateTime(2026, 8, 15, 8)),
          _m(2, DateTime(2026, 8, 16, 8)),
          _m(3, DateTime(2023, 4, 18, 11)),
        ],
        phases: [_p(1, 'Ramipril 5 mg', DateTime(2026, 8, 12))],
        assignments: const {},
        now: _jetzt,
      );

      expect(gruppen.unclear, hasLength(1));
      expect(gruppen.unclear.single.deviceSequence, 3);
      expect(gruppen.memberships.single.count, 2);
    });

    test('eine Entscheidung des Nutzers überstimmt die Zweifel', () {
      final gruppen = groupByPhase(
        [
          _m(1, DateTime(2026, 8, 15, 8)),
          _m(2, DateTime(2026, 8, 16, 8)),
          _m(3, DateTime(2023, 4, 18, 11)),
        ],
        phases: [_p(1, 'Ramipril 5 mg', DateTime(2026, 8, 12))],
        assignments: const {3: 1},
        now: _jetzt,
      );

      expect(gruppen.unclear, isEmpty);
      expect(gruppen.memberships.single.count, 3);
    });
  });

  group('Entscheidungen des Nutzers', () {
    test('"zu keiner Phase" ist eine Aussage, kein fehlender Wert', () {
      final gruppen = groupByPhase(
        [_m(1, DateTime(2026, 8, 15, 8))],
        phases: [_p(1, 'Ramipril 5 mg', DateTime(2026, 8, 12))],
        assignments: const {1: null},
        now: _jetzt,
      );

      expect(gruppen.memberships.single.count, 0);
      expect(gruppen.unassigned, hasLength(1));
    });

    test('eine Zuordnung auf eine gelöschte Phase zählt nicht mehr', () {
      final gruppen = groupByPhase(
        [_m(1, DateTime(2026, 8, 15, 8))],
        phases: [_p(1, 'Ramipril 5 mg', DateTime(2026, 8, 12))],
        assignments: const {1: 99},
        now: _jetzt,
      );

      expect(gruppen.unassigned, hasLength(1));
    });
  });

  test('jede Messung steht in genau einer Liste', () {
    final messungen = [
      for (var i = 1; i <= 10; i++) _m(i, DateTime(2026, 8, 10 + i, 8)),
      _m(11, DateTime(2023, 4, 18, 11)),
    ];
    final gruppen = groupByPhase(
      messungen,
      phases: [
        _p(1, 'Ramipril 5 mg', DateTime(2026, 8, 15)),
      ],
      assignments: const {},
      now: _jetzt,
    );

    expect(gruppen.total, messungen.length);
  });
}
