# Einzelmessungen, Phasen und Messplan — konsolidierter Entwurf

Stand 11.09.2026. Grundlage: die Antworten F1–F21 im Projektgespräch.
Die Funktionalität ist im Arbeitsbaum implementiert; die reale Geräteabnahme steht
noch aus. Prüfnachweise: [Abnahmeprotokoll](../../reviews/2026-09-11-messplan-abnahme.md).
Explizite Nutzerentscheidungen stehen in §1; ergänzende Planannahmen in §2.
Der [Umsetzungsplan](../plans/2026-09-11-messungen-phasen-messplan.md) beschreibt die Reihenfolge.

## 1. Bestätigte Anforderungen

### Eine Oberfläche und persönliche Ergänzungen

- Heute und Verlauf bilden die gemeinsame Oberfläche. Konzeptwahl, Messanlass-
  Gruppierung und deren Bedienprozess entfallen vollständig. Einzelmessungen
  bleiben die Grundlage der normalen Auswertungen.
- Gemeinsame Messungskarte: Blutdruck prominent, Puls klar beschriftet darunter.
  Der Verlauf erhält auswählbare Messpunkte und eine Blutdruck-/Pulsumschaltung.
  Inspirationsquellen sind die beiden Omron-Screenshots vom Nutzer.
- Alle Formen tragen dieselben Informationen und Funktionen. Charakteristik,
  Palette und Schrift bleiben unabhängig; die Formen werden nicht vereinheitlicht.
- Wochenraster und „Letzte Tage“ sind unabhängig abschaltbar. Der vorhandene
  Abschnitt zeigt letzte Messungen, deshalb heißt er künftig „Letzte Messungen“.
- Eine Bemerkung und mehrere Tags je Messung. Neue Tags jederzeit beim Bearbeiten
  anlegen; bestehende Tags wiederverwenden. Ergänzungen bleiben lokal.
- Verlauf nach Zeitraum, Tags und Phasen filtern. Mehrere Tagfilter bedeuten
  standardmäßig mindestens eines; Umschaltung auf alle ausgewählten Tags.
- Phasen werden manuell als Zeiträume angelegt. Plausible Messzeiten ordnen
  eine Messung automatisch allen passenden Phasen zu. Manuelle Korrektur möglich.
  Überlappungen und mehrere Phasen je Messung sind erlaubt.
- Phasen sind optional über die Konfiguration aktivierbar.
- Der Phasenvergleich wird zunächst weggelassen, ebenso ein eigener Backup-Export.

### Messplan und Erinnerungen

- Messplan gehört zum aktuellen Umsetzungsumfang, nicht nur zur Vorbereitung.
- Frei wählbare, täglich gleiche Uhrzeiten, beispielsweise drei oder fünf.
  Keine Wochentagsvarianten. Der Plan gilt, bis der Nutzer ihn beendet.
- Änderungen gelten für zukünftige Termine. Vorhandene Messungen bleiben erhalten;
  eine Uhrzeitänderung erzeugt weder eine Phase noch einen neuen Messzeitraum.
- Ein eigener Reiter Messplan erscheint nur bei aktivierter Funktion. Deaktivieren
  schaltet die gesamte Funktion einschließlich Erinnerungen aus. Keine anderen
  Erinnerungsarten, keine Einrichtungskarte für die ausgeschaltete Funktion.
- Anzeige, welchen geplanten Terminen Messungen zugeordnet wurden.
- Automatische Zuordnung höchstens ±15 Minuten; keine mehrdeutige Doppelzählung.
- Exakte Alarme, wenn verfügbar; sonst ungenaue Alarme wie beim SkillKompass-Prinzip.
- Einstellungen → Abgleich zeigt Datum/Uhrzeit des letzten erfolgreichen
  Geräteabgleichs. Auch „keine neuen Messungen“ zählt; ein Fehlschlag nicht.
  Health-Connect-Export und Geräteabgleich haben getrennte Ergebnisse.
- Keine manuelle „bereits gemessen“-Bestätigung ohne vorhandenen Messwert vorgesehen.

### Bestehende Grenzen

- Rohwerte, Gerätezeit, Messungsnummern und Exportidentitäten bleiben erhalten.
- Autosync bleibt standardmäßig aus. Übernahmefreigabe und Exportjournal bleiben wirksam.
- Cloud-Backup und automatischer Gerätetransfer bleiben ausgeschlossen; eigenes Backup später.
- Kein Commit, Push, neuer APK-Build oder neue Installation allein aufgrund dieses Plans.

## 2. Ergänzende Planannahmen

Diese Regeln konkretisieren bisher nicht einzeln entschiedene Details. Sie sind
sichtbare Annahmen, keine nachträglich behaupteten Nutzerantworten.

