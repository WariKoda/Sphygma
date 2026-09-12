# Heute — vier Entwürfe nach der Omron-Vorlage

Entwurfsstand 11.09.2026. Nur visuelle Vorschläge; die installierte App bleibt unverändert.

Entwurf **01 Originalnah** wurde zur Umsetzung freigegeben. Die Flutter-Umsetzung
folgt dem [Implementierungsplan](../../superpowers/plans/2026-09-11-heute-originalnah.md).
Die Galerie bleibt als Entwurfsvergleich erhalten.

## Ansehen

[index.html](index.html) direkt im Browser öffnen. Oben zwischen den vier Richtungen
wechseln; darunter alle sechs Formen groß vergleichen oder eine Form auswählen.
„Groß öffnen“ zeigt eine einzelne Ansicht. Palette, Wochenraster und letzte Tage sind
unabhängig umschaltbar. Entwurf4 besitzt einen funktionierenden Blutdruck-/Pulsschalter;
Messungslinks öffnen eine Vorschau. Weitere App-Aktionen sind nicht implementiert.

| Entwurf | Aufbau | PDF mit sechs Einzelseiten |
|---|---|---|
| 01 Originalnah | Blutdruck und Puls getrennt, Morgen-/Abendmittel innerhalb beider Bereiche | [A3-PDF](a-entwurf.pdf) |
| 02 Tagesvergleich | Je ein großer Morgen- und Abendbereich mit SYS, DIA und Puls | [A3-PDF](b-entwurf.pdf) |
| 03 Einzelmessungen | Vier große Messungszeilen, jeweils eigene Pulsspalte | [A3-PDF](c-entwurf.pdf) |
| 04 Kurve & Werte | Zwei Messgrößenfelder, zeitproportionale Kurve, Tagesmittel | [A3-PDF](d-entwurf.pdf) |

Jedes PDF enthält genau eine Form pro Seite: Messinstrument, Tagebuch, Material,
Luft, Raster und Band. Daneben liegen 24 hochauflösende PNGs, benannt nach
Entwurfsbuchstabe und Form. Die HTML-Galerie funktioniert lokal ohne Server oder
externe Schrift-/Skriptaufrufe. Sie benötigt die mitgelieferten JS/CSS-Dateien und
die bestehenden Schriftdateien unter `assets/fonts`.

## Gemeinsame Grundlage

- Referenz: die beiden vom Nutzer genannten Omron-Screenshots vom 05.09.2026.
- Demotag 01.09.2026: Messungen528–531 aus `../beispieldaten.json`.
- Letzte Messung114/85, Puls77 um20:42. Morgenmittel127/89, Puls83;
  Abendmittel115/85, Puls80; Tagesmittel121/87, Puls81. Mittelwerte werden aus den
  vier Datensätzen gerechnet und kaufmännisch auf ganze Zahlen gerundet.
- „2 Messungen“ ist eine Bestandsanzahl, keine Planvorgabe. Es werden keine
  Omron-Erfüllungshäkchen oder fremde Pflichtmessungen übernommen.
- Wochenraster und letzte Tage sind zunächst ausgeblendet, unabhängig zuschaltbar.
  Das optionale Wochenraster erprobt systolische Tagesmittel und ist ausdrücklich
  eine alternative Darstellung zum vorhandenen Morgen-/Abendraster.
- In diesen Vorschauen ist kein Messplan aktiviert. Metadaten sind als Beispiele
  erkennbar; keine privaten Messdaten vom Handy wurden verwendet.
- Alle Formen beginnen mit Papier und derselben Schrift. Die Farbwahl verändert
  nicht die Form. Band färbt ausschließlich den Blutdruckbereich nach Einordnung,
  Puls bleibt neutral. ESC-Einordnung entspricht für diese Beispieldaten der App;
  die Skala setzt den Zeiger wie `ClassificationScale` in die Mitte der Kategorie.

## Empfehlung und Abwägung

**01 Originalnah** trifft die genannte Omron-Startseite am unmittelbarsten: zwei
klar getrennte Messgrößen, große letzte Werte, Mittelwerte direkt zugeordnet.
02 eignet sich für den Tagesvergleich. 03 zeigt jede Messung ohne Umweg, braucht
mehr Scrollfläche. 04 vereint Zahlen und Verlauf, ist dadurch informationsreicher.
Auf schmalen Bildschirmen stehen Mittelwertfelder untereinander; Lesbarkeit geht
vor einem erzwungenen Zweispaltenraster.

## Prüfung

Im lokalen Chrome gerendert: 24 Ansichten, sechs Formen je Entwurf, keine
JavaScript-Fehler oder horizontalen Inhaltsüberläufe bei375px. Form-/Palettenwahl,
beide optionalen Abschnitte, Großansicht, Pulskurve und Messungsdetail geprüft.
Vier PDFs mit je sechs A3-Seiten; PNGs mit doppelter Pixeldichte. Referenzbilder und
repräsentative gerenderte Ansichten visuell geprüft. Keine Flutter-/APK-Änderungen.
