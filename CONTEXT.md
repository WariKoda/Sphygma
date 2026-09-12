# Sphygma

Sphygma verwaltet lokale Blutdruckmessungen aus zwei Gerätespeicherplätzen.
Messwerte und ergänzende Nutzerentscheidungen bleiben getrennt.

## Language

**Measurement** (Messung): Ein unveränderter Gerätedatensatz mit Blutdruck, Puls
und Gerätezeit, identifiziert durch Speicherplatz und Gerätenummer.
_Avoid_: Messanlass, Sitzung

**DeviceCivilTime** (Gerätezeit): Kalenderangaben aus den Rohbytes ohne bekannte
Zeitzone. Sie werden für Terminzuordnungen ohne Sommerzeitnormalisierung verglichen;
ein Vergleichsbehälter in UTC behauptet keinen tatsächlichen UTC-Messzeitpunkt.

**UserSlot** (Speicherplatz): Einer der beiden getrennten Messungsspeicher des Omron.
Tags, Phasen und Messpläne gelten jeweils für einen Speicherplatz.

**Tag**: Frei anlegbares Schlagwort an einer oder mehreren Messungen. Eine Messung
kann beliebig mehrere vorhandene Tags erhalten.

**MeasurementNote** (Bemerkung): Freitext zu genau einer Messung; kein Gerätewert.

**ScopedPhase** (Phase): Benannter Zeitraum eines Speicherplatzes. Überlappende
Zeiträume können gleichzeitig gelten; eine manuelle Auswahl ersetzt für eine
Messung die gesamte automatische Auswahl, auch durch eine leere Menge.
_Avoid_: Konzept, Anlass

**MeasurementPlan** (Messplan): Feste täglich wiederkehrende Messzeiten eines
Speicherplatzes, gültig bis zum Beenden. Änderungen betreffen zukünftige Termine.
_Avoid_: befristeter Messauftrag

**PlannedOccurrence** (Termin): Ein einzelner Messzeitpunkt aus einer Planrevision.
Ein Termin kann höchstens einer echten Messung zugeordnet werden.

**Fulfillment** (Erfüllung): Zuordnung einer Messung zu einem Termin, automatisch
innerhalb von ±15 Minuten oder ausdrücklich manuell. Kein ersatzweises Abhaken.

**Sync** (Abgleich): Auslesen des Messgeräts in die lokale Datenbank.
_Avoid_: Health-Connect-Export

**Export**: Übertragung lokaler Messwerte nach Health Connect; unabhängig vom
Importresultat und ohne Tags, Bemerkungen oder Plandaten.
