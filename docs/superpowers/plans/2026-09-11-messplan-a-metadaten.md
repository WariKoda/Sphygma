# A — Metadaten und gemeinsame Oberfläche Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans. Work task-by-task with the checkbox steps. No commits, APK builds or installation without explicit user request.

**Goal:** Tags, Bemerkungen und mehrere Phasen je Messung anbieten und die Konzeptwahl entfernen.

**Architecture:** Additives Schema6 erhält Schema5-Daten und führt neue, slotgebundene Metadaten ein. Eine reine Phasenauflösung trennt automatische Mitgliedschaft von vollständigen manuellen Ausnahmen. Alte Tabellen bleiben ausschließlich für Historie und Upgrades erhalten.

**Tech Stack:** Dart, Flutter, Drift/SQLite; bestehende Theme-Bausteine.

## Global Constraints

Alle [gemeinsamen Constraints](2026-09-11-messungen-phasen-messplan.md#global-constraints)
und Entwurfsannahmen gelten. Ausgangs-App muss zwischen den Aufgaben weiter starten.
Die folgenden Namen sind neue Verträge. Bestehende Rohmessungen nicht neu erzeugen.

## A1 — Schema6 und echte Bestandsmigration

**Dateien:** ändern `lib/db/app_database.dart`, generiertes `lib/db/app_database.g.dart`;
neu `lib/db/legacy_tables.dart`, `test/db/metadata_migration_test.dart`.
`test/db/export_migration_test.dart` bleibt Referenz für reale Datei-Upgrades.

**Datenvertrag:** Drift-Tabellen entsprechend diesem SQL; Sekunden-/Datumsspeicherung
an den vorhandenen Drift-DateTime-Modus anpassen. SQL im Migrationstest mit echten
v5-Dateien ausführen; keine Änderung an `measurements` oder `measurement_exports`.

```sql
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
```

Neue generierte Zeilentypen explizit benennen: `MeasurementNote`, `MeasurementTag`,
`MeasurementTagLink`, `ScopedPhase`, `PhaseSelection`, `PhaseSelectionMember`.
Repository validiert darüber hinaus gleiche Slots; kein stilles Verknüpfen fremder Daten.
Alte `OccasionDecisions`, `Phases`, `PhaseAssignments` nach `legacy_tables.dart`
verschieben, weiterhin in der DB registrieren; keine Anwendung nutzt sie nach A3.
Historische Schema-Upgrades bis v5 müssen weiterhin dieselben Tabellennamen erreichen.

- [x] **Rot:** Datei mit tatsächlichem v5-Schema und zwei Slots erstellen. Messungen,
  Rohbytes, Exportjournal, zwei überlappende globale Phasen, eine manuelle Einzelwahl,
  eine explizite `phase_id=NULL` und eine verwaiste alte Referenz einfügen.
  Upgrade mit aktueller DB öffnen; neue Tabellen/Mengen erwarten. Zusätzlich leere
  Neuinstallation, v4→v6 und absichtlich unterbrochene Migration testen.
- [x] **Rot ausführen:** `flutter test --no-pub test/db/metadata_migration_test.dart`;
  Erwartung: fehlende Schema6-Migration, kein Umgebungs- oder Syntaxfehler.
- [x] **Migration implementieren:** `schemaVersion=6`, gesamtes Upgrade transaktional.
  Alte globale Phasen in **beide** Slots kopieren: sie galten bisher für beide.
  Neue `legacy_id` bildet die Zuordnung unabhängig von neu vergebenen IDs ab.

```sql
INSERT INTO scoped_phases
  (user_slot, legacy_id, name, begins_at, ends_at, anchor, created_at)
SELECT slots.slot, p.id, p.name, p.begins_at, p.ends_at, p.anchor, p.created_at
FROM phases p CROSS JOIN (SELECT 1 AS slot UNION ALL SELECT 2) slots;
INSERT INTO phase_selections(user_slot, device_sequence, decided_at)
SELECT user_slot, device_sequence, decided_at FROM phase_assignments;
INSERT INTO phase_selection_members(user_slot, device_sequence, phase_id)
SELECT a.user_slot, a.device_sequence, p.id
FROM phase_assignments a JOIN scoped_phases p
  ON p.legacy_id=a.phase_id AND p.user_slot=a.user_slot;
```

  Jede alte manuelle Wahl bleibt damit eine vollständige Auswahlmenge. NULL oder
  verwaiste Phasenreferenz ergibt explizit die leere Menge; fehlender Header bedeutet
  weiterhin automatische Auflösung. Keine Ableitung aus fehlenden Daten erfinden.
  `phases_enabled` nur dann auf true initialisieren, wenn Phasen existieren und noch
  keine ausdrückliche Wahl gespeichert ist; Neuinstallationen false.
- [x] **Codegen/Grün:** `dart run build_runner build --delete-conflicting-outputs`,
  `flutter test --no-pub test/db`, `flutter analyze --no-pub`.
  Erwartung: unveränderte Originalzeilen/Exportzustände; Rollback lässt Datei erneut öffnen.

## A2 — Metadatenzugriff und Mehrfachphasen

**Dateien:** neu `lib/db/measurement_metadata_repository.dart`,
`lib/db/phase_repository.dart`, `lib/stats/measurement_metadata.dart`,
`test/db/measurement_metadata_repository_test.dart`, `test/db/phase_repository_test.dart`;
ändern `lib/stats/phase_grouping.dart`; neu `test/stats/phase_membership_test.dart`.

**Neue Interface-Verträge:**

```dart
typedef MeasurementKey = ({int userSlot, int deviceSequence});

class MeasurementMetadata {
  const MeasurementMetadata({required this.note, required this.tagIds});
  final String? note;
  final Set<int> tagIds;
}

abstract interface class MetadataStore {
  Future<Map<int, MeasurementMetadata>> readSlot(int userSlot);
  Future<List<MeasurementTag>> tags(int userSlot);
  Future<int> createTag(int userSlot, String name);
  Future<void> renameTag(int tagId, String name);
  Future<void> deleteTag(int tagId);
  Future<void> save(MeasurementKey key, {required String? note, required Set<int> tagIds});
  Future<void> addTags(Set<MeasurementKey> keys, Set<int> tagIds);
}

abstract interface class PhaseStore {
  Future<List<ScopedPhase>> phases(int userSlot);
  Future<int> savePhase({int? id, required int userSlot, required String name,
    required DateTime begin, required DateTime? end});
  Future<void> deletePhase(int id);
  Future<Map<int, Set<int>>> selections(int userSlot);
  Future<void> select(MeasurementKey key, Set<int> phaseIds);
  Future<void> useAutomatic(MeasurementKey key);
}
```

`MeasurementMetadataRepository implements MetadataStore`; `PhaseRepository implements
PhaseStore`. Constructors nehmen `AppDatabase` entgegen. Neue Interface-Datei enthält
Imports der generierten DB-Typen. Beginn und Ende werden vom Aufrufer explizit
übergeben und im Editor bestätigt. Neue Phasen erhalten deshalb den vorhandenen
Herkunftswert `bestaetigt`; ein expliziter Zeitpunkt wird nie als automatisch
erzeugtes `jetzt` ausgegeben. Bei unverändertem Beginn den bisherigen anchor
erhalten, bei Korrektur des Beginns auf `bestaetigt` setzen.
`savePhase` validiert vorhandene ID/Slot, trim name, leeren Namen, Ende vor Beginn.
UI und Tests verwenden genau die oben angegebene Signatur.

Reine Funktion ergänzen; alten Resolver bis A3 parallel erhalten:

```dart
Set<int> resolvePhaseIds({required DateTime measuredAt,
    required bool timePlausible, required List<ScopedPhase> phases,
    required Set<int>? manualSelection}) {
  if (manualSelection != null) {
    final existing = phases.map((p) => p.id).toSet();
    if (!existing.containsAll(manualSelection)) {
      throw StateError('Manuelle Auswahl verweist auf fehlende Phase.');
    }
    return Set.unmodifiable(manualSelection);
  }
  if (!timePlausible) return const {};
  return Set.unmodifiable(phases.where((p) =>
    !measuredAt.isBefore(p.beginsAt) &&
    (p.endsAt == null || measuredAt.isBefore(p.endsAt!)))
    .map((p) => p.id));
}
```

- [x] **Rot:** Tests für unabhängige Slots, Neustartpersistenz, tag rename ohne
  Linkverlust, verbotene fremde Tag-/Phasen-IDs, leere manuelle Menge versus null,
  überlappende Zeiträume und manuelle Auswahl trotz fraglicher Gerätezeit schreiben.
  Kernassertion nach Anlage zweier überlappender Phasen:

```dart
expect(resolvePhaseIds(measuredAt: at, timePlausible: true,
    phases: phases, manualSelection: null), {firstId, secondId});
expect(resolvePhaseIds(measuredAt: at, timePlausible: true,
    phases: phases, manualSelection: const {}), isEmpty);
```

  `at`, `phases`, `firstId`, `secondId` im Test über reale `PhaseRepository.savePhase`
  und anschließendes `phases(slot)` erzeugen; In-Memory-Drift wie bestehende DB-Tests.
- [x] **Rot prüfen:** `flutter test --no-pub test/db/measurement_metadata_repository_test.dart test/db/phase_repository_test.dart test/stats/phase_membership_test.dart`.
- [x] **Implementieren:** Alle Mehrzeilen-Schreibvorgänge in DB-Transaktion. Tagname
  `trim().toLowerCase()` als normalisierte Identität; vorhandener identischer Tag
  bei create zurückgeben, bei kollidierendem rename expliziter Fehler. Leere Notiz
  entfernt nur die Notizzeile. `save` ersetzt Tags dieser Messung; `addTags` vereinigt.
  Auswahl zuerst als Header, dann Mitglieder schreiben. useAutomatic löscht Mitglieder
  und Header; deletePhase löscht Mitglieder zur Phase, bewahrt leere Header.
  Vor Änderungen Messung und sämtliche IDs/Slots prüfen; fehlerhafte Batchauswahl
  verändert nichts. Nicht auf SQLite-FK-Defaults vertrauen.
- [x] **Grün:** dieselben Tests, `flutter test --no-pub test/db test/stats`, Analyse.

## A3 — Ein gemeinsamer Appzugang mit Metadateneditoren

**Dateien:** neu `lib/ui/app_home.dart`, `lib/ui/metadata/measurement_metadata_editor.dart`,
`lib/ui/metadata/tag_picker.dart`, `lib/ui/phases/phase_management_screen.dart`,
`lib/ui/phases/phase_selection_editor.dart`; ändern `lib/main.dart`,
`lib/app/app_controller.dart`, `lib/db/settings_repository.dart`,
`lib/ui/sphygma_app.dart`, `lib/ui/settings_screen.dart`, `lib/ui/measurement_sheet.dart`.

**Tests:** neu `test/ui/metadata/measurement_metadata_editor_test.dart`,
`test/ui/phases/phase_management_test.dart`, `test/ui/app_home_test.dart`;
ändern `test/ui/sphygma_app_test.dart`, `test/ui/measurement_sheet_test.dart`,
`test/ui/settings_screen_test.dart`, alle AppController-Konstruktorstellen in Tests.

**Entfernen nach Ersetzen ihrer Zugänge:** `lib/app/concept.dart`,
`lib/ui/concepts/concept_home.dart`, `lib/ui/concepts/occasion/`,
`lib/ui/concepts/phase/`, `lib/ui/concepts/tabbed_home.dart`,
`lib/stats/occasion_grouping.dart`, `lib/db/occasion_repository.dart`.
Nicht blind Tests löschen: Kernfunktionen aus `test/ui/concepts/funktionsraster_test.dart`
in `test/ui/app_home_test.dart` überführen; obsolete Konzept-/Anlass-Tests durch
Migrationserhalt und neue Navigationstests ersetzen. Alte single-phase-Tests umschreiben.

- [x] **Rot:** Mit gespeicherten `app_concept=phase` bzw. `messanlass` startet die App
  auf Heute, ohne Konzeptkarte. Metadaten bearbeiten/abbrechen/speichern/restart;
  Phasen deaktiviert → kein Phaseneditor, aktiviert → mehrere auswählen und wieder
  automatisch zuordnen. Tests prüfen unveränderte Rohwerte/Exportzustände nach Speichern.
- [x] **Rot ausführen:** `flutter test --no-pub test/ui/app_home_test.dart test/ui/metadata test/ui/phases`.
- [x] **Controller verdrahten:** Konstruktor erhält `MetadataStore metadataRepository`
  und `PhaseStore phaseRepository` statt OccasionRepository. `_refresh` lädt ausgewählten
  Slot, Metadaten, Phasen und Ausnahmen; `judgeTimestamps` vor jedem Filter auf vollständigem
  Slotbestand. Eine Map `Map<int, Set<int>> phaseIdsBySequence` hält die Auflösung.
  UI nutzt Controller-Methoden zum Speichern und Refresh; Exceptions gehen an Editor,
  Speichern ist während des Futures deaktiviert. Beim Slotwechsel sämtliche temporären
  Editoren/Selektionen schließen, damit kein alter Schlüssel im neuen Slot speichert.
- [x] **UI-Vertrag umsetzen:** `AppHome(controller: ...)` aus TabbedHome übernehmen;
  zunächst zwei Reiter. `showMeasurementSheet` behält Messungs-ID als Identität und
  ergänzt `MeasurementMetadataEditor`; Tags/Bemerkung immer erreichbar, Phasen nur
  bei `phasesEnabled`. PhaseSelectionEditor bearbeitet Menge, nicht einzelne Priorität.
  Settings führt `phasesEnabled()`/`setPhasesEnabled(bool)` mit Schlüssel
  `phases_enabled`; fehlend false, ungültiger Boolwert expliziter Fehler.
  Alte `app_concept`-Zeile bleibt historisch ohne Wirkung; kein Fallback-Konzept wählen.
- [x] **Grün und Abnahme:** `flutter test --no-pub test/app test/ui test/db test/stats`,
  `flutter analyze --no-pub`. `rg 'AppConcept|proposeOccasions|OccasionRepository' lib`
  darf nach vollständiger Umstellung keine ausführbaren Treffer liefern.
  Start, Paarung, Export/Rückzug, Intake-Auswahl, Themes und Geräteuhrhinweis bleiben erreichbar.
