# Was Android für geplante Erinnerungen erlaubt

Recherchiert 2026-09-08 gegen die Primärquellen. Jede Behauptung trägt ihre
Quelle; nichts hier stammt aus dem Gedächtnis.

Grundlage für `PLAN.md` §9.3. Sphygma steht auf `minSdk 29`, `targetSdk 36` —
alle unten genannten Regeln greifen also, keine ist durch ein niedriges Ziel
umgangen.

## Die Kurzfassung

**Eine Erinnerung, die auf die Minute genau zündet, bekommt Sphygma nicht
geschenkt — und die bequeme Abkürzung dorthin ist ihr verboten.** Wer das
ignoriert, baut ein Feature, das entweder unzuverlässig ist oder die App aus
dem Play Store wirft.

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
| Bei Neuinstallation auf API 33+ | gewährt | **nicht** vorgewährt |
| Play-Policy | nur Wecker-/Timer- und Kalender-Apps | frei nutzbar |

Die Play-Policy zu `USE_EXACT_ALARM` ist wörtlich: Apps dürfen die Berechtigung
nur deklarieren, wenn ihre **Kernfunktion** einen exakten Alarm verlangt;
zugelassen sind Wecker-, Timer- und Kalender-Apps. **Eine Medikamenten- oder
Gesundheitserinnerung qualifiziert nicht.** Apps, die die Kriterien nicht
erfüllen, werden von der Veröffentlichung bei Google Play ausgeschlossen; die
Policy verweist ausdrücklich auf `SCHEDULE_EXACT_ALARM` als Alternative.
[Play policy]

Zu `SCHEDULE_EXACT_ALARM` kommt eine unangenehme Eigenschaft: Die Berechtigung
**geht bei Backup-and-Restore auf ein neues Gerät verloren**. [Schedule alarms]
Wer sein Telefon wechselt, hat seine Erinnerungen also lautlos verloren, wenn
die App das nicht bemerkt und meldet.

Prüfen und anfordern:

* `AlarmManager.canScheduleExactAlarms()` — vor jedem Setzen fragen
* `Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM` — führt in die
  Systemeinstellung „Wecker und Erinnerungen"
* `ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED` — Rundfunk, wenn der
  Nutzer sie entzieht oder erteilt; danach müssen die Alarme neu gesetzt werden

Alle drei aus [Schedule alarms].

## 3. Doze und App Standby verschieben, was nicht ausgenommen ist

| Fakt | Quelle |
|---|---|
| In Doze werden `setExact()` und `setWindow()` bis zum nächsten Wartungsfenster **verschoben** | [Doze and App Standby] |
| `setAndAllowWhileIdle()` und `setExactAndAllowWhileIdle()` feuern auch in Doze | [Doze and App Standby] |
| …aber **höchstens einmal je neun Minuten und App** | [Doze and App Standby] |
| `setAlarmClock()` feuert pünktlich und holt das Gerät aus Doze — gedacht für Wecker und Kalender, ausdrücklich als sehr ressourcenintensiv bezeichnet | [Doze and App Standby], [Schedule alarms] |
| Die Wartungsfenster werden **seltener, je länger das Gerät ungenutzt bleibt** | [Doze and App Standby] |
| `WorkManager` hilft hier nicht: Es setzt auf `JobScheduler`, und der läuft in Doze nicht | [Doze and App Standby] |

**App Standby trifft Sphygma härter als Doze.** Es greift, wenn der Nutzer die
App länger nicht angefasst hat, sie keinen Vordergrundprozess und keine
sichtbare Benachrichtigung hat — und verschiebt Alarme ebenso. [Doze and App
Standby]

Das ist bei Sphygma **der Normalfall, nicht der Ausnahmefall**: Die App
synchronisiert von selbst, sobald das Gerät nach einer Messung sendet. Wer sie
benutzt, wie sie gedacht ist, öffnet sie kaum. Genau dieser Nutzer landet im
Standby-Bucket — und wäre der, dessen Erinnerung zu spät käme.

## 4. Die neun Minuten sind für uns kein Problem, die Kombination schon

Ein Messplan braucht zwei bis vier Erinnerungen am Tag, Stunden auseinander.
Die Neun-Minuten-Grenze von `setExactAndAllowWhileIdle()` bindet also nicht.

Das Problem liegt woanders: Ohne `SCHEDULE_EXACT_ALARM` bleibt nur ein
ungenauer Alarm, und der wird in Doze **bis zum nächsten Wartungsfenster
verschoben** — dessen Abstand mit der Ruhezeit wächst. Eine Erinnerung für
07:00 kann so um 08:40 kommen. Für „miss morgens" ist das grenzwertig; für
einen ärztlichen Messplan, dessen Werte nach Tageszeit ausgewertet werden, ist
eine um 100 Minuten verschobene Morgenmessung eine verfälschte Morgenmessung.

**Daraus folgt die Entwurfsfrage, die vor dem Bauen zu klären ist:** Wird die
Erinnerung als „ungefähr" angekündigt und bleibt ohne Sonderrechte, oder
verlangt sie `SCHEDULE_EXACT_ALARM` vom Nutzer und sagt ehrlich, warum? Ein
Mittelweg, der Genauigkeit verspricht und keine liefert, ist der einzige Weg,
der ausscheidet.

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
* [Play policy]: <https://support.google.com/googleplay/android-developer/answer/13161072>
* [Doze and App Standby]: <https://developer.android.com/training/monitoring-device-state/doze-standby>
