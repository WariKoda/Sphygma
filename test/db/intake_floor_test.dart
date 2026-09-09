// Die Aufnahmegrenze: Was vor ihr liegt, wird nie gezeigt und nie übertragen.
//
// Beim Koppeln entscheidet der Nutzer, was von dem, was schon auf dem Gerät
// liegt, übernommen wird. Die Entscheidung darf nicht bloß die Anzeige
// betreffen — was ausgeblendet ist, darf auch nicht in der Gesundheitsakte
// landen.
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';

SlotRecord _rec(int seq, DateTime at) => SlotRecord(
  userSlot: 1,
  record: BloodPressureRecord(
    systolic: 130 + seq,
    diastolic: 85,
    pulse: 70,
    timestamp: at,
    arrhythmiaFlag: false,
    movementFlag: false,
    sequence: seq,
  ),
  rawBytes: Uint8List(14),
);

void main() {
  late AppDatabase db;
  late MeasurementRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = MeasurementRepository(db);
    await repo.importAll([
      for (var i = 1; i <= 5; i++) _rec(i, DateTime(2026, 7, 10 + i, 8)),
    ]);
  });

  tearDown(() => db.close());

  test('ohne Grenze ist alles sichtbar', () async {
    expect(await repo.allForSlot(1), hasLength(5));
    expect(await repo.pendingExport(1), hasLength(5));
  });

  test('unterhalb der Grenze wird nichts angezeigt', () async {
    await repo.setIntakeFloor(1, 3);

    final sichtbar = await repo.allForSlot(1);
    expect(sichtbar.map((m) => m.deviceSequence), [3, 4, 5]);
  });

  test('unterhalb der Grenze wird nichts übertragen', () async {
    // Der wichtigere Teil: Ausgeblendetes darf nicht in die Gesundheitsakte.
    await repo.setIntakeFloor(1, 4);

    final offen = await repo.pendingExport(1);
    expect(offen.map((m) => m.deviceSequence), [4, 5]);
  });

  test('die Grenze lässt sich aufheben', () async {
    await repo.setIntakeFloor(1, 3);
    await repo.setIntakeFloor(1, null);

    expect(await repo.allForSlot(1), hasLength(5));
  });

  test('die Grenze gilt je Speicherplatz', () async {
    await repo.setIntakeFloor(1, 4);
    expect(await repo.intakeFloor(2), isNull);
    expect(await repo.allForSlot(1), hasLength(2));
  });

  test('der Abgleich sieht weiter alles', () async {
    // `highestSequenceFor` darf **nicht** filtern: Es dient dem Dedup und dem
    // automatischen Abgleich. Sonst hielte die App die ausgeblendeten
    // Messungen für neu und holte sie bei jedem Advertising erneut.
    await repo.setIntakeFloor(1, 3);
    expect(await repo.highestSequenceFor(1), 5);
  });

  test('ein Datum wird einmal in eine Messungsnummer übersetzt', () async {
    // Die Geräteuhr geht nachweislich falsch. Deshalb hängt die Grenze nach
    // der Wahl nicht mehr an Zeitstempeln — sie wird einmal aufgelöst.
    final ab = DateTime(2026, 7, 13);
    expect(await repo.firstSequenceFrom(1, ab), 3);

    await repo.setIntakeFloor(1, await repo.firstSequenceFrom(1, ab));
    expect((await repo.allForSlot(1)).map((m) => m.deviceSequence), [3, 4, 5]);
  });

  test('ohne Messung ab dem Datum gibt es keine Nummer', () async {
    // Null ist ein echter Zustand: Es gibt dort nichts zu übernehmen.
    expect(await repo.firstSequenceFrom(1, DateTime(2027)), isNull);
  });
}
