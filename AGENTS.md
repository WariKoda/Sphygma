# Repository Guidelines

## Projektstruktur und Architektur

Sphygma ist eine Android-App mit Flutter/Dart zum Auslesen des Omron RS7 Intelli IT (HEM-6232T) über BLE und zum Export nach Health Connect.

- `lib/protocol/`: hardwareunabhängige Frames, EEPROM-Zugriffe und Record-Parsing.
- `lib/ble/`: Bluetooth-Anbindung, Pairing und Sessions.
- `lib/db/`: Drift-Datenbank und Repositories; generierte `*.g.dart` sind versioniert.
- `lib/sync/`, `lib/stats/`, `lib/app/`, `lib/ui/`: Abgleich/Export, Auswertungen, Steuerung und Oberfläche.
- `test/`: Tests entsprechend der Struktur von `lib/`.
- `assets/fonts/`: Schriftdateien und Lizenztexte; `android/`: Plattformkonfiguration.
- `docs/`: Protokollspezifikation, Design und Release-Anleitung; `fdroid/metadata/`: Distributionsmetadaten.

## Vorarbeiten gezielt nutzen

- Vor inhaltlichen Änderungen: `CLAUDE.md` und relevante Entscheidungen in `PLAN.md` lesen. Alte Statusangaben und offene Kästchen gegen Code, Tests und Git-Historie prüfen.
- BLE/Pairing: `docs/protocol/hem-6232t.md` enthält Hardwarebefunde und Testvektoren. Neue Befunde dort dokumentieren.
- UI/Konzepte: `docs/design/funktionsraster.md` und den Bestandsabgleich in `docs/design/umsetzung-konzepte.md` lesen. Alle Konzepte müssen denselben Funktionsumfang tragen.
- Gestaltung: `docs/design/gestaltung-drei-achsen.md`, besonders „Was daraus wurde“, lesen. Charakteristik, Palette und Schrift unabhängig halten; Formentscheidungen gehören in gemeinsame Widgets.
- Entwurfstafeln: verbindliche Zahlen aus `docs/design/beispieldaten.json` und deren Erklärung in `docs/design/beispieldaten.md` verwenden.
- Erinnerungen: `PLAN.md` §9.3 und `docs/research/android-erinnerungen.md` als Vorarbeit nutzen; externe Vorgaben vor Umsetzung neu verifizieren.

## Entwicklung, Build und Checks

Führe Befehle im Repository-Root aus. Die Release-Toolchain steht in `docs/RELEASE.md`.

- `flutter pub get`: Abhängigkeiten installieren.
- `flutter run`: App auf einem verbundenen Android-Gerät starten.
- `flutter run -t lib/spike_main.dart`: BLE-Diagnose-App starten.
- `dart format lib test`: Dart-Code formatieren.
- `flutter analyze`: statische Analyse nach Änderungen ausführen.
- `flutter test`: gesamte Testsuite ausführen.
- `flutter test test/protocol/frame_test.dart`: gezielt eine Testdatei prüfen.
- `dart run build_runner build --delete-conflicting-outputs`: Drift-Code regenerieren.
- `flutter build apk --release --split-per-abi --dart-define=SPHYGMA_ESC=true`: Release-APKs bauen; Signierung gemäß `docs/RELEASE.md` vorbereiten.

## Stil und Benennung

Nutze zwei Leerzeichen Einrückung und `dart format`. `analysis_options.yaml` aktiviert `flutter_lints`. Verwende `snake_case.dart`, `UpperCamelCase` für Typen und `lowerCamelCase` für Mitglieder. Code-Bezeichner bleiben Englisch. Kommentare erklären fachliche Regeln oder Gründe.

Bei Schemaänderungen Schema-Version erhöhen, Migration ergänzen und generierten Drift-Code mitführen.

## Tests

Unit- und Widget-Tests verwenden `flutter_test`; Dateien heißen `*_test.dart`. Bei Klassifikationsänderungen zusätzlich `flutter test --dart-define=SPHYGMA_ESC=true` ausführen. Nutze bestehende Tests für Funktionsgleichheit, Kontrast, große Systemschrift, Autosync-Neustart und Autoexport als Regressionsschutz. BLE-/Pairing-Änderungen zusätzlich am Gerät prüfen; fehlende Hardwareprüfung melden.

## Commits und Pull Requests

Die Historie verwendet etwa `feat(android): …` und `fix(sync): …` mit kurzen deutschen Beschreibungen. Arbeite auf einem Themenbranch. Commit, Tag, Push und PR erfolgen nur auf ausdrücklichen Wunsch. Beschreibe im PR Problem, Änderung und ausgeführte Checks; verlinke relevante Issues und ergänze bei UI-Änderungen Screenshots.

## Sicherheitsgrenzen

Die lokale Datenbank ist maßgeblich; Health Connect dient ausschließlich dem Export. Dedup erfolgt über `(userSlot, deviceSequence)`; die ältere Zeitstempel-Aussage in `CLAUDE.md` ist überholt. Gerätezeiten unverändert speichern und Plausibilitätsprobleme anzeigen. Health-Connect-Writes benötigen `clientRecordId` und `clientRecordVersion`.

EEPROM-Schreibzugriffe sind nur für den Pairing-Key erlaubt. Externe Fehler explizit melden; erfolgreicher Import und fehlgeschlagener Export bleiben unterscheidbar. Signierschlüssel und `android/key.properties` bleiben außerhalb der Versionsverwaltung.
