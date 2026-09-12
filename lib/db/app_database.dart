// Lokale Persistenz (M4). Die lokale DB ist Source of Truth; Health Connect
// ist eine reine Export-Senke (CLAUDE.md, PLAN.md §4).
import 'package:drift/drift.dart';

import 'legacy_tables.dart';
import 'plan_tables.dart';

part 'app_database.g.dart';

/// Eine vom Geraet gelesene Messung.
///
/// Dedup-Schluessel ist (userSlot, deviceSequence) - die laufende
/// Messungsnummer des Geraets, nicht der Zeitstempel, weil die Geraeteuhr
/// nachweislich falsch gehen kann (docs/protocol/hem-6232t.md §6.3, §8.2).
@DataClassName('Measurement')
class Measurements extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 1 oder 2, wie am Geraet beschriftet.
  IntColumn get userSlot => integer()();

  /// Laufende Messungsnummer des Geraets (Record-Bytes 9-11).
  IntColumn get deviceSequence => integer()();

  IntColumn get systolic => integer()();
  IntColumn get diastolic => integer()();
  IntColumn get pulse => integer()();

  /// Zeitstempel laut Geraeteuhr - nur so plausibel wie die Uhr.
  DateTimeColumn get measuredAt => dateTime()();

  BoolColumn get movement => boolean()();
  BoolColumn get arrhythmia => boolean()();

  /// Die 14 Rohbytes des Records, fuer Nachvollziehbarkeit und spaetere
  /// Auswertung der noch ungeklaerten Bytes.
  BlobColumn get rawBytes => blob()();

  DateTimeColumn get importedAt => dateTime()();

  /// Gesetzt, sobald der Datensatz nach Health Connect geschrieben wurde.
  DateTimeColumn get exportedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {userSlot, deviceSequence},
  ];
}

/// Externe Exportversuche und ausdrückliche Rückzüge überleben einen Neustart.
/// Ein begonnener Write kann bereits Daten in Health Connect hinterlassen haben,
/// selbst wenn die Antwort oder der anschließende Pulsexport fehlschlägt.
@DataClassName('MeasurementExport')
class MeasurementExports extends Table {
  IntColumn get measurementId => integer().references(Measurements, #id)();
  BoolColumn get mayExist => boolean()();
  BoolColumn get withdrawn => boolean()();
  BoolColumn get legacyUnknown =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {measurementId};
}

/// Schluessel/Wert-Einstellungen der App (z. B. der gewaehlte User-Slot).
@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('MeasurementNote')
class MeasurementNotes extends Table {
  IntColumn get userSlot => integer()();
  IntColumn get deviceSequence => integer()();
  TextColumn get body => text()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {userSlot, deviceSequence};
  @override
  List<String> get customConstraints => ['CHECK(user_slot IN (1,2))'];
}

@DataClassName('MeasurementTag')
class MeasurementTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userSlot => integer()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  @override
  List<Set<Column>> get uniqueKeys => [
    {userSlot, normalizedName},
  ];
  @override
  List<String> get customConstraints => ['CHECK(user_slot IN (1,2))'];
}

@DataClassName('MeasurementTagLink')
class MeasurementTagLinks extends Table {
  IntColumn get userSlot => integer()();
  IntColumn get deviceSequence => integer()();
  IntColumn get tagId => integer().references(MeasurementTags, #id)();
  @override
  Set<Column> get primaryKey => {userSlot, deviceSequence, tagId};
}

@DataClassName('ScopedPhase')
class ScopedPhases extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userSlot => integer()();
  IntColumn get legacyId => integer().nullable()();
  TextColumn get name => text()();
  DateTimeColumn get beginsAt => dateTime()();
  DateTimeColumn get endsAt => dateTime().nullable()();
  TextColumn get anchor => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  List<Set<Column>> get uniqueKeys => [
    {userSlot, legacyId},
  ];
  @override
  List<String> get customConstraints => [
    'CHECK(user_slot IN (1,2))',
    'CHECK(ends_at IS NULL OR ends_at >= begins_at)',
  ];
}

@DataClassName('PhaseSelection')
class PhaseSelections extends Table {
  IntColumn get userSlot => integer()();
  IntColumn get deviceSequence => integer()();
  DateTimeColumn get decidedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {userSlot, deviceSequence};
}

