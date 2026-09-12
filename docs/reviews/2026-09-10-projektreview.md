# Projektreview Sphygma — 10.09.2026

**Nachtrag vom 11.09.:** Ein Test mit dem tatsächlichen BLE-Watcher zeigte eine
weitere Lücke beim Scan-Cancel, die die bisherigen Controller-Tests mit
eingespeistem Datenstrom nicht erfassten. Der Hänger und die pauschale
Autosync-Warnkarte sind korrigiert; Details und neuer Prüfstand im
[Autosync-Nachtrag](2026-09-11-autosync-nach-erster-messung.md).

## Korrekturstand nach Umsetzung

Die Befunde R01–R11 sind auf `fix/review-sync-export-phase` korrigiert und mit
Regressionstests abgesichert. Die folgenden ursprünglichen Befundbeschreibungen
beziehen sich auf den damaligen Stand; ihre alten Zeilennummern sind keine aktuellen
Codeverweise. Es wurde nichts committed oder veröffentlicht.

- **R01/R02:** Autosync ist standardmäßig aus und erfordert ausdrückliches Einschalten.
  Scan-Neustarts sind serialisiert. Übernahmeentscheidungen werden je Speicherplatz
  dauerhaft gespeichert; Abbruch, fehlgeschlagener Erstimport, Neustart und Slotwechsel
  können die Exportfreigabe nicht umgehen. Auch manueller Export prüft die Freigabe.
- **R04/R05:** Ein persistentes Exportjournal hält Versuche und Rückzüge fest.
  Zurückgezogene Werte werden nicht automatisch erneut gesendet. Teilexporte und
  unterbrochene Rückzüge lassen sich wiederholen oder entfernen, auch im Messungsdetail.
  Schema v5 behandelt alte unbestätigte Exporte ausdrücklich als unbekannt; sie benötigen
  vor erneuter Übertragung eine manuelle Auswahl. Echte v4-Upgrades samt Datenbestand,
  Fehler-Rollback und erneutem Öffnen sind getestet.
- **R07–R10:** Nicht zugeordnete Messungen sind erreichbar; Zuordnungen lassen sich
  ändern, entfernen oder auf Gerätezeit zurücksetzen. Abgeschlossene Phasen bleiben
  vergleichbar. Bei gleichem Beginn gilt dieselbe Reihenfolge für Auswahl und Anzeige.
- **R06/R11:** EEPROM-Antworten müssen exakt zur angeforderten Länge passen.
  Scan- und Notificationfehler erreichen den Aufrufer. Fehlerhafte Initialisierung räumt
  die Verbindung auf. Scan-Start, Stop und Fehlerbereinigung teilen ein begrenztes Zeitbudget.
- **R03:** Die bestehende Lokal-only-Zusage wird beibehalten: Cloud-Backup und
  automatischer Android-Gerätetransfer sind explizit ausgeschlossen. Eine abweichende
  Antwort auf die optionale Rückfrage lag bei Umsetzung nicht vor; die Annahme wurde
  mitgeteilt. Datenschutzhinweise sind angepasst. Eine eigene Backup-/Restorefunktion
  fehlt weiterhin; bereits früher erzeugte Backups werden dadurch nicht gelöscht.

**Abschlussprüfung:** `flutter analyze --no-pub` ohne Befund; jeweils **624 Tests**
mit und ohne `SPHYGMA_ESC=true` bestanden. Release-APKs für armeabi-v7a, arm64-v8a
und x86_64 erfolgreich gebaut. Backup-Regeln in allen drei zusammengeführten
Release-Manifesten geprüft; XML-Regeln zusätzlich semantisch und mit AAPT2 geprüft.
`dart format` für berührte Dateien und `git diff --check` sauber. Unabhängige
Gegenprüfungen von Controller, Export und BLE sind eingeflossen.

**Weiter offen:** reale BLE-/Pairing- und Health-Connect-Prüfung am Gerät,
Backup-Ausschluss auf realen Android-Geräten, eigene Wiederherstellung, die unten
aufgeführten Produktfunktionen sowie Release-Angaben. Die `health`-KGP-Buildwarnung
besteht weiterhin. Der Datenschutz-Verantwortlichenplatzhalter wurde nicht erfunden.
Die früheren v1–v3-Migrationspfade wurden nicht zusätzlich mit historischen Datenbanken
geprüft. Klassifikationsposition und Wochenbeschriftung bleiben Produktfragen.

