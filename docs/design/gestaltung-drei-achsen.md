# Gestaltung in drei Achsen: Charakteristik, Palette, Schrift

Entwurf vom 2026-09-08. Noch nicht gebaut.

Tafel dazu: `gestaltung-drei-achsen.html` — die Kreuzung als Bild, im Browser zu
öffnen. Wer wissen will, ob die Trennung trägt, schaut dort und liest hier das
Warum.

## Der Befund, der dazu führt

Sechs Gestaltungen stehen zur Wahl, vier davon sind kaum auseinanderzuhalten:
**Messinstrument, Material 3, Pulse Grid und Pegel** — alle heller Grund, kein
Schatten, Radius zwischen 0 und 12, ähnliche Abstände. Unterscheidbar nur an
Akzentfarbe und Schriftgewicht, also an Details, die man ohne direkten
Vergleich nicht sieht.

**Das war nie so entworfen.** `handschriften.html` stellt seinem Abschnitt die
Überschrift *„Nicht die Farben, sondern der Aufbau"* voran und gibt jeder
Handschrift ein strukturelles Merkmal:

| Handschrift | Merkmal laut Entwurf |
|---|---|
| A Messinstrument | Haarlinien, keine Flächen, Radius ≤ 3, Ziffern tabellarisch |
| B Tagebuch | Kennzahlen als Mini-Karten **nebeneinander** statt Zeilen untereinander |
| C Material 3 | Filter-Chips statt Segmentleiste, **ein** Extended FAB je Bildschirm |
| D Aura | Keine Trennstriche — Luft gliedert, nicht der Strich |
| E Pulse Grid | SYS und DIA als **zwei gleichwertige Zahlenblöcke**, nicht „124/85"; Listen als Datentabelle mit Spaltenkopf |
| F Pegel | Die Einordnung färbt die **Kopffläche selbst**; das Band ist der Knopf |

Davon ist fast nichts gebaut. Geprüft am 08.09.2026:

* `FloatingActionButton`, `FilterChip`, `DataTable` und `LinearGradient` kommen
  in **null** Dateien vor.
* **Kein einziger Bildschirm verzweigt nach der Gestaltung** — `ThemeVariant`
  taucht außerhalb von `lib/ui/theme/` nur in der Auswahlliste auf.
* Es gibt **keine Schriftfamilie**. Der einzige `fontFamily`-Eintrag im Projekt
  steht in der Diagnose-App für Rohbytes; der `fonts:`-Block in `pubspec.yaml`
  ist unangetastet der auskommentierte Vorlagentext.

Alle sechs laufen also durch dieselbe Widget-Struktur, in derselben
System-Schrift, und bekommen nur andere Zahlen und Farben. Sie sind nicht zu
ähnlich **entworfen**, sondern zu ähnlich **gebaut**.

## Die Trennung

Statt sechs Gestaltungen drei freie Achsen:

* **Charakteristik** — die Form. Wie wird getrennt, wie geordnet, wie gebaut?
  Trennstrich oder Luft oder Flächenwechsel; Zahl als Bruch oder als zwei
  Blöcke; Liste als Zeilen oder als Tabelle. Dazu Radius, Abstände, Größe und
  Gewicht.
* **Palette** — die Farbe. Grund, Text, Nebensächliches, Linien, Akzent und die
  fünf Kategorienfarben.
* **Schrift** — die Familie. Heute gar nicht vorhanden; deshalb die billigste
  der drei, es gibt nichts zu entwirren.

Zusammen mit dem Konzept ergibt das **Konzept × Charakteristik × Palette ×
Schrift**.

Beim letzten Anlauf war eine dritte Achse gescheitert: „Karte, Band, Linie"
(06.–08.09.) lag auf derselben Ebene wie die Gestaltung — Form gegen Form, und
beide stritten um denselben Radius. **Form gegen Farbe gegen Familie schneidet
sauber**, weil die drei nichts gemeinsam haben, worüber sie streiten könnten —
mit vier benannten Ausnahmen, siehe unten.

Der Gewinn ist nicht nur Ordnung, sondern Prüfbarkeit: Bei echter
Orthogonalität testet man **sechs Charakteristika plus sechs Paletten plus die
Schriften**, nicht ihr Produkt.

## Wo heute die Grenze verläuft — und wo sie falsch verläuft

`SphygmaTheme` hat 17 Felder. Die meisten lassen sich eindeutig zuordnen:

