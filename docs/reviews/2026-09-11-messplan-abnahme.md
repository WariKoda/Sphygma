# Messungen, Phasen und Messplan — Abnahmeprotokoll

Stand 11.09.2026. Umsetzung im bestehenden Themenbranch
`fix/review-sync-export-phase`; kein Commit. Nach erneuter Bereitstellung des Handys
wurde genau eine Debug-APK gebaut und als Update installiert (siehe unten).
Der [Plan](../superpowers/plans/2026-09-11-messungen-phasen-messplan.md) ist die Grundlage.
Softwareprüfung und Geräteabnahme sind getrennt ausgewiesen.

## Geliefert

- Eine gemeinsame Navigation Heute/Verlauf; Konzeptwahl und Anlassprozess entfernt.
- Bemerkungen, frei anlegbare Tags und optionale überlappende Phasen je Messung.
  Automatische Phasenwahl und vollständige manuelle Auswahl einschließlich leerer
  Auswahl bleiben unterscheidbar.
- Einheitliche Zeitraum-/Tag-/Phasenfilter für Liste, Kurven und Kennzahlen;
  zeitproportionale Blutdruck-/Pulskurven mit öffnbaren Messpunkten.
- Heute-Zusammenfassung, unabhängig abschaltbares Wochenraster und letzte Messungen;
  Zeitpunkt des letzten erfolgreichen Abgleichs in den Einstellungen.
- Optionaler Messplan mit täglichen Zeiten bis zum Beenden, zukünftigen Revisionen,
  tatsächlicher Erfüllung im ±15-Minuten-Fenster und manueller Zuordnung.
- Native Android-Erinnerungen mit exakt/ungenau/blockiert/fehlgeschlagen als Zuständen,
  persistenter Planung, Quittungen, Zeitwechseln und Wiederanlauf.
- Additives Schema7: echte ältere Datenbankschemata und Rollback geprüft. Rohwerte,
  Messungsidentitäten, Exportjournal und alte manuelle Phasenentscheidungen erhalten.
- Dokumentation, Begriffsverzeichnis und beide Datenschutzhinweise aktualisiert.
  AGENTS.md unverändert gelassen.

## Unabhängige Reviews und korrigierte Befunde

Codex-Subagenten prüften Metadatenintegration, Diagramme/Zuordnung, Planpersistenz,
Android-Lifecycle und Appintegration. Nach ausdrücklicher Übertragungsfreigabe
prüfte Claude zusätzlich die Metadatenmigration und Repositories anhand übergebener
Quelltexte. Ein lokaler Ollama-Gegenblick ergänzte Randfälle; seine Aussagen wurden
nicht als Quellen- oder Testbelege verwendet.

Korrigierte Befunde umfassen Diagrammhöhe und Ausschlusshinweise, alte Terminbelege
nach Revisionen, Rechtequittungen, native Generationen voraus, Zeitzonenereignisse,
verspätete Alarme bei App-Rückkehr, Tageswechsel und Benachrichtigungsstart.

Insbesondere darf eine nach Zeitzonenwechsel erneut gelesene Rohzeit einen anderen
Instant als der ursprünglich gespeicherte Drift-Zeitpunkt darstellen. Der unzulässige
Gleichheitsvergleich ist entfernt. Änderungen/Abschalten übertragen den neuen
Sollzustand vor einer nativen Inspektion, die sonst alte Alarme wieder aktivieren
könnte. Ein Fehler beim Speichern des Abgleichzeitpunkts verhindert nicht mehr die
Planaktualisierung nach bereits erfolgreichem Import. Regressionstests sichern diese
Fälle ab. Der Sommerzeitfall wurde unter `TZ=Europe/Berlin` reproduziert und
korrigiert: Rohzeit 02:30 darf nicht durch lokale Normalisierung den Termin 03:30
erfüllen. Reine Kalenderkomponenten umgehen diese Verschiebung; ungültige
Kalenderangaben scheitern ausdrücklich. Bestehende Import-/Exportzeitpunkte
werden dadurch nicht neu geschrieben.

## Prüfnachweise

