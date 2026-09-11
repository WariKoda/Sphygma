# Einzelmessungen, Phasen und Messplan — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. If delegation is later requested, use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax for tracking. Do not commit, build an APK or install without a separate user request.

**Goal:** Eine gemeinsame Messungsoberfläche mit lokalen Tags/Bemerkungen, optionalen Mehrfachphasen und optionalem Messplan einschließlich Android-Erinnerungen liefern.

**Architecture:** Bestehende Flutter-/Drift-Schichten weiterverwenden. Metadaten und Planrevisionen liegen getrennt von Rohmessungen; Filter und Zuordnung sind reine Funktionen. Ein Android-Modul besitzt die Alarmplanung hinter einem kleinen Dart-Interface, mit persistentem, aus Drift abgeleitetem Arbeitsstand für Neustarts ohne laufendes Flutter.

**Tech Stack:** Flutter/Dart gemäß Repository, Drift/SQLite, Kotlin und Android AlarmManager/NotificationManager. Kein neues Diagrammpaket; keine Cloud. Native Erinnerungen brauchen kein zusätzliches Flutter-Benachrichtigungspaket.

## Global Constraints

- Maßgeblich: [konsolidierter Entwurf](../specs/2026-09-11-messungen-phasen-messplan-design.md), einschließlich ausdrücklich gekennzeichneter Annahmen A1–A12.
- Ausgangsbasis ist der **Arbeitsbaum**, nicht nur HEAD: Branch `fix/review-sync-export-phase`, Schema v5, Autosync-/Exportkorrekturen und 633 zuletzt bestandene Tests. Bestehende uncommittete Änderungen weder zurücksetzen noch überschreiben.
- Bei Ausführung zuerst `AGENTS.md`, `CLAUDE.md`, `PLAN.md` und `git status --short` lesen. AGENTS.md auf Nutzeranweisung nicht verändern; widersprechende alte Konzeptregeln als durch diesen Auftrag abgelöst behandeln.
- Keine EEPROM-Writes außer Pairing-Key. Rohbytes, Gerätezeit, Messungsnummern, Exportidentitäten und Exportjournal unverändert erhalten.
- Android minSdk29, compileSdk36, targetSdk36. MainActivity bleibt FlutterFragmentActivity für Health Connect.
- Autosync standardmäßig aus, Übernahmeentscheidung je Slot vor Export prüfen. Den inzwischen korrigierten Scan-Cancel nicht wieder durch `async*` ersetzen.
- Deutsche Oberfläche, englische Bezeichner; zwei Leerzeichen in Dart, `dart format`, vorhandene Theme-Bausteine. Alle Formen/Paletten/Schriften unterstützen.
- Externe Fehler ausdrücklich darstellen. Kein UTC-Ersatz bei fehlender Zeitzone, keine erfundene Erfüllung, keine leeren Listen als Ersatz für Lesefehler.
- Keine anderen Erinnerungsarten, Snooze, Phasenvergleich, Offset-Konfiguration, Wochentagsvarianten oder eigene Backupfunktion in diesem Auftrag.
- Kein Commit/Tag/Push/PR. APK-Build und Installation nur auf separaten Auftrag; keine automatisch gestarteten drei ABI-Builds.
- Vorgeschlagene neue Typen, Tabellen und Methoden in den Teilplänen sind **neu zu implementierende Verträge**, keine Behauptungen über existierende APIs.

## Reihenfolge und Teilpläne

| Teil | Ergebnis | Voraussetzung |
|---|---|---|
| [A — Metadaten und gemeinsame Oberfläche](2026-09-11-messplan-a-metadaten.md) | Schema6, Tags/Bemerkungen, Mehrfachphasen, eine Navigation, alter Anlassprozess entfernt | Arbeitsbaum v5 |
| [B — Darstellung und Filter](2026-09-11-messplan-b-oberflaeche.md) | konsistente Filter, interaktive Kurven, gemeinsame Karte, abschaltbare Heute-Abschnitte, letzter Abgleich | A |
| [C — Messplan und Erinnerungen](2026-09-11-messplan-c-erinnerungen.md) | Schema7, Terminzuordnung, optionaler Reiter, Android-Alarme, Lifecycle-Prüfung | A; UI-Integration nach B |

Jeder Teil endet in einer startfähigen App mit eigenen Tests. Keine versteckten
unfertigen Schalter freischalten. Schema6 führt keine leeren Plan-Tabellen ein;
Schema7 kommt erst mit der tatsächlichen Planfunktion. Reine Rechenarbeit aus C
kann separat entwickelt werden; Schema/AppController/Navigation nie gleichzeitig
von mehreren Arbeitern ändern.

## Modul- und Dateigrenzen

