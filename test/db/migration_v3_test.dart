// Die Migration von Schema 2 auf 3 legt zwei Tabellen an. Bestehende
// Messungen dürfen dabei unangetastet bleiben — auf dem Gerät liegen 114.
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/occasion_repository.dart';

void main() {
  test('Schema 3 legt beide Tabellen an und lässt Messungen unberührt',
      () async {
    final db = AppDatabase(NativeDatabase.memory());

    await db.into(db.measurements).insert(
          MeasurementsCompanion.insert(
            userSlot: 1,
            deviceSequence: 542,
            systolic: 128,
            diastolic: 87,
            pulse: 82,
            measuredAt: DateTime(2026, 9, 5, 23, 57),
            movement: false,
            arrhythmia: false,
            rawBytes: Uint8List(14),
            importedAt: DateTime(2026, 9, 5, 23, 58),
          ),
        );

    final repo = OccasionRepository(db);
    await repo.confirmSplit(userSlot: 1, deviceSequence: 542);
    await repo.startPhase(
      name: 'Ramipril 5 mg',
      begin: DateTime(2026, 8, 10),
      anchor: PhaseAnchor.bestaetigt,
    );

    expect(db.schemaVersion, 3);
    expect(await db.select(db.measurements).get(), hasLength(1));
    expect(await repo.confirmedSplits(1), {542});
    expect(await repo.phases(), hasLength(1));

    await db.close();
  });
}
