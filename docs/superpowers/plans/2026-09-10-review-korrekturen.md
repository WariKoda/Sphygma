# Review-Korrekturen — Umsetzungsplan

**Auftrag:** Die sechs im Review zusammengefassten Punkte beheben; Autosync wird
standardmäßig ausgeschaltet. Grundlage: `docs/reviews/2026-09-10-projektreview.md`.
Die Korrekturrichtungen sind durch den anschließenden Nutzerauftrag freigegeben.

**Architektur:** Bestehende Schichten behalten. Nutzerentscheidungen und externe
Exportversuche werden dauerhaft gespeichert. Scan-Starts und -Stops werden serialisiert.
UI-Aktionen verwenden die vorhandenen Controller-/Repository-Zugänge.

**Constraints:** Kein Commit/Push. Keine EEPROM-Writes außer Pairing-Key. Rohmesswerte
unverändert lassen. Neue APIs vor Nutzung lokal prüfen. Neue Fehlerfälle zuerst rot
reproduzieren, dann korrigieren. Bestehende Hardwarebefunde bleiben maßgeblich.

## 1. Autosync und Übernahme — Hauptagent

Dateien: `lib/app/app_controller.dart`, `lib/db/settings_repository.dart`,
`lib/ui/settings_screen.dart`, `lib/ui/intake_choice_sheet.dart`, `test/app/`, `test/ui/`.

- [x] Tests für standardmäßig ausgeschalteten Autosync, gespeicherte Zustimmung,
  Deaktivierung während Cancel, parallele Neustarts und fehlgeschlagene Stops schreiben.
- [x] Persistente Übernahmeentscheidung pro Slot vor Pairing/Erstimport schützen;
  offene Auswahl, Abbruch, fehlgeschlagenen Readout und Neustart testen.
- [x] Controller und Einstellungsschalter umsetzen; Scanübergänge serialisieren.
- [x] Automatischer Export darf eine offene Übernahmeentscheidung nicht umgehen.
- [x] Spezifische App-/UI-Tests ausführen.

## 2. Export und Rückzug — unabhängiger Arbeitsbereich

Dateien: `lib/db/app_database.dart`, generierter Drift-Code,
`lib/db/measurement_repository.dart`, `lib/sync/export_service.dart`,
`lib/sync/health_connect_sink.dart`, `test/db/`, `test/sync/`.

- [x] Reproduktionen für manuell zurückgezogene Werte und gescheiterte Teilexporte
  als Tests übernehmen; Teilerfolg, Retry und erneuten Appstart ergänzen.
- [x] Exportversuch vor externem Write dauerhaft festhalten; Rückzugsentscheidung
  vor Löschung sichern. Teilweise vorhandene Einträge bleiben rückziehbar.
- [x] Automatische Wiederübertragung zurückgezogener Werte verhindern;
  ausdrücklicher manueller Export bleibt möglich.
- [x] Schemaänderungen mit echter Upgrade-Prüfung, Codegenerierung und Tests absichern.

## 3. Phasen — unabhängiger Arbeitsbereich

Dateien: `lib/ui/concepts/phase/`, `lib/ui/measurement_sheet.dart`,
`lib/stats/phase_grouping.dart`, passende `test/ui/` und `test/stats/`.

- [x] Tests für nicht zugeordnete Messungen, korrigierbare Zuordnungen,
  abgeschlossene Phasenvergleiche und gleichen Phasenbeginn ergänzen.
- [x] Listen-/Detailzugänge für alle Messungen und Zuordnungskorrekturen anbieten.
- [x] Vergleichszugang unabhängig von einer gefüllten laufenden Phase ermöglichen.
- [x] Gemeinsame vollständige Phasenreihenfolge für Zuordnung und Anzeige verwenden.
- [x] Widget- und Auswertungstests ausführen.

## 4. Protokoll und BLE-Fehlerpfade — unabhängiger Arbeitsbereich

Dateien: `lib/protocol/`, `lib/ble/`, passende `test/protocol/` und `test/ble/`.

- [x] Zu kurze und zu lange EEPROM-Antworten mit korrekter Prüfsumme rot testen.
- [x] Exakte Antwortlänge verlangen und explizit fehlschlagen.
- [x] Asynchrone Scan-/Notify-Fehler an wartende Aufrufer weiterreichen;
  geöffnete Verbindungen bei fehlgeschlagener Initialisierung schließen.
- [x] Gezielte Tests ausführen; ungeprüfte Hardwarefälle dokumentieren.

## 5. Backup — Hauptagent

Dateien: Android-Manifest und Backup-Regeln, `docs/PRIVACY.md`, Android-Datenschutzhinweis.

- [x] Cloud-Backup und Gerätetransfer getrennt anhand offizieller Dokumentation prüfen.
- [x] Backup-Politik klären: mangels abweichender Antwort die bestehende Lokal-only-Zusage
  beibehalten; Cloud-Backup und automatischen Gerätetransfer ausschließen.
  Diese Annahme wurde dem Nutzer während der Umsetzung mitgeteilt.
- [x] Gewählte Regeln und Datenschutzhinweise konsistent umsetzen; XML und
  zusammengeführtes Release-Manifest prüfen.

## 6. Integration und Abschluss

- [x] Gegenseitige Schnittstellen prüfen, insbesondere neue Exportzustände im Messungsdetail.
- [x] `dart format` nur für berührte Dart-Dateien; `flutter analyze`.
- [x] `flutter test` und `flutter test --dart-define=SPHYGMA_ESC=true`.
- [x] Android-Release-APKs bauen, abschließender unabhängiger Code-Review.
- [x] Review-Dokument um verifizierten Erledigungsstand ergänzen; offene Hardwareprüfung nennen.

## Verifizierter Abschluss

`flutter analyze --no-pub` ohne Befund; beide vollständigen Testsuiten mit jeweils
624 bestandenen Tests. Drei Release-APKs gebaut und deren zusammengeführte Manifeste
auf Backup-Ausschlüsse geprüft. Die Gegenprüfung von Ausschalten/Dispose während
ausstehendem Cancel bestand zusätzlich isoliert; Stopfehler und Timeout sind dauerhaft
in den BLE-Tests abgesichert. Keine neue Geräteprüfung, kein Commit oder Push.
