# Autosync nach der ersten Messung

## Auftrag und Beobachtung

Der Nutzer meldet nach der ersten Messung die Karte „Kein automatischer
Abgleich“ auf Heute. Eine solche pauschale Meldung soll entfallen. Separat ist
zu prüfen, ob mehrere Messungen bei geöffneter App automatisch importiert werden.

## Befunde

1. Die Karte prüft bislang nur `paired && !autoSyncActive`. Sie unterscheidet
   weder bewusst ausgeschalteten Autosync noch einen laufenden Scan-Neustart
   von einem Fehler. Der Screenshot allein belegt daher keine konkrete Ursache.
2. Der Controller setzt beim serialisierten Scan-Neustart `_watch` auf `null`
   und wartet auf `previous.cancel()`, bevor er erneut lauscht. Diese Reihenfolge
   verhindert, dass ein alter Stop den neuen Scan beendet.
3. Im tatsächlichen `watchOmronStatus` kann die `async*`-Weiterleitung beim
   Abbestellen auf das nächste Scan-Ereignis warten. Der neue Scan kann dadurch
   nicht starten. Ein isolierter Test mit echtem `watchOmronStatus`, echtem
   FlutterBluePlus und simulierter Plattform reproduziert den ausstehenden Cancel.
4. Die bisherigen Controller-Tests verwenden einen eingespeisten Datenstrom.
   Sie prüfen die Serialisierung, erfassen jedoch den Hänger der tatsächlichen
   Weiterleitung nicht.

## Korrekturrichtung

- Pauschale Autosync-Warnkarte auf Heute entfernen. Einstellung und technischer
  Fehlerstatus bleiben getrennt davon erhalten.
- Der Leerzustand darf bei standardmäßig ausgeschaltetem Autosync nicht
  versprechen, dass Messungen von selbst geholt werden.
- Scan-Abbestellung muss das Eingangsabo aktiv beenden und den Plattform-Stop
  abwarten, ohne dafür ein weiteres Advertising zu benötigen.
- Regressionen prüfen Cancel ohne neues Ereignis und mehrere automatische
  Imports über die tatsächliche Scan-Weiterleitung.

## Grenzen

Bei der Analyse war kein Gerät über `adb devices -l` erreichbar. Simulierte
Plattformtests sind kein neuer Hardware-Nachweis und erlauben keine Zusage für
Android-Hintergrundbetrieb. Der Auftrag betrifft die geöffnete App.
Kein neuer APK-Build und keine Installation im Rahmen dieser Analyse.

## Ergebnis und Prüfung

Die Korrekturen sind im Arbeitsbaum umgesetzt. Die explizite Scan-Weiterleitung
beendet ihr Eingangsabo beim Cancel und wartet auf den Plattform-Stop.
Fehler werden erst nach dem Cleanup weitergereicht, damit ein neuer Scan aus
dem Fehlerhandler nicht nachträglich vom alten Cleanup gestoppt wird.

- Zwei neue Heute-Tests zeigten zunächst die unerwünschte Karte und die falsche
  Zusage im Leerzustand; beide bestehen nach der Korrektur.
- Sieben Tests in `test/ble/omron_watch_test.dart` prüfen den tatsächlichen
  Watcher und FlutterBluePlus mit einer simulierten Plattform: Cancel ohne
  weiteres Advertising, Cancel während Start, Start-/Scan-/Stopfehler,
  Neustart aus dem Fehlerhandler und zwei aufeinanderfolgende automatische Imports.
- Der Importtest bestätigt zwei gespeicherte Messungen und die Reihenfolge
  Watch → Readout → Watch → Readout → Watch.
- Gesamtsuite: `flutter test --no-pub` mit **633 bestandenen Tests**.
- `flutter analyze --no-pub`: keine Befunde. Berührte Dart-Dateien formatiert;
  `git diff --check` sauber.

Damit ist ein konkreter Fortsetzungsfehler reproduziert und korrigiert. Ohne
Gerätelog bleibt offen, ob genau dieser Fehler oder ausgeschalteter Autosync
die Karte im übermittelten Screenshot ausgelöst hat.

## Nachträgliche Installation auf ausdrücklichen Auftrag

Am 11.09.2026 wurde genau eine ARM64-Debug-APK mit `SPHYGMA_ESC=true` und
Versionscode 2002 gebaut. Signatur gegen die vom Handy gelesene vorherige APK
verglichen: identisch. Installation mit `adb install -r` erfolgreich;
`DEBUGGABLE`, Versionscode und aktualisierter Installationszeitpunkt bestätigt.
App-Start per `am start -W` erfolgreich, Prozess läuft. In den beim Start
geprüften Logs keine passenden Absturz- oder Autosync-Fehler gefunden.
Keine Deinstallation, kein Löschen der App-Daten. Dies prüft Installation und
Start, nicht zwei reale aufeinanderfolgende Messungen.
