# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projektzustand

**Hier existiert noch kein Code.** Das Repo enthält ausschließlich `PLAN.md` und
`docs/protocol/hem-6232t.md`. Es gibt keine `pubspec.yaml`, kein Flutter-Projekt, keine Tests.
Die unten genannten Befehle greifen erst, nachdem Meilenstein 0 das Projekt angelegt hat.

Vor inhaltlicher Arbeit **`PLAN.md` lesen** — dort stehen die getroffenen Entscheidungen, die
Meilensteinreihenfolge und das Risikoregister. Die Reihenfolge der Meilensteine ist bindend:
**M1 (Protokoll-Spike an echter Hardware) blockiert alles Weitere.** Vor einem erfolgreichen
Pairing und Voll-Readout auf der Konsole wird weder Persistenz noch Health Connect noch UI
gebaut.

## Was die App tut

Liest einen **Omron RS7 Intelli IT (HEM-6232T)** über ein proprietäres BLE-Protokoll aus und
schreibt die Messwerte nach Health Connect. Android only, Package-ID `de.bdgraue.sphygma`.

## Befehle

Toolchain ist installiert: Flutter 3.47.0-0.1.pre (**beta channel**), Dart 3.13.0,
`adb` unter `~/Android/Sdk/platform-tools/`.

```bash
flutter analyze                              # statische Analyse — nach jeder Änderung
flutter test                                 # gesamte Testsuite
flutter test test/protocol/frame_test.dart   # eine Datei
flutter test --plain-name "XOR"              # ein Test per Namensfragment
flutter test --name "<regexp>"               # ein Test per Regex
flutter test --coverage
flutter run                                  # Gerät muss per adb verbunden sein
flutter devices
```

Der **beta channel** ist für den in `PLAN.md` M7 geplanten reproduzierbaren F-Droid-Build ein
Problem. Vor dem Release auf einen stabilen Kanal wechseln und die Version pinnen.

Health Connect verlangt `minSdk 26` (Untergrenze des `health`-Pakets); der Plan empfiehlt 29.

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
- **`ihb` und `mov` werden nicht nach Health Connect exportiert**, solange die
  Flag-Zuordnung ungeklärt ist. Die beiden Referenzimplementierungen widersprechen sich hier
  (Details in `docs/protocol/hem-6232t.md` §6.2). Ein falsch gesetztes Arrhythmie-Flag in der
  Gesundheitsakte ist schlimmer als ein fehlendes.
- **Kein Code aus UBPM übernehmen** — das Projekt ist GPL-3.0 und würde Sphygma unter Copyleft
  zwingen. UBPM dient ausschließlich als Gegenprobe fürs Protokollverständnis.
- **Die Protokollschicht wird aus `docs/protocol/hem-6232t.md` neu implementiert**, nicht aus
  omblepy übersetzt. Das Protokoll ist nicht schutzfähig, der fremde Code schon.
- **Die ESC-Klassifikation bleibt hinter einem Compile-Time-Flag.** Sie kann die App nach
  MDCG 2019-11 zum Medizinprodukt machen (MDR-Regel 11, Blutdruck = vitaler Parameter →
  Klasse IIa). Begründung in `PLAN.md` §3.2.
- **Fail hard.** Prüfsummenfehler, unvollständige Pakete oder abgebrochene Verbindungen werfen.
  Niemals eine leere Liste zurückgeben, wo ein Fehler vorliegt — leer ist von „keine Messwerte
  vorhanden" nicht unterscheidbar.

## Protokollarbeit

`docs/protocol/hem-6232t.md` ist die maßgebliche Spezifikation und zugleich Testgrundlage.
Jede Aussage dort trägt ihre Quelle: `[O]` = omblepy, `[U]` = UBPM, `[O+U]` = beide bestätigen
sich. Die Testvektoren in §7 sind gegen beide Referenzalgorithmen geprüft und gehören als
Unit-Tests in die Protokollschicht.

Wird am Protokollverständnis etwas Neues verifiziert — insbesondere die `ihb`/`mov`-Frage aus
M1 —, gehört das Ergebnis **dort hinein**, nicht nur in den Code.