| ID | Regel und Grund |
|---|---|
| A1 | Neue Installationen: Phasen und Messplan aus, letzte Messungen an. Vorhandene Wochenrasterwahl bleibt erhalten. Bestehende Phasendaten aktivieren Phasen beim Upgrade, damit sie erreichbar bleiben. |
| A2 | Tags, Phasen und Pläne sind je Speicherplatz getrennt. Je Slot höchstens ein nicht beendeter Plan; ein Slotwechsel versteckt Daten des anderen Slots, löscht sie nicht. Aktivierte Pläne beider Slots dürfen erinnern, mit klarer Slotangabe. |
| A3 | Ausschalten bewahrt Daten, erzeugt aber keine Termine für die ausgeschaltete Zeit. Wieder einschalten setzt einen vorhandenen nicht beendeten Plan ab jetzt fort; nichts Vergangenes nachholen. Beenden ist eine eigene Aktion; danach kann ein neuer Plan angelegt werden. |
| A4 | Höchstens ein Termin pro Messung. Zuerst nächstgelegenen Termin innerhalb ±15 Minuten bestimmen; Gleichstand: früherer Termin. Dann dessen nächstgelegene Messung wählen; Gleichstand: frühere Messzeit, danach kleinere Messungsnummer. Weitere Messungen bleiben im Verlauf, werden nicht auf Nachbartermine verteilt. |
| A5 | Erinnerungen folgen der örtlichen Handyuhr. Keine frei wählbare Gerätezeitzone und kein globaler Stundenversatz. Omron-Zeit bleibt eine Geräteangabe ohne rekonstruierbare Zeitzone. Bei abweichender Geräteuhr ist eine sichere automatische Zuordnung nicht versprochen. |
| A6 | Keine Snooze-Funktion, keine Eskalation und keine Benachrichtigungsserie für verpasste Termine. Erinnerung nur zum nächsten geplanten Termin; bereits rechtzeitig importierte Erfüllung kann die einzelne anstehende Erinnerung unterdrücken. Späterer Import korrigiert die Anzeige rückwirkend. |
| A7 | Normale Liste, Kurve und Mittelwerte verwenden dieselbe gefilterte Auswahl. Phasenfilter wie Tags mit mindestens eines/alle. Messungen werden auch bei mehreren passenden Phasen nur einmal gezählt. „Ohne Phase“ und „Ohne Tags“ sind jeweils eigene, mit ID-Auswahl unvereinbare Filtermodi. |
| A8 | Bei Tag-/Phasenfiltern keine Wochenvollständigkeit oder als vollständige Messwoche beschrifteten Sonderwerte. Normale Mittelwerte und Tagesabschnitte bleiben. Kein medizinischer Schluss aus Tags oder Phasen. |
| A9 | Manuelle Phasenauswahl ersetzt die automatisch ermittelte Menge vollständig; eine leere manuelle Menge bedeutet ausdrücklich keine Phase. „Automatisch zuordnen“ entfernt die gesamte Ausnahme. |
| A10 | Tageszusammenfassung zeigt Mittel und Anzahl der tatsächlich heutigen Messungen, keine festen Morgen-/Abend-Pflichtkreise. Ein aktiver Messplan zeigt separat zugeordnete Termine und nächsten Termin. Ohne neue Messung steht beim letzten Wert weiterhin sein echtes Datum. |
| A11 | Bemerkung optional bis 4000 Zeichen; Tagname getrimmt, 1–40 Zeichen, innerhalb Slot ohne Groß-/Kleinschreibung eindeutig. Keine automatische Verschmelzung ähnlich geschriebener Tags. Umbenennen erhält Zuordnungen; Löschen benötigt Bestätigung und löscht keine Messwerte. |
| A12 | Vergangene Termine bleiben bei Planänderung erhalten. Für technische Historie werden Planrevisionen gespeichert. Neue Revision ersetzt nur Termine ab dem Änderungszeitpunkt. Die technische Revision ist kein neuer Plan in der Oberfläche. |

## 3. Navigation und Darstellung

- Heute: gemeinsame letzte Messung → vorhandene sachliche Gerätehinweise →
  Tageszusammenfassung → aktiver Messplan → optional Wochenraster → optional letzte Messungen.
- Verlauf: Zeitraum und Filter → Diagramm mit Blutdruck/Puls → Mittelwerte und
  Tageszeiten → Messungsliste. Filterchips und Trefferzahl bleiben sichtbar.
- Messungsdetail: Originalwerte, Exportstatus, Bemerkung, Tags, bei aktivierten
  Phasen automatische/manuelle Phasenmenge. Speichern, Fehler und Abbrechen sind eindeutig.
