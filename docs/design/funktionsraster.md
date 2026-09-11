# Funktionsraster der gemeinsamen Messungsoberfläche

Stand 11.09.2026. Heute und Verlauf sind die gemeinsame Oberfläche. Die frühere
Konzeptwahl und der Messanlassprozess entfallen; die historischen Entwürfe stehen
in [Umsetzung der Konzepte](umsetzung-konzepte.md).

| Funktion | Ort und Verhalten |
|---|---|
| Heutige Messungen | Heute: getrennte Blutdruck-/Pulsbereiche, heutige Morgen-/Abendmittel mit Anzahl und Zeitspanne; Tagesliste und Einzelmessungsdetails |
| Wochenraster / letzte Tage | Heute; beide Abschnitte unabhängig abschaltbar |
| Zeitraum und Auswertung | Verlauf: dieselbe Auswahl für Liste, Kurve und Kennzahlen |
| Tags / Bemerkungen | Messungsdetail; mehrere Tags frei anlegbar, Freitext pro Messung |
| Phasen | Optional in Einstellungen; Verwaltung im Verlauf, mehrere passende Phasen und manuelle Ausnahmen |
| Metadatenfilter | Verlauf: Tags und Phasen mit beliebiger/allen gewählten Zuordnungen; ohne Zuordnung auswählbar |
| Kurven | Blutdruck und Puls mit zeitproportionaler Achse und öffnbaren Einzelmessungen |
| Zeitplausibilität | Hinweise bleiben sichtbar; zweifelhafte Zeiten werden nicht unbemerkt als sichere Kurvenpunkte verwendet |
| Einordnung | Gemeinsame Messungsdarstellung; ESC-Klassifikation bleibt konfigurationsabhängig |
| Pairing und Speicherplatz | Einstellungen; getrennte Bestände für Speicherplatz 1 und 2 |
| Manueller / automatischer Abgleich | Einstellungen; Autosync standardmäßig aus, letzter erfolgreicher Abgleich dort sichtbar |
| Health Connect | Einzel- und Gesamtexport sowie Rückzug; Fehler und Exportzustand bleiben unterscheidbar |
| Messplan | Optionaler Reiter und Heute-Karte; feste tägliche Zeiten bis zum Beenden |
| Erinnerungen | Nur bei aktivierter Planfunktion; exakt wenn verfügbar, andernfalls ungenau mit sichtbarem Status |
| Gestaltung | Charakteristik, Palette und Schrift unabhängig; gemeinsame Funktionen in jeder Form |

## Grenzen

Kein Anlassprozess, eigener Phasenvergleich, Berichtsexport, eigener Backupimport,
Zeitoffset, Snooze oder weitere Erinnerungsart. Die Zuordnungstoleranz von ±15 Minuten
ist keine Zusage über die Android-Zustellzeit.

Aktuelle Software- und Hardwareprüfung: [Umsetzungsreview](../reviews/2026-09-11-messplan-umsetzung.md).
