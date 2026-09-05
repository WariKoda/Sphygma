# Verbindlicher Beispieldatensatz

Stand 2026-09-05. **Alle Entwurfstafeln zeigen diese Zahlen und keine anderen.**

Bis hierher hat sich jede Tafel eigene Beispielwerte ausgedacht. Dieselbe
Gerätenummer stand in drei Dateien für drei verschiedene Messungen, Nummern
widersprachen ihren Zeitstempeln, Balkenlängen passten nicht zu den Werten
daneben. Dieser Datensatz behebt das an der Wurzel.

Erzeugt von `beispieldaten.py` (Zufallsstartwert 4711). Das Skript prüft seine
Eckwerte selbst und bricht ab, statt stillschweigend zu wenige Messungen zu
liefern. Wer Zahlen ändert, führt es neu aus und zieht die Tafeln nach.

## Eckwerte

| Größe | Wert |
|---|---|
| Messungen gesamt | **114** |
| Gerätenummern | **429 bis 542**, lückenlos, monoton steigend |
| Letzte Messung | **Nr. 542 · 05.09.2026, 23:57 · 128/87 · Puls 82** |
| Vorletzte, derselbe Anlass | Nr. 541 · 05.09.2026, 23:55 · 123/87 · Puls 81 |
| Mittel der letzten 7 Tage | **124/85** · Puls 81 · aus 18 Messungen |
| Mittel der letzten 30 Tage | 127/84 · Puls 81 · 59 Messungen |
| Mittel der letzten 3 Monate | 130/86 · Puls 82 · 111 Messungen |
| Nach Health Connect übertragen | **14** (die ältesten) |
| Noch offen | **100** |
| Mit Bewegungskennzeichen | 10 |
| Mit Arrhythmiekennzeichen | 5 |
| Speicherplatz | Benutzer 1 |

## Gerechnete Größen je Konzept

Aus dem Datensatz **gerechnet**, nicht geschätzt. Wer sie in einer Tafel nennt,
nennt sie so.

| Konzept | Größe | Wert |
|---|---|---|
| Messanlass | Anlässe gesamt | **89** aus 114 Rohmessungen |
| Messanlass | mit zwei Messungen | 23 |
| Messanlass | mit einer | 65 |
| Sieben Tage | Kalenderwochen mit Messungen | 9 |
| Sieben Tage | davon vollständig (14 von 14) | **3** |
| Tagesprofil | vormittags, vor 12 Uhr | 51 · **135/89** · Puls 82 |
| Tagesprofil | abends, ab 18 Uhr | 60 · **126/84** · Puls 82 |
| Tagesprofil | Unterschied morgens zu abends | **9.5 mmHg** systolisch |
| Tagesprofil | Uhrzeit zwischen 23 und 6 Uhr | 0 — der Bestand hat keine |
| Phase | „Ohne Medikament" 12.05.–09.08. | 53 Messungen · **134/89** |
| Phase | „Ramipril 5 mg" ab 10.08. | 58 Messungen · **127/84** |
| Phase | Unterschied zwischen den Phasen | **7 mmHg** systolisch |
| Phase | keiner Phase zuzuordnen | 3 (die falsch datierten) |

## Die Messwochen

| Woche | Felder | Messungen | Mittel |
|---|---|---|---|
| 31.08.–06.09.2026 | 10/14 | 16 | 124/85 |
| 24.08.–30.08.2026 | 14/14 | 14 | 130/84 |
| 17.08.–23.08.2026 | 14/14 | 14 | 128/83 |
| 10.08.–16.08.2026 | 14/14 | 14 | 128/84 |
| 03.08.–09.08.2026 | 9/14 | 15 | 134/89 |
| 27.07.–02.08.2026 | 9/14 | 12 | 130/89 |
| 20.07.–26.07.2026 | 9/14 | 13 | 135/89 |
| 13.07.–19.07.2026 | 6/14 | 9 | 135/89 |
| 06.07.–12.07.2026 | 3/14 | 4 | 136/90 |

Drei Wochen sind vollständig — sie taugen für die Praxis. Die übrigen zeigen
Lücken, und die laufende Woche ist noch offen.

## Die falsch datierten Messungen

Drei Messungen tragen das Datum **18.04.2023**, obwohl ihre Gerätenummern
unmittelbar vor dem letzten Anlass liegen. Das Gerät stand auf einer falschen
Uhr: Die Nummer beweist, wann gemessen wurde, das Datum lügt.

| Nr. | Datum laut Gerät | Wert |
|---|---|---|
| 538 | 18.04.2023, 11:02 | 133/91 · Puls 78 |
| 539 | 18.04.2023, 11:05 | 129/88 · Puls 81 |
| 540 | 18.04.2023, 11:08 | 136/92 · Puls 75 |

**Sphygma korrigiert diese Zeitstempel nicht.** Sie stehen so in der Datenbank,
wie das Gerät sie geliefert hat. Die App stellt die Abweichung beim Abgleich
fest und weist darauf hin; gestellt wird die Uhr am Gerät, von Hand. Ein
verschobener Zeitstempel wäre schlimmer als ein erkennbar falscher.

