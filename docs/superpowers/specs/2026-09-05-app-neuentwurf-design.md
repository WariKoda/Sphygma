# Sphygma: Neuentwurf der App

Stand 2026-09-05. Ersetzt das gewachsene Gerüst aus M6, das als Rohentwurf taugte,
aber keinen Schwerpunkt hatte.

## Zweck

Sphygma ist ein **Blutdruck-Tagebuch**. Beim Öffnen steht vorn, wie es um den
Blutdruck steht — Werte, Verlauf, Einordnung. Das Auslesegerät arbeitet im
Hintergrund und fällt nur auf, wenn etwas klemmt.

Das ist eine Verschiebung gegenüber heute: Bisher stand die Technik vorn
(Kopplung, Sync-Knopf, Export-Zähler), die Werte waren Beiwerk.

## Was das Gerät hergibt, und was nicht

Diese Befunde sind an der Hardware erarbeitet (`docs/protocol/hem-6232t.md`) und
begrenzen den Entwurf. Sie sind **nicht erneut zu prüfen**:

| Fähigkeit | Stand |
|---|---|
| Messungen lesen | ja, beide Speicherplätze, 100 je Platz |
| Neue Messungen erkennen ohne Verbindung | ja, über das Advertising (§2.1) |
| Automatischer Abgleich nach einer Messung | ja, das Gerät sendet von selbst |
| Messungen auf dem Gerät löschen | **nein** (§8.4, §8.6) |
| Geräteuhr per Bluetooth stellen | **nein** (§8.7) |
| Zweiter Speicherplatz | wird gelesen, aber laut Entscheidung nicht genutzt |

## Entscheidungen

| Frage | Entscheidung | Grund |
|---|---|---|
| Schwerpunkt | Blutdruck-Tagebuch | siehe Zweck |
| Zeitachse | Zeitstempel des Geräts | gewohnte Darstellung; die Uhr stellt der Nutzer am Gerät |
| Datumskorrektur in der App | **entfällt** | Uhr wird am Gerät richtig gestellt; spart Spalte, Migration und Erfassungsaufwand |
| Messungen löschen | **gar nicht** | Die DB bleibt reines Abbild des Geräts; kein Merken gelöschter Einträge, kein Wiederauftauchen |
| Speicherplätze | **einer je Installation** | Eine App an einem Gerät bedient einen Benutzer; Wahl beim Einrichten, danach unsichtbar |
| Bereiche | drei: Heute, Verlauf, Gerät | Die Technik bekommt einen eigenen Ort und stört vorn nicht |
| Gestaltung | **drei Varianten, umschaltbar** | Entscheidung bleibt offen; erfordert Farb- und Maßtabellen statt fester Werte |
| Arztausgabe | **PDF und CSV** | PDF zum Vorlegen, CSV zur Weiterverarbeitung |

## Aufbau

```
UI (drei Bereiche)
  └── AppController          Zustand und Aktionen
        ├── SyncService      Readout → DB
        ├── ExportService    DB → Health Connect
        ├── ReportService    DB → PDF/CSV          (neu)
        └── MeasurementRepository
```

Die bestehende Schichtung bleibt unangetastet: UI → Sync → {DB | Health Connect} →
Protokoll → BLE. Neu ist allein die Berichtsschicht neben dem Export.

### Heute

Der Bildschirm beim Öffnen.

1. **Letzte Messung**, groß: systolisch, diastolisch, Puls, Zeitpunkt.
2. **Einordnung** als schmale Skala mit Zeiger, Farbe trägt hier Bedeutung.
   Nur sichtbar, wenn die Klassifikation eingeschaltet ist (`SPHYGMA_ESC`).
3. **Hinweisfeld**, nur wenn nötig. Anlässe: Geräteuhr weicht ab, Kopplung fehlt,
   automatischer Abgleich nicht verfügbar. Der Uhr-Hinweis trägt die
   Einstellschritte aus dem Handbuch zum Aufklappen (§8.7).
4. **Letzte Tage**, drei bis fünf Zeilen zum Nachschlagen.

Der Uhr-Hinweis steht hier und nicht unter „Gerät", weil er die Glaubwürdigkeit
der Werte betrifft, die gerade angesehen werden.

### Verlauf

1. **Zeitraum**: Woche, Monat, Jahr, Alles.
2. **Kurve**: zwei Linien (systolisch, diastolisch), dazu die Leitlinien-Schwelle
   als gestrichelte Linie. Der Puls bleibt draußen — drei Linien werden unlesbar.
   Punkte mit Bewegungs- oder Arrhythmie-Kennzeichen werden hervorgehoben.
3. **Mittelwerte** für den gewählten Zeitraum: gesamt, morgens (vor 12 Uhr),
   abends (ab 18 Uhr).
