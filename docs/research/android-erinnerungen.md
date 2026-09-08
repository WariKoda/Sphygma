# Was Android für geplante Erinnerungen erlaubt

Recherchiert 2026-09-08 gegen die Primärquellen. Jede Behauptung trägt ihre
Quelle; nichts hier stammt aus dem Gedächtnis.

Grundlage für `PLAN.md` §9.3. Sphygma steht auf `minSdk 29`, `targetSdk 36` —
alle unten genannten Regeln greifen also, keine ist durch ein niedriges Ziel
umgangen.

## Die Kurzfassung

**Eine Erinnerung, die auf die Minute genau zündet, bekommt Sphygma nicht
geschenkt — und die bequeme Abkürzung dorthin ist ihr verboten.** Aber sie
braucht diese Genauigkeit auch nicht: `setAndAllowWhileIdle()` liefert ohne
jedes Sonderrecht eine Erinnerung auf etwa eine Viertelstunde genau, und das
reicht für „miss morgens" vollkommen.

Diese Datei wurde am 08.09.2026 nach einem Gegenblick korrigiert. Die erste
Fassung hatte `setAndAllowWhileIdle()` in der Abwägung übersehen und deshalb zu
Sonderrechten geraten, die es nicht braucht; die beiden falschen Stellen sind
unten ausdrücklich als solche benannt statt stillschweigend ersetzt.

## 1. Benachrichtigungen brauchen eine Laufzeitberechtigung

| Fakt | Quelle |
|---|---|
| `POST_NOTIFICATIONS` ist eine Laufzeitberechtigung, eingeführt mit Android 13 (API 33) | [Notification runtime permission] |
| Lehnt der Nutzer ab, sind **alle** Benachrichtigungskanäle der App blockiert, nicht nur einer | [Notification runtime permission] |
| Bei `targetSdk` 33+ bestimmt die App selbst, wann der Dialog erscheint | [Notification runtime permission] |
| Ausgenommen sind nur Medien- und Anruf-Benachrichtigungen — für Sphygma nicht einschlägig | [Notification runtime permission] |
| `NotificationManager.areNotificationsEnabled()` sagt vor dem Senden, ob es überhaupt geht | [Notification runtime permission] |

**Folge für uns:** Der Zustand „Erinnerungen eingerichtet, aber Berechtigung
entzogen" ist ein echter, dauerhafter Zustand und muss sichtbar sein. Eine App,
die stumm nicht erinnert, ist schlimmer als eine ohne Erinnerung — der Nutzer
verlässt sich darauf.

## 2. Exakte Alarme: die Abkürzung ist Sphygma verboten

Es gibt zwei Berechtigungen, und die bequeme davon dürfen wir nicht nehmen.

| | `USE_EXACT_ALARM` | `SCHEDULE_EXACT_ALARM` |
|---|---|---|
| Ab | Android 13 (API 33) | Android 12 (API 31) |
| Vergabe | **automatisch**, nicht widerrufbar | **Nutzer muss zustimmen** |
| Bei Neuinstallation auf Android 14+ | gewährt | **standardmäßig verweigert** |
| Play-Policy | nur Wecker-/Timer- und Kalender-Apps | frei nutzbar |

Die Play-Policy zu `USE_EXACT_ALARM` lautet wörtlich, die Funktion sei nur zu
nutzen, wenn „your app's core, user facing functionality requires
precisely-timed actions, such as: the app is an alarm or timer app; the app is
a calendar app that shows event notifications". Und zur Folge: „Apps that
request this restricted permission are subject to review, and those that do not
meet the acceptable use case criteria will be **disallowed from publishing on
Google Play**." [Play policy]

**Eine Blutdruck-Messerinnerung steht auf keiner der beiden Listen.** Die
Policy verweist für diesen Fall ausdrücklich auf `SCHEDULE_EXACT_ALARM`.

Zu `SCHEDULE_EXACT_ALARM` kommt eine unangenehme Eigenschaft: Die Berechtigung
**geht bei Backup-and-Restore auf ein neues Gerät verloren**. [Schedule alarms]
Wer sein Telefon wechselt, hat seine Erinnerungen also lautlos verloren, wenn
die App das nicht bemerkt und meldet.

**Android 14 verschärft das nochmals:** `SCHEDULE_EXACT_ALARM` ist bei
Neuinstallation *standardmäßig verweigert* — für jede App mit `targetSdk` 33+,
die keine Kalender- oder Weckeranwendung ist. [Android 14] Sphygma liegt mit
`targetSdk 36` mitten darin.

### Die Ausnahme: Power-Allowlist

