# Umsetzung der vier Konzepte: Reihenfolge und Begründung

Stand 2026-09-06.

Die vier Konzepte sind vollständige, eigenständige Ausführungen derselben App.
Sie unterscheiden sich in der Organisation, nicht im Funktionsumfang, und
arbeiten auf demselben Datenbestand.

## Warum nicht mit dem billigsten Konzept anfangen

Der naheliegende Weg wäre, mit „Tagesprofil" zu beginnen, weil es als einziges
ohne Datenbankänderung auskommt. Das ist der schnellste Weg, nicht der beste:
Er baut die Konzepte nacheinander und lässt jedes seine eigene Grundlage
mitbringen. Vier Konzepte, die dieselbe Sache viermal leicht verschieden
lösen — genau das, was diese Sitzung an den Entwürfen schon einmal korrigieren
musste.

Der Vergleich der vier Datenmodell-Abschnitte zeigt: **Das meiste ist
gemeinsam.** Vier Bausteine werden von mehreren Konzepten gebraucht, und
sie sind es, die falsch werden, wenn jedes Konzept sie für sich nachbaut.

## Die gemeinsame Grundschicht

| Baustein | Gebraucht von | Art |
|---|---|---|
| **Tageszeit-Zuordnung** — morgens, vormittags, nachmittags, abends, nachts; Grenzen einstellbar | Sieben Tage (morgens/abends), Tagesprofil (fünf Abschnitte) | Ableitung + eine Einstellung |
| **Zeitplausibilität je Messung** — trägt eine Messung ein Datum, das ihrer Gerätenummer widerspricht? | alle vier | reine Ableitung, kein Feld |
| **Zielbereich** — Heimmess-Schwellen 135/85 statt der Praxiswerte 140/90 | Sieben Tage ausdrücklich, sinnvoll für alle | Einstellung |
| **Anlass-Gruppierung** — mehrere Messungen kurz hintereinander sind ein Messen | Messanlass als Einheit, Sieben Tage für die Feldbelegung | Ableitung + persistierte Nutzerentscheidungen |

Die Zeitplausibilität ist der interessanteste Fall: Sie braucht **kein neues
Feld**. Die Gerätenummer steigt monoton, der Zeitstempel muss es auch — wo er
das nicht tut, ist die Uhr falsch gegangen. Das ist rechenbar, und deshalb wird
es gerechnet und nicht gespeichert. Passend dazu die harte Regel: Sphygma
verschiebt keine Zeitstempel.

## Was wirklich gespeichert werden muss

Nur, wo ein Mensch entschieden hat. Alles andere ist Ableitung und wird bei
jeder Abfrage neu gerechnet.

| Neu | Wofür | Konzept |
|---|---|---|
| `MeasurementOccasions` | Anlässe, die der Nutzer bestätigt oder korrigiert hat, mit Entstehungsart | Messanlass |
| `OccasionMembers` | welche Rohmessung zu welchem Anlass gehört | Messanlass |
| `Phases` | Name, bestätigter Beginn, optionales Ende, Zeitanker-Quelle | Phase |
| `PhaseAssignments` | Messung zu Phase, mit Status vorgeschlagen/bestätigt/ungeklärt | Phase |

Vier Tabellen, **eine** Migration. Nicht vier Migrationen nacheinander, weil
jedes Konzept seine eigene mitbringt.

## Reihenfolge

1. **Grundschicht, rein und ohne Flutter testbar.** Tageszeit, Zeitplausibilität,
   Zielbereich, Anlass-Vorschläge. Vollständig für alle vier Konzepte, nicht
   nur für das erste.
2. **Persistenz.** Die vier Tabellen, eine Migration, Repositories, Tests.
   Nutzerentscheidungen überschreiben nie die Ableitung — sie treten daneben
   und gewinnen.
3. **Konzeptschicht.** `AppConcept` neben `ThemeVariant`, gespeichert wie die
   Gestaltungswahl, umschaltbar im Gerätebereich. Zwei freie Achsen.
4. **Die vier Oberflächen.** Jede deckt alle fünfzehn Funktionen aus
   `funktionsraster.md` ab, jede funktioniert in jeder Gestaltung.

Schritt 1 und 2 sind das Fundament und tragen alle vier. Sie werden einmal
gebaut und danach nicht mehr angefasst.