| Prüfung | Ergebnis |
|---|---|
| Ausgangssuite vor diesem Auftrag | 633 Tests bestanden |
| Abschließende Gesamtsuite, Standard | 624 Tests bestanden |
| Abschließende Gesamtsuite, ESC=true | 624 Tests bestanden |
| Flutter-Analyse | Ohne Befund |
| Drift-Codegenerierung | Erfolgreich |
| Native Unit-Tests | 21 Tests, keine Fehler/übersprungenen Tests |
| Android-Lint | Erfolgreich, vollständiger Gradle-Lauf einschließlich Flutter-Kompilierung |
| Formatierung / Diff | 171 Dateien geprüft, keine weiteren Formatänderungen; Diff sauber |

Die Testzahl ist kein unverändertes Soll: Tests entfernter Konzeptoberflächen wurden
entfernt oder auf die gemeinsame Oberfläche übertragen; neue Metadaten-, Plan-,
Migrations- und Integrationsfälle kamen hinzu. Native Checks sind keine APK-Erstellung.
Gradle meldet bestehende Abkündigungen für eine spätere Gradle10-Umstellung.

Reproduzierbare Abschlussbefehle:

```bash
flutter test --no-pub
flutter test --no-pub --dart-define=SPHYGMA_ESC=true
flutter analyze --no-pub
dart format --output=none --set-exit-if-changed lib test
git diff --check
# aus android/:
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 ./gradlew :app:testDebugUnitTest :app:lintDebug --offline
```

Wird die Handyuhr vor die letzte Planänderung zurückgestellt, lehnt das Repository
weitere Planänderungen mit einem ausdrücklichen Uhrzeithinweis ab. Es erfindet keine
chronologisch passenden Änderungszeitpunkte. Die Kalender-Timer des injizierten
PlanControllers müssen bei dessen Austausch vom Besitzer entsorgt werden; der
Produktions-Entrypoint hält ihn für die gesamte Prozesslaufzeit.

## Geräteabnahme — begonnen

Am 11.09.2026 über WLAN-ADB ausgeführt: genau ein Build mit
`flutter build apk --debug --target-platform android-arm64 --build-number 2003 --dart-define=SPHYGMA_ESC=true`.
Vorher war Versionscode2002 installiert. Zertifikats-SHA256 von bestehender und
neuer APK identisch; `adb install -r` erfolgreich, anschließend Versionscode2003
über den Paketmanager bestätigt. Kaltstart `Status: ok`; Heute visuell geprüft.

Lokaler Vorher-/Nachher-Vergleich nach gestoppter App: Schema5→7, alle 146
Messungszeilen inklusive Rohbytes und Zeitpunkten sowie 145 Exportjournalzeilen
unverändert. Auch eine Legacy-Phase, null manuelle Legacy-Zuordnungen und vier
Anlassentscheidungen unverändert. SQLite-Integrität und Fremdschlüsselprüfung
fehlerfrei. Keine Deinstallation, kein Datenlöschen, keine Messwerte im Protokoll.
Die App wurde danach wieder geöffnet.


| Fall | Status |
|---|---|
| Update derselben App mit erhaltener Datenbank/Signatur | Version 2003 installiert, Signatur identisch, Schema5→7 geprüft |
| Reale UI, Bearbeitung, Filter und große Schrift am Telefon | Heute nach Kaltstart sichtbar; weitere Bedienfälle noch offen |
| Zwei neue BLE-Messungen bei geöffneter App | Nicht geprüft |
| Exakte und ungenaue Erinnerungen, tatsächliche Zustellzeit | Nicht geprüft |
| Benachrichtigungsrecht/Kanal sperren und wieder freigeben | Nicht geprüft |
| Bildschirm aus, App geschlossen, Doze | Nicht geprüft |
| Neustart, deaktivieren/reaktivieren | Nicht geprüft |
| Benachrichtigung öffnet die App und den Messplan | Nur Widget-/Protokollprüfung |
| Reale Gerätezeit-/Zeitzonenänderung | Nur automatisierte Prüfung; Änderung nur nach Zustimmung |

Nächster Schritt: gemeinsam Testtermine und die noch offenen Gerätefälle prüfen.
Gerätezeitänderungen und Neustart dafür vorher mit dem Nutzer abstimmen.

Es wird keine Zuverlässigkeit realer Android-Zustellung allein aus diesen
Softwaretests abgeleitet. Weitere Grenzen: [Android-Erinnerungen](../research/android-erinnerungen.md).