Apps **auf der Power-Allowlist** dürfen `setExact()` und
`setExactAndAllowWhileIdle()` aufrufen, **ohne** `SCHEDULE_EXACT_ALARM` zu
besitzen. [Android 14] Auf die Allowlist kommt eine App über
`ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`, also durch eine bewusste
Entscheidung des Nutzers — und dieselbe Freistellung nimmt die App aus dem
App Standby (Abschnitt 3). Zwei Probleme, eine Frage.

**Vermutlich brauchen wir sie trotzdem nicht** — siehe die korrigierte
Abwägung in Abschnitt 4. Sie steht hier als letzte Rückfallebene, nicht als
Empfehlung. Zu prüfen, bevor jemand darauf baut: Auch das Anfordern der
Freistellung unterliegt einer Play-Policy, die hier **nicht** recherchiert
ist.

### Weitere belegte Einzelheiten

* `setWindow()` als ungenauer Rückfall hat ein Mindestfenster von **10
  Minuten**. [Android 14]
* `setExact()` mit einem `OnAlarmListener` braucht die Berechtigung nicht —
  nutzlos für uns, weil das nur läuft, solange der Prozess lebt. [Android 14]
* Empfohlener Rückfall, wenn die Berechtigung fehlt: in `onResume()` prüfen und
  auf `setWindow()` ausweichen. [Android 14]

Prüfen und anfordern:

* `AlarmManager.canScheduleExactAlarms()` — vor jedem Setzen fragen
* `Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM` — führt in die
  Systemeinstellung „Wecker und Erinnerungen"
* `ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED` — Rundfunk **nur bei
  der Erteilung**

Die ersten beiden aus [Schedule alarms].

**Achtung, hier stand zuerst etwas Falsches:** Der Rundfunk kommt *nicht* beim
Entzug. Der Quelltext sagt es wörtlich — „This broadcast will *not* be sent
when the user revokes the permission" —, und beim Entzug werden zugleich alle
mit exakten Alarmen geplanten Weckrufe **gelöscht**. [AlarmManager Z. 153-170]

Eine Umsetzung, die sich auf den Rundfunk verlässt, bemerkt den Entzug also
nie: Die Erinnerungen sind weg, und die App hält sie für gesetzt. Der Entzug
muss beim Zurückkehren in die App aktiv geprüft werden — mit
`canScheduleExactAlarms()`.

## 3. Doze und App Standby verschieben, was nicht ausgenommen ist

| Fakt | Quelle |
|---|---|
| In Doze werden `setExact()` und `setWindow()` bis zum nächsten Wartungsfenster **verschoben** | [Doze and App Standby] |
| `setAndAllowWhileIdle()` und `setExactAndAllowWhileIdle()` feuern auch in Doze | [Doze and App Standby] |
| …aber mit einer Frequenzgrenze je App: die Doku nennt „einmal je neun Minuten", der Quelltext „etwa jede Minute, in Ruhemodi deutlich länger, etwa 15 Minuten" | [Doze and App Standby] / [AlarmManager Z. 1195-1210] |
| `setAlarmClock()` feuert pünktlich und holt das Gerät aus Doze — gedacht für Wecker und Kalender, ausdrücklich als sehr ressourcenintensiv bezeichnet | [Doze and App Standby], [Schedule alarms] |
| Die Wartungsfenster werden **seltener, je länger das Gerät ungenutzt bleibt** | [Doze and App Standby] |
| `WorkManager` hilft hier nicht: Es setzt auf `JobScheduler`, und der läuft in Doze nicht | [Doze and App Standby] |
| `setAndAllowWhileIdle()` verlangt **keine** Berechtigung — `@RequiresPermission(SCHEDULE_EXACT_ALARM)` steht nur an `setExact`, `setExactAndAllowWhileIdle` und `setAlarmClock` | [AlarmManager Z. 805, 910, 1237, 1275] |
| Seit Android 14 hebt `SCHEDULE_EXACT_ALARM` den Standby-Bucket **nicht mehr** an | [AlarmManager Z. 302-313] |

**App Standby trifft Sphygma härter als Doze.** Es greift, wenn der Nutzer die
App länger nicht angefasst hat, sie keinen Vordergrundprozess und keine
sichtbare Benachrichtigung hat — und verschiebt Alarme ebenso. [Doze and App
Standby]

Das ist bei Sphygma **der Normalfall, nicht der Ausnahmefall**: Die App
synchronisiert von selbst, sobald das Gerät nach einer Messung sendet. Wer sie
benutzt, wie sie gedacht ist, öffnet sie kaum. Genau dieser Nutzer landet im
Standby-Bucket — und wäre der, dessen Erinnerung zu spät käme.

