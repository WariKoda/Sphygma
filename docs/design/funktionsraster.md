# Funktionsraster: was jedes Konzept können muss

Stand 2026-09-05.

Die Konzepte sind **vollständige, eigenständige Ausführungen derselben App**
über demselben Datenbestand. Der Nutzer wählt eines aus — und bekommt dann die
komplette Funktionalität in dieser Organisation. Kein Konzept ist ein Ausschnitt,
keines verweist auf ein anderes, keines lässt etwas weg.

Das unterscheidet sie von den Handschriften nur in der Ebene: Eine Handschrift
bestimmt, **wie** es aussieht. Ein Konzept bestimmt, **wie es organisiert ist**.
Beide Achsen sind frei kombinierbar.

## Die Funktionen

Verbindlich aus `lib/app/app_controller.dart` und den bestehenden Bildschirmen
abgelesen, nicht geschätzt.

| # | Funktion | Woran es im Code hängt |
|---|---|---|
| F1 | Messwerte ansehen | `measurements`, `latest` |
| F2 | Auswertung über einen Zeitraum | `measurementsInPeriod`, `period`, `setPeriod`, `PeriodAverages`, `TrendStats` |
| F3 | Eine einzelne Messung im Detail | `Measurement` mit `deviceSequence`, `importedAt`, `movement`, `arrhythmia` |
| F4 | Einordnung des Werts | `classifyOffice`, `escClassificationEnabled` |
| F5 | Bericht für die Praxis | noch nicht gebaut, eigener Plan |
| F6 | Gerät koppeln | `pair`, `paired`, `setUserSlot`, `userSlot` |
| F7 | Abgleich, selbst ausgelöst | `sync`, `busy` |
| F8 | Abgleich, automatisch — und sein Zustand | `autoSyncActive`, das Advertising |
| F9 | Health Connect, alle | `exportAll`, `retractAll`, `pendingExport` |
| F10 | Health Connect, einzeln | `exportOne`, `retractOne`, `exportedAt` |
| F11 | Hinweis: Geräteuhr geht falsch | `clockLooksWrong` |
| F12 | Hinweis: nicht gekoppelt | `paired` |
| F13 | Meldungen des Steuerungsteils | `status` |
| F14 | Gestaltung wählen | `themeVariant`, `setThemeVariant` |
| F15 | Konzept wählen | neu |

## Die Regel

**Jedes Konzept deckt alle fünfzehn ab.** Wo eine Funktion in der Logik des
Konzepts keinen naheliegenden Ort hat, muss das Konzept einen erfinden — sie
wegzulassen ist kein Stilmittel, sondern ein Fehler.

Was ein Konzept dagegen frei bestimmt: wo eine Funktion sitzt, wie sie heißt, wie
prominent sie ist, und über welches Objekt man an sie herankommt. „Sieben Tage"
erreicht eine Einzelmessung über die Woche, „Tagesprofil" über die Tageszeit,
„Messanlass" über den Anlass — dieselbe Funktion F3, drei Wege dorthin.

## Was das für die vorhandenen Ausarbeitungen heißt

Die bisherigen Entwürfe wurden unter einer falschen Annahme gezeichnet: dass ein
Konzept weglassen darf, was nicht zu seiner These passt. Das ist zu korrigieren.
Bekannte Lücken:

| Konzept | Fehlt heute |
|---|---|
| Sieben Tage | F2 über frei gewählte Zeiträume, F14 |
| Tagesprofil | F5, F6, F9, F10, F14 |
| Messanlass | F2, F5, F14 |
| Phase | F5 teilweise, F14 |
| Das Auffällige | F1 vollständig, F2, F5 — nur als Skizze vorhanden |
| Übertragung | F1 bis F5 vollständig — nur als Skizze vorhanden |

## Zwei Fragen, die davon unberührt bleiben

Sie betreffen den Funktionsumfang der App, nicht die Konzeptwahl, und gelten
deshalb für alle Konzepte gleich:

* Ob eine Messung einen Zeit-Offset tragen darf, um den AM/PM-Fehler der
  Geräteuhr auszugleichen. Betrifft die Regel „die Datenbank ist reines Abbild
  des Geräts".
* Ob Wertschwellen einstellbar sind. Betrifft dieselbe MDR-Frage wie die
  ESC-Klassifikation.

Fällt die Antwort ja, bekommen **alle** Konzepte die Funktion und müssen ihr
einen Ort geben. Fällt sie nein, hat **keines** sie.
