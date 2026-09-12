import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/phase_repository.dart';
import 'package:sphygma/stats/phase_grouping.dart';

void main() {
  test(
    'alle Zeiträume, halb offene Grenzen und vollständige manuelle Ausnahme',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = PhaseRepository(db);
      final begin = DateTime(2026, 9, 1);
      final end = DateTime(2026, 9, 10);
      final a = await repo.savePhase(
        userSlot: 1,
        name: 'A',
        begin: begin,
        end: end,
      );
      final b = await repo.savePhase(
        userSlot: 1,
        name: 'B',
        begin: begin,
        end: null,
      );
      final phases = await repo.phases(1);
      Set<int> resolve(
        DateTime at, {
        bool plausible = true,
        Set<int>? manual,
      }) => resolvePhaseIds(
        measuredAt: at,
        timePlausible: plausible,
        phases: phases,
        manualSelection: manual,
      );
      expect(resolve(begin), {a, b});
      expect(resolve(end), {b});
      expect(resolve(begin.subtract(const Duration(seconds: 1))), isEmpty);
      expect(resolve(begin, plausible: false), isEmpty);
      expect(resolve(begin, manual: {}), isEmpty);
      expect(resolve(end, plausible: false, manual: {a}), {a});
      expect(() => resolve(begin, manual: {999}), throwsStateError);
    },
  );
}
