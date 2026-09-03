# Sphygma — Implementierungsplan

Android-App (Flutter/Dart), die einen **Omron RS7 Intelli IT (HEM-6232T)** per Bluetooth LE
ausliest und die Messwerte in **Health Connect** schreibt.

> Status (2026-09-03): **M0–M4 abgeschlossen.** M1 an echter Hardware bestanden (Befunde in
> `docs/protocol/hem-6232t.md` §0, §2.1, §5.1, §6.2, §6.3, §8); M3 (`OmronSession`,
> `SyncService`) und M4 (drift, Dedup über die Messungsnummer) end-to-end am Gerät validiert:
> Keystore-Key → Pairing → Readout → DB, zweiter Sync 0 neue Datensätze. Offen: M5 Health
> Connect, M6 UI, M7 Release. Die offenen Fragen aus §2.2 und dem Risikoregister sind unten
> als erledigt markiert.

Recherchestand: 2026-09-03. Alle Protokollaussagen sind gegen den Quellcode zweier
unabhängiger Referenzimplementierungen verifiziert; die Belege je Aussage stehen in
[`docs/protocol/hem-6232t.md`](docs/protocol/hem-6232t.md).

---

## 1. Getroffene Entscheidungen

| Thema | Entscheidung |
|---|---|
| Zielplattform | Android only |
| Distribution | GitHub (`git@github.com:WariKoda/Sphygma.git`) **+ Google Play + F-Droid** |
| Trendansicht | **mit** ESC-Klassifikation |
| Name | **Sphygma** bleibt |
| Pairing-Key | **zufällig je Installation**, lokal gespeichert |
| EEPROM-Writes | ausschließlich der Pairing-Key. Sonst nichts. |

Die letzten drei Entscheidungen tragen Risiken, die in §3 und §4 offen benannt sind. Sie
sind bewusst so getroffen; der Plan arbeitet sie ab, statt sie zu umgehen.

---

## 2. Was die Recherche ergeben hat (Protokoll)

Ausgewertet wurden zwei unabhängige Implementierungen desselben proprietären Omron-Protokolls:

- **omblepy** (Python, `userx14`) — inklusive `deviceSpecific/hem-6232t.py`, dem Modul für
  genau dieses Gerät.
- **UBPM** (C++/Qt, `LazyT`) — führt HEM-6232T als „RS7 Intelli IT" in seiner Gerätedatenbank.

### 2.1 Beide Quellen stimmen überein

Die Gerätekonstanten sind in beiden Projekten identisch — das ist die stärkste Bestätigung,
die ohne eigene Hardware zu bekommen ist:

| Parameter | Wert |
|---|---|
| User-Slots | 2 |
| Records je Slot | 100 |
| EEPROM-Start User 1 / User 2 | `0x02E8` / `0x0860` |
| Record-Größe | 14 Bytes — **nur die ersten 8 tragen Messwerte** |
| Endianness | big-endian |
| Pairing | erforderlich |
| GATT-Parent-Service | `ecbe3980-c9a2-11e1-b1bd-0002a5d5c51b` |

Ich habe zusätzlich beide Bit-Extraktionen nachgerechnet — omblepy liest MSB-first über den
gesamten Record, UBPM tauscht erst Bytepaare und liest dann LSB-first. Trotz völlig
unterschiedlicher Herangehensweise liefern beide **bitgenau dasselbe** für Systole, Diastole,
Puls, Datum und Uhrzeit, inklusive des `+25`-Offsets auf die Systole.

### 2.2 Der eine Widerspruch: `ihb` und `mov` sind vertauscht

Die beiden Referenzen widersprechen sich in genau zwei Bits:

| Flag | omblepy | UBPM |
|---|---|---|
| `ihb` (Arrhythmie) | Bit 32 → `b4.bit7` | Bit 46 → `b4.bit6` |
| `mov` (Bewegung) | Bit 33 → `b4.bit6` | Bit 47 → `b4.bit7` |

Maschinell verifiziert: bei gesetztem Flag melden die beiden Implementierungen für denselben
Record **gegenteilige** Werte. Welche Zuordnung stimmt, ist aus dem Code allein nicht
entscheidbar — beide Projekte führen HEM-6232T als getestet, aber niemand hat die beiden
Flags gegeneinander geprüft.

