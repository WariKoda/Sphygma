# Kompakter Verlauf und Dialogkorrekturen

## Änderungen

- Verlaufseinträge und die vollständige Tagesliste verwenden gemeinsame Spalten:
  Uhrzeit, Exportstatus, Blutdruck als SYS/DIA und Puls. Einheiten stehen einmal
  im kleinen, nicht fetten Tabellenkopf, der normal mitscrollt. Fehlende
  Exporthaken verschieben keine Werte; Messhinweise bleiben sichtbar.
  Große Systemschrift verwendet einen zweizeiligen Aufbau. Die ausführlichen
  Karten auf Heute behalten ihre Darstellung.
- Tag-Anlage und Umbenennung besaßen den Eingabecontroller außerhalb des Dialogs.
  `showDialog` kehrt bereits beim Pop zurück, während die Rückanimation das Textfeld
  noch verwendet. Der reproduzierte Fehler lautete
  `TextEditingController was used after being disposed`.
- `showNameDialog` besitzt den Controller jetzt im Dialog-State und gibt ihn erst
  beim Unmount frei. Asynchrone Tag-Callbacks prüfen den weiterhin gemounteten Picker.
  Abbruch verändert keine Daten; erfolgreiche Anlage wählt den neuen Tag weiter aus.
- Derselbe Lifecyclefehler im Phasendialog wurde entsprechend korrigiert.

## Bedienweg für neue Phasen

Einstellungen → Phasen → „Phasen verwenden“ aktivieren. Im Verlauf oben rechts
„Phasen verwalten“ öffnen, anschließend „Phase anlegen“. Bei deaktivierter Funktion
bleibt der Einstieg ausgeblendet.

## Prüfung

- `flutter analyze`: ohne Befund.
- `flutter test`: 704 Tests bestanden.
- Kompakte Zeilen mit realer Schrift in allen sechs Formen bei normaler und doppelter
  Schrift geprüft, einschließlich nebeneinander liegendem Puls und Detailzugriff.
- Dialogfehler vor Änderung reproduziert; Tag-Anlage, Umbenennung, Abbruch und
  Phasen-Abbruch nach Änderung ohne Controller-Lifecyclefehler geprüft.

## Erinnerungsstatus

Auf ergänzenden Nutzerwunsch ersetzt „Erinnerungen aktiv“ den technischen Begriff
„Exakte Erinnerungen“. Bei verzögerbarer Zustellung steht „Erinnerungen können
später kommen“. Der Status und „Was bedeutet das?“ öffnen eine verständliche
Erklärung zur Erinnerungszeit und gegebenenfalls zu den Berechtigungen.
Die neun Messplan-Widgettests bestehen einschließlich Öffnen und Schließen der
Erklärung in allen sechs Formen mit doppelter Schrift. Die Erinnerungsplanung
selbst wurde nicht verändert.

Jeder abweichende Erinnerungszustand erklärt außerdem Ursache und nächsten Schritt.
Die Hilfe enthält direkte Aktionen: Berechtigungen prüfen, erneut einrichten,
Messplan anlegen/bearbeiten oder bei fehlendem Speicherplatz Einstellungen öffnen.
Der neue `openAccessSettings`-Pfad öffnet bei gesperrten Benachrichtigungen direkt
Androids App-Benachrichtigungseinstellungen. Damit bleibt die Abhilfe auch nach
permanenter Ablehnung des Laufzeitdialogs erreichbar. Die erste Aktivierung nutzt
weiterhin den bisherigen Berechtigungsdialog; Rückkehr und Fehler werden über den
bestehenden Receipt-/Reconcile-Ablauf verarbeitet.

## Abschließender Stand

- Gesamtsuite: 711 Tests bestanden; `flutter analyze` ohne Befund.
- Android: `JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 ./gradlew :app:testDebugUnitTest :app:lintDebug --offline` erfolgreich.
- ARM64-Debug-APK mit `SPHYGMA_ESC=true`, Versionscode 2007, gebaut und per
  `adb install -r` auf dem Fairphone 4 über Version 2006 installiert.
  Paketversion 2007, `am start -W` mit `Status: ok` und laufender Prozess bestätigt.
  Keine App-Daten gelöscht; kein Commit im Rahmen dieses Auftrags.
- Dauerhaft verweigerte Android-Berechtigungen wurden nicht auf dem persönlichen
  Gerät absichtlich hergestellt. Gateway-/Controller-Pfad ist automatisiert geprüft;
  der native Einstellungsaufruf ist kompiliert und per Android-Lint geprüft.

## Kompakte Messungstabelle

- 36 gezielte Widgettests bestanden: alle sechs Formen mit normaler und doppelter
  Schrift, gemeinsame Spalten trotz unterschiedlicher Zahlenlängen und fehlendem
  Exportstatus, dezenter Kopf sowie Detailzugriff in Verlauf und Tagesliste.
- `flutter analyze`: ohne Befund. Tabellenanpassung anschließend mit Version 2008 installiert.

## Heutige Termine mit Messwerten

- „Termine heute“ behält offene und erfüllte Termine und zeigt zugeordneten
  Messungen ihre Messzeit, Blutdruck und Puls an. Der bestehende Einstieg zur
  manuellen Zuordnung bleibt erhalten.
- Der Bildschirm beobachtet zusätzlich den AppController: Beim Import aktualisiert
  sich der Plan vor der Messungsliste. Später eintreffende Messwerte müssen deshalb
  einen eigenen Neuaufbau auslösen. Regressionstest ohne dieses Abonnement schlägt
  fehl; mit Abonnement werden die Werte im geöffneten Bildschirm sichtbar.
- Lokale Diagnose am Fairphone: Der 18-Uhr-Termin war nach der Messung bereits
  erfolgreich an die native Erinnerungsplanung als erfüllt gemeldet. Kein Fehler
  im gespeicherten Erinnerungszustand. Eine fehlgeschlagene Zuordnung ließ sich
  für diesen Vorgang nicht bestätigen.
- 42 gezielte Tests für Messplan-Oberfläche, Import und PlanController bestanden;
  statische Analyse ohne Befund. Diese Anpassung ist in Version 2009 enthalten.

## Git-Abschluss und Installation 2009

- Terminstatus links mit Haken im Kreis für zugeordnete und Strich im Kreis für
  offene Termine. 14 Messplan-Widgettests einschließlich Statuswechsel bestanden.
- Gesamtsuite: 712 Tests bestanden; `flutter analyze` ohne Befund.
- Einzelne ARM64-Debug-APK mit `SPHYGMA_ESC=true`, Versionscode 2009 gebaut.
  `adb install -r` auf dem Fairphone 4 meldete `Success`; App-Daten bleiben erhalten.
  Der anschließende Startcheck scheiterte an der inzwischen getrennten
  WLAN-Debugging-Verbindung (`device offline`, danach `Connection refused`).
- Gestaltungsbeispiel mit Testdaten: [Heute, Instrument](screenshots/2026-09-12-heute-instrument.png).
  Aufnahme der gemeinsamen Karten vor Ergänzung des Nicht-übertragen-Symbols.