4. **Liste** aller Messungen im Zeitraum, nach Tagen gruppiert, mit den
   Kennzeichen je Messung.
5. **Bericht erzeugen** → PDF oder CSV für den gewählten Zeitraum.

### Gerät

Alles Technische an einem Ort.

1. **Gerät**: Modell, Kopplungszustand, gewählter Speicherplatz, Firmware.
2. **Abgleich**: Zustandszeile („Wartet auf Messungen" mit Punkt), Zeitpunkt des
   letzten Abgleichs, Anzahl gespeicherter Messungen, Knopf für sofortigen
   Abgleich. Kein Schalter zum Abstellen.
3. **Health Connect**: übertragen von gesamt, alle übertragen, übertragene
   entfernen. Das einzelne Übertragen je Messung entfällt.

## Neue Bausteine

### Gestaltungsvarianten

Drei Handschriften, umschaltbar unter „Gerät":

| Variante | Charakter |
|---|---|
| Messinstrument | zurückhaltend, viel Weißraum, Farbe nur bei der Einordnung |
| Tagebuch | wärmer, Farbflächen, gerundete Karten |
| Material 3 | Systemvorgaben, dynamische Farben |

Umsetzung über eine `SphygmaTheme`-Abstraktion: Farb- und Maßtabellen als Daten,
die drei Varianten als Instanzen. Kein Widget greift auf feste Farbwerte zu.
Die Wahl liegt in `SettingsRepository`, das bereits existiert.

**Prüfung:** Jeder Bildschirm wird gegen alle drei Varianten getestet.

### Berichte

`ReportService` erzeugt aus einem Zeitraum:

* **PDF**: Kopfdaten (Zeitraum, Anzahl, Gerät), Mittelwerte, Kurve, Tabelle aller
  Messungen mit Kennzeichen. Weitergabe über die Android-Teilen-Funktion.
* **CSV**: eine Zeile je Messung, Semikolon getrennt, mit Kopfzeile.

Pakete: `pdf` 3.13.0 und `printing` 5.15.0 für die Erzeugung, `share_plus` 13.3.0
für die Weitergabe. Alle drei sind reine Ausgabe und berühren keine Gesundheitsdaten
außer den eigenen.

**Der Bericht ist keine ärztliche Bewertung.** Er trägt einen entsprechenden
Hinweis, und die Einordnung erscheint darin nur, wenn die Klassifikation
eingeschaltet ist.

### Kurve

`fl_chart` 1.2.0. Alternative wäre eigenes Zeichnen über `CustomPainter`; das
Paket spart erheblichen Aufwand bei Achsen, Beschriftung und Berührungspunkten.

## Was aus dem Bestand bleibt

Unverändert: Protokollschicht, BLE-Transport, Datenbank, Sync, Export,
Autosync, Klassifikation, Mittelwerte. Der Umbau betrifft ausschließlich die
Oberfläche und den Steuerungsteil.

Der Steuerungsteil bekommt: Zeitraumwahl, Gestaltungswahl, Berichtserzeugung.
Er verliert: `exportOne`, `retractOne` (entfallen mit dem Einzelexport).

## Was bewusst fehlt

* Löschen von Messungen, in App wie Gerät
* Notizen oder eigene Kennzeichnungen
* Zweiter Speicherplatz in der Oberfläche
* Erinnerungen ans Messen
* Datenausgabe an Dritte außer Health Connect und den eigenen Berichten

## Fehlerfälle

| Fall | Verhalten |
|---|---|
| Nicht gekoppelt | Hinweisfeld auf „Heute", führt zur Kopplung |
| Gerät nicht erreichbar | Meldung mit dem Hinweis, die Taste zu drücken |
| Uhr weicht ab | Hinweisfeld mit aufklappbarer Anleitung |
| Abgleich-Scan bricht ab | Zustandszeile unter „Gerät" nennt den Grund |
| Keine Messungen | „Heute" zeigt die Aufforderung zu messen, statt leerer Flächen |
| Bericht ohne Messungen im Zeitraum | Knopf inaktiv, mit Begründung |

Fehler werden geworfen und angezeigt, nie durch Ersatzwerte verdeckt.

## Prüfung

* Reine Logik (Zeitraumfilter, Berichtsdaten, Kurvenpunkte) ohne Flutter testbar
* Widget-Tests je Bildschirm, gegen alle drei Gestaltungsvarianten
* PDF und CSV gegen erwarteten Inhalt, nicht gegen Pixel
* Am Gerät: automatischer Abgleich, Kopplung, Export

## Reihenfolge

1. Gestaltungstabellen und die drei Varianten
2. „Heute" mit Hinweisfeldern
3. „Gerät" mit Zustandsanzeige
4. „Verlauf" mit Liste und Mittelwerten
5. Kurve
6. Berichte

Jeder Schritt ist für sich lauffähig und prüfbar.
