# UX-Gutachten: zwei unabhängige Blicke, geprüft

Stand 2026-09-05. Zwei Gutachten aus anderen Modellhäusern zum Entwurf in
`handschriften.html` und `docs/superpowers/specs/2026-09-05-app-neuentwurf-design.md`:

* **Gemini 3.1 Pro** (`agy`) — Informationsarchitektur, grundsätzlich
* **Codex** — sechs Nutzungsabläufe Schritt für Schritt

Jede Behauptung ist hier gegen den Code geprüft. Was nicht stimmt, steht mit
Gegenbeleg dabei.

---

## Was nicht stimmt

### „Die neu importierte Messung verschwindet in der Historie"

**Beide Gutachter, unabhängig voneinander — und beide falsch.**

Die Annahme: Bei einer Geräteuhr, die 2023 zeigt, landet eine heute gemessene
Messung mehrere Jahre zurück in der Liste; „Heute" zeigt weiter den alten Wert.

Der Code sortiert aber nicht nach Datum:

```dart
// measurement_repository.dart:82
..orderBy([(m) => OrderingTerm.asc(m.deviceSequence)]);
// app_controller.dart:283
measurements = (await repository.allForSlot(slot)).reversed.toList();
```

`measurements.first` ist damit die Messung mit der **höchsten Gerätenummer**,
also die tatsächlich neueste — unabhängig vom Zeitstempel. „Heute" zeigt sie.
Auch `_clockLooksWrong` greift aus demselben Grund korrekt: Es prüft genau
diese Messung.

**Was aber stimmt, und niemand gesehen hat:** Der Verlauf filtert sehr wohl
nach Datum (`filterByPeriod`, `period.dart:26`). Eine heute gemessene, auf 2023
datierte Messung steht also auf „Heute" ganz oben und fehlt gleichzeitig im
Verlauf der letzten Woche — samt Mittelwerten. **Diese Inkonsistenz ist echt**
und wiegt schwerer als das behauptete Verschwinden.

### „114 Messungen auf einem Speicherplatz sind unmöglich, ein Platz hält 100"

Codex, halb richtig. Das Gerät hält 100 Records je Slot
(`hem-6232t.md` §Kennzahlen). Die **Datenbank** akkumuliert aber über die Zeit:
Das Gerät überschreibt seine ältesten Einträge, die App behält sie. 114 in der
DB bei 100 auf dem Gerät ist deshalb der Normalfall, kein Widerspruch.

### „Die Kopplungsanleitung kommt in keinem Entwurf vor"

Codex, trifft die Entwurfstafel, nicht den Code. `device_screen.dart` zeigt
bereits: „Zum Koppeln die Bluetooth-Taste am Gerät lange drücken, bis ‚-P-'
blinkt." Nur meine Zeichnung hat es weggelassen.

---

## Was stimmt und mich trifft

### Die Gestaltungsvarianten unterscheiden sich in der Funktion, nicht nur im Aussehen

Codex, und der Befund ist richtig. In meiner Entwurfstafel hat allein Material 3
den Knopf „Alle Messungen ansehen"; „Messinstrument" zeigt in der Fußzeile
Bestandszahlen, wo „Tagebuch" einen Wochenschnitt zeigt. Das sind
Funktionsunterschiede. Eine Handschrift darf Layout und Gewichtung ändern —
niemals, welche Aktionen es gibt.

**Folge:** Die Tafel muss korrigiert werden, bevor sie Umsetzungsgrundlage wird.

### „Woche / Monat / Jahr / Alles" kann „letzte drei Monate" nicht ausdrücken

Codex. Verifiziert in `period.dart:5` — genau diese vier Werte. Für den
Arztbericht ist das der wahrscheinlichste Zeitraum überhaupt, und er fehlt.

### Der Verlauf startet auf „Woche" und ist nach einer Messpause leer

Codex. `Period.week` ist der Standard (`app_controller.dart:60`). Bei acht
Wochen Pause zeigt der Verlauf leere Kurve und leere Mittelwerte, obwohl 114
Messungen daliegen. Der leere Zustand nennt heute keinen Grund.

### Ein einzelner Blutdruckwert trägt die Hauptaussage nicht

Gemini, und es deckt sich mit dem, was mir beim Entwurf schon unwohl war. Ein
Einzelwert ist medizinisch fast bedeutungslos; der Wochenschnitt beantwortet
die Frage „wie steht es um meinen Blutdruck" wirklich. Trotzdem steht der
Einzelwert in 58 px im Zentrum, der Schnitt klein daneben oder gar nicht.

### „Wartet auf Messungen" mit grünem Punkt kann „alles aktuell" bedeuten

Codex. Technische Bereitschaft und Datenaktualität sind zwei Aussagen; der
Entwurf zeigt nur die erste, und sie beruhigt über die zweite hinweg.

### Das ESC-Flag schützt nicht, was es schützen soll

Gemini nennt es ein Feigenblatt. Der Befund trifft, ist aber im Projekt bereits
offen notiert: `docs/RELEASE.md` §2 hält fest, dass Release-Builds das Flag
**immer** setzen und „das MDR-Risiko aus PLAN.md §3.2 damit bestehen bleibt".
Es ist also eine bewusste, dokumentierte Entscheidung — kein Versehen. Was
Gemini ergänzt: Das Flag verdoppelt trotzdem die Testpfade, ohne etwas zu
tragen.

---

## Was Nutzerentscheidung ist, nicht Befund

Diese Punkte widersprechen ausdrücklichen Festlegungen. Sie stehen hier, damit
sie bewusst bestätigt oder verworfen werden — nicht, weil sie Fehler wären.

| Gutachten sagt | Festgelegt ist |
|---|---|
| „Gerät" verschwendet ein Drittel der Navigationsleiste, gehört ins Überlaufmenü | „die technik darf gerne ihren eigenen bereich haben" |
| Die drei Handschriften sind Überentwicklung — eine wählen, zwei wegwerfen | ausdrücklich alle drei, umschaltbar |
| Beim Import automatisch die Telefonzeit setzen, wenn die Geräteuhr falsch geht | „Datumskorrektur kann weg", DB bleibt Abbild des Geräts |
| ESC-Klassifikation ganz entfernen oder ganz hineinnehmen | hinter Compile-Time-Flag, Release setzt es |

Zur Zeitkorrektur ein Zusatz: Gemini meint nicht die abgelehnte
Korrekturmaske für den Nutzer, sondern eine automatische Zuweisung der
Telefonzeit beim Import. Das ist eine andere Frage als die entschiedene — und
sie hängt an der oben belegten Inkonsistenz zwischen „Heute" und Verlauf.

---

## Unbelegt weitergereicht

Codex nennt zu Abschnitt E medizinische Schwellen (180/120 als Grenze zur
hypertensiven Krise) und verweist auf American Heart Association und Deutsche
Hochdruckliga. **Diese Quellen sind hier nicht geprüft.** Bevor eine solche
Schwelle oder ein Handlungshinweis in die App kommt, gehört sie gegen die
Primärquelle verifiziert — und die MDR-Frage neu gestellt, weil ein
Handlungshinweis das Medizinprodukt-Risiko erhöht, nicht senkt.
