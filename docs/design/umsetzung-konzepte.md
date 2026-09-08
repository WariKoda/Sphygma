# Umsetzung der vier Konzepte: Reihenfolge und Begründung

Geschrieben 2026-09-06, abgeglichen 2026-09-08.

**Dies ist der Plan von damals, nicht der Stand von heute.** Er steht in
Zukunftsform, und so bleibt er — eine Begründung, die man nachträglich in eine
Beschreibung umschreibt, begründet nichts mehr. Was tatsächlich daraus wurde,
steht am Ende unter „Der Abgleich"; wo eine Aussage hier von der Wirklichkeit
abweicht, ist sie dort benannt.

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
   Gestaltungswahl, umschaltbar an einer Stelle. Zwei freie Achsen.
4. **Die vier Oberflächen.** Jede deckt alle fünfzehn Funktionen aus
   `funktionsraster.md` ab, jede funktioniert in jeder Gestaltung.

Schritt 1 und 2 sind das Fundament und tragen alle vier. Sie werden einmal
gebaut und danach nicht mehr angefasst.

---

## Der Abgleich, 2026-09-08

Zwei Tage später. Was der Plan versprach, gegen das, was im Code steht — mit
Belegstelle, damit der nächste Leser nicht raten muss.

### Die Reihenfolge hat gehalten

Der Kern des Plans war die Behauptung, die Grundschicht müsse **vor** der
ersten Oberfläche fertig sein, sonst baue jedes Konzept sie sich selbst. Das
ist so gelaufen, und zwar in einem Zug:

| Wann | Was |
|---|---|
| 06.09. 05:01–05:58 | Grundschicht: Tageszeit, Zeitplausibilität, Zielbereich, Anlass-Vorschläge |
| 06.09. 06:21 | Persistenz, Schema 3 (`f9750c2`) |
| 06.09. ab 10:24 | die vier Oberflächen (`347d054` und danach) |

Kein Konzept musste nachträglich eine Grundlage mitbringen. Der teurere Weg
war der richtige.

### Drei Tabellen statt vier

Geplant waren `MeasurementOccasions` **und** `OccasionMembers`. Gebaut wurde
`OccasionDecisions` — eine Tabelle, die nur festhält, ob eine Messung an ihren
Vorgänger *angeschlossen* oder von ihm *getrennt* wurde (`'join'` / `'split'`).
Die Anlässe selbst und ihre Mitglieder werden daraus abgeleitet.

Das ist keine Vereinfachung aus Bequemlichkeit, sondern die konsequentere
Anwendung der eigenen Regel „nur, wo ein Mensch entschieden hat": Ein Anlass
ist keine Entscheidung, er ist ihre Folge. Der Plan hatte die Regel formuliert
und selbst noch gegen sie verstoßen.

### Zwei Migrationen statt einer

Der Plan bestand auf **einer** Migration. Es wurden zwei: Schema 3 legt
`OccasionDecisions` und `Phases` an, Schema 4 kam mit dem Konzept „Phase" für
`PhaseAssignments` nach. Der Grund steht in `app_database.dart` an der
Migration: Die Zuordnung verweist auf `Phases` und kann nicht vor ihr
entstehen. Vermeidbar wäre es gewesen, wenn die vierte Tabelle beim ersten Mal
mitgekommen wäre — sie war schlicht noch nicht entworfen.

### Von vier Konzepten sind zwei übrig

Alle vier wurden gebaut. Am 08.09. sind **„Sieben Tage" und „Tagesprofil"
aufgelöst** worden (`a256de5`): nicht, weil sie schlecht waren, sondern weil
ihre Aussagen keine eigene Ordnung tragen. Eine Messwoche und ein Tagesprofil
sind Blickwinkel auf denselben Bestand, kein anderer Zugang zu ihm.

Beide Aussagen sind erhalten und stehen jetzt dort, wo man sie sucht:

* das **Wochenraster** auf „Heute", abschaltbar (`ThisWeekPanel`)
* der **Wochenwert ohne den ersten Tag** und die Feldvollständigkeit im
  Verlauf, sobald der Zeitraum „Woche" gewählt ist
* die **fünf Tagesabschnitte** im Verlauf unter „Nach Tageszeit" — vorher
  kannte er nur morgens und abends

Übrig als eigenständige Ordnungen sind „Messanlass" und „Phase", neben dem
gewachsenen „Messung und Filter". Das Funktionsraster gilt unverändert für
alle drei und wird als Test durchgesetzt
(`test/ui/concepts/funktionsraster_test.dart`).

### Offen: zwei Bausteine sind nicht bis zur Einstellung geführt

Die Tabelle der Grundschicht nennt zweimal „Einstellung". Beide sind in der
**Rechenschicht** eingelöst und in der **Oberfläche** nicht:

| Baustein | Stand |
|---|---|
| **Zielbereich** 135/85 | `TargetRange` kann beliebige Schwellenpaare; jede Aufrufstelle nimmt fest `TargetRange.heim`. Keine Einstellung, kein Schlüssel in `SettingsRepository`. |
| **Tageszeit-Grenzen** | `BandGrid.grobMit(schnitt:)` nimmt einen freien Schnittpunkt — außerhalb der Tests ruft ihn niemand mit einem anderen als 12:00 auf. Der Kommentar in `time_of_day_band.dart` sagt „Die Grenzen sind einstellbar"; einstellen kann sie niemand. |

Persistiert werden bis heute vier Dinge: `user_slot`, `theme_variant`,
`app_concept`, `week_panel_visible`. Wer im Schichtdienst arbeitet, hat weiter
den Morgen des Dokuments und nicht seinen eigenen.

### Wo die Konzeptwahl steht

Der Plan sagte „umschaltbar im Gerätebereich". Den gibt es nicht mehr: Seit dem
08.09. steht die gesamte Technik hinter dem Zahnrad oben rechts, eine Karte je
Abschnitt, nach Häufigkeit geordnet. Konzept und Gestaltung stehen dort unten —
man stellt sie einmal ein.