## 4. Die Abwägung — korrigiert nach dem Gegenblick

**Hier stand zuerst ein Fehler, und er verzerrte die ganze Empfehlung.** Der
erste Entwurf behauptete: „Ohne `SCHEDULE_EXACT_ALARM` bleibt nur ein ungenauer
Alarm, und der wird in Doze bis zum nächsten Wartungsfenster verschoben" — was
Stunden heißen kann. Das übersah `setAndAllowWhileIdle()`, das zwei Absätze
weiter oben in der eigenen Tabelle stand.

Richtig ist:

* `setAndAllowWhileIdle()` feuert **auch in Doze**, braucht **keine**
  Berechtigung und wartet nicht auf ein Wartungsfenster.
* Es ist ein *ungenauer* Alarm mit einer Frequenzgrenze — laut Quelltext etwa
  eine Minute im Normalbetrieb, in Ruhemodi „deutlich länger, etwa 15
  Minuten". [AlarmManager Z. 1195-1210]
* Für einen Messplan mit zwei bis vier Erinnerungen am Tag, Stunden
  auseinander, bindet diese Grenze nicht.

**Eine Viertelstunde Streuung, nicht Stunden.** Für „miss morgens" ist das
völlig ausreichend; die Tageszeit-Zuordnung einer Messung ändert sich dadurch
nicht.

### Die drei Wege, neu bewertet

1. **`setAndAllowWhileIdle()`, ohne jedes Sonderrecht.** Kostet den Nutzer
   nichts außer der Benachrichtigungsberechtigung, die ohnehin nötig ist. Die
   Erinnerung ist auf etwa eine Viertelstunde genau — was man ihr auch so
   sagen darf. **Das ist der Weg, mit dem zu beginnen ist.**
2. **`SCHEDULE_EXACT_ALARM` erbitten.** Bringt Minutengenauigkeit, kostet einen
   Gang in die Systemeinstellungen, ist seit Android 14 standardmäßig
   verweigert, geht bei einem Gerätewechsel verloren, meldet ihren Entzug
   nicht — und hebt seit Android 14 den Standby-Bucket **nicht** mehr an, löst
   das Standby-Problem also gerade nicht. Viel Aufwand für den Unterschied
   zwischen 15 Minuten und einer Minute.
3. **Energiefreistellung erbitten.** Der größte Eingriff, ungeprüfte
   Play-Policy. Erst zu erwägen, wenn sich am Gerät zeigt, dass Weg 1 nicht
   trägt.

Die frühere Empfehlung lief auf Weg 2 oder 3 hinaus. Nach der Korrektur ist
das falsch herum: **Weg 1 ist der richtige Anfang**, und ob er reicht,
entscheidet eine Messung am Gerät, keine Vermutung.

## 5. Was noch offen ist

Nicht recherchiert, weil es erst beim Entwurf zählt:

* Welches Flutter-Paket geplante Benachrichtigungen abdeckt und ob es
  `setExactAndAllowWhileIdle` bzw. `setAlarmClock` überhaupt anbietet. Sphygma
  hat heute **kein** Benachrichtigungspaket in `pubspec.yaml`.
* Wie herstellereigene Energiesparfunktionen (Fairphone/Android-Skins) sich
  zusätzlich verhalten. Die Android-Doku deckt nur den Standard ab.
* Ob eine Erinnerung nach einem Neustart des Telefons neu gesetzt werden muss
  und welche Berechtigung das verlangt.

## Quellen

* [Schedule alarms]: <https://developer.android.com/develop/background-work/services/alarms/schedule>
* [Notification runtime permission]: <https://developer.android.com/develop/ui/views/notifications/notification-permission>
* [Play policy]: <https://support.google.com/googleplay/android-developer/answer/16558241>
  („Permissions and APIs that Access Sensitive Information", Abschnitt *Exact
  Alarm Permission*). Der Wortlaut wurde zusätzlich über eine Suche auf
  `support.google.com` gegengeprüft, weil die erste abgerufene Seite eine
  Fassung ohne den Policy-Text war.
* [Android 14]: <https://developer.android.com/about/versions/14/changes/schedule-exact-alarms>
* [Doze and App Standby]: <https://developer.android.com/training/monitoring-device-state/doze-standby>
* [AlarmManager]: der lokal installierte Quelltext,
  `~/Android/Sdk/sources/android-36/android/app/AlarmManager.java`. Wo er der
  Doku widerspricht, gilt er — er ist die Quelle, aus der die Doku entsteht.