@DataClassName('PhaseSelectionMember')
class PhaseSelectionMembers extends Table {
  IntColumn get userSlot => integer()();
  IntColumn get deviceSequence => integer()();
  IntColumn get phaseId => integer().references(ScopedPhases, #id)();
  @override
  Set<Column> get primaryKey => {userSlot, deviceSequence, phaseId};
  @override
  List<String> get customConstraints => [
    'FOREIGN KEY(user_slot, device_sequence) '
        'REFERENCES phase_selections(user_slot, device_sequence)',
  ];
}

@DriftDatabase(
  tables: [
    Measurements,
    MeasurementExports,
    AppSettings,
    OccasionDecisions,
    Phases,
    PhaseAssignments,
    MeasurementNotes,
    MeasurementTags,
    MeasurementTagLinks,
    ScopedPhases,
    PhaseSelections,
    PhaseSelectionMembers,
    MeasurementPlans,
    PlanRevisions,
    PlanTimes,
    PlanOccurrences,
    PlanAssignmentOverrides,
    ReminderSync,
    PlanTimeChanges,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'INSERT INTO reminder_sync(id, desired_generation) VALUES (1, 0)',
      );
    },
    onUpgrade: (m, from, to) => transaction(() async {
      if (from < 2) {
        await m.createTable(appSettings);
      }
      if (from < 3) {
        // Eine Migration fuer beide Tabellen: Sie kommen zusammen, weil
        // die Konzepte zusammen gebaut werden.
        await m.createTable(occasionDecisions);
        await m.createTable(phases);
      }
      // Nach Phases, nicht davor: Die Zuordnung verweist auf sie.
      if (from < 4) {
        await m.createTable(phaseAssignments);
      }
      if (from < 5) {
        await m.createTable(measurementExports);
        // Ohne Versuchsjournal sind alte unbestätigte Messungen nicht von
        // Teilexporten oder Rückzügen unterscheidbar. Sie bleiben rückziehbar,
        // aber erfordern vor einem erneuten Write eine ausdrückliche Auswahl.
        await customStatement('''
          INSERT INTO measurement_exports
            (measurement_id, may_exist, withdrawn, legacy_unknown)
          SELECT id, 1, exported_at IS NULL, exported_at IS NULL
          FROM measurements
        ''');
      }
      if (from < 6) {
        await m.createTable(measurementNotes);
        await m.createTable(measurementTags);
        await m.createTable(measurementTagLinks);
        await m.createTable(scopedPhases);
        await m.createTable(phaseSelections);
        await m.createTable(phaseSelectionMembers);
        // Globale Altphasen galten für beide Speicherplätze. Explizite leere
        // Ausnahmen bleiben durch einen Header ohne Mitglieder erhalten.
        await customStatement('''
          INSERT INTO scoped_phases
            (user_slot, legacy_id, name, begins_at, ends_at, anchor, created_at)
          SELECT slots.slot, p.id, p.name, p.begins_at, p.ends_at, p.anchor, p.created_at
          FROM phases p CROSS JOIN (SELECT 1 AS slot UNION ALL SELECT 2) slots
        ''');
        await customStatement('''
          INSERT INTO phase_selections(user_slot, device_sequence, decided_at)
          SELECT user_slot, device_sequence, decided_at FROM phase_assignments
        ''');
        await customStatement('''
          INSERT INTO phase_selection_members(user_slot, device_sequence, phase_id)
          SELECT a.user_slot, a.device_sequence, p.id
          FROM phase_assignments a JOIN scoped_phases p
            ON p.legacy_id=a.phase_id AND p.user_slot=a.user_slot
        ''');
        await customStatement('''
          INSERT INTO app_settings(key, value)
          SELECT 'phases_enabled', 'true' WHERE EXISTS (SELECT 1 FROM phases)
          ON CONFLICT(key) DO NOTHING
        ''');
      }
      if (from < 7) {
        await m.createTable(measurementPlans);
        await m.createTable(planRevisions);
        await m.createTable(planTimes);
        await m.createTable(planOccurrences);
        await m.createTable(planAssignmentOverrides);
        await m.createTable(reminderSync);
        await m.createTable(planTimeChanges);
        await customStatement(
          'CREATE UNIQUE INDEX one_open_plan_per_slot '
          'ON measurement_plans (user_slot) WHERE ended_at IS NULL',
        );
        await customStatement(
          'INSERT INTO reminder_sync(id, desired_generation) VALUES (1, 0)',
        );
      }
    }),
  );
}
