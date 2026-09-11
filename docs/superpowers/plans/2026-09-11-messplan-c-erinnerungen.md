# C — Messplan und Android-Erinnerungen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans. Work task-by-task; no commits or APK installation without explicit user request. Do not present simulated reminder delivery as a real-device result.

**Goal:** Einen optionalen täglichen Messplan bis zum manuellen Beenden mit nachvollziehbarer Erfüllung und exakten oder ungenauen Android-Erinnerungen liefern.

**Architecture:** Drift hält Pläne, Revisionen, Terminbelege und Änderungsabsichten. Reine Dart-Funktionen ordnen Messungen zu. Ein Android-Modul verwaltet die tatsächlich gesetzten Alarme und einen persistenten, abgeleiteten Arbeitsstand; Flutter kommuniziert über ein kleines ReminderGateway.

**Tech Stack:** Dart/Flutter, Drift Schema7, Kotlin, java.time, Android AlarmManager und NotificationManager. Android minSdk29 macht java.time nutzbar. Kein zweiter Scheduler über ein Flutter-Plugin.

## Global Constraints

[Gemeinsame Constraints](2026-09-11-messungen-phasen-messplan.md#global-constraints)
und Annahmen A1–A12 gelten. Keine Kopie der fehlerhaften „höchstens 15 Minuten
Verspätung“-Zusage aus der alten Recherche. ±15 Minuten ist die **Matching-Regel**,
nicht eine zugesicherte Alarmgenauigkeit. Bei Alarmverspätung Matchingfenster nicht erweitern.

## C1 — Planrevisionen, Terminbelege und reine Zuordnung

**Dateien:** neu `lib/plan/plan_models.dart`, `lib/plan/occurrence_matching.dart`,
`lib/db/measurement_plan_repository.dart`, `test/plan/occurrence_matching_test.dart`,
`test/db/plan_migration_test.dart`, `test/db/measurement_plan_repository_test.dart`;
ändern `lib/db/app_database.dart`, generiertes `lib/db/app_database.g.dart`.

**Schema7:** additive Tabellen; alle Zeiten als UTC-Zeitpunkte speichern, zusätzlich
lokales Termindatum, Minute und Zone im Terminbeleg. Kein Zeit-Offset an Messungen.

| Tabelle | Felder und Invarianten |
|---|---|
| measurement_plans | id PK, user_slot 1/2, started_at, ended_at nullable; partieller UNIQUE-Index auf user_slot WHERE ended_at IS NULL |
| plan_revisions | id PK, plan_id FK, effective_at UTC, enabled bool; strikt geordnete Änderungen je Plan |
| plan_times | id PK, revision_id FK, minute_of_day 0..1439; UNIQUE(revision_id, minute_of_day) |
| plan_occurrences | occurrence_key TEXT PK, revision_id FK, due_at UTC nullable, local_date YYYY-MM-DD, minute_of_day, zone_id nullable, time_ambiguous bool; frühere Belege unverändert |
| plan_assignment_overrides | user_slot, device_sequence, occurrence_key nullable, decided_at; PK(slot,sequence), UNIQUE(occurrence_key) wenn nicht null |
| reminder_sync | singleton id=1, desired_generation int, applied_generation nullable, last_error nullable; nur bestätigte Anwendung erhält applied_generation |

`plan_assignment_overrides` ordnet ausschließlich **vorhandene** Messungen zu;
kein Knopf erzeugt eine behauptete Messung. Eine explizite NULL-Zuordnung nimmt eine
Messung aus dem automatischen Matching. Wird ein belegter Termin manuell ersetzt,
muss die vorherige Zuordnung im selben Schreibvorgang gelöst werden.

Neue Domänentypen in `plan_models.dart`:

```dart
class PlannedOccurrence {
  const PlannedOccurrence({required this.key, required this.userSlot,
    required this.revisionId, required this.dueAt,
    required this.localDate, required this.minuteOfDay,
    required this.zoneId, required this.timeAmbiguous});
  final String key;
  final int userSlot;
  final int revisionId;
  final DateTime? dueAt;
  final String localDate;
  final int minuteOfDay;
  final String? zoneId;
  final bool timeAmbiguous;
}

class TimedMeasurement {
  const TimedMeasurement({required this.key,
    required this.localTime, required this.plausible});
  final MeasurementKey key; // imported from stats/measurement_metadata.dart in A
  final DateTime localTime; // UTC container for civil components, NOT a claimed UTC measurement
  final bool plausible;
}
```

Für historisch nicht belegbare Zeitzonen bleiben `zoneId` und `dueAt` null und
`timeAmbiguous=true`. Kein Ersatz durch UTC oder die heutige Zone. Solche Termine
erlauben nur eine ausdrückliche manuelle Zuordnung; künftige native Alarme benötigen
immer einen konkreten Zeitpunkt und eine bekannte Zone.

`matchOccurrences(List<TimedMeasurement>, List<PlannedOccurrence>,
{required Map<MeasurementKey, String?> manualAssignments})` liefert
`Map<String, MeasurementKey>`; nur erfüllte occurrence keys stehen darin.
Manuelle Einträge zuerst validieren: gleicher Slot, vorhandene IDs, keine zwei
Messungen für denselben Termin. Automatische Kandidaten brauchen plausible Zeit.
Civil-Komponenten zum Vergleichen ausdrücklich in `DateTime.utc(y,m,d,h,min,s)`
kopieren; diese Hilfsdarstellung niemals nach Health Connect exportieren.
Für Messungszeit die Rohaufzeichnung mit vorhandenem `parseRecord(rawBytes)` lesen;
Sentinel/abweichende Sequenz in einer gespeicherten Messung ist expliziter Datenfehler.
Die bestehenden Tests mit Dummy-Rohbytes für solche Fälle um echte Record-Fixtures ergänzen.

Automatik in zwei Schritten, nicht gierig auf noch freie Termine verteilen:

```text
Für jede plausible, nicht manuell behandelte Messung:
  Termine desselben Slots mit Abstand <= 15 Minuten sammeln.
  Den kleinsten Abstand wählen; bei Gleichstand früheren Termin, danach key.
  Die Messung nur dieser Kandidatenliste zuordnen.
Für jeden noch nicht manuell belegten Termin:
  Kandidat mit kleinstem Abstand, dann früherer Messzeit, dann kleinerer Sequenz wählen.
```

Auch vorherige/nächste Kalendertage berücksichtigen (00:05 zu 23:58). Kein Filter
nach Tags/Phasen/aktuell sichtbarem Zeitraum vor dieser Rechnung. Intake-Grenzen
werden respektiert. Bei mehrdeutiger Gerätezeit aus Zeitwechseln keine automatische
Bestätigung; Importzeit ist kein Ersatz für Messzeit.

- [x] **Rot:** Kernfälle anlegen: 07:44:59 passt nicht zu08:00, 07:45 und08:15 passen,
  08:15:01 nicht; Termine08:00/08:20 mit Messung08:10 gehören nur zu08:00;
  drei Messungen08:01/08:02/08:03 erfüllen nicht zusätzlich08:20.
  Gleichstand, Mitternacht, Slottrennung, fragwürdige Zeit, manueller Override,
  später Import, keine Kandidaten, Duplikate und ungültige Minuten testen.
- [x] **Rot ausführen:** `flutter test --no-pub test/plan/occurrence_matching_test.dart test/db/plan_migration_test.dart test/db/measurement_plan_repository_test.dart`.
- [x] **Implementieren:** `MeasurementPlanRepository` erhält AppDatabase + Uhr.
  Methoden `start(int slot, List<int> minutes)`, `changeTimes(int planId, List<int> minutes)`,
  `end(int planId)`, `setFeatureEnabled(bool enabled)`, `readSlot(int slot)`.
  Schreibaktionen speichern Revision und erhöhen desired_generation in **einer**
  Transaktion. Wiederaktivierung schreibt neue enabled-Revision; deaktivierte Zeit
  erzeugt keine neuen Solltermine. Änderung behält vergangene Belege, entfernt nur
  zukünftige Belege der alten Revision. Keine Revision auf eine erfundene Uhrzeit setzen.
- [x] **Grün:** Codegen, `flutter test --no-pub test/plan test/db`, Analyse.
  Reale v5→v7- und v6→v7-Dateiupgrades erhalten Metadaten und Exportjournal;
  Fehler während Upgrade rollt alles zurück. Keine stillen Plan-Defaults für ungültigen Slot.

## C2 — Android-Alarmmodul mit persistentem Arbeitsstand

**Neue Dateien:**
- `lib/plan/reminder_gateway.dart`, `lib/plan/android_reminder_gateway.dart`
- `android/app/src/main/kotlin/de/bdgraue/sphygma/reminders/ReminderModels.kt`
- `android/app/src/main/kotlin/de/bdgraue/sphygma/reminders/ReminderStore.kt`
- `android/app/src/main/kotlin/de/bdgraue/sphygma/reminders/ReminderScheduler.kt`
- `android/app/src/main/kotlin/de/bdgraue/sphygma/reminders/ReminderReceiver.kt`
- `android/app/src/main/kotlin/de/bdgraue/sphygma/reminders/ReminderPlugin.kt`
- `android/app/src/main/res/drawable/ic_reminder.xml`
- `android/app/src/test/kotlin/de/bdgraue/sphygma/reminders/ReminderSchedulerTest.kt`
- `test/plan/android_reminder_gateway_test.dart`

**Ändern:** `MainActivity.kt`, `AndroidManifest.xml`, `android/app/build.gradle.kts`.
Native Unit-Tests über lokal vorhandenes `testImplementation("junit:junit:4.12")`;
keine neue Produktionsabhängigkeit. Alarm-/Notificationzugriffe injizierbar halten,
Uhr/Zone ebenfalls; Unit-Tests prüfen Entscheidungslogik ohne Android-Gerät.

**Dart-Vertrag:** Neue Typen `ReminderSnapshot` und `ReminderReceipt` sind JSON-
transportierbar, Schema des Kanals versionieren (`protocolVersion=1`).

```dart
enum ReminderMode { off, exact, inexact, blocked, failed }

abstract interface class ReminderGateway {
  Future<ReminderReceipt> replace(ReminderSnapshot desired);
  Future<ReminderReceipt> inspect();
  Future<ReminderReceipt> requestAccess();
}
```

Snapshot: `protocolVersion`, `generation`, `enabled`, `rules`, `fulfilledKeys`,
`acknowledgedOccurrenceKeys` und `acknowledgedEventIds`. Die beiden Ack-Listen
enthalten ausschließlich bereits in einer erfolgreichen Drift-Transaktion
übernommene Belege. Leere Listen sind beim ersten Abgleich ein gültiger Zustand.
Jede rule enthält planId, revisionId, userSlot, sortierte minutesOfDay,
effectiveAtUtc und optional endsAtUtc. Keine Messwerte/Tags/Notizen/Pairing-Keys.
Receipt: generation, mode, notificationsAllowed, exactAllowed, channelBlocked,
pendingOccurrenceKeys, erzeugte PlannedOccurrences, Zeitwechselereignisse
(mit stabiler eventId, Zeitpunkt sowie alter/neuer Zone) und gegebenenfalls Fehler.
Bei nicht belegbarer alter Zone ist diese ausdrücklich null. Fehlende Pflichtfelder/Versionsabweichung werfen, nie `{}`.
MethodChannel-Name neu festlegen: `de.bdgraue.sphygma/reminders`, Methoden
`replace`, `inspect`, `requestAccess`; MainActivity bleibt FlutterFragmentActivity.

Native Ports für Testbarkeit: `AlarmPort`, `NotificationPort`, `SnapshotStore`,
`Clock`/`ZoneId`. Sie besitzen nur die tatsächlich verwendeten Operationen
(scheduleExact, scheduleInexact, cancel; permissions, post; load, save).
Der Android-Adapter führt nach erneuter Berechtigungsprüfung aus:

```kotlin
val exactAllowed = Build.VERSION.SDK_INT < 31 || alarmManager.canScheduleExactAlarms()
if (exactAllowed) {
    try {
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pendingIntent)
    } catch (error: SecurityException) {
        if (Build.VERSION.SDK_INT >= 31 && !alarmManager.canScheduleExactAlarms()) {
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pendingIntent)
        } else {
            throw error
        }
    }
} else {
    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pendingIntent)
}
```

SecurityException ist nur bei belegtem Rechteentzug ein erlaubter Rückfall.
Andere externe Fehler führen zu mode failed und einem sichtbaren Grund.
`areNotificationsEnabled()` und Kanal-Importance prüfen, bevor aktiv behauptet wird.

**Persistenz-/Lifecycle-Regeln:**
- SharedPreferences-Datei `sphygma_reminders` enthält versionierten JSON-Snapshot,
  Generation, gesetzte Schlüssel, Zustellhistorie und noch nicht quittierte Termin-/
  Zeitwechselbelege. Dies ist ein aus Drift abgeleiteter Arbeitsstand; native Änderungen
  betreffen nur Zustellung und Zeitumgebung, nie Planzeiten oder Messungswerte.
- Angewendete Generation und gewünschte Generation unterscheiden. Nach Teilfehler
  bleibt der Arbeitsstand unbestätigt; Wiederholung derselben Generation muss alle
  Alarme idempotent abgleichen. Alte Alarmidentitäten bis zum bestätigten Cancel
  behalten, damit ein Prozessabbruch keine unerreichbaren Alarme hinterlässt.
- `commit()`-Fehler ist Fehler. Neuere Generation atomar speichern **vor** Cancel/Replace,
  damit ein bereits zugestellter alter PendingIntent beim Receiver abgewiesen wird.
- Einmalige Alarme statt ungenauem `setRepeating`; nach Zustellung nächsten lokalen
  Tageszeitpunkt planen. ID/Intent-data deterministisch aus slot/revision/minute,
  Generation und occurrence key als Extras; nicht aus instabilem hashCode allein.
- PendingIntent explizit, immutable, update-current. Receiver prüft Generation,
  enabled, occurrence key und bisherige Zustellung vor dem Posten. Doppelte Broadcasts
  erzeugen keine zweite Benachrichtigung. Tap öffnet Messplan, kein automatischer Export.
- Termine heute/morgen bei replace/inspect materialisieren; bei Receiverlauf nächste
  Termine. Noch nicht nach Drift übernommene Terminbelege bleiben im Store bis zur
  Quittierung einer erfolgreichen DB-Transaktion (Receipt-Ack im nächsten replace).
- Datum/Minute/Zone je geplantem Termin festhalten. Zeitwechselereignisse ebenfalls
  dauerhaft protokollieren. Historische Lücken anhand alter Revisionen und bekannter
  Zone rückrechnen; ohne belastbare Zone als timeAmbiguous mit null-Zeitpunkt/Zone markieren, nicht raten.
- Alarmzeiten mit `java.time` aus lokaler Uhr berechnen; Sommerzeitloch → erster
  gültiger Zeitpunkt, doppelte Uhrzeit → frühere Instanz, einmal je lokale Termin-ID.
- Bei BOOT_COMPLETED, MY_PACKAGE_REPLACED, TIME_SET, TIMEZONE_CHANGED und Erteilung
  des Exact-Zugriffs künftige Alarme aus Snapshot ersetzen. Keine vergangene Serie nachholen.
- Exact-Rechteentzug hat keine verlässliche Entzugsbroadcast-Zusage. inspect bei Appstart/
  Resume prüft deshalb alle Rechte und plant gegebenenfalls ungenau neu. Diese Grenze
  dokumentieren; keine Garantie für sofortigen Rückfall bei bereits beendetem Prozess.
- Force-stop respektieren; keine Tricks zum Umgehen des Nutzerstopps.

Manifest-Ergänzungen (bestehende BLE/Health/Backup-Konfiguration erhalten):

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<!-- Inside application -->
<receiver android:name=".reminders.ReminderReceiver" android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
        <action android:name="android.intent.action.TIME_SET" />
        <action android:name="android.intent.action.TIMEZONE_CHANGED" />
        <action android:name="android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED" />
    </intent-filter>
</receiver>
```

Keine USE_EXACT_ALARM-Berechtigung übernehmen. Nur der explizite Nutzerweg zum
Aktivieren darf Berechtigungsdialoge öffnen; kein Prompt im BootReceiver.

- [x] **Rot:** Native Ports testen: exact true→exact, exact false→inexact;
  Notifications/Kanal blockiert→blocked; Fehler im Persistieren/Cancel/Schedule→failed;
  alte Generation und doppelte Zustellung→kein Post; disable→keine gesetzten Alarme;
  Neustart mit aktiviertem/ausgeschaltetem Snapshot; Zeitwechsel 02:30 sowie Tageswechsel.
  Dart-Test mockt nur den MethodChannel und prüft das vollständige Receipt-Decoding.
- [x] **Rot ausführen:** `flutter test --no-pub test/plan/android_reminder_gateway_test.dart`;
  aus android: `./gradlew :app:testDebugUnitTest --offline`.
- [x] **Implementieren:** Klassen und Receiver nach den obigen Verträgen; keine
  produktive Noop-Implementierung. Reconcile serialisieren, damit ältere Callbacks
  keine neuere Generation überschreiben. Änderungen am Store/Alarmbetrieb in einem
  nativen Prozess koordinieren; kein langes DB-/Netzwerk-I/O im Receiver.
- [x] **Grün:** dieselben Tests, `./gradlew :app:lintDebug --offline`, Flutter-Analyse.
  XML semantisch auf Receivernamen/Rechte und erhaltene Backup-Ausschlüsse prüfen.

## C3 — PlanController, optionaler Reiter und Erfüllung

**Neue Dateien:** `lib/plan/plan_controller.dart`, `lib/ui/plan/measurement_plan_screen.dart`,
`lib/ui/plan/plan_editor.dart`, `lib/ui/plan/plan_today_card.dart`,
`lib/ui/plan/occurrence_assignment_sheet.dart`, `test/plan/plan_controller_test.dart`,
`test/ui/plan/measurement_plan_screen_test.dart`, `test/ui/plan/plan_visibility_test.dart`.
**Ändern:** `lib/main.dart`, `lib/app/app_controller.dart`, `lib/ui/app_home.dart`,
`lib/ui/today_screen.dart`, `lib/ui/settings_screen.dart`, `lib/db/settings_repository.dart`.

**PlanController-Vertrag:** Constructor erhält MeasurementPlanRepository, Metadata-
unabhängigen MeasurementRepository, ReminderGateway und Uhr. Er bietet
`load()`, `setEnabled(bool)`, `saveTimes(List<int>)`, `endPlan()`, `refreshAfterSync()`
und `reconcileReminders()`. Sichtbare Felder: enabled, busy, mode, error,
currentSlotPlan, todayOccurrences, fulfillment, nextOccurrence.
`setUserSlot(int)` lädt einen anderen Slot, verändert aber keine Pläne anderer Slots.
Settings-Key `measurement_plan_enabled`: fehlend false, explizit gespeicherte Auswahl
bleibt. Die globale Funktion schaltet alle Planalarme aus; keine anderen Alarmarten.

Koordination jeder Mutation:

```text
1. Planrevision/desired_generation in Drift-Transaktion speichern.
2. Neueste vollständige desired-Konfiguration aller Slots lesen.
3. await gateway.replace(snapshot).
4. Nur bei passender Generation Receipt/Terminbelege in Drift übernehmen.
5. applied_generation bestätigen; UI mode aus Receipt, nicht aus Wunschwert ableiten.
Bei Fehler: desired behalten, angewendeten Zustand als unbestätigt kennzeichnen,
Fehler anzeigen und beim nächsten load/resume erneut abgleichen.
```

Wenn Ausschalten vor dem nativen Cancel scheitert, nicht „alles aus“ behaupten:
„Abschalten der Erinnerungen nicht bestätigt“ bleibt an der Einstellung sichtbar,
und der nächste Abgleich wiederholt den Vorgang. Native Generation verhindert
verspätete alte Posts erst nachdem der neue Snapshot tatsächlich angekommen ist.

- [x] **Rot:** enabled false→kein Tab, keine Karte, kein Prompt; enabled true ohne
  Plan→Editor erreichbar; drei/fünf Zeiten speichern und Neustart. Deaktivieren vom
  ausgewählten Messplan-Tab führt auf Heute und cancelt Alarme. Reaktivierung setzt
  nur zukünftige Termine. Readoutfehler/Exportfehler getrennt; späterer erfolgreicher
  Sync ergänzt vergangene Erfüllung ohne neue Erinnerung.
- [x] **Rot ausführen:** `flutter test --no-pub test/plan/plan_controller_test.dart test/ui/plan`.
- [x] **Implementieren:** native Gateway im main verdrahten; PlanController lebt
  neben AppController, wird über App-Lifecycle resumed abgeglichen. Erfolgreicher Sync
  aktualisiert Erfüllung nach persistiertem Readout, unabhängig von Exporterfolg.
  Keine Schleife, die bei jedem UI-Neubau alle Alarme neu setzt.
- [x] **Oberfläche:** Uhrzeiten als sortierte, bearbeitbare Liste, leere/duplizierte
  Zeitliste verständlich abweisen. Pro Termin „Messung zugeordnet“, „Noch keine
  Messung zugeordnet“ oder „Zeit nicht eindeutig“. Kein „Nicht gemessen“ aus fehlendem
  Import ableiten. Vorhandene Messung manuell zuordnen über das Assignment-Sheet,
  weder Messwert noch Zeitstempel dabei verändern. Kein „bereits gemessen“-Knopf.
  PlanTodayCard zeigt zugeordnete Anzahl und nächsten Termin, weder Strafe noch Serie.
  Bei ausgeschalteter Funktion weder Reiter noch Karte/Einrichtungsaufforderung.
- [x] **Grün:** `flutter test --no-pub test/plan test/ui/plan test/app`, Analyse;
  Tests mit zwei Slots, Rechtefehler, Race zwischen Ausschalten und altem Receipt,
  Prozessneustart nach DB-Schreiben vor Gateway-Aufruf. Alle Gestaltungsformen prüfen.

## C4 — Integration, Dokumentation und spätere Geräteabnahme

**Dateien:** Dokumentationsliste im Hauptplan; neu
`docs/reviews/2026-09-11-messplan-abnahme.md` bei Umsetzung, mit Ergebnissen statt vorab
behaupteter Erfolge. Geräteprüfung erst nach ausdrücklichem Build-/Installationsauftrag.

- [x] **Automatisch:** gemeinsame Abschlussbefehle aus Hauptplan; Kotlin Unit/Lint,
  echte DB-Upgrades v4/v5/v6→v7, Export-/Intake-/Autosync-Regressionssuite, beide ESC-Modi.
- [x] **Datenfälle:** Bestands-ID, Rohbytes und exportierte Client-ID vor/nach Upgrade
  identisch; alte manuelle Phasenwahl erhalten; beide Slotkopien; Notizen/Tags bei
  erneuter Geräteeinlesung erhalten. Keine Phasen- oder Tagfilterwirkung auf Exportumfang.
- [x] **Dokumentation:** Annahmen/gelieferte Regeln abgleichen; alte Konzept-Matrix,
  Datenschutz und Alarmrecherche aktualisieren. Kein AGENTS.md-Overwrite.
- [x] **Gerät nach Auftrag:** Genau eine passende Debug-APK mit ESC=true und höherem
  als dem dann installierten Versionscode; Signatur vergleichen, `adb install -r`,
  niemals zur Behebung eines Signaturproblems deinstallieren. Keine Versionszahl aus
  diesem Plan blind übernehmen; derzeitiger bekannter Stand ist Debug2002.
- [ ] **Reale Fälle:** Zeitnahe Testtermine mit Nutzer vereinbaren; Exact erlaubt und
  verweigert, Kanal blockiert, App geschlossen ohne force-stop, Bildschirm aus,
  Neustart, disable/re-enable, Zeitwechsel nur mit ausdrücklicher Zustimmung zum
  Ändern der Gerätezeit. Tatsächliche Zustellzeit und geplante Zeit protokollieren.
  Zwei echte BLE-Messungen prüfen, ohne hierfür Messwerte zu erzeugen oder zu fingieren.
- [x] **Abschluss:** Erfolgreiche und ungeprüfte Fälle einzeln nennen. Keine Aussage
  „Erinnerungen zuverlässig“ allein aus Mocktests oder einem erfolgreichen Build.