- Phasenverwaltung über Verlauf, kein Hauptreiter; anlegen, umbenennen, Zeitraum
  korrigieren, beenden und löschen. Löschen entfernt Zuordnungen, nicht Messungen.
- Messplan: Uhrzeiten bearbeiten, nächste Termine und heutige Zuordnung ansehen,
  Plan beenden. Der Konfigurationsschalter schaltet den gesamten Bereich aus.
- Einstellungen behalten Gerät, Sync, Export und Gestaltungsachsen. Konzeptkarte entfällt.
- Diagramm: echte Zeitabstände für plausible Zeiten, gerade Verbindungen, gefüllte/
  offene Markierungen für SYS/DIA, zugängliche Textauswahl neben Touch. Fragwürdige
  Zeiten bleiben in der Liste, werden nicht in eine scheinbar sichere Zeitkurve gezwungen.

## 4. Zeit und Alarmgrenzen

Gerätezeit ist kein belegter UTC-Zeitpunkt. Neue Terminzuordnung verwendet explizite
Kalenderkomponenten der Geräteaufzeichnung und ein gespeichertes lokales Termindatum;
keine Umdeutung aller Rohmessungen durch einen globalen Offset. Fragwürdige Zeiten
bleiben ohne automatische Erfüllung. Vorhandene Rohbytes und gespeicherte Zeiten
werden nicht geändert; ein späterer Zeitkorrektur-Entwurf ist nicht Teil dieses Umfangs.

Android plant den nächsten Termin mit seiner aktuellen Zeitzone. Beim Sommerzeitloch
wird der erste gültige Zeitpunkt nach der Lücke genommen, bei doppelter Uhrzeit einmal
die frühere Instanz. Neustart, Paketupdate und Zeitwechsel planen künftige Alarme neu.
Bereits erzeugte historische Termine behalten ihre gespeicherte lokale Zeit/Zone.

Benachrichtigungsrecht, Kanalstatus und Recht für exakte Alarme sind getrennte Zustände.
Fehlende Genauigkeit ist ein ungenauer Betriebsmodus, fehlende Benachrichtigungsrechte
sind blockierte Erinnerungen. Ein Berechtigungsentzug exakter Alarme kann geplante
Alarme löschen, ohne eine Entzugsnachricht an die App; die Wiederherstellung muss
spätestens beim nächsten Öffnen erfolgen. Eine lückenlose automatische Reaktion bei
beendetem Prozess wird nicht versprochen. „Stopp erzwingen“ und ausgeschaltetes Handy
sind ebenfalls keine lieferfähigen Zustände.

## 5. Bestand und Nachweise

Aktueller Arbeitsbaum: Schema v5, Flutter/Dart, Drift, Android minSdk29/compileSdk36/
targetSdk36; lokale Plattform ist Kotlin. Die frühere Einzelphasenzuordnung wird
verlustarm migriert; Regeln dazu stehen in Teilplan A. Anlassentscheidungen werden
nicht weiter ausgewertet, bleiben als ungenutzte historische Tabellen erhalten.
Die alte Konzeptwahl ist nach Migration wirkungslos.

Der Autosync-Nachtrag ist bereits korrigiert, mit 633 Tests geprüft und auf Wunsch
als Debug-Version 2002 installiert. Das ist die Ausgangsbasis, nicht Teil der noch
ausstehenden Feature-Implementierung:
[Autosync-Nachtrag](../../reviews/2026-09-11-autosync-nach-erster-messung.md).

Gelesene visuelle Referenzen: `/home/bdgraue/Downloads/Screenshot_20260905-090133.png`
und `/home/bdgraue/Downloads/Screenshot_20260905-090142.png`.

Am 11.09.2026 erneut verifizierte Primärquellen:
- [Android-Alarme](https://developer.android.com/develop/background-work/services/alarms):
  exakte/ungenaue Verfahren und Sonderzugriff.
- [Benachrichtigungsrecht](https://developer.android.com/develop/ui/views/notifications/notification-permission).
- Lokal: Android-36-Quelltexte für AlarmManager, NotificationManager und Intent.
- Vergleich: lokale Notification-Services von FocusJournal, DailyThoughts und SkillKompass.
  Deren praktische Zuverlässigkeit ist keine Zusage für Sphygma.

Die alte Recherche `docs/research/android-erinnerungen.md` verspricht für ungenaue
Alarme fälschlich ungefähr maximal 15 Minuten. Diese Obergrenze wird nicht übernommen;
bei Umsetzung die Datei berichtigen und auf die Primärquelle verweisen.
