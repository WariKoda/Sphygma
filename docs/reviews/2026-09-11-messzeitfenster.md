# Morgen- und Abendfenster

Die starre 12-Uhr-Teilung wurde durch gemeinsame, einstellbare Fenster ersetzt.
Standard gemäß Nutzerentscheidung: morgens 05:00–10:00, abends 18:00–23:00.
Der Beginn zählt dazu, das Ende nicht. Messungen um 13 Uhr zählen daher nicht mehr
zum Abendmittel, bleiben aber in Listen, Kurven und Gesamtauswertungen erhalten.

Einstellungen → Ansicht → Morgen und Abend öffnet den Editor. Änderungen werden
zusammen gespeichert, wirken rückwirkend auf Heute, Wochenraster und Verlauf und
ändern weder Messdaten noch Messplan/Erinnerungen. Über Mitternacht laufende
Fenster sind möglich; die Messung bleibt bei ihrem tatsächlichen Kalendertag.
Leere oder überlappende Fenster werden abgelehnt. Abbrechen verwirft den Entwurf.

## Prüfung

- `flutter analyze`: keine Befunde.
- `flutter test --no-pub`: 663 Tests bestanden.
- `flutter test --no-pub --dart-define=SPHYGMA_ESC=true`: 663 Tests bestanden.
- Grenzzeiten, 13-Uhr-Regression, eigene/über Mitternacht laufende Fenster,
  Gesamtmittel und Datenbestand, Speichern/Neuladen, Editor-Abbruch, Reset,
  Überschneidungen und Speicherfehler geprüft.
- Unabhängiges Quellcodereview: keine konkreten Vertragsverletzungen.
- Formatierung und `git diff --check` sauber.

Auf Installationsauftrag eine ARM64-Debug-APK mit Versionscode 2005 und
`SPHYGMA_ESC=true` erfolgreich gebaut. Nach Wiederaktivierung von WLAN-Debugging
per `adb install -r` erfolgreich als Update installiert. Paketmanager bestätigt
Versionscode 2005; App-Start meldet `Status: ok`. Keine Deinstallation oder
Datenlöschung. Eine vollständige manuelle Bedienprüfung bleibt offen.
