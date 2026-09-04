# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projektzustand

**M0–M6 sind implementiert und an echter Hardware validiert** (Fairphone 4, HEM-6232T,
2026-09-03/04); M7 (Release) ist vorbereitet (`docs/RELEASE.md`), die Release-Entscheidungen
stehen in `PLAN.md` M7. Status, Entscheidungen und Risikoregister stehen in `PLAN.md` — vor
inhaltlicher Arbeit lesen.

Verzeichnisse: `lib/protocol` (rein, ohne Bluetooth), `lib/ble` (flutter_blue_plus-Anbindung,
Session, Pairing, Key-Store), `lib/db` (drift, generierte `*.g.dart` sind eingecheckt),
`lib/sync` (Readout→DB, DB→Health Connect), `lib/stats`, `lib/app`, `lib/ui`.
`lib/spike/` ist die M1-Diagnose-App (eigener Entrypoint `lib/spike_main.dart`,
`flutter run -t lib/spike_main.dart`) — bewusst behalten, weil sie Settings-Abtastung und
Rohbyte-Logging kann, die die App nicht hat.

## Was die App tut

Liest einen **Omron RS7 Intelli IT (HEM-6232T)** über ein proprietäres BLE-Protokoll aus und
schreibt die Messwerte nach Health Connect. Android only, Package-ID `de.bdgraue.sphygma`.

## Befehle

Toolchain ist installiert: **Flutter 3.47.2 (stable, gepinnt für den Release)**, Dart 3.13.2,
`adb` unter `~/Android/Sdk/platform-tools/`.

```bash
flutter analyze                              # statische Analyse — nach jeder Änderung
flutter test                                 # gesamte Testsuite
flutter test test/protocol/frame_test.dart   # eine Datei
flutter test --plain-name "XOR"              # ein Test per Namensfragment
flutter test --name "<regexp>"               # ein Test per Regex
flutter test --coverage
flutter run                                  # Gerät muss per adb verbunden sein
flutter run --dart-define=SPHYGMA_ESC=true   # mit ESC-Klassifikation (Standard: aus)
flutter run -t lib/spike_main.dart           # M1-Diagnose-App
flutter run --pid-file /tmp/sphygma.pid      # dann: kill -USR1 (Hot Reload) / -USR2 (Restart)
dart run build_runner build --delete-conflicting-outputs   # nach Änderungen am drift-Schema
flutter build apk --release --split-per-abi  # Release, siehe docs/RELEASE.md
flutter devices
```

Nach Schema-Änderungen in `lib/db/app_database.dart`: `schemaVersion` erhöhen, Migration in
`migration` ergänzen, Codegen laufen lassen, generierte Datei mit einchecken.

Release-Builds tragen **immer** `--dart-define=SPHYGMA_ESC=true` (Entscheidung 2026-09-04,
`docs/RELEASE.md` §2). Die Flutter-Version ist in `docs/RELEASE.md` §1.1 und den
F-Droid-Metadaten gepinnt; beim Upgrade beide Stellen mitziehen.

Health Connect verlangt `minSdk 26` (Untergrenze des `health`-Pakets); gesetzt ist 29.
`compileSdk`/`targetSdk` sind auf 36 gepinnt (Play-Anforderung seit 31.08.2026).

## Architektur

Fünf Schichten, Abhängigkeiten ausschließlich nach unten:

```
UI  →  Sync  →  {Persistenz (drift) | Health Connect}  →  Protokoll  →  BLE-Transport
```

Zwei Entwurfsentscheidungen tragen das ganze Projekt und sind beim Ändern zu respektieren:

**Die Protokollschicht kennt kein Bluetooth.** Sie spricht gegen ein schmales
`BleTransport`-Interface (Bytes rein, Bytes raus). Frame-Bau, XOR-Prüfsumme,
Kanal-Reassemblierung und Record-Parsing sind reine Funktionen über `Uint8List` und damit
vollständig ohne Hardware testbar. Wer BLE-Typen in die Protokollschicht zieht, zerstört ihre
Testbarkeit — genau deshalb liegt das Interface dazwischen.

**Die lokale DB ist Source of Truth, Health Connect ist reine Export-Senke.** Von dort wird
nie zurückgelesen. Dedup-Schlüssel ist `(Zeitstempel, User-Slot)`; nach außen wird er als
`clientRecordId` an Health Connect gegeben, das damit selbst dedupliziert.

## Harte Projektregeln

