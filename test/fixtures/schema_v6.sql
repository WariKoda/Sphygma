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


CREATE TABLE measurement_notes (
  user_slot INTEGER NOT NULL CHECK(user_slot IN (1,2)),
  device_sequence INTEGER NOT NULL,
  body TEXT NOT NULL,
  updated_at INTEGER NOT NULL,
  PRIMARY KEY(user_slot, device_sequence)
);
CREATE TABLE measurement_tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_slot INTEGER NOT NULL CHECK(user_slot IN (1,2)),
  name TEXT NOT NULL,
  normalized_name TEXT NOT NULL,
  UNIQUE(user_slot, normalized_name)
);
CREATE TABLE measurement_tag_links (
  user_slot INTEGER NOT NULL,
  device_sequence INTEGER NOT NULL,
  tag_id INTEGER NOT NULL REFERENCES measurement_tags(id),
  PRIMARY KEY(user_slot, device_sequence, tag_id)
);
CREATE TABLE scoped_phases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_slot INTEGER NOT NULL CHECK(user_slot IN (1,2)),
  legacy_id INTEGER,
  name TEXT NOT NULL,
  begins_at INTEGER NOT NULL,
  ends_at INTEGER,
  anchor TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  UNIQUE(user_slot, legacy_id),
  CHECK(ends_at IS NULL OR ends_at >= begins_at)
);
CREATE TABLE phase_selections (
  user_slot INTEGER NOT NULL,
  device_sequence INTEGER NOT NULL,
  decided_at INTEGER NOT NULL,
  PRIMARY KEY(user_slot, device_sequence)
);
CREATE TABLE phase_selection_members (
  user_slot INTEGER NOT NULL,
  device_sequence INTEGER NOT NULL,
  phase_id INTEGER NOT NULL REFERENCES scoped_phases(id),
  PRIMARY KEY(user_slot, device_sequence, phase_id),
  FOREIGN KEY(user_slot, device_sequence)
    REFERENCES phase_selections(user_slot, device_sequence)
);

PRAGMA user_version = 6;
