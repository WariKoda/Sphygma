// Die Schemaerweiterungen der Konzepte legen Tabellen an. Bestehende
// Messungen dürfen dabei unangetastet bleiben — auf dem Gerät liegen 114.
//
// Geprüft wird eine frisch angelegte Datenbank, nicht der Upgrade-Pfad
// selbst: Dafür bräuchte es die Schema-Dumps von drift_dev, die dieses
// Projekt nicht pflegt. Die Reihenfolge in `onUpgrade` ist deshalb von Hand
// zu wahren — phaseAssignments verweist auf phases und muss nach ihr kommen.
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/occasion_repository.dart';

void main() {
  test('das aktuelle Schema legt alle Tabellen an und lässt Messungen '
      'unberührt',
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

    await db.into(db.phaseAssignments).insert(
          PhaseAssignmentsCompanion.insert(
            userSlot: 1,
            deviceSequence: 542,
            decidedAt: DateTime(2026, 9, 6),
          ),
        );

    expect(db.schemaVersion, 4);
    expect(await db.select(db.measurements).get(), hasLength(1));
    expect(await repo.confirmedSplits(1), {542});
    expect(await repo.phases(), hasLength(1));
    expect(await db.select(db.phaseAssignments).get(), hasLength(1));

    await db.close();
  });
}
