# NOTICE

Sphygma implementiert das proprietäre Omron-BLE-Protokoll für das HEM-6232T neu, auf Basis
der in `docs/protocol/hem-6232t.md` dokumentierten Spezifikation. Kein Code der unten
genannten Projekte wird übernommen. Die rechtliche Analyse steht in `PLAN.md` Abschnitt 3.1.

## omblepy

[omblepy](https://github.com/userx14/omblepy) (Autor: `userx14`) diente als primäre
Referenz zum Verständnis des Protokolls, insbesondere `deviceSpecific/hem-6232t.py`.

Das Repository trägt keine Lizenzdatei. Der Maintainer hat auf Nachfrage erklärt, dass er
seine eigenen Beiträge unter MIT freigibt, da eine formale Lizensierung des Gesamtprojekts
die Zustimmung aller früheren Mitwirkenden erfordern würde
([Kommentar](https://github.com/userx14/omblepy/issues/67#issuecomment-4468826470)):

> „For my contributions, feel free to use them under MIT license. […] copyright does not
> cover the communication protocol anyway."

Sämtliche Commits an `deviceSpecific/hem-6232t.py` — dem für Sphygma relevanten
Gerätemodul — stammen von `userx14` selbst; diese MIT-Freigabe deckt es vollständig ab.
Verwendet wurde daraus ausschließlich das Protokollwissen (Kommandobytes, EEPROM-Adressen,
Bitlayout, Prüfsummenverfahren), das ohnehin nicht als Ausdruck, sondern als Tatsache gilt
und damit keinem Copyright unterliegt.

## flutter_blue_plus

Sphygma nutzt [flutter_blue_plus](https://github.com/chipweinberger/flutter_blue_plus) als
BLE-Transport (Begründung: `PLAN.md` Abschnitt 4.1). Das Paket steht unter der
[FlutterBluePlus License](https://github.com/chipweinberger/flutter_blue_plus/blob/main/LICENSE)
(nicht BSD-3). Sphygma nutzt es als kostenloses Hobby-Projekt einer Einzelperson unter den
„Open Use Terms" (Abschnitt 2, `License.nonprofit`). Das Paket sendet laut Lizenz Abschnitt 1.4
eine Build-Time-Telemetrie (Package-Name, App-Name, Version, Datum) an den Hersteller.

## UBPM (Universal Blood Pressure Manager)

[UBPM](https://codeberg.org/LazyT/ubpm) (Autor: `LazyT`) steht unter GPL-3.0 und diente
ausschließlich als unabhängige Gegenprobe für das Protokollverständnis
(`sources/plugins/vendor/omron/bluetooth/`). Es wurde kein Code aus UBPM übernommen — weder
wörtlich noch sinngemäß in Struktur. Übernommener GPL-3.0-Code würde Sphygma unter
Copyleft zwingen, was mit der gewählten MIT-Lizenz unvereinbar wäre.