**Erledigt in M1 (2026-09-03):** Per Display-Foto verifiziert — **UBPM stimmt**, omblepy hat
die Flags für dieses Modell vertauscht. Bit 32 = Bewegung, Bit 33 = Arrhythmie. `record.dart`
und die Testvektoren folgen der Hardware (`docs/protocol/hem-6232t.md` §6.2, §7.3). Beide
Flags dürfen exportiert werden.

### 2.3 Ablauf einer Sitzung

1. **Verbinden** und warten, bis der Parent-Service aufgelöst ist.
2. **Entsperren:** `0x01` + 16-Byte-Key auf die Unlock-Characteristic. Antwort `0x8100` = Key
   akzeptiert.
3. **Start:** `0800000000100018` senden, `0x8000` erwarten.
4. **Lesen:** je Kommando `0x08 0x0100 <addr:2> <len:1> 0x00 <xor>`, Antwort `0x8100` +
   Nutzdaten. Für einen Voll-Readout beider Slots: 2 × 1400 Bytes.
5. **Ende:** `080f000000000007` senden, `0x8f00` erwarten; das Datenbyte trägt einen
   Fehlercode (≠ 0 = Gerät meldet Fehler).

Alle Frames sind so konstruiert, dass **XOR über sämtliche Bytes 0 ergibt** — Byte 0 ist die
Paketlänge, das vorletzte Byte Padding, das letzte die Prüfsumme. Verifiziert für alle drei
Frame-Typen.

### 2.4 Multi-Channel-Empfang

Antworten kommen über **mehrere Notify-Characteristics parallel**, weil ein BLE-Paket hier
16 Bytes fasst. Kanal 0 trägt in Byte 0 die Gesamtlänge; die Kanäle werden in fester
Reihenfolge konkateniert, bis die Länge erreicht ist, dann wird die XOR-Prüfsumme geprüft.
Benötigte Kanäle = `ceil(Paketlänge / 16)`.

Die beiden Referenzen gehen hier auseinander: omblepy registriert 4 RX- und 4 TX-Kanäle,
UBPM nur 2 RX und 1 TX (die übrigen sind auskommentiert mit dem Hinweis, sie seien nur für
Notifications > 16 Bytes nötig). **Sphygma implementiert alle 4 RX-Kanäle** — das ist der
Obermenge-Fall und deckt beide Verhaltensweisen ab.

### 2.5 Pairing

Beide Projekte machen exakt dasselbe, mit unterschiedlichen Keys:

1. Gerät in den Pairing-Modus bringen — **Bluetooth-Taste lange drücken, bis `-P-` blinkt**.
2. Notifications auf der Unlock-Characteristic aktivieren. Das löst laut omblepy einen
   SMP Security Request des Geräts aus, der das BLE-Bonding anstößt.
3. `0x02` + 16 Nullbytes → Key-Programmiermodus. Antwort `0x8200`. omblepy wiederholt das bis
   zu 10× im Sekundentakt, weil das Bonding im Hintergrund noch läuft.
4. `0x00` + 16-Byte-Key → Key schreiben. Antwort `0x8000` = Erfolg.
5. Einmal Start/Ende-Transmission — laut omblepy nötig, wenn das Gerät noch nie gepairt war.

Der Key ist **frei wählbar** und im Gerät steckt immer nur einer: omblepy nutzt
`deadbeaf12341234deadbeaf12341234`, UBPM den ASCII-String `UBPM-PairingKey!`. Sphygma
erzeugt laut Entscheidung einen Zufallskey je Installation — siehe Risiko R-4.

---

## 3. Rechtliche Lage

Ich bin kein Anwalt; das Folgende ist recherchierte Faktenlage mit Quellen, keine
Rechtsberatung. Für den Play-Release mit ESC-Klassifikation ist anwaltliche Prüfung
angeraten (§3.2).

### 3.1 Urheberrecht an den Referenzimplementierungen — lösbar

**omblepy hat keine Lizenz.** Kein `LICENSE`, keine Lizenzangabe im Code, GitHub meldet
`license: null`. Ohne Lizenz gilt das gesetzliche Urheberrecht: keine Nutzungsrechte.

