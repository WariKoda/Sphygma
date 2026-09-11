import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';

// Historisches Schema v4: unabhängig vom aktuellen Code, damit wirklich
// onUpgrade und der Erhalt bestehender Rohmessungen geprüft werden.
NativeDatabase _version4({String mark = '2', File? file}) => file == null
    ? NativeDatabase.memory(setup: _version4Setup(mark))
    : NativeDatabase(file, setup: _version4Setup(mark));

DatabaseSetup _version4Setup(String mark) => (sqlite) {
  sqlite.execute('''
      CREATE TABLE measurements (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        user_slot INTEGER NOT NULL, device_sequence INTEGER NOT NULL,
        systolic INTEGER NOT NULL, diastolic INTEGER NOT NULL, pulse INTEGER NOT NULL,
        measured_at INTEGER NOT NULL, movement INTEGER NOT NULL,
        arrhythmia INTEGER NOT NULL, raw_bytes BLOB NOT NULL,
        imported_at INTEGER NOT NULL, exported_at INTEGER,
        UNIQUE (user_slot, device_sequence)
      );
      CREATE TABLE app_settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL);
      CREATE TABLE occasion_decisions (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        user_slot INTEGER NOT NULL, device_sequence INTEGER NOT NULL,
        decision TEXT NOT NULL, decided_at INTEGER NOT NULL,
        UNIQUE (user_slot, device_sequence)
      );
      CREATE TABLE phases (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, begins_at INTEGER NOT NULL, ends_at INTEGER,
        anchor TEXT NOT NULL, created_at INTEGER NOT NULL
      );
      CREATE TABLE phase_assignments (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        user_slot INTEGER NOT NULL, device_sequence INTEGER NOT NULL,
        phase_id INTEGER REFERENCES phases(id), decided_at INTEGER NOT NULL,
        UNIQUE (user_slot, device_sequence)
      );
      INSERT INTO measurements VALUES
        (1, 1, 1, 121, 81, 71, 1000, 0, 1, x'0102', 2000, 3000),
        (2, 1, 2, 122, 82, 72, 1001, 1, 0, x'0304', 2001, NULL),
        (3, 1, 3, 123, 83, 73, 1002, 0, 0, x'0506', 2002, NULL),
        (4, 2, 1, 124, 84, 74, 1003, 0, 0, x'0708', 2003, NULL);
      PRAGMA user_version = 4;
    ''');
  sqlite.execute('INSERT INTO app_settings VALUES (?, ?)', [
    'auto_export_mark_1',
    mark,
  ]);
};

class _FailingUpgrade extends AppDatabase {
  _FailingUpgrade(super.executor);
  @override
  Future<void> customStatement(String statement, [List<Object?>? args]) async {
    await super.customStatement(statement, args);
    if (statement.contains('INSERT INTO measurement_exports')) {
      throw StateError('Abbruch während Migration');
    }
  }
}

class _LegacySink implements HealthSink {
  final stored = <String>{'sphygma-slot1-seq2', 'sphygma-slot1-seq3'};
  final written = <String>[];
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {
    written.add(write.clientRecordId);
  }

  @override
  Future<void> deleteBloodPressure(String id) async {
    stored.remove(id);
  }
}

void main() {
  test('v4-Upgrade bewahrt Rohwerte, Export und alte Rückzugssperre', () async {
    final db = AppDatabase(_version4());
    addTearDown(db.close);
    final repo = MeasurementRepository(db);
    final rows = await db.select(db.measurements).get();
    expect(db.schemaVersion, 7);
    expect(rows.map((m) => m.systolic), [121, 122, 123, 124]);
    expect(rows.map((m) => m.rawBytes.toList()), [
      [1, 2],
      [3, 4],
      [5, 6],
      [7, 8],
    ]);
    expect(rows.first.exportedAt, DateTime.fromMillisecondsSinceEpoch(3000000));
    expect(await repo.pendingAutoExport(1), isEmpty);
    expect(await repo.pendingAutoExport(2), isEmpty);
    expect(await repo.exportStatesForSlot(1), {
      1: MeasurementExportState.exported,
      2: MeasurementExportState.legacyUnknown,
      3: MeasurementExportState.legacyUnknown,
    });
    final stateRows = await db
        .customSelect(
          'SELECT * FROM measurement_exports ORDER BY measurement_id',
        )
        .get();
    expect(stateRows.map((r) => r.read<int>('measurement_id')), [1, 2, 3, 4]);
    expect(stateRows.map((r) => r.read<int>('may_exist')), [1, 1, 1, 1]);
    expect(stateRows.map((r) => r.read<int>('withdrawn')), [0, 1, 1, 1]);
    expect(stateRows.map((r) => r.read<int>('legacy_unknown')), [0, 1, 1, 1]);
  });

  test('eine überholte defekte Marke umgeht keine Legacy-Sperre', () async {
    final db = AppDatabase(_version4(mark: 'defekt'));
    addTearDown(db.close);
    expect(await MeasurementRepository(db).pendingAutoExport(1), isEmpty);
  });

  test(
    'frühere Teilexporte unter und über der Marke sind rückziehbar',
    () async {
      final db = AppDatabase(_version4());
      addTearDown(db.close);
      final repo = MeasurementRepository(db);
      final sink = _LegacySink();
      final service = ExportService(repository: repo, sink: sink);
      await service.retractExported(userSlot: 1);
      expect(sink.stored, isEmpty);
      expect(
        (await repo.exportStatesForSlot(1)).values,
        everyElement(MeasurementExportState.retracted),
      );
    },
  );

  test(
    'fehlgeschlagenes Upgrade hinterlässt kein Teilschema und ist wiederholbar',
    () async {
      final dir = await Directory.systemTemp.createTemp('sphygma-migration-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/db.sqlite');
      final failing = _FailingUpgrade(_version4(file: file));
      await expectLater(
        failing.select(failing.measurements).get(),
        throwsStateError,
      );
      await failing.close();
      var oldTables = <String>[];
      final retry = AppDatabase(
        NativeDatabase(
          file,
          setup: (sqlite) {
            oldTables = sqlite
                .select("SELECT name FROM sqlite_master WHERE type='table'")
                .map((row) => row['name'] as String)
                .toList();
          },
        ),
      );
      addTearDown(retry.close);
      await retry.select(retry.measurements).get();
      expect(oldTables, isNot(contains('measurement_exports')));
      expect(await MeasurementRepository(retry).allForSlot(1), hasLength(3));
    },
  );

  test(
    'Legacywerte bleiben gesperrt bis zum ausdrücklichen manuellen Export',
    () async {
      final db = AppDatabase(_version4());
      addTearDown(db.close);
      final repo = MeasurementRepository(db);
      final sink = _LegacySink();
      final service = ExportService(repository: repo, sink: sink);
      expect(await service.exportPending(userSlot: 1, onlyNew: true), 0);
      expect(sink.written, isEmpty);
      final m = (await repo.allForSlot(1))[1];
      await service.exportOne(m);
      expect(sink.written, ['sphygma-slot1-seq2']);
      expect(
        (await repo.exportStatesForSlot(1))[m.id],
        MeasurementExportState.exported,
      );
      expect(
        (await repo.exportStatesForSlot(1))[3],
        MeasurementExportState.legacyUnknown,
      );
    },
  );
}
