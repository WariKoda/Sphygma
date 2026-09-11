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
CREATE TABLE measurement_exports (
 measurement_id INTEGER NOT NULL PRIMARY KEY REFERENCES measurements(id),
 may_exist INTEGER NOT NULL, withdrawn INTEGER NOT NULL,
 legacy_unknown INTEGER NOT NULL DEFAULT 0
);
PRAGMA user_version = 5;