## Ursprüngliches Ergebnis und Prüfstand

Die Anwendung ist weit über einen Prototyp hinaus: Protokoll, Persistenz, BLE-Pairing,
Abgleich, Health-Connect-Export, drei Bedienkonzepte und das Gestaltungssystem sind
implementiert. Der Bestand lässt sich analysieren, testen und als Android-App bauen.
Vor weiterer Funktionserweiterung sollten jedoch die nachstehenden Fehler in
Exportsteuerung, Autosync und Phasenbedienung behoben werden.

Geprüfter Stand: `8aadf19b1a5911546fb9a3e4a58c4e9a21588fd2`, Branch `feat/startsymbol`.
Die zuvor erstellte `AGENTS.md` war unversioniert. Dieses Review verändert keine
Anwendungsdateien. Untersucht wurden Quellcode, Tests, lokale Paketimplementierungen,
Git-Historie, Projektpläne und ausgewählte offizielle Android-Dokumentation.
Drei unabhängige Teilreviews ergänzten die Prüfung von Datenbank und Release-Konfiguration.

| Prüfung | Ergebnis |
|---|---|
| `flutter analyze --no-pub` | Keine Befunde |
| `flutter test --no-pub` | 569 Tests bestanden |
| `flutter test --no-pub --dart-define=SPHYGMA_ESC=true` | 569 Tests bestanden |
| `flutter build apk --release --split-per-abi --dart-define=SPHYGMA_ESC=true --no-pub` | APKs für armeabi-v7a, arm64-v8a und x86_64 gebaut |
| Zusätzliche isolierte Review-Reproduktionen | Neue Fehler außerhalb der vorhandenen Testfälle nachgewiesen; Details unten |

Die zusätzliche Dateifreigabe behebt den Telemetriefehler. Flutter-Tests benötigten
außerdem eine Ausführung außerhalb der Sandbox für ihren lokalen Testserver-Socket.
Der erste gesperrte Testlauf war ein Umgebungsfehler, kein fehlgeschlagener Anwendungstest.
Buildwarnung: Das installierte `health`-Plugin verwendet noch das Kotlin Gradle Plugin;
der Build kündigt dafür eine künftige Flutter-Inkompatibilität an.

**Grenzen:** Keine neue Prüfung am Messgerät, kein Geräte-/Backup-Restore-Test,
keine Store-Einreichung und keine rechtliche Neubewertung. Erfolgreich gebaut bedeutet
nicht, dass Signatur, Vertriebsvoraussetzungen oder reale Geräteabläufe freigegeben sind.

## Priorisierte Fehler

P1: vor weiterer Freigabe beheben, da ungewollte Gesundheitsdatenübertragung oder
Ausfall einer Kernfunktion möglich ist. P2: konkreter Funktions-/Fehlerbehandlungsfehler.
„Reproduziert“ bezeichnet isolierte Tests mit simulierten Abhängigkeiten, keine neue
Hardwarebeobachtung. „Codebelegt“ bezeichnet einen nachvollzogenen Pfad ohne neue Reproduktion.

### R01 · P1 · Übernahmeentscheidung schützt nur den ersten Sync

**Ort:** [settings_screen.dart](../../lib/ui/settings_screen.dart), Zeilen 64–81;
[app_controller.dart](../../lib/app/app_controller.dart), Zeilen 280–297 und 416–428.

Nach dem Koppeln wird einmal `sync(autoExport: false)` ausgeführt. Während das anschließende
Übernahmeblatt oder dessen Datumsauswahl noch offen ist, läuft der Advertising-Watcher
bereits wieder. Eine weitere Messung kann einen normalen Sync auslösen. Bei vorhandenen
Health-Connect-Schreibrechten exportiert dieser auch den Altbestand: Eine ausstehende
Übernahmeentscheidung ist kein eigener Zustand; die Aufnahmegrenze fehlt noch.
Eine danach gewählte Einschränkung zieht die bereits exportierten Daten nicht zurück.