| Ort | Verantwortung |
|---|---|
| `lib/db/app_database.dart`, `lib/db/legacy_tables.dart` (neu) | aktuelle Tabellen, additive Upgrades und erhaltene alte Tabellen |
| `lib/db/measurement_metadata_repository.dart` (neu) | Notizen, Tags, Tagzuordnung, atomare Mehrfachänderungen |
| `lib/db/phase_repository.dart` (neu) | slotgebundene Phasen und vollständige manuelle Auswahlmengen |
| `lib/stats/phase_grouping.dart` | Mehrfachmitgliedschaft, ohne persistierte automatische Zuordnungen |
| `lib/stats/measurement_filter.dart` (neu) | eine gemeinsame, deduplizierte Auswahl für alle Verlaufsbestandteile |
| `lib/app/app_controller.dart` | bestehende Sync-/App-Steuerung und öffentliches Zusammenspiel; keine native Alarmberechnung hineinbauen |
| `lib/ui/app_home.dart` (neu) | Heute/Verlauf/optionaler Messplan, mit stabilem Tabzustand |
| `lib/ui/phases/`, `lib/ui/metadata/` (neu) | fachliche Bearbeitungsoberflächen ohne Konzeptwechsel |
| `lib/plan/` (neu) | Modelle, Terminberechnung, Matching, ReminderGateway, PlanController |
| `lib/db/measurement_plan_repository.dart` (neu) | Planrevisionen, lokale Termine und Änderungsabsichten |
| `lib/ui/plan/` (neu) | Planeditor, heutige Erfüllung, Terminzuordnung |
| `android/app/src/main/kotlin/de/bdgraue/sphygma/reminders/` (neu) | persistenter Alarmarbeitsstand, BroadcastReceiver, Zeit-/Berechtigungsbehandlung |

## Kontrollpunkte

Softwarestand vom 11.09.2026: A–C3 implementiert; Prüfdetails und verbleibende
Hardwarefälle stehen im [Abnahmeprotokoll](../../reviews/2026-09-11-messplan-abnahme.md).
Schema7 enthält die additiven Schritte über Schema6. Testdateinamen wurden bei
Integration teilweise zusammengeführt; maßgeblich sind die dort genannten Prüfungen.


- [x] **K0:** Ausgangsdiff und Schema5 sichern/prüfen; vorhandene Tests grün. Keine Änderungen aus früherer Sitzung als neu eigene Arbeit ausgeben.
- [x] **K1:** Teil A: Upgrade v4→v6 und v5→v6, inklusive leerer manueller Phasenwahl, bestanden; App startet ohne Konzeptwahl.
- [x] **K2:** Teil B: jede Filterauswahl wirkt identisch auf Zeilen, Kurve, Werte; alle Gestaltungsformen und große Schrift geprüft.
- [x] **K3:** Teil C: ±15-Minuten-Regeln, zukünftige Revisionen, Stop/Start, Native-Fehler und Neustartverhalten automatisiert geprüft.
- [x] **K4:** Gesamtsuite und ESC-Konfiguration bestanden; Analyse und native Unit-/Lintprüfungen sauber. Build/Installation für die weiterhin offene Hardwareabnahme benötigen einen separaten Auftrag.
- [ ] **K5:** Hardwarefälle aus C dokumentiert: tatsächlich geprüft / nicht geprüft, keine simulierten Fälle als Gerätebeweis ausgeben.

## Gemeinsame Abschlussprüfung

Nach jeder Aufgabe ihre genannten gezielten Tests; bei fertigem integrierten Stand:

```bash
dart format lib test
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub --dart-define=SPHYGMA_ESC=true
git diff --check
```

Erwartung: Analyse ohne Befunde, alle Tests erfolgreich, formatierter Code und
sauberer Diff. Die Testzahl wird durch neue Tests verändert und ist kein fixes Soll.
Bei neuen Kotlin-Dateien zusätzlich aus `android/`:

```bash
./gradlew :app:testDebugUnitTest :app:lintDebug --offline
```

Falls eine neu ergänzte Testabhängigkeit noch nicht lokal vorliegt, den Abruffehler
als Umgebungsgrenze melden und den Paketabruf gezielt ermöglichen; Tests nicht
als bestanden zählen. Diese Gradle-Prüfungen sind kein Auftrag zum APK-Bauen.

## Dokumentation am Abschluss

- `PLAN.md`: veraltete Konzeptabschnitte und §9.1 Notizen/§9.3 Erinnerungen abgleichen.
- `CLAUDE.md`: aktuelle Architektur, Schema und entfernte Konzeptwahl; keine neue Änderung an AGENTS.md.
- `docs/design/funktionsraster.md`: eine Funktionsmatrix, Konzeptwahl entfällt; Tags, Filter, Phasen und Plan ergänzen.
- `docs/design/umsetzung-konzepte.md`: datierten neuen Bestandsabgleich ergänzen, historische Entwurfsbegründung erhalten.
- `docs/design/gestaltung-drei-achsen.md`: gemeinsame Informationsstruktur in jeder Form erläutern.
- `docs/PRIVACY.md` und nativer Datenschutzhinweis: lokale Tags, Notizen, Phasen, Planzeiten und Benachrichtigungen; keine erfundenen Verantwortlichenangaben.
- `docs/research/android-erinnerungen.md`: falsche Viertelstundenzusage berichtigen, verifizierte Lifecycle-Grenzen nennen.

## Selbstprüfung des Plans

Die Teilpläne verknüpfen jede Anforderung mit mindestens einer Aufgabe und einem
beobachtbaren Testfall. Exakte Android-APIs wurden in Android36-Quelltexten und der
[offiziellen Alarmdokumentation](https://developer.android.com/develop/background-work/services/alarms)
geprüft. Die Plugin-Alternative wurde lokal geprüft, aber für diesen Plan nicht
gewählt: deren BootReceiver reagiert nicht auf Zeitzonenwechsel. Eine native,
Android-spezifische Zuständigkeit vermeidet einen zweiten konkurrierenden Scheduler.
Die tatsächlich installierte Toolchain und Branchlage bei Ausführung erneut prüfen.