Der Maintainer hat sich dazu geäußert ([Issue #67](https://github.com/userx14/omblepy/issues/67#issuecomment-4468826470),
verlinkt aus dem geschlossenen [Issue #74 „What is the license on the project?"](https://github.com/userx14/omblepy/issues/74)):

> „About adding a license, the problem would be that I would need to get permission from all
> former contributors […] For my contributions, feel free to use them under MIT license. […]
> So at best it can serve as an implementation for reference and **copyright does not cover
> the communication protocol anyway**."

Daraus folgen zwei belastbare Punkte:

1. **Das Protokoll selbst ist nicht geschützt.** Kommandobytes, EEPROM-Adressen, Bit-Layout
   und Prüfsummenverfahren sind Tatsachen, kein urheberrechtlich geschützter Ausdruck. Sie
   dürfen frei verwendet werden.
2. **Für das Gerätemodul liegt eine MIT-Freigabe vor.** Alle fünf Commits an
   `deviceSpecific/hem-6232t.py` stammen von `userx14` selbst — verifiziert über die
   Commit-Historie. Genau dessen Beiträge sind unter MIT freigegeben. Fremdbeiträge gibt es
   ausgerechnet in dieser Datei nicht.

**UBPM ist GPL-3.0.** Übernommener Code würde Sphygma unter Copyleft zwingen. UBPM dient
daher **ausschließlich als Gegenprobe für das Protokollverständnis** — es wird kein Code
übernommen.

**Vorgehen, das das Risiko auf praktisch null bringt:**

- Die Dart-Protokollschicht wird **aus der Spezifikation in `docs/protocol/hem-6232t.md`
  neu implementiert**, nicht Zeile für Zeile aus Python oder C++ übersetzt. Die Spezifikation
  beschreibt Fakten; die Dart-Umsetzung ist eigener Ausdruck.
- Herkunft wird dokumentiert: `NOTICE.md` nennt omblepy (MIT-Freigabe des Maintainers für die
  genutzten Teile) und UBPM (nur Verifikation, kein Code).
- Kein Copy-Paste aus UBPM — auch nicht sinngemäß in C++-Struktur.

**Eigene Lizenz:** F-Droid verlangt eine FOSS-Lizenz. Empfehlung **MIT** oder **Apache-2.0** —
kompatibel mit der MIT-Freigabe, aus der wir schöpfen. Apache-2.0 bringt zusätzlich eine
explizite Patentklausel. Zu entscheiden vor dem ersten Commit.

### 3.2 Medizinprodukterecht (EU MDR) — das eigentliche Risiko

Maßgeblich ist [MDCG 2019-11](https://health.ec.europa.eu/system/files/2020-09/md_mdcg_2019_11_guidance_en_0.pdf).
Entscheidungsschritt 3 lautet wörtlich:

> „if the software does perform an action on data, or performs an action **beyond storage,
> archival, communication, simple search**, lossless compression […] then it may be a medical
> device software"

**Ohne Klassifikation** wäre Sphygma reines Auslesen, Speichern, Anzeigen und Weitergeben —
das bleibt unterhalb dieser Schwelle und wäre kein Medizinprodukt.

**Mit ESC-Klassifikation** sieht es anders aus. Die Einordnung von Messwerten in
Hypertonie-Grade ist eine Interpretation zum Nutzen des einzelnen Patienten. Damit sind
Schritt 3 und Schritt 4 („is the action for the benefit of individual patients?") beide mit
„ja" zu beantworten — die App qualifiziert dann als MDSW. Verschärfend kommt MDR-Regel 11
hinzu; MDCG 2019-11 nennt Blutdruck ausdrücklich als vitalen physiologischen Parameter:

> „Vital physiological processes and parameters include, for example, respiration, heart rate,
> cerebral functions, blood gases, **blood pressure** and body temperature."

Das führt zu **Klasse IIa** — mit Benannter Stelle, QMS nach ISO 13485, technischer
Dokumentation und CE-Kennzeichnung. Für ein Einzelprojekt ist das praktisch nicht leistbar.

Relevant wird das durch das **Inverkehrbringen**. Ein Play-Store- oder F-Droid-Release ist
Bereitstellung auf dem Markt — auch kostenlos. Reine Eigennutzung wäre es nicht.

**Der Plan trägt dem so Rechnung:** Die Klassifikation wird gebaut wie entschieden, aber
hinter einem Compile-Time-Flag, das im Release-Build umgelegt werden kann (M6). Damit ist
sie da, ohne dass der Store-Build unwiderruflich daran hängt. Die Entscheidung, ob der
veröffentlichte Build sie enthält, fällt am Ende — nicht durch die Architektur vorweg.

Mildernd, aber nicht befreiend: eine Darstellung als neutrale Referenztabelle ohne
personalisierte Aussage („Ihr Wert liegt bei…") wiegt schwächer als eine Ampel mit
Handlungsempfehlung. Wer den Store-Release will, sollte die Formulierungen anwaltlich prüfen
lassen.

### 3.3 Google Play — harte Zugangshürde

- **Verifiziertes Organisationskonto Pflicht.** Seit 28.01.2026 müssen Health-Apps über ein
  verifiziertes Organisationskonto laufen, nicht über ein Privatkonto — damit im Leckagefall
  eine juristische Person haftet. **Das ist mit einem privaten Entwicklerkonto nicht
  erfüllbar** und muss vor allem anderen geklärt werden.
- **Health-Apps-Declaration** ist für jede veröffentlichte App auszufüllen, auch in Closed
  Testing.
- **Je Datentyp eine Begründung**, warum die App ihn braucht.
- **Datenschutzerklärung**, identisch auf Store-Seite und im Health-Connect-Link.
- Seit 2026 zusätzlich ein **Medical-Device-Labeling** in der Deklaration — hier trifft §3.2
  unmittelbar auf den Store-Prozess.

F-Droid stellt diese Anforderungen nicht, verlangt aber FOSS-Lizenz und reproduzierbare
Builds.

### 3.4 Name

**„Sphygmo"** existiert: eine Blutdruck-App von mmHg Inc. (Ausgründung der University of
Alberta) auf [Google Play](https://play.google.com/store/apps/details?id=ca.mmhg.sphygmo)
und im [App Store](https://apps.apple.com/us/app/sphygmo-bp-glucose/id1457406418) — ein
Buchstabe Unterschied, identisches Produktsegment.

Auf GitHub existieren bereits zwei weitere `sphygma`-Repos (u. a. eine chinesische
Pulsdiagnose-App). Die Namensräume auf PyPI und npm sind frei.

Bewertung: Für ein GitHub-Repo ist das Risiko gering. Für einen Play-Store-Release in
derselben Kategorie besteht Verwechslungsgefahr, die zu einer Beanstandung führen kann.
Da die Entscheidung für Sphygma gefallen ist, minimiert der Plan wenigstens die
Folgekosten: Die **Package-ID wird bewusst neutral gewählt** (`de.bdgraue.sphygma`), damit
ein späterer Anzeigename-Wechsel keine neue App-Identität erzwingt — die Package-ID ist auf
Play unveränderlich.

---

## 4. Architektur

Fünf Schichten, strikt getrennt, Abhängigkeiten nur nach unten:

```
┌─────────────────────────────────────────────────┐
│ UI            Pairing · Sync · Liste · Trend    │
├─────────────────────────────────────────────────┤
│ Sync          orchestriert Readout → DB → HC    │
├──────────────────────────┬──────────────────────┤
│ Persistenz (drift)       │ Health Connect       │
│ Source of Truth          │ Export-Senke         │
├──────────────────────────┴──────────────────────┤
│ Protokoll     Frames · CRC · EEPROM · Records   │  ← rein, testbar
├─────────────────────────────────────────────────┤
│ BLE-Transport Scan · Bond · Notify · Write      │
└─────────────────────────────────────────────────┘
```

**Die Protokollschicht kennt kein Bluetooth.** Sie spricht gegen ein schmales Interface
(„sende diese Bytes, hier kommen Bytes zurück") und ist damit vollständig ohne Hardware
testbar — das ist die wichtigste Entwurfsentscheidung des Projekts. Frame-Bau,
XOR-Prüfsumme, Kanal-Reassemblierung und Record-Parsing sind reine Funktionen über
`Uint8List`.

**Lokale DB ist Source of Truth.** Health Connect ist eine Export-Senke, keine Datenquelle.
Zurückgelesen wird von dort nicht. Dedup-Schlüssel ist `(Zeitstempel, User-Slot)`.

### 4.1 Technologiewahl

**BLE: `flutter_blue_plus` (2.3.12).** Begründet durch den Pairing-Ablauf, nicht durch
allgemeine Vorlieben:

Der Omron-Flow braucht die Fähigkeit, **Bonding gezielt anzustoßen** — der Key wird über eine
zunächst unverschlüsselte Verbindung geschrieben, während das Gerät parallel einen Security
Request stellt. Ich habe beide Kandidaten im Quellcode geprüft:

- `flutter_blue_plus` stellt `BluetoothDevice.createBond({int timeout = 90, Uint8List? pin})`
  als Dart-API bereit (Android-only), dokumentiert als „Force the bonding popup to show now".
  Ebenso vorhanden: `write(value, {withoutResponse, allowLongWrite, timeout})`,
  `setNotifyValue(bool)` und `onValueReceived` — alles, was der Multi-Channel-Transport braucht.
- `flutter_reactive_ble` (5.5.0) kennt Bonding **nur intern im Kotlin-Code**: es wartet ab,
  wenn ein Bonding läuft, und enthält eine Retry-Behandlung für bonding-bedingte Fehler. Eine
  Dart-API zum Auslösen oder Abfragen des Bond-Status gibt es nicht.

**Lizenzhinweis, bei der Implementierung entdeckt (nicht in der ursprünglichen Recherche):**
`flutter_blue_plus` steht seit Version 2.x unter einer eigenen [FlutterBluePlus License](https://github.com/chipweinberger/flutter_blue_plus/blob/main/LICENSE) statt BSD-3. `BluetoothDevice.connect()` verlangt seither einen Pflichtparameter `License license` (`nonprofit` oder `commercial`). Für Sphygma als kostenloses Hobby-/Open-Source-Projekt einer Einzelperson greift `License.nonprofit` (Abschnitt 2 der Lizenz: „personal user"). Zwei Punkte zur Kenntnisnahme:
- Der Lizenztext nennt „commercial use by individuals" als Auslöser der kommerziellen Stufe — bezieht sich nach Wortlaut und Kontrast zu „personal user" auf gewinnorientierte Nutzung, nicht auf kostenlose Hobby-Veröffentlichung. Bei einer Neubewertung (z. B. Spenden-Buttons, Monetarisierung) ist das neu zu prüfen.
- Das Paket sendet laut Lizenz Abschnitt 1.4 eine **Build-Time-Telemetrie** (Package-Name, App-Name, Version, Datum) an den Hersteller; das Ausbleiben blockiert den Build nicht. Für die Datenschutzerklärung (M7, Play-Store-Pflicht) gehört das in die Liste der Drittanbieter-Datenflüsse.

Damit ist die Wahl sachlich entschieden. **Ein Platform-Channel zu nativem Kotlin ist nach
aktuellem Stand nicht nötig** — die kritische Fähigkeit ist in Dart verfügbar. Der Plan hält
den Ausweg trotzdem offen: Die BLE-Schicht liegt hinter einem eigenen Interface, sodass eine
native Implementierung sie ersetzen kann, ohne Protokoll oder UI anzufassen. M1 entscheidet
das an echter Hardware, nicht auf dem Papier.

**Health Connect: `health` (13.3.2).** Der vom Auftrag geforderte Check ist erfolgt — das
Paket deckt beides ab:

- `writeBloodPressure({required int systolic, required int diastolic, required DateTime
  startTime, String? clientRecordId, double? clientRecordVersion, DateTime? endTime,
  RecordingMethod recordingMethod})`
- `HealthDataType.HEART_RATE` steht in `dataTypeKeysAndroid` und ist über `writeHealthData`
  schreibbar.

Besonders wertvoll: **`clientRecordId` und `clientRecordVersion`.** Damit lässt sich die
Deduplizierung an Health Connect delegieren — ein wiederholter Sync desselben Records
überschreibt statt zu duplizieren. Das ist deutlich robuster als App-seitiges Raten. Ein
Platform-Channel ist auch hier nicht nötig.

Verifizierte Rahmenbedingungen: `minSdk 26`, `compileSdk 36`,
`androidx.health.connect:connect-client:1.2.0-alpha02`. Benötigte Permissions:
`android.permission.health.WRITE_BLOOD_PRESSURE` und
`android.permission.health.WRITE_HEART_RATE`.

**minSdk:** 26 ist die Untergrenze des Pakets. Empfehlung **29**, weil Health Connect in der
Praxis auf modernen Geräten läuft und BLE-Berechtigungen ab Android 12 ohnehin anders
funktionieren; das spart einen Sonderpfad. Endgültig in M2 festzulegen.

**Persistenz: `drift`** wie vorgegeben. Konkrete API-Nutzung wird in M4 gegen die
Paketdokumentation verifiziert.

---

## 5. Meilensteine

Reihenfolge ist bindend. Jeder Meilenstein hat ein überprüfbares Ergebnis.

### M0 — Projektgerüst und Rechtsrahmen

Klein halten, aber vor dem Code erledigen.

- Flutter-Projekt, Android-only, Package-ID `de.bdgraue.sphygma`
- Lizenz wählen (MIT oder Apache-2.0) und `LICENSE` anlegen
- `NOTICE.md`: Herkunft des Protokollwissens, MIT-Freigabe für die genutzten omblepy-Teile,
  UBPM als reine Verifikationsquelle
- `docs/protocol/hem-6232t.md` ins Repo (liegt bereits vor)
- Repo auf `git@github.com:WariKoda/Sphygma.git`

**Parallel und unabhängig vom Code zu klären — blockiert sonst später M7:**
Verfügbarkeit eines verifizierten Google-Play-**Organisationskontos**. Ohne das ist der
Play-Release nicht möglich, egal wie gut die App ist.

**Ergebnis:** Repo mit Lizenz und Protokollspezifikation, offene Store-Frage benannt.

### M1 — Protokoll-Spike ⭐ Erst hier zeigt sich, ob das Projekt trägt

**Nichts anderes wird gebaut, bevor das läuft.** Eine Wegwerf-App mit einem Knopf, die auf
die Konsole loggt. Keine DB, keine Health-Connect-Anbindung, keine gestaltete UI.

1. Scan, Gerät finden, verbinden
2. Pairing: Gerät auf `-P-`, Key-Programmiermodus, Zufallskey schreiben, Bonding
3. Entsperren, Start, **beide User-Slots voll auslesen**, Ende
4. Records parsen und auf die Konsole schreiben

**Das ist der Moment, um die offenen Punkte zu klären:**

- **`ihb` gegen `mov` entscheiden (§2.2).** Eine Messung bewusst mit Bewegung durchführen —
  Arm bewegen, sprechen —, bis das Gerät das Bewegungssymbol zeigt. Dann sehen, welches Bit
  gesetzt ist. Ergebnis in `docs/protocol/hem-6232t.md` festhalten. **Wenn das nicht
  eindeutig gelingt, bleiben beide Flags dauerhaft aus dem Health-Connect-Export heraus** —
  ein falsch gesetztes Arrhythmie-Flag in der Gesundheitsakte ist schlimmer als ein fehlendes.
- **Reichen 2 RX-Kanäle oder braucht es 4?** Die Referenzen widersprechen sich (§2.4).
- **Trägt `createBond()`?** Falls das Bonding hier scheitert, ist das der Zeitpunkt für den
  Kotlin-Platform-Channel — nicht in Meilenstein 4.
- **Timing:** omblepy arbeitet mit 1 s Timeout und 5 Wiederholungen; ob das auf Android trägt,
  zeigt erst das Gerät.

**Risiken:**

- Der Pairing-Modus ist der wackeligste Teil des ganzen Protokolls. omblepy braucht dort bis
  zu 10 Anläufe, und das README verzeichnet ausgiebige Plattform-Probleme.
- Ein Gerät, das schon mit der offiziellen Omron-App gepairt ist, verhält sich womöglich
  anders. Notfalls vorher in den Android-Bluetooth-Einstellungen entkoppeln.
- **HEM-6232T ist in omblepy nur für Pairing und Readout als getestet vermerkt**, nicht für
  Zeitsynchronisation und Zähler — wir brauchen beides nicht (§6).

**Ergebnis:** Echte Messwerte aus dem eigenen Gerät auf der Konsole. Ohne das kein M2.

### M2 — Protokollschicht als eigenständiges Modul

Der Spike-Code wird nicht weiterverwendet, sondern ersetzt. Jetzt sauber:

- `BleTransport`-Interface (Bytes rein, Bytes raus) — trennt Protokoll von `flutter_blue_plus`
- Frame-Bau und XOR-Prüfsumme
- Kanal-Reassemblierung inklusive Längenlogik
- EEPROM-Lesen in Blöcken
- Record-Parser für HEM-6232T
- Fehler als Exceptions, keine Rückgabe leerer Listen im Fehlerfall

**Unit-Tests gegen die verifizierten Vektoren** aus `docs/protocol/hem-6232t.md`:

| Fall | Bytes | Erwartung |
|---|---|---|
| Start-Frame | `0800000000100018` | XOR = 0 |
| Ende-Frame | `080f000000000007` | XOR = 0 |
| Read 0x26 @ 0x0260 | `080100026026004d` | XOR = 0, exakt so gebaut |
| Record | `556b18440de70aa1` | 2024-03-15 07:42:33, sys 132, dia 85, bpm 68 |
| Leerer Record | 14 × `0xFF` | wird übersprungen |

Der Record-Vektor ist gegen **beide** Referenzalgorithmen geprüft und liefert in allen elf
Feldern identische Werte — er ist damit ein belastbarer Anker, kein erfundenes Beispiel.

Ergänzend Tests für: fehlerhafte Prüfsumme wirft, unvollständige Kanäle blockieren nicht,
Sekundenwert > 59 wird geklemmt (das Gerät liefert bis 63).

**Risiko:** Die Vektoren sind aus der Spezifikation konstruiert, nicht vom Gerät geloggt.
Deshalb wird in M1 ein echter Record mitgeschnitten und als weiterer Testfall aufgenommen.

**Ergebnis:** Protokollmodul mit grüner Testsuite, ohne Hardware lauffähig.

### M3 — BLE-Transport

Implementierung des Interfaces gegen `flutter_blue_plus`: Scan mit Service-Filter,
Verbindung, Bonding, Notify auf 4 RX-Kanälen, Writes auf TX, Reconnect-Verhalten,
Laufzeit-Berechtigungen.

**Risiken:** Android-BLE-Berechtigungen unterscheiden sich vor und ab Android 12.
Verbindungsabbrüche mitten in der Übertragung müssen sauber scheitern, nicht halbe
Datensätze liefern.

**Ergebnis:** Voll-Readout über die saubere Schichtung, funktional wie der Spike.

### M4 — Persistenz

drift-Schema: Messungen mit `(timestamp, userSlot)` als eindeutigem Schlüssel, Rohbytes des
Records zur Nachvollziehbarkeit, Importzeitpunkt, Flag für „nach Health Connect exportiert".
Dedup beim Import. Migrationen von Anfang an.

**Ergebnis:** Wiederholter Sync erzeugt keine Duplikate — als Test belegt.

### M5 — Health Connect

- Verfügbarkeitsprüfung, Berechtigungsdialog, Umgang mit Verweigerung
- `writeBloodPressure` je Messung, `clientRecordId` deterministisch aus `(timestamp, slot)`
- Puls als `HealthDataType.HEART_RATE`
- `RecordingMethod.automatic` — die Werte stammen aus einem Messgerät, nicht aus Handeingabe
- `ihb`/`mov` dürfen exportiert werden — Zuordnung in M1 geklärt (§2.2)
- **Nur der in der App gewählte User-Slot wird exportiert.** Das Gerät speichert zwei Slots,
  die Schalterstellung ist nicht auslesbar (`hem-6232t.md` §8.1), und Health Connect ist die
  Akte *einer* Person — fremde Messungen dürfen dort nicht landen. Beide Slots werden
  importiert und beschriftet; die Slot-Wahl ist Teil des Pairing-Flows (M6).

**Risiko:** Health Connect kann fehlen oder veraltet sein; der Nutzer kann die Berechtigung
dauerhaft verweigern. Beides muss die App aushalten, ohne den lokalen Bestand zu gefährden —
die DB bleibt Source of Truth.

**Ergebnis:** Messwerte erscheinen in Health Connect, erneuter Sync dupliziert nicht.

### M6 — UI

Bewusst schmal:

1. **Pairing-Flow** mit klarer Anleitung zum langen Druck auf die Bluetooth-Taste
2. **„Jetzt synchronisieren"** mit Fortschritt
3. **Messwertliste**, nach Datum gruppiert, User-Slot erkennbar
4. **Trendansicht:** Morgen-/Abendmittelwerte, 7-Tage-Durchschnitt

**Die ESC-Klassifikation kommt hinter ein Compile-Time-Flag** (§3.2). Standardmäßig aus im
Release-Build. Der Code ist da, die Entscheidung bleibt bis M7 offen und ist dann eine
Konfigurations-, keine Umbaufrage.

Kein Feature-Creep: kein Export, keine Cloud, keine Benutzerkonten, keine Widgets.

### M7 — Release

- GitHub: Signiertes APK, Release Notes
- F-Droid: FOSS-Lizenz, reproduzierbarer Build
- Play: **nur wenn das Organisationskonto aus M0 vorliegt.** Dann Health-Apps-Declaration,
  Datenschutzerklärung, Begründung je Datentyp, Medical-Device-Labeling
- Entscheidung über die ESC-Klassifikation im veröffentlichten Build

---

## 6. Nicht-Ziele

Bewusst ausgeschlossen — jede Position mit Grund:

| Ausgeschlossen | Grund |
|---|---|
| **EEPROM-Writes außer Pairing-Key** | Im Settings-Bereich liegen vermutlich Kalibrierdaten des Drucksensors. Ein Fehlschreiben kann das Gerät dauerhaft verfälschen. Tabu. |
| **„New record counter"** | Erfordert Schreiben in genau diesen Bereich und ist für HEM-6232T in omblepy **ungetestet**. Stattdessen: immer Voll-Readout, Dedup in der App. 200 Records sind schnell gelesen. |
| **Zeitsynchronisation** | Ebenfalls EEPROM-Write; in `hem-6232t.py` auskommentiert mit dem Kommentar „this is probably not correct". |
| iOS | Nicht beauftragt. Die Schichtung stünde dem nicht im Weg. |
| Weitere Omron-Modelle | YAGNI. Keine Geräteabstraktion auf Verdacht. |
| Health Connect als Datenquelle | Einbahnstraße; die lokale DB ist Source of Truth. |

---

## 7. Risikoregister

| ID | Risiko | Auswirkung | Umgang |
|---|---|---|---|
| R-1 | ~~Pairing schlägt auf Android fehl~~ **erledigt** | — | M1 bestanden ohne Kotlin-Channel; Ablauf in `hem-6232t.md` §5.1 |
| R-2 | ~~`ihb`/`mov` bleiben unklar~~ **erledigt** | — | Per Display-Foto geklärt (§6.2); omblepy vertauscht, UBPM korrekt |
| R-9 | Geräteuhr geht falsch, nicht stellbar (kein EEPROM-Write) | Falsche Zeitstempel in Health Connect | Dedup über Messungsnummer (§6.3); Plausibilitätsprüfung und Warnung beim Sync |
| R-3 | ESC-Klassifikation macht die App zum Medizinprodukt Klasse IIa | Kein legaler Store-Release | Compile-Time-Flag; Entscheidung in M7; ggf. anwaltliche Prüfung |
| R-4 | Zufallskey geht bei Neuinstallation verloren | Neu-Pairing nötig, omblepy/UBPM verlieren Zugriff | Key in Backup einschließen; Neu-Pairing im UI erklären |
| R-5 | Kein Play-Organisationskonto | Play-Release unmöglich | In M0 klären, nicht erst in M7 |
| R-6 | Namenskollision mit „Sphygmo" | Beanstandung im Store | Neutrale Package-ID, damit ein Namenswechsel billig bleibt |
| R-7 | ~~2 statt 4 RX-Kanäle nötig~~ **erledigt** | — | Gerät antwortet über alle 4 Kanäle; Reassemblierung verifiziert |
| R-8 | Gerät bereits mit Omron-App gepairt | Pairing schlägt fehl | Vorher entkoppeln; im Pairing-Flow erklären |

---

## 8. Quellen

- [omblepy](https://github.com/userx14/omblepy) — `omblepy.py`, `sharedDriver.py`,
  `deviceSpecific/hem-6232t.py`, README (Kommandotabelle, Gerätematrix)
- [omblepy Issue #67, Kommentar des Maintainers zur Lizenz](https://github.com/userx14/omblepy/issues/67#issuecomment-4468826470)
  und [Issue #74](https://github.com/userx14/omblepy/issues/74)
- [UBPM](https://codeberg.org/LazyT/ubpm) (GPL-3.0) —
  `sources/plugins/vendor/omron/bluetooth/` inkl. `omron-bluetooth.json`
- [MDCG 2019-11](https://health.ec.europa.eu/system/files/2020-09/md_mdcg_2019_11_guidance_en_0.pdf)
- [Publish your health app on Google Play](https://developer.android.com/health-and-fitness/health-connect/publish)
- [Health apps declaration form](https://support.google.com/googleplay/android-developer/answer/14738291)
- Quellcode von `flutter_blue_plus` 2.3.12, `flutter_reactive_ble` 5.5.0, `health` 13.3.2
- [Sphygmo auf Google Play](https://play.google.com/store/apps/details?id=ca.mmhg.sphygmo)