**Reproduziert:** Erster `sync(autoExport: false)` schreibt nichts; ein zweiter normaler
`sync()` vor der Übernahmeentscheidung schreibt `[seq1, seq2]` bei weiterhin leerer
Aufnahmegrenze. Controller-/Service-Test mit simuliertem Readout, kein neuer Widget-/Advertising-Test.
Der Codepfad vom Watcher ruft genau diesen normalen Sync auf. Der bestehende
First-Pairing-Test prüft nur einen scheiternden Hardware-Sync.
**Korrekturrichtung:** Ausstehende Übernahmeentscheidung ausdrücklich festhalten und
bis zum Abschluss jeden automatischen Export sperren; auch Fehler und Neustarts behandeln.

### R02 · P1 · Zwei Neustarts können Autosync erneut dauerhaft stoppen

**Ort:** [app_controller.dart](../../lib/app/app_controller.dart), Zeilen 565–576.

`_restartWatching` setzt `_watch` auf null und wartet dann auf das alte Cancel.
Eine zweite schnelle Aktion startet währenddessen einen neuen Watcher. Anschließend
beendet das alte Cancel den globalen BLE-Scan. Das neue Abo bleibt vorhanden; die
Oberfläche kann weiter aktiven Autosync anzeigen, obwohl keine Meldungen mehr kommen.

**Reproduziert:** Zwei aufeinanderfolgende `exportAll()` mit kontrolliert verzögertem
Cancel erzeugen `[start, start, stopp]`. Das installierte BLE-Paket steuert Scans global.
Der vorhandene Regressionstest deckt nur einen einzelnen Neustart ab.
**Korrekturrichtung:** Neustarts serialisieren oder zusammenfassen; Eigentümerschaft und
Lebenszyklus des Scans eindeutig machen. Den überlappenden Fall dauerhaft testen.

### R03 · P1 · Backup-Verhalten widerspricht der Zusage „nur auf deinem Gerät“

**Ort:** [AndroidManifest.xml](../../android/app/src/main/AndroidManifest.xml),
`application` ab Zeile 26; [main.dart](../../lib/main.dart), Datenbankinitialisierung;
[PRIVACY.md](../PRIVACY.md), Abschnitt „Wo die Daten liegen“.

Es gibt weder eine ausdrückliche Backup-Einstellung noch Ausschlussregeln für die
Datenbank oder Secure-Storage-Dateien. Das wurde auch im zusammengeführten Release-Manifest
geprüft. Drift legt die DB standardmäßig im internen Dokumentverzeichnis ab.
Android aktiviert Auto Backup standardmäßig und kann interne App-Dateien bei aktivierter
Gerätesicherung in das Konto-Backup aufnehmen. Daraus folgt eine mögliche Sicherung der
Gesundheitsdaten außerhalb des Geräts; ein tatsächlich erfolgter Upload wurde nicht beobachtet.

Zusätzlich warnt das installierte `flutter_secure_storage` vor Wiederherstellung seiner
Dateien ohne den zugehörigen Keystore-Schlüssel. Das konkrete Restore-Verhalten der App
ist nicht getestet.

**Korrekturrichtung:** Cloud-Backup und Gerätetransfer ausdrücklich entscheiden,
passende Regeln setzen und Wiederherstellung testen. Datenschutzhinweise einschließlich
Phasen, Nutzerentscheidungen und automatischem Export an den tatsächlichen Zustand anpassen.
Ein einzelnes `allowBackup=false` deckt nicht auf jedem Herstellergerät auch den Gerätetransfer ab.