Diese Punkte sind nicht verhandelbar und lassen sich dem Code allein nicht ansehen:

- **Keine EEPROM-Writes außer dem Pairing-Key.** Im Settings-Bereich des Geräts liegen
  vermutlich Kalibrierdaten des Drucksensors; ein Fehlschreiben kann das Messgerät dauerhaft
  verfälschen. Damit entfallen auch „new record counter" und Zeitsynchronisation — stattdessen
  immer Voll-Readout mit Dedup in der App.
- **Flag-Zuordnung: Bit 32 = Bewegung, Bit 33 = Arrhythmie** — an Hardware per Display-Foto
  verifiziert (`docs/protocol/hem-6232t.md` §6.2). omblepy hat die beiden für dieses Modell
  vertauscht; wer dort abschreibt, exportiert falsche Arrhythmie-Flags. Nur `record.dart`
  ist maßgeblich.
- **Dedup-Schlüssel ist die Messungsnummer** (Record-Bytes 9–11, §6.3), nicht der
  Zeitstempel: Die Geräteuhr geht nachweislich falsch und kann weder gestellt noch
  verlässlich gelesen werden (§8.2). Zeitstempel beim Sync auf Plausibilität prüfen.
- **Kein Code aus UBPM übernehmen** — das Projekt ist GPL-3.0 und würde Sphygma unter Copyleft
  zwingen. UBPM dient ausschließlich als Gegenprobe fürs Protokollverständnis.
- **Die Protokollschicht wird aus `docs/protocol/hem-6232t.md` neu implementiert**, nicht aus
  omblepy übersetzt. Das Protokoll ist nicht schutzfähig, der fremde Code schon.
- **Die ESC-Klassifikation bleibt hinter einem Compile-Time-Flag.** Sie kann die App nach
  MDCG 2019-11 zum Medizinprodukt machen (MDR-Regel 11, Blutdruck = vitaler Parameter →
  Klasse IIa). Begründung in `PLAN.md` §3.2.
- **Health-Connect-Writes immer mit `clientRecordId` und `clientRecordVersion`.** Das
  health-Plugin übernimmt die Client-ID nur zusammen mit einer Version in die Metadaten;
  ohne Version entstehen Duplikate, und das Entfernen per Client-ID trifft nichts, meldet
  aber Erfolg (am Gerät erlebt, `PLAN.md` R-10).
- **Fail hard.** Prüfsummenfehler, unvollständige Pakete oder abgebrochene Verbindungen werfen.
  Niemals eine leere Liste zurückgeben, wo ein Fehler vorliegt — leer ist von „keine Messwerte
  vorhanden" nicht unterscheidbar.

## BLE-Eigenheiten des Geräts (an Hardware verifiziert)

Diese Punkte kosten jeweils einen Fehlschlag, wenn man sie nicht kennt
(`docs/protocol/hem-6232t.md` §2.1, §5.1, §8.1):

- Das Gerät bewirbt im Advertising **nur** den Standard-Service `0x1810`, nicht den
  proprietären Parent-Service. Scan-Filter nach Service findet es nie — nach Name
  (`BLEsmart_`/`BLESmart_`) filtern und den Scan beim ersten Treffer sofort beenden.
- Es sendet nur auf Tastendruck (kurz: normal, lang: Pairing-Modus `-P-`) und trennt nach
  ~60 s ohne Kommando.
- Pairing: Notify auf RX 0 löst das Bonding aus; bis `bonded` antwortet das Gerät auf den
  Programmiermodus mit `82 0f`. Auf den Bond-Status warten, nicht blind wiederholen.
  Bonding und Key-Write gehören in dieselbe Sitzung.
- Settings-Bereich nur in den kleinen Abschnitten lesen, die omblepy nutzt; ein 0x38-Byte-Read
  ab `0x0260` bleibt unbeantwortet.

## Protokollarbeit

`docs/protocol/hem-6232t.md` ist die maßgebliche Spezifikation und zugleich Testgrundlage.
Jede Aussage dort trägt ihre Quelle: `[O]` = omblepy, `[U]` = UBPM, `[O+U]` = beide bestätigen
sich. Die Testvektoren in §7 sind gegen beide Referenzalgorithmen geprüft und gehören als
Unit-Tests in die Protokollschicht.

Wird am Protokollverständnis etwas Neues verifiziert — insbesondere die `ihb`/`mov`-Frage aus
M1 —, gehört das Ergebnis **dort hinein**, nicht nur in den Code.