| Achse | Felder |
|---|---|
| **Palette** | `surface`, `onSurface`, `muted`, `line`, `accent`, `categoryColors` |
| **Charakteristik** | `radius`, `gapSmall`, `gapLarge`, `headlineSize`, `headlineWeight`, `showDividers` |
| **Schrift** | — nichts. Die Achse ist neu. |

Drei Felder liegen quer, weil sie **Ob** und **Welcher Ton** in einem Wert
vermischen:

| Feld | heute | richtig getrennt |
|---|---|---|
| `panelBorder: Color?` | Farbe *und* die Aussage „hat eine Kante" | Charakteristik: `hatKante: bool` · Palette: welcher Ton |
| `panelShadow: List<BoxShadow>?` | Schattenliste *und* „wirft Schatten" | Charakteristik: `erhebung: double` · Palette: welcher Ton |
| `panelBase` / `panelRaised` | zwei feste Farben | Palette: die Tonleiter · Charakteristik: **ob** sie Flächen nutzt |

Die Regel dahinter, und sie trägt den ganzen Entwurf:

> **Die Charakteristik entscheidet, ob und wie stark. Die Palette entscheidet,
> welcher Ton. Die Schrift entscheidet, in welcher Familie.**

## Die vier Kopplungen, die aufzulösen sind

Ohne diese vier bricht die Trennung leise — die Kombination baut sich, sieht
aber falsch aus. Alle vier sind an den heutigen Werten nachgemessen.

### 1. Aura definiert seine Flächen relativ, alle anderen absolut

