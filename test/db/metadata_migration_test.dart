import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';

NativeDatabase legacy(File file, {bool disabled = false}) => NativeDatabase(
  file,
  setup: (sqlite) {
    sqlite.execute(File('test/fixtures/schema_v5.sql').readAsStringSync());
    sqlite.execute('''
      INSERT INTO measurements VALUES
        (42,1,10,123,82,65,1000,0,1,x'010203',2000,3000),
        (43,2,11,124,83,66,1001,1,0,x'040506',2001,NULL);
      INSERT INTO measurement_exports VALUES (42,1,0,0),(43,1,1,0);
      INSERT INTO phases VALUES
        (7,'A',500,NULL,'jetzt',500),(9,'B',600,1200,'bestaetigt',600);
      INSERT INTO phase_assignments VALUES
        (1,1,10,7,2000),(2,2,11,9,2000),
        (3,1,12,NULL,2000),(4,2,13,999,2000);
    ''');
    if (disabled) {
      sqlite.execute(
        "INSERT INTO app_settings VALUES ('phases_enabled','false')",
      );
    }
  },
);

class FailingMetadataUpgrade extends AppDatabase {
  FailingMetadataUpgrade(super.executor);
  @override
  Future<void> customStatement(String statement, [List<Object?>? args]) async {
    await super.customStatement(statement, args);
    if (statement.contains('INSERT INTO phase_selections')) {
      throw StateError('Unterbrochene Metadatenmigration');
    }
  }
}

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('sphygma-metadata-');
  });
  tearDown(() => directory.delete(recursive: true));

  test(
    'v5-Datei erhält Rohdaten, Exportjournal und alle manuellen Wahlen',
    () async {
      final file = File('${directory.path}/db.sqlite');
      final db = AppDatabase(legacy(file));
      final measurements = await db
          .customSelect('SELECT * FROM measurements ORDER BY id')
          .get();
      final exports = await db
          .customSelect(
            'SELECT * FROM measurement_exports ORDER BY measurement_id',
          )
          .get();
      expect(measurements.map((r) => r.read<int>('id')), [42, 43]);
      expect(measurements.map((r) => r.read<int>('measured_at')), [1000, 1001]);
      expect(measurements.first.read<List<int>>('raw_bytes'), [1, 2, 3]);
      expect(exports.map((r) => r.read<int>('withdrawn')), [0, 1]);
      final phases = await db
          .customSelect(
            'SELECT * FROM scoped_phases ORDER BY user_slot, legacy_id',
          )
          .get();
      expect(phases.map((r) => r.read<int>('user_slot')), [1, 1, 2, 2]);
      expect(phases.map((r) => r.read<int>('legacy_id')), [7, 9, 7, 9]);
      final selections = await db
          .customSelect('SELECT * FROM phase_selections')
          .get();
      expect(selections, hasLength(4));
      final members = await db.customSelect('''
      SELECT m.user_slot, m.device_sequence, p.legacy_id FROM phase_selection_members m
      JOIN scoped_phases p ON p.id=m.phase_id ORDER BY m.user_slot
    ''').get();
      expect(members.map((r) => r.read<int>('legacy_id')), [7, 9]);
      expect(members.map((r) => r.read<int>('device_sequence')), [10, 11]);
      expect(
        (await db
                .customSelect(
                  "SELECT value FROM app_settings WHERE key='phases_enabled'",
                )
                .getSingle())
            .read<String>('value'),
        'true',
      );
      await db.close();
      final reopened = AppDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      expect(
        await reopened.customSelect('SELECT * FROM phase_selections').get(),
        hasLength(4),
      );
      expect(
        await reopened
            .customSelect('SELECT * FROM phase_selection_members')
            .get(),
        hasLength(2),
      );
    },
  );

  test('Migration erhält eine ausdrückliche Deaktivierung', () async {
    final db = AppDatabase(
      legacy(File('${directory.path}/db.sqlite'), disabled: true),
    );
    addTearDown(db.close);
    expect(
      (await db
              .customSelect(
                "SELECT value FROM app_settings WHERE key='phases_enabled'",
              )
              .getSingle())
          .read<String>('value'),
      'false',
    );
  });

  test(
    'Neuinstallation hat leere Metadaten und keine aktivierten Phasen',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      for (final table in [
        'measurement_notes',
        'measurement_tags',
        'measurement_tag_links',
        'scoped_phases',
        'phase_selections',
        'phase_selection_members',
      ]) {
        expect(await db.customSelect('SELECT * FROM $table').get(), isEmpty);
      }
      expect(
        await db
            .customSelect(
              "SELECT * FROM app_settings WHERE key='phases_enabled'",
            )
            .get(),
        isEmpty,
      );
    },
  );

  test(
    'abgebrochenes Dateiupgrade rollt Schema und Daten gemeinsam zurück',
    () async {
      final file = File('${directory.path}/db.sqlite');
      final failing = FailingMetadataUpgrade(legacy(file));
      await expectLater(
        failing.customSelect('SELECT * FROM measurements').get(),
        throwsStateError,
      );
      await failing.close();
      var before = <String>[];
      var version = -1;
      final retry = AppDatabase(
        NativeDatabase(
          file,
          setup: (sqlite) {
            before = sqlite
                .select("SELECT name FROM sqlite_master WHERE type='table'")
                .map((r) => r['name'] as String)
                .toList();
            version =
                sqlite.select('PRAGMA user_version').single['user_version']
                    as int;
          },
        ),
      );
      addTearDown(retry.close);
      expect(
        await retry.customSelect('SELECT * FROM scoped_phases').get(),
        hasLength(4),
      );
      expect(before, isNot(contains('scoped_phases')));
      expect(version, 5);
      expect(
        await retry.customSelect('SELECT * FROM measurements').get(),
        hasLength(2),
      );
    },
  );
}
