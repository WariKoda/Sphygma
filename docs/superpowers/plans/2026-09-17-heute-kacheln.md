# Heute-Kacheln und niedrige Blutdruckwerte

Freigegeben: Variante B der Vorschau, ergänzt um einmalige Einheiten für alle
Werte einer reinen Blutdruck- bzw. Pulskarte. Umsetzung auf Themenbranch, ohne
Tag oder Veröffentlichung; Commit, Push und PR sind freigegeben.

## Entwurf und Grenzen

- Kartenkopf: Titel mit kleiner Einheit, Messdatum/-zeit rechts, bei Platzmangel
  darunter. Keine redundanten Kicker. SYS/DIA in gleich breiten Feldern;
  bei großer Schrift dürfen sie untereinander stehen.
- Morgen-/Abendmittel: keine Einheitenwiederholung; nebeneinander gleich hoch,
  Leerzustand mit Strich und „Noch keine Messung“. Keine erfundenen Messwerte.
- Nur Hauptkartenköpfe tragen die Einheiten; Unterabschnitte wiederholen sie
  nicht. Gemischte Hauptkarten nennen einmal „Blutdruck mmHg · Puls bpm“.
  Spaltenköpfe in Messungslisten und eigenständige Einzelkarten behalten die
  nötige Zuordnung. Puls verwendet überall bpm.
- Niedrig: systolisch <90 oder diastolisch <60 mmHg. Die einzelnen Komponenten
  bleiben unterscheidbar. Eine gleichzeitig erhöhte Komponente behält ihre
  obere Kategorie, ergänzt um den Hinweis auf die niedrige Komponente.
- Die bestehende ESC/ESH-2018-Einstufung wird nicht auf eine andere Leitlinie
  umgestellt. „Niedrig“ ist ausdrücklich eine ergänzende Kategorie. Erklärung
  mit Referenzen ist an der Skala erreichbar; Klassifikation bleibt hinter
  SPHYGMA_ESC. Zonenfarben berücksichtigen niedrige Werte ebenfalls.
- Keine Pulsdiagnostik, Datenbank-, Sync- oder BLE-Änderung.

## Umsetzung und Prüfungen

- [x] Heute: Regressionstests für gemeinsame Einheiten, getrennte Werte,
  gleich hohe Mittelwertfelder, Messzeit und große Schrift ergänzen; rot prüfen.
  PanelHeader um Einheit und seitliche Zeit erweitern; TodayVitals anpassen.
- [x] Übrige Ansichten: Detail, Verlaufskurve, Mittelwerte, Wochenraster und
  gemischte Einzelwerte prüfen. Einheiten an die zugehörige Überschrift ziehen;
  fehlende Einheiten ergänzen. Bestehende Aktions-/Layouttests weiterverwenden.
- [x] Niedrig: Grenzwerttests 89/70, 110/59, 85/55, 90/60, 140/55, 130/55 und
  ungültige Werte; ergänzende Kategorie/Farben und Skaleninformation umsetzen.
  Einheitliche Anzeige in Heute und Messungsdetail prüfen.
- [x] dart format; flutter analyze; flutter test; flutter test
  --dart-define=SPHYGMA_ESC=true. Gerenderte Vorschau prüfen; Diff gegen Auftrag
  gegenlesen und Reviewbefunde bearbeiten.

## Referenzen (17.09.2026 geprüft)

- NHS: https://www.nhs.uk/conditions/low-blood-pressure-hypotension/
  nennt niedrigen Blutdruck unter 90/60 mmHg.
- NHLBI: https://www.nhlbi.nih.gov/health/low-blood-pressure
  nennt ebenfalls unter 90/60 mmHg.
- Mayo Clinic: https://newsnetwork.mayoclinic.org/discussion/condition-causes-significant-drop-in-blood-pressure-upon-standing/
  beschreibt systolischen oder diastolischen Niedrigwert getrennt (dort inklusive
  90 bzw. 60). Sphygma verwendet strikt „unter“ in Anlehnung an NHS/NHLBI.
- herzmedizin.de nennt abweichende Schwellen; die App-Regel ist deshalb eine
  transparente Referenz, keine universelle Norm oder individuelle Diagnose.


## Ergebnis

- `flutter analyze --no-pub`: ohne Befund.
- `flutter test --no-pub`: 724 Tests erfolgreich.
- `flutter test --no-pub --dart-define=SPHYGMA_ESC=true`: 724 Tests erfolgreich.
- Unabhängiger Read-only-Review für Niedrig-Einstufung und UI: keine wesentlichen
  Befunde. Zusätzlicher Test für lange gemischte Hinweise bei 320 px/Textfaktor 2.
- Flutter-Rendering der Heute-Kacheln in Papier und Nacht geprüft.
- Version 0.2.0+10 als Release-Split-APKs gebaut, ARM64-Version (2010) auf Fairphone 4
  als Update installiert und App-Start geprüft. Kein erneuter BLE-/Export-Test.
  APKs lokal mit Debug-Key signiert. Tag/Veröffentlichung erst nach dem Merge.
