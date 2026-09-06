import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/occasion_repository.dart';

void main() {
  late AppDatabase db;
  late OccasionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = OccasionRepository(db);
  });

  tearDown(() => db.close());

  group('Entscheidungen über Messanlässe', () {
    test('ohne Entscheidungen ist beides leer', () async {
      expect(await repo.confirmedJoins(1), isEmpty);
      expect(await repo.confirmedSplits(1), isEmpty);
    });

    test('eine bestätigte Zusammenfassung wird gemerkt', () async {
      await repo.confirmJoin(userSlot: 1, deviceSequence: 542);

      expect(await repo.confirmedJoins(1), {542});
      expect(await repo.confirmedSplits(1), isEmpty);
    });

    test('eine bestätigte Trennung wird gemerkt', () async {
      await repo.confirmSplit(userSlot: 1, deviceSequence: 542);

      expect(await repo.confirmedSplits(1), {542});
      expect(await repo.confirmedJoins(1), isEmpty);
    });

    test('die spätere Entscheidung ersetzt die frühere', () async {
      await repo.confirmJoin(userSlot: 1, deviceSequence: 542);
      await repo.confirmSplit(userSlot: 1, deviceSequence: 542);

      expect(await repo.confirmedJoins(1), isEmpty);
      expect(await repo.confirmedSplits(1), {542});
    });

    test('eine Entscheidung lässt sich zurücknehmen', () async {
      await repo.confirmSplit(userSlot: 1, deviceSequence: 542);
      await repo.clearDecision(userSlot: 1, deviceSequence: 542);

      expect(await repo.confirmedSplits(1), isEmpty);
      expect(await repo.confirmedJoins(1), isEmpty);
    });

    test('Speicherplätze werden getrennt geführt', () async {
      await repo.confirmJoin(userSlot: 1, deviceSequence: 100);
      await repo.confirmSplit(userSlot: 2, deviceSequence: 100);

      expect(await repo.confirmedJoins(1), {100});
      expect(await repo.confirmedJoins(2), isEmpty);
      expect(await repo.confirmedSplits(2), {100});
    });
  });

  group('Phasen', () {
    test('ohne Phasen ist die Liste leer', () async {
      expect(await repo.phases(), isEmpty);
    });

    test('eine Phase wird angelegt und gefunden', () async {
      final id = await repo.startPhase(name: 'Ramipril 5 mg', anchor: PhaseAnchor.bestaetigt, begin: DateTime(2026, 8, 10));

      final alle = await repo.phases();
      expect(alle, hasLength(1));
      expect(alle.single.id, id);
      expect(alle.single.name, 'Ramipril 5 mg');
      expect(alle.single.endsAt, isNull, reason: 'läuft noch');
      expect(alle.single.anchor, PhaseAnchor.bestaetigt.name);
    });

    test('eine Phase wird beendet', () async {
      final id = await repo.startPhase(name: 'Urlaub', anchor: PhaseAnchor.bestaetigt, begin: DateTime(2026, 5, 18));
      await repo.endPhase(id, at: DateTime(2026, 6, 2));

      final phase = (await repo.phases()).single;
      expect(phase.endsAt, DateTime(2026, 6, 2));
    });

    test('Phasen kommen neueste zuerst', () async {
      await repo.startPhase(name: 'Alt', anchor: PhaseAnchor.bestaetigt, begin: DateTime(2026, 5, 1));
      await repo.startPhase(name: 'Neu', anchor: PhaseAnchor.bestaetigt, begin: DateTime(2026, 8, 1));

      expect((await repo.phases()).map((p) => p.name), ['Neu', 'Alt']);
    });

    test('eine Phase wird gelöscht', () async {
      final id = await repo.startPhase(name: 'Versuch', anchor: PhaseAnchor.jetzt);
      await repo.deletePhase(id);

      expect(await repo.phases(), isEmpty);
    });
  });

  group('Fail hard', () {
    test('eine Phase ohne Namen ist keine Phase', () async {
      expect(
        () => repo.startPhase(name: '   ', anchor: PhaseAnchor.jetzt),
        throwsArgumentError,
      );
    });

    test('ein Ende vor dem Beginn wird abgelehnt', () async {
      final id = await repo.startPhase(name: 'Test', anchor: PhaseAnchor.jetzt);

      expect(
        () => repo.endPhase(id, at: DateTime(2026, 8, 1)),
        throwsArgumentError,
      );
    });

    test('eine unbekannte Phase zu beenden ist ein Fehler, kein Nichts',
        () async {
      expect(
        () => repo.endPhase(9999, at: DateTime(2026, 9, 1)),
        throwsStateError,
      );
    });

    test('eine beendete Phase lässt sich nicht erneut beenden', () async {
      // Sonst verschöbe ein Doppeltipp eine aufgezeichnete Phasengrenze.
      final id = await repo.startPhase(
          name: 'Urlaub', anchor: PhaseAnchor.bestaetigt, begin: DateTime(2026, 5, 18));
      await repo.endPhase(id, at: DateTime(2026, 6, 2));

      expect(
        () => repo.endPhase(id, at: DateTime(2026, 7, 1)),
        throwsStateError,
      );
      expect((await repo.phases()).single.endsAt, DateTime(2026, 6, 2));
    });

    test('bei „jetzt" darf kein Beginn übergeben werden', () async {
      // Sonst könnte ein beliebiges Datum als „jetzt" ausgegeben werden und
      // die Herkunftsangabe stünde als Lüge dauerhaft in der Datenbank.
      expect(
        () => repo.startPhase(
            name: 'Test', anchor: PhaseAnchor.jetzt, begin: DateTime(2020, 1, 1)),
        throwsArgumentError,
      );
    });

    test('bei „jetzt" stammt der Beginn von der Uhr des Telefons', () async {
      final vorher = DateTime.now();
      await repo.startPhase(name: 'Test', anchor: PhaseAnchor.jetzt);
      final nachher = DateTime.now();

      final phase = (await repo.phases()).single;
      expect(phase.beginsAt.isBefore(vorher.subtract(const Duration(seconds: 1))),
          isFalse);
      expect(phase.beginsAt.isAfter(nachher.add(const Duration(seconds: 1))),
          isFalse);
    });

    test('bei „bestätigt" ist der Beginn Pflicht', () async {
      expect(
        () => repo.startPhase(name: 'Test', anchor: PhaseAnchor.bestaetigt),
        throwsArgumentError,
      );
    });

    test('ein ungültiger Speicherplatz wird abgelehnt', () async {
      expect(
        () => repo.confirmJoin(userSlot: 3, deviceSequence: 100),
        throwsArgumentError,
      );
    });
  });
}