Quelle: [Android: Auto Backup](https://developer.android.com/identity/data/autobackup?hl=en),
insbesondere Standardwerte, enthaltene Dateien und Unterschiede ab Android 12.

### R04 · P2 · Zurückgezogene manuelle Exporte werden erneut automatisch gesendet

**Ort:** [export_service.dart](../../lib/sync/export_service.dart), Zeilen 74–77;
[measurement_repository.dart](../../lib/db/measurement_repository.dart), `pendingAutoExport`;
[app_controller.dart](../../lib/app/app_controller.dart), Zeilen 538–547.

Der Rückzug löscht nur `exportedAt`. Die Schutzmarke entsteht ausschließlich nach einem
vollständig erfolgreichen Autoexport. Wer vorher manuell exportiert und zurückzieht,
hat deshalb keinen Schutz vor dem nächsten Autoexport. Erfolgreiche Einträge eines später
fehlgeschlagenen automatischen Batches sind ebenfalls betroffen.

**Reproduziert:** Messung 1 manuell exportieren, zurückziehen, Messung 2 importieren,
Autoexport ausführen. Schreibfolge: `[seq1, seq1, seq2]`.
**Korrekturrichtung:** Rückzugsentscheidungen unabhängig vom Erfolg und Zeitpunkt früherer
Export-Batches speichern; automatische und ausdrücklich manuelle Wiederübertragung unterscheiden.

### R05 · P2 · Teilexport kann nicht über die App zurückgezogen werden

**Ort:** [health_connect_sink.dart](../../lib/sync/health_connect_sink.dart), Zeilen 126–149;
[export_service.dart](../../lib/sync/export_service.dart), Zeilen 45–70.

Blutdruck und Puls werden getrennt geschrieben. Gelingt Blutdruck, aber Puls nicht,
bleibt lokal die Exportmarkierung leer. Der Sammelrückzug berücksichtigt nur markierte
Datensätze; das Detailblatt bietet für diesen Zustand ebenfalls nur Export an.
Der bereits vorhandene Blutdruckeintrag bleibt in Health Connect.

**Reproduziert:** Blutdruck-Write erfolgreich, Puls-Write abgelehnt. `retractAll()` meldet
„0 Messungen … entfernt“, ruft keinen Delete auf und lässt den Blutdruckeintrag stehen.
Ein erfolgreicher Retry kann reparieren, ersetzt aber keinen funktionierenden Rückzug.
**Korrekturrichtung:** Teilerfolge nachvollziehbar speichern oder kompensieren und
auch nach gescheitertem Export einen gezielten Rückzug ermöglichen.

### R06 · P2 · Zu kurze EEPROM-Antworten gelten als vollständiger Readout

**Ort:** [eeprom_reader.dart](../../lib/protocol/eeprom_reader.dart), Zeilen 35–53.

Antworttyp und Adresse werden geprüft, die erhaltene Nutzdatenlänge aber nicht gegen
die angeforderte Blocklänge. Die nächste Adresse steigt trotzdem um den ganzen Block.
Dadurch können Records fehlen oder nachfolgende Record-Grenzen verschoben werden.

**Reproduziert:** 50 formal korrekte Antworten mit passender Adresse, Prüfsumme und
null Nutzbytes führen zu einem erfolgreichen `readAllRecords()` mit null Records.
Nicht belegt ist, dass das reale Gerät diesen Antworttyp tatsächlich sendet.
**Korrekturrichtung:** Exakte Nutzdatenlänge je Read verlangen; Abweichungen explizit ablehnen.

### R07 · P2 · Nicht zugeordnete Messungen sind im Phasen-Konzept unzugänglich

**Ort:** [phase_list_screen.dart](../../lib/ui/concepts/phase/phase_list_screen.dart),
Zeilen 48–59.

Nach Anlegen einer Phase „Jetzt“ liegen ältere Werte außerhalb jeder Phase.
Die Oberfläche zeigt hierfür nur eine nicht antippbare Zählzeile. Liste, Detail und
Einzelexport/-rückzug sind im gewählten Konzept nicht erreichbar. Das verletzt das
Funktionsraster; ein Konzeptwechsel ist kein Ersatz für den fehlenden Zugang.

**Reproduziert:** Widgettest findet die Bestandszeile, aber keinen antippbaren Listenzugang.
**Korrekturrichtung:** Nicht zugeordnete und ungeklärte Werte mit vollständigen
Messungsaktionen zugänglich machen.

### R08 · P2 · Bestätigte Phasenzuordnungen sind nicht korrigierbar

**Ort:** [phase_assign_screen.dart](../../lib/ui/concepts/phase/phase_assign_screen.dart),
Zeile 32 und Entscheidungsbuttons; [app_controller.dart](../../lib/app/app_controller.dart),
`clearPhaseAssignment`.

Die Zuordnungsoberfläche zeigt ausschließlich ungeklärte Werte. Sobald eine Entscheidung
fällt, verschwindet die Messung aus dieser Menge. Eine falsche Phase oder „Keiner Phase“
lässt sich über keine UI-Aktion korrigieren. `clearPhaseAssignment` existiert, wird aber
nirgends aus der UI aufgerufen. Falsche Entscheidungen beeinflussen weiter die Auswertung.

**Beleg:** Codepfad und Suche nach allen UI-Aufrufstellen; keine neue Widget-Reproduktion.
**Korrekturrichtung:** Zuordnung im Messungsdetail ändern und auf die automatische
Zuordnung zurücksetzen können.

### R09 · P2 · Beendete Phasen verlieren den Zugang zum Vergleich

**Ort:** [current_phase_screen.dart](../../lib/ui/concepts/phase/current_phase_screen.dart),
Zeile 192 und Navigation zum Vergleich.

Der einzige Vergleichszugang verlangt eine gefüllte laufende Phase und eine gefüllte
Vorgängerphase. Sobald die letzte laufende Phase endet oder eine neue noch leer ist,
verschwindet der Zugang, obwohl vergleichbare Daten vorhanden sind.

**Reproduziert:** Vergleich vor dem Phasenende sichtbar; danach kein Zugang bei weiterhin
zwei gefüllten Phasen.
**Korrekturrichtung:** Vergleich unabhängig vom laufenden Dashboard aus der Phasenliste
zugänglich machen und die Vergleichspartner wählbar halten.

### R10 · P2 · Gleich beginnende Phasen werden unterschiedlich priorisiert

**Ort:** [phase_grouping.dart](../../lib/stats/phase_grouping.dart), Zeilen 113–114 und
153–156; [current_phase_screen.dart](../../lib/ui/concepts/phase/current_phase_screen.dart),
Zeile 98.

Die Zuordnung entscheidet bei gleichem Beginn nach Erstellungszeit und ID. Die
Membership-Liste sortiert nur nach Beginn; das Dashboard nimmt deren erste offene Phase.
Es kann deshalb eine ältere, leere Phase zeigen, während neue Messungen der anderen zugeordnet werden.

**Reproduziert:** Messung landet in Phase 2, erste offene Membership ist Phase 1.
**Korrekturrichtung:** Einen gemeinsamen vollständigen Vergleich für Zuordnung und
Darstellungsreihenfolge verwenden.

### R11 · P2 · Asynchrone Scanfehler werden zu irreführendem „Gerät nicht gefunden“

**Ort:** [omron_session.dart](../../lib/ble/omron_session.dart), `scanResults.listen`
ab Zeile 156.

Der Listener hat keinen Fehlerhandler. Das installierte `flutter_blue_plus` sendet
asynchrone Scanfehler über diesen Stream und stoppt den Scan. Der ursprüngliche Fehler
landet unbehandelt in der Zone; der wartende Sync kann stattdessen „Gerät nicht gefunden“
melden und zum Tastendruck auffordern. Der Hinweis behebt einen Scan-/Plattformfehler nicht.

**Beleg:** Aufrufpfad und Paketquellcode, nicht am Gerät reproduziert.
**Korrekturrichtung:** Streamfehler in den wartenden Scan-Future übernehmen und aufräumen.

## Weitere technische Lücken

- `OmronSession.open()` räumt nur bei `FlutterBluePlusException` auf. Fehlende GATT-Services
  werfen `ProtocolException`, nachdem die Verbindung bereits offen ist. Cleanup auch für
  diesen Pfad sicherstellen; mangels zurückgegebener Session kann der Aufrufer es nicht übernehmen.
- Beschädigte Notifications können im Reassembler innerhalb des Stream-Callbacks werfen.
  Der wartende Mailbox-Leser bekommt den Fehler nicht und endet erst im Timeout.
  Leere/zu kurze Kanaldaten sind isoliert reproduzierbar; der komplette Gerätepfad wurde nicht getestet.
- `test/db/migration_v3_test.dart` prüft ausdrücklich nur die Neuanlage des aktuellen Schemas.
  Historische DB-Versionen mit Bestandsdaten durch echte Upgrades testen; aus dieser Lücke
  allein folgt noch kein nachgewiesener Migrationsfehler.
- Die Klassifikationsskala positioniert ausschließlich Kategorienmitten. Die im Design
  verlangte Position innerhalb einer Kategorie fehlt. Vor Umsetzung deren fachliche
  Bedeutung festlegen; keine beliebige lineare Interpolation einbauen.
- Der Verlauf mischt einen rollierenden Siebentagefilter mit Kennzahlen der jüngsten
  Kalenderwoche. Die Tests behandeln das bewusst getrennt; als Beschriftungs-/UX-Frage klären,
  nicht ohne Weiteres als Rechenfehler ändern.

## Was tatsächlich noch ansteht

| Aufgabe | Stand und nächster sinnvoller Schritt |
|---|---|
| Fehler R01–R11 | Korrigiert; Abschlussprüfung oben. Reale Geräteprüfung steht aus. |
| Backup/Restore | Automatische Android-Backups und Gerätetransfer ausgeschlossen. Eigene Backupfunktion aus PLAN §9.2 weiterhin offen. |
| Tageszeitgrenzen | Rechenbausteine vorhanden; Nutzerkonfiguration und Persistenz fehlen. Abhängigkeit für Messaufträge. |
| Messauftrag/Erinnerungen | PLAN §9.3 und Android-Recherche vorhanden, keine implementierte Funktion. Zeitgenauigkeit und Berechtigungsabläufe entscheiden. |
| Praxisbericht | PLAN §9.5 und Funktionsraster F5; in keinem Konzept implementiert. Ausgabeformat und Umfang entscheiden, bestehende Rechenregeln wiederverwenden. |
| Messnotizen | Vorgemerkt, nicht gebaut. Bindung an Einzelmessung oder Messanlass entscheiden. |
| Individueller Zielbereich | Rechenschicht parametrierbar, UI verwendet festen Zielbereich. Fachliche/Produktentscheidung vor der Implementierung. |
| Gestaltung | Drei Achsen und Formmerkmale gebaut. Raster-Datentabelle offen; Material-FAB bewusst ohne tragfähige Hauptaktion zurückgestellt. |
| Release | Technischer Build gelingt. Datenschutztext vervollständigen, dokumentierte Vertriebsvoraussetzungen abschließen, F-Droid-Commitplatzhalter und Paketlizenzfrage klären. Kein Store-Status wurde extern abgefragt. |
| Toolchain | `health`-KGP-Warnung vor einem Flutter-Upgrade bearbeiten und Build danach erneut prüfen. |
| Dokumentation | PLAN §9.4 (Logo), §9.7 (Gestaltungsachsen), alte offene Plan-Kästchen und die falsche Dedup-Aussage in CLAUDE.md an den Codebestand angleichen. |

**Bereits erledigt:** eigenes adaptives Startsymbol mit Quell-SVGs, drei Gestaltungsachsen,
Formmerkmale, Schriftlizenzen, Übernahmeauswahl, Autosync und Autoexport sind implementiert.
Sie sind keine offenen Neuentwicklungen; einzelne Abläufe benötigen die oben genannten Korrekturen.
Die eigenständigen Konzepte „Sieben Tage“ und „Tagesprofil“ wurden bewusst aufgelöst,
ihre Auswertungen in Heute/Verlauf übernommen.

## Reproduktionsmaterial und Fortsetzung

Temporäre Dateien liegen außerhalb des Repositorys:

- `/tmp/sphygma_intake_review_test.dart`: erwarteter Assertion-Fehler für R01.
- `/tmp/sphygma_restart_race_test.dart`: bestätigt die fehlerhafte Ereignisreihenfolge.
- `/tmp/sphygma_export_review_test.dart`: zwei erwartete Assertion-Fehler für R04/R05.
- `/tmp/sphygma_ble_review.dart`: akzeptierter leerer Readout und beschädigte Kanaldaten.
- `/tmp/sphygma_phase_review_test.dart`: zwei erwartete Widget-Assertion-Fehler für R07/R09.
- `/tmp/sphygma_phase_order_review_test.dart`: erwarteter Assertion-Fehler für R10.

Tests laufen mit `flutter test --no-pub /tmp/<name>_test.dart` aus dem Repository-Root.
Das reine Protokollskript läuft mit `dart /tmp/sphygma_ble_review.dart`.
Diese Reproduktionen sind kein Ersatz für eingecheckte Regressionstests und können bei
Bereinigung von `/tmp` verschwinden. Die dauerhaften Fehlerbeschreibungen stehen oben.

Nächster Schritt nach den Korrekturen: reale Geräteabläufe prüfen, dann offene
Produktfunktionen und eigene Wiederherstellung planen. Keine Änderungen wurden committed oder veröffentlicht.
