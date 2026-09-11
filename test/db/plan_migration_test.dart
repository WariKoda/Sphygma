import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';

class FailedPlanUpgrade extends AppDatabase {
  FailedPlanUpgrade(super.executor);
  @override
  Future<void> customStatement(String statement, [List<Object?>? args]) async {
    await super.customStatement(statement, args);
    if (statement.contains('INSERT INTO reminder_sync')) {
      throw StateError('Planmigration unterbrochen');
    }
  }
}

void main() {
  test(
    'v5-Datei ergänzt Planbereich ohne Messung oder Export zu verändern',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'sphygma-plan-migration-',
      );
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/db');
      final db = AppDatabase(
        NativeDatabase(
          file,
          setup: (sqlite) {
            sqlite.execute(
              File('test/fixtures/schema_v5.sql').readAsStringSync(),
            );
            sqlite.execute('''
        INSERT INTO measurements VALUES (8,1,10,123,82,65,1000,0,1,x'010203',2000,3000);
        INSERT INTO measurement_exports VALUES (8,1,0,0);
      ''');
          },
        ),
      );
      addTearDown(db.close);
      for (final table in [
        'measurement_plans',
        'plan_revisions',
        'plan_times',
        'plan_occurrences',
        'plan_assignment_overrides',
        'plan_time_changes',
      ]) {
        expect(await db.customSelect('SELECT * FROM $table').get(), isEmpty);
      }
      final raw =
          (await db.customSelect('SELECT * FROM measurements').getSingle())
              .data;
      expect(raw, {
        'id': 8,
        'user_slot': 1,
        'device_sequence': 10,
        'systolic': 123,
        'diastolic': 82,
        'pulse': 65,
        'measured_at': 1000,
        'movement': 0,
        'arrhythmia': 1,
        'raw_bytes': [1, 2, 3],
        'imported_at': 2000,
        'exported_at': 3000,
      });
      expect(
        (await db.customSelect('SELECT * FROM measurement_exports').getSingle())
            .data,
        {
          'measurement_id': 8,
          'may_exist': 1,
          'withdrawn': 0,
          'legacy_unknown': 0,
        },
      );
      final sync = await db
          .customSelect('SELECT * FROM reminder_sync')
          .getSingle();
      expect(sync.read<int>('desired_generation'), 0);
      expect(sync.readNullable<int>('applied_generation'), isNull);
      expect(
        (await db.customSelect('SELECT * FROM measurements').getSingle())
            .read<int>('id'),
        8,
      );
      expect(
        (await db.customSelect('SELECT * FROM measurement_exports').getSingle())
            .read<int>('measurement_id'),
        8,
      );
    },
  );
  test(
    'v6-Datei erhält Notiz, Tags und bewusste leere Phasenauswahl',
    () async {
      final dir = await Directory.systemTemp.createTemp('sphygma-v6-');
      addTearDown(() => dir.delete(recursive: true));
      final db = AppDatabase(
        NativeDatabase(
          File('${dir.path}/db'),
          setup: (sqlite) {
            sqlite.execute(
              File('test/fixtures/schema_v6.sql').readAsStringSync(),
            );
            sqlite.execute('''
        INSERT INTO measurements VALUES (8,1,10,123,82,65,1000,0,1,x'010203',2000,3000);
        INSERT INTO measurement_exports VALUES (8,1,0,0);
        INSERT INTO measurement_notes VALUES (1,10,'bleibt erhalten',2000);
        INSERT INTO measurement_tags VALUES (11,1,'Sport','sport');
        INSERT INTO measurement_tag_links VALUES (1,10,11);
        INSERT INTO phase_selections VALUES (1,10,2000);
      ''');
          },
        ),
      );
      addTearDown(db.close);
      expect(
        (await db.select(db.measurementNotes).getSingle()).body,
        'bleibt erhalten',
      );
      expect((await db.select(db.measurementTagLinks).getSingle()).tagId, 11);
      expect(await db.select(db.phaseSelections).get(), hasLength(1));
      expect(await db.select(db.phaseSelectionMembers).get(), isEmpty);
      expect(await db.select(db.measurementPlans).get(), isEmpty);
      expect(
        (await db.select(db.measurementExports).getSingle()).measurementId,
        8,
      );
    },
  );

  test('v6-Upgrade-Abbruch hinterlässt kein halbes Planschema', () async {
    final dir = await Directory.systemTemp.createTemp('sphygma-v6-abort-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db');
    final first = FailedPlanUpgrade(
      NativeDatabase(
        file,
        setup: (sqlite) {
          sqlite.execute(
            File('test/fixtures/schema_v6.sql').readAsStringSync(),
          );
        },
      ),
    );
    await expectLater(
      first.customSelect('SELECT * FROM reminder_sync').get(),
      throwsStateError,
    );
    await first.close();
    var version = -1;
    var tables = <String>[];
    final retry = AppDatabase(
      NativeDatabase(
        file,
        setup: (sqlite) {
          version =
              sqlite.select('PRAGMA user_version').single['user_version']
                  as int;
          tables = sqlite
              .select("SELECT name FROM sqlite_master WHERE type='table'")
              .map((r) => r['name'] as String)
              .toList();
        },
      ),
    );
    addTearDown(retry.close);
    expect(
      (await retry.select(retry.reminderSync).getSingle()).desiredGeneration,
      0,
    );
    expect(version, 6);
    expect(tables, isNot(contains('measurement_plans')));
  });
}