## Alle 114 Messungen

| Nr. | Zeitpunkt laut Gerät | mmHg | Puls | übertragen | Kennzeichen |
|---|---|---|---|---|---|
| 429 | 11.07.2026 20:37 | 129/86 | 87 | ja |  |
| 430 | 12.07.2026 07:13 | 144/92 | 89 | ja | Bewegung |
| 431 | 12.07.2026 07:15 | 140/91 | 80 | ja |  |
| 432 | 12.07.2026 20:19 | 132/89 | 82 | ja |  |
| 433 | 13.07.2026 20:37 | 128/87 | 88 | ja |  |
| 434 | 13.07.2026 20:39 | 127/87 | 83 | ja |  |
| 435 | 15.07.2026 07:05 | 146/93 | 81 | ja |  |
| 436 | 17.07.2026 07:04 | 137/94 | 82 | ja | unregelm. Puls |
| 437 | 17.07.2026 07:06 | 143/89 | 82 | ja |  |
| 438 | 17.07.2026 20:45 | 134/88 | 82 | ja |  |
| 439 | 17.07.2026 20:47 | 128/83 | 85 | ja |  |
| 440 | 19.07.2026 07:12 | 137/93 | 80 | ja |  |
| 441 | 19.07.2026 20:10 | 132/84 | 88 | ja |  |
| 442 | 20.07.2026 20:44 | 134/86 | 80 | ja |  |
| 443 | 21.07.2026 07:31 | 141/90 | 89 | — |  |
| 444 | 21.07.2026 07:33 | 136/94 | 83 | — |  |
| 445 | 21.07.2026 20:12 | 126/88 | 88 | — |  |
| 446 | 22.07.2026 07:06 | 137/89 | 79 | — |  |
| 447 | 22.07.2026 07:08 | 137/94 | 89 | — | Bewegung |
| 448 | 22.07.2026 20:35 | 131/87 | 84 | — |  |
| 449 | 24.07.2026 07:10 | 138/94 | 84 | — |  |
| 450 | 24.07.2026 20:41 | 135/86 | 83 | — |  |
| 451 | 24.07.2026 20:43 | 128/84 | 85 | — |  |
| 452 | 25.07.2026 07:03 | 136/89 | 86 | — |  |
| 453 | 25.07.2026 07:05 | 140/93 | 86 | — |  |
| 454 | 25.07.2026 20:34 | 134/89 | 85 | — |  |
| 455 | 27.07.2026 20:37 | 129/84 | 80 | — |  |
| 456 | 27.07.2026 20:39 | 133/89 | 79 | — |  |
| 457 | 28.07.2026 07:31 | 136/90 | 81 | — |  |
| 458 | 28.07.2026 20:22 | 126/89 | 83 | — |  |
| 459 | 30.07.2026 20:38 | 125/90 | 89 | — |  |
| 460 | 30.07.2026 20:40 | 128/83 | 88 | — |  |
| 461 | 31.07.2026 20:40 | 127/88 | 80 | — | Bewegung |
| 462 | 31.07.2026 20:42 | 125/83 | 85 | — |  |
| 463 | 01.08.2026 07:43 | 139/95 | 81 | — |  |
| 464 | 01.08.2026 20:43 | 128/90 | 89 | — |  |
| 465 | 02.08.2026 07:21 | 138/95 | 84 | — |  |
| 466 | 02.08.2026 20:33 | 132/90 | 86 | — | Bewegung |
| 467 | 03.08.2026 07:20 | 143/93 | 81 | — |  |
| 468 | 03.08.2026 07:22 | 135/89 | 89 | — |  |
| 469 | 03.08.2026 20:40 | 129/84 | 83 | — |  |
| 470 | 03.08.2026 20:42 | 124/86 | 86 | — |  |
| 471 | 04.08.2026 07:21 | 141/89 | 80 | — |  |
| 472 | 04.08.2026 07:23 | 134/93 | 84 | — | Bewegung |
| 473 | 04.08.2026 20:06 | 129/85 | 80 | — |  |
| 474 | 05.08.2026 07:30 | 136/94 | 80 | — |  |
| 475 | 05.08.2026 20:14 | 128/90 | 82 | — | Bewegung |
| 476 | 05.08.2026 20:16 | 129/83 | 81 | — |  |
| 477 | 06.08.2026 07:16 | 141/89 | 86 | — |  |
| 478 | 06.08.2026 07:18 | 142/88 | 89 | — |  |
| 479 | 06.08.2026 20:04 | 131/86 | 87 | — |  |
| 480 | 06.08.2026 20:06 | 133/87 | 87 | — |  |
| 481 | 07.08.2026 07:31 | 141/94 | 80 | — |  |
| 482 | 10.08.2026 07:20 | 132/84 | 83 | — |  |
| 483 | 10.08.2026 20:06 | 122/80 | 78 | — |  |
| 484 | 11.08.2026 07:25 | 131/85 | 84 | — |  |
| 485 | 11.08.2026 20:04 | 123/80 | 80 | — |  |
| 486 | 12.08.2026 07:36 | 132/89 | 86 | — |  |
| 487 | 12.08.2026 20:45 | 128/81 | 81 | — |  |
| 488 | 13.08.2026 07:05 | 131/89 | 77 | — |  |
| 489 | 13.08.2026 20:26 | 123/80 | 77 | — |  |
| 490 | 14.08.2026 07:07 | 135/85 | 78 | — |  |
| 491 | 14.08.2026 20:42 | 125/83 | 83 | — |  |
| 492 | 15.08.2026 07:32 | 135/85 | 81 | — |  |
| 493 | 15.08.2026 20:45 | 120/83 | 82 | — |  |
| 494 | 16.08.2026 07:24 | 135/88 | 78 | — |  |
| 495 | 16.08.2026 20:04 | 121/80 | 86 | — |  |
| 496 | 17.08.2026 07:45 | 129/86 | 76 | — |  |
| 497 | 17.08.2026 20:16 | 123/79 | 76 | — |  |
| 498 | 18.08.2026 07:17 | 129/83 | 86 | — |  |
| 499 | 18.08.2026 20:01 | 127/79 | 76 | — |  |
| 500 | 19.08.2026 07:08 | 129/86 | 82 | — |  |
| 501 | 19.08.2026 20:03 | 119/81 | 79 | — |  |
| 502 | 20.08.2026 07:20 | 135/86 | 83 | — |  |
| 503 | 20.08.2026 20:22 | 128/84 | 77 | — | Bewegung |
| 504 | 21.08.2026 07:09 | 136/85 | 84 | — |  |
| 505 | 21.08.2026 20:10 | 128/78 | 86 | — |  |
| 506 | 22.08.2026 07:06 | 131/89 | 77 | — |  |
| 507 | 22.08.2026 20:01 | 124/83 | 82 | — |  |
| 508 | 23.08.2026 07:20 | 131/87 | 76 | — |  |
| 509 | 23.08.2026 20:06 | 118/78 | 83 | — | unregelm. Puls |
| 510 | 24.08.2026 07:06 | 130/84 | 78 | — | Bewegung |
| 511 | 24.08.2026 20:13 | 119/83 | 77 | — | Bewegung |
| 512 | 25.08.2026 07:00 | 137/88 | 85 | — |  |
| 513 | 25.08.2026 20:01 | 124/79 | 84 | — |  |
| 514 | 26.08.2026 07:15 | 137/86 | 76 | — |  |
| 515 | 26.08.2026 20:22 | 128/79 | 78 | — |  |
| 516 | 27.08.2026 07:11 | 133/89 | 77 | — | unregelm. Puls |
| 517 | 27.08.2026 20:22 | 125/79 | 78 | — |  |
| 518 | 28.08.2026 07:10 | 136/86 | 85 | — | Bewegung |
| 519 | 28.08.2026 20:03 | 127/82 | 79 | — |  |
| 520 | 29.08.2026 07:42 | 138/86 | 86 | — |  |
| 521 | 29.08.2026 20:39 | 125/79 | 83 | — |  |
| 522 | 30.08.2026 07:19 | 134/87 | 83 | — |  |
| 523 | 30.08.2026 20:26 | 120/86 | 80 | — |  |
| 524 | 31.08.2026 07:27 | 131/88 | 81 | — |  |
| 525 | 31.08.2026 07:29 | 130/85 | 80 | — |  |
| 526 | 31.08.2026 20:45 | 115/82 | 79 | — | unregelm. Puls |
| 527 | 31.08.2026 20:47 | 121/81 | 84 | — |  |
| 528 | 01.09.2026 07:26 | 128/92 | 80 | — |  |
| 529 | 01.09.2026 07:28 | 126/86 | 85 | — |  |
| 530 | 01.09.2026 20:40 | 115/84 | 82 | — |  |
| 531 | 01.09.2026 20:42 | 114/85 | 77 | — |  |
| 532 | 02.09.2026 07:33 | 131/85 | 81 | — |  |
| 533 | 02.09.2026 20:17 | 121/80 | 84 | — |  |
| 534 | 03.09.2026 07:41 | 128/89 | 77 | — |  |
| 535 | 03.09.2026 20:21 | 124/81 | 84 | — |  |
| 536 | 04.09.2026 20:43 | 123/82 | 77 | — |  |
| 537 | 04.09.2026 20:45 | 120/83 | 82 | — |  |
| 538 | 18.04.2023 11:02 | 133/91 | 78 | — | **Gerätezeit fraglich** |
| 539 | 18.04.2023 11:05 | 129/88 | 81 | — | **Gerätezeit fraglich** |
| 540 | 18.04.2023 11:08 | 136/92 | 75 | — | unregelm. Puls, **Gerätezeit fraglich** |
| 541 | 05.09.2026 23:55 | 123/87 | 81 | — |  |
| 542 | 05.09.2026 23:57 | 128/87 | 82 | — |  |
