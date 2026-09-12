# Heute — Umsetzung Originalnah

Stand 11.09.2026. Freigegebener Entwurf 01 ist in Flutter umgesetzt.

## Verhalten

- Blutdruck und Puls stehen in getrennten Bereichen, mit großen letzten Werten
  und vollständiger Messzeit. Beide öffnen dieselbe angezeigte Einzelmessung.
- Morgen-/Abendmittel beziehen sich auf den heutigen Kalendertag des gewählten
  Speicherplatzes (Grenze 12 Uhr). Anzahl und tatsächliche Zeitspanne stehen dabei;
  fehlende Werte werden nicht durch Nullwerte ersetzt.
- Die Tagesliste öffnet einzelne Messungen einschließlich Metadatenbearbeitung.
  Über Mitternacht wechseln die Mittelwerte ohne neuen Abgleich.
- Alle sechs Formen verwenden gemeinsame Bausteine; Palette und Schrift bleiben
  unabhängig. Wochenraster und letzte Messungen bleiben separat abschaltbar.

## Prüfung

- `flutter analyze`: keine Befunde.
- `flutter test --no-pub`: 642 Tests bestanden.
- `flutter test --no-pub --dart-define=SPHYGMA_ESC=true`: 642 Tests bestanden.
- Echte 360-Pixel-View mit doppelter Systemschrift für alle sechs Formen geprüft;
  ergänzend Nachtfarben, Mittelwerte, Zeitspannen, leere Zeitbänder, Navigation,
  Geräteuhr-Rückstellung, Mitternacht und optionale Abschnitte getestet.
- Sechs Flutter-Ansichten mit kanonischen Beispieldaten, Archivo und Material-
  Symbolen gerendert und visuell geprüft. Formatierung und `git diff --check` sauber.
- Unabhängiges Review: Auswahl der letzten Messung, Nachtfarben, tatsächliche
  Layoutbreite und fehlende Zeitspannen korrigiert.

## Geräteabnahme

Auf ausdrücklichen Installationsauftrag am 11.09.2026 eine ARM64-Debug-APK mit
Versionscode 2004 und `SPHYGMA_ESC=true` gebaut. Update von 2003 per `adb install -r`
erfolgreich; Paketmanager bestätigt Version 2004, App-Start meldet `Status: ok`.
Keine Deinstallation oder Datenlöschung. Die neue Oberfläche ist damit installiert;
eine vollständige manuelle Bedienprüfung ist noch offen. Frühere offene Hardwareprüfungen
für Erinnerungen bleiben im [Messplan-Abnahmeprotokoll](2026-09-11-messplan-abnahme.md).
