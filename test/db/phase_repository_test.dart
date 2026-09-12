import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/phase_repository.dart';

import 'measurement_metadata_repository_test.dart'
    show seedMetadataMeasurements;

void main() {
  late AppDatabase db;
  late PhaseRepository repo;
  final begin = DateTime(2026, 9, 1);
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = PhaseRepository(db);
    await seedMetadataMeasurements(db);
  });
  tearDown(() => db.close());
  Future<int> phase(String name, {int slot = 1}) =>
      repo.savePhase(userSlot: slot, name: name, begin: begin, end: null);
  const key = (userSlot: 1, deviceSequence: 10);

  test(
    'Mehrfachauswahl, leere Ausnahme und Automatik bleiben verschieden',
    () async {
      final a = await phase('A');
      final b = await phase('B');
      expect(await repo.selections(1), isEmpty);
      await repo.select(key, {a, b});
      expect((await repo.selections(1))[10], {a, b});
      await repo.select(key, {});
      expect((await repo.selections(1))[10], isEmpty);
      await repo.useAutomatic(key);
      expect((await repo.selections(1)).containsKey(10), isFalse);
    },
  );
  test(
    'Phasenlöschen erhält ausdrückliche leere Auswahl und Rohwerte',
    () async {
      final a = await phase('A');
      await repo.select(key, {a});
      await repo.deletePhase(a);
      expect((await repo.selections(1))[10], isEmpty);
      expect(await db.select(db.measurements).get(), hasLength(4));
    },
  );
  test(
    'fremde Phase, fehlende Messung und ungültige Zeit werden abgewiesen',
    () async {
      final a = await phase('A');
      final b = await phase('B', slot: 2);
      await repo.select(key, {a});
      await expectLater(repo.select(key, {a, b}), throwsArgumentError);
      await expectLater(
        repo.select((userSlot: 1, deviceSequence: 999), {a}),
        throwsStateError,
      );
      await expectLater(
        repo.savePhase(
          userSlot: 1,
          name: 'X',
          begin: begin,
          end: begin.subtract(const Duration(days: 1)),
        ),
        throwsArgumentError,
      );
      await expectLater(
        repo.savePhase(id: b, userSlot: 1, name: 'X', begin: begin, end: null),
        throwsArgumentError,
      );
      expect((await repo.selections(1))[10], {a});
      expect((await repo.phases(2)).single.name, 'B');
    },
  );
  test(
    'Umbenennen und Zeitraumkorrektur erhalten Phase und Zuordnungen',
    () async {
      final a = await phase(' A ');
      await repo.select(key, {a});
      expect(
        await repo.savePhase(
          id: a,
          userSlot: 1,
          name: 'Neu',
          begin: begin,
          end: DateTime(2026, 9, 12),
        ),
        a,
      );
      final row = (await repo.phases(1)).single;
      expect(row.name, 'Neu');
      expect(row.endsAt, DateTime(2026, 9, 12));
      expect(row.anchor, 'bestaetigt');
      expect((await repo.selections(1))[10], {a});
    },
  );
}