Gemessen: Auras `panelBase` ist **weiß mit 4,3 % Deckung**, `panelRaised` 2,4 %,
die Kante 7,1 % — Aufhellungen über dunklem Grund, genau wie der Entwurf sagt
(„4,5 % und 2,5 % Weiß"). Alle anderen tragen deckende Farben: `#ffffff` bei
vier Handschriften, `#e8def8` bei Material 3.

Kombiniert man Auras Form mit einer hellen Palette, ist 4 % Weiß auf Weiß
unsichtbar.

**Auflösung:** Die Palette liefert ihre Flächen **selbst** als fertige Töne —
`grund`, `flaeche`, `flaecheGehoben` —, statt dass die Charakteristik sie
ausrechnet. Eine dunkle Palette hebt nach Weiß auf, eine helle ebenfalls,
Material 3 in seinen Sekundärcontainer. Jede Palette weiß, wie ihre Töne sich
verhalten; die Charakteristik weiß es nicht und muss es nicht wissen.

Die naheliegende Alternative — „Fläche = Grund gemischt mit der Kontrastfarbe"
— wurde verworfen: Sie erklärt Material 3 nicht, dessen Fläche weder heller
noch dunkler, sondern **farbiger** ist als der Grund.

### 2. Messinstrument ist monochrom

Gemessen: Bei Messinstrument gilt `accent == onSurface` — als einzigem der
sechs. Der Entwurf sagt warum: *„Das Einordnungsband ist die einzige Farbe."*

Das ist eine Aussage der **Form**, nicht der Palette. Eine Charakteristik muss
den Akzent ihrer Palette also ablehnen dürfen.

**Auflösung:** `nutztAkzent: bool` an der Charakteristik. Ist er falsch, tritt
die Textfarbe an die Stelle des Akzents — die Kategorienfarben bleiben, denn
sie tragen Bedeutung und sind nie Schmuck.

### 3. Pegel braucht Kategorienfarben, die als Fläche taugen

Gemessen: Pegels Kategorienfarben sind blass (`#d9e5e0`, `#efe1c9`, `#f3e4cb`,
`#e8c9a8`, `#dcb08a`), die der anderen kräftig (`#7ea77e`, `#c9b45e`, `#c07d5a`,
…). Kein Zufall: Bei Pegel färbt die Einordnung die **ganze Kopffläche**, und
darauf muss Text lesbar bleiben. Ein Chip von 60 Pixeln verträgt einen Ton, der
über die halbe Bildschirmbreite unerträglich wird.

**Auflösung:** Jede Palette liefert die fünf Kategorien in **zwei Rollen**:

* `markierung` — kräftig, für Punkte, Chips, Bänder, Rasterzellen
* `flaeche` — blass, für großflächiges Einfärben, mit lesbarem Text darauf

Die Charakteristik greift die Rolle, die ihre Form braucht. Damit ist Pegel
nicht mehr an seine eigene Palette gefesselt.

### 4. Nicht jede Schrift trägt jedes Gewicht

Diese Kopplung entsteht **erst durch die dritte Achse** — bei zwei Achsen gab
es sie nicht.

Die Charakteristiken nennen heute feste Zahlen: 200 für Aura, 300 für
Messinstrument, 400 für Material 3 und Pulse Grid, 500 für Pegel, 700 für
Tagebuch. Eine Familie ohne ExtraLight-Schnitt fällt lautlos auf den nächsten
zurück — und Aura verliert genau das, was es ausmacht.

**Auflösung:** Die Charakteristik nennt eine **Rolle** — leicht, normal,
kräftig — statt einer Zahl. Die Schrift deklariert, welche Schnitte sie
wirklich führt, und bildet die Rolle auf den nächstliegenden ab. Aus einem
stillen Rückfall wird eine bekannte Abbildung.

Das gilt auch für ein Detail, das dem Projekt schon wichtig ist: `today_screen`
setzt Ziffern mit `FontFeature.tabularFigures()`. **Eine Schrift ohne
tabellarische Ziffern lässt Messwerte in Listen springen** — die Achse muss
deklarieren, ob sie sie führt, sonst ist sie für Sphygma unbrauchbar.

## Was daraus folgt: drei Aufzählungen statt einer

### Charakteristika

| Name | Trennung | Kennzeichen |
|---|---|---|
| Messinstrument | Haarlinien | monochrom, Radius 3, leicht, große Zahl |
| Tagebuch | Karten mit Schatten | Radius 18, kräftig, Kennzahlen nebeneinander |
| Material | Karten ohne Schatten | Radius 12, Chips, ein FAB |
| Luft | keine Striche | Flächen mit feiner Kante, sehr leicht |
| Raster | Spalten und Weißraum | SYS/DIA getrennt, Datentabelle, Radius 2 |
| Band | Flächenwechsel | Radius 0, Einordnung färbt die Kopffläche |

### Paletten

| Name | Grund | Text | Akzent | stammt aus |
|---|---|---|---|---|
| Papier | `#faf9f7` | `#1b1b1a` | — (monochrom) | Messinstrument |
| Himmel | `#f2f5fb` | `#182034` | `#4f7fd8` | Tagebuch |
| Flieder | `#fef7ff` | `#1d1b20` | `#6750a4` | Material 3 |
| Nacht | `#14181f` | `#e8ecf2` | `#6c5ce7` | Aura |
| Petrol | `#f5f6f4` | `#171a1c` | `#087f78` | Pulse Grid |
| Salbei | `#eceeeb` | `#16211f` | `#0e5c4c` | Pegel |

**Damit ist die Aura-Frage beantwortet:** Aura zerfällt in beides. Seine Form
lebt als Charakteristik **Luft** weiter, seine Farbwelt als Palette **Nacht**.
Das war bisher eins und musste getrennt werden — der klarste Beleg dafür, dass
die alte Achse zwei Dinge vermengte.

Palette **Papier** hat keinen Akzent, weil Messinstrument monochrom ist. Damit
sie mit anderen Charakteristika taugt, braucht sie einen. Zu entscheiden beim
Bauen, nicht hier.

### Schriften

Noch keine Liste — die Achse ist leer, und die Auswahl ist keine
Geschmacksfrage, sondern hat zwei harte Bedingungen:

* **Lizenz.** Sphygma geht zu F-Droid (`docs/RELEASE.md`); jede eingebettete
  Schrift muss frei sein.
* **Umfang.** Jede Familie in vier Schnitten wiegt in der APK, und der Release
  liefert mit `--split-per-abi` ohnehin schon mehrere Pakete aus.
* **Tabellarische Ziffern**, siehe Kopplung 4.

Eine Möglichkeit bleibt immer: **System** — die Schrift des Telefons, wie
heute. Sie kostet nichts und ist der richtige Standard.

## Die Auswahl

Drei Achsen mal sechs Möglichkeiten sind achtzehn Optionen. Als Radiolisten
untereinander — so steht es heute für Konzept und Gestaltung — wäre das
Einstellungsblatt unlesbar. Je Achse ein Auswahlfeld hält es auf drei Zeilen.

In Material 3 ist das `DropdownMenu<T>` mit `DropdownMenuEntry<T>` (verifiziert
im Flutter-SDK, `packages/flutter/lib/src/material/dropdown_menu.dart`).

**Mit Vorschau darunter.** Wer die Wahl trifft, soll sie sehen, ohne das Blatt
zu verlassen — dieselbe Probe wie in der Tafel, mit einer echten Messung. Das
ist derselbe Grund, aus dem der Gestaltungswechsel am 07.09. sofort
durchschlagen musste: Eine Gestaltungswahl, deren Wirkung man erst nach dem
Zurückgehen sieht, ist keine Wahl, sondern ein Rätsel.

Ob das Konzept dieselbe Bauform bekommt, ist offen: Es hat nur drei Optionen
und einen erklärenden Untertitel je Eintrag, den ein Auswahlfeld nicht zeigt.

## Migration der gespeicherten Wahl

`SettingsRepository` legt heute unter `theme_variant` den Namen der Variante
ab. Nach der Trennung braucht es drei Schlüssel — und der alte Wert darf nicht
verfallen: Wer „Pegel" gewählt hat, soll „Band auf Salbei" wiederfinden, nicht
den Standard.

| gespeichert | wird zu |
|---|---|
| `instrument` | Messinstrument · Papier · System |
| `diary` | Tagebuch · Himmel · System |
| `material` | Material · Flieder · System |
| `aura` | Luft · Nacht · System |
| `pulseGrid` | Raster · Petrol · System |
| `pegel` | Band · Salbei · System |

Die sechs Kombinationen der Diagonale sind damit genau die heutigen sechs
Gestaltungen — **niemand verliert sein Aussehen.** Der alte Schlüssel wird
einmal gelesen, in die drei neuen übersetzt und danach nicht mehr geschrieben.

Kein Schemawechsel nötig: `AppSettings` ist eine Schlüssel-Wert-Tabelle, neue
Schlüssel brauchen keine Migration.

## Prüfbarkeit

Der eigentliche Gewinn. Heute prüft `funktionsraster_test.dart` drei
Gestaltungen; bei über hundert Kombinationen wäre das nicht durchzuhalten.

* **Je Charakteristik einmal**, auf einer festen Palette und Schrift: Sitzt das
  Merkmal? Trennt Messinstrument mit Linien, Luft mit Abstand, Band mit
  Flächen?
* **Je Palette einmal**, auf einer festen Charakteristik: Tragen die Farben?
  Steht Text lesbar auf Grund und Fläche?
* **Je Schrift einmal:** Sind alle Gewichtsrollen abgebildet, sind die Ziffern
  tabellarisch?
* **Die Kreuzung stichprobenartig**, nicht vollständig — mit vier Ausnahmen.
  Die aufgelösten Kopplungen bekommen je einen eigenen Test, weil genau sie
  beim Kreuzen brechen würden:
  * Luft auf **heller** Palette: Flächen müssen sichtbar bleiben
  * Papier mit einer Charakteristik, die den Akzent nutzt
  * Band mit **jeder** Palette: Text auf der eingefärbten Kopffläche lesbar
  * Eine Charakteristik mit Rolle „sehr leicht" auf einer Schrift ohne
    ExtraLight: Die Abbildung muss greifen, nicht der stille Rückfall

Der bestehende Radius-Test (`alle Flächen tragen den Radius der Gestaltung`)
wandert zur Charakteristik, wo er hingehört — er prüft Form, nicht Farbe.

## Offene Punkte

* **Reihenfolge des Bauens.** Die Trennung ist die eine Hälfte, die fehlenden
  Struktur-Merkmale (FAB, Chips, Datentabelle, SYS/DIA-Blöcke, eingefärbte
  Kopffläche) die andere. Die Trennung ohne die Merkmale ändert am Eindruck
  **nichts** — die vier sähen weiter gleich aus, nur wären sie jetzt
  Kombinationen statt Gestaltungen. Deshalb: erst die Merkmale, oder beides
  zusammen. Die Trennung allein wäre Aufwand ohne sichtbares Ergebnis.
* **Wie ein Bildschirm sein Merkmal erfährt.** Heute kennt kein Bildschirm die
  Gestaltung, und das war Absicht. Zwei Wege: Der Bildschirm fragt die
  Charakteristik ab (einfach, aber jeder Bildschirm bekommt Verzweigungen), oder
  die Charakteristik liefert **Bausteine** statt Werte (aufwendiger, hält die
  Bildschirme frei). Der zweite Weg passt zu dem, was `SurfacePanel` schon tut.
  Zu entscheiden, bevor gebaut wird.
* **Ob sechs Paletten nötig sind.** Sechs Charakteristika sind begründet — jede
  trägt ein eigenes Merkmal. Bei den Paletten ist das offen: Papier, Petrol und
  Salbei liegen dicht beieinander. Drei bis vier könnten genügen.
* **Welche Schriften**, unter welcher Lizenz, zu welchem Preis in Megabyte.
