# Heute — Originalnah

**Freigegebener Entwurf:** `docs/design/heute-omron-2026-09-11/`, Variante01, vom Nutzer ausgewählt und zur Umsetzung beauftragt.

**Ziel:** Zwei getrennte Messgrößenbereiche mit letztem Wert, ehrlicher Zeitangabe,
heutigen Morgen-/Abendmitteln und Bestandsanzahl. Alle sechs Formen bleiben erhalten.

**Architektur:** Gemeinsame Blutdruck-Zahlendarstellung aus ReadingHeadline extrahieren;
TodayVitals nutzt bestehende ReadingPanel/SurfacePanel/Theme-Bausteine. TodayScreen
bindet Tageswechsel, Einzelmessungsdetails und Tagesliste an. Keine DB-/Syncänderung.

- [x] Widgettests für zwei Bereiche, Tagesmittel, fehlende Zeitbänder, sechs Formen,
  große Systemschrift und ESC-Verhalten rot/grün ausführen.
- [x] BloodPressureValue wiederverwendbar machen; TodayVitals implementieren.
- [x] TodayScreen umstellen; überflüssige Tagesmittelkarte ersetzen, Hinweise,
  optionalen Plan, Wochenraster und letzte Messungen erhalten.
- [x] Tagesliste und Detailnavigation mit echten Datensätzen prüfen; Mitternacht
  und vorhandene Tests abgleichen.
- [x] Analyse, vollständige Tests ohne/mit ESC und unabhängiges Review.
- [x] Freigegebene Umsetzung und Prüfnachweise dokumentieren.

Morgen/Abend folgen zunächst der vorhandenen Grenze12:00. Mittelwerte beziehen sich
auf den aktuellen lokalen Kalendertag und den gewählten Speicherplatz. Fehlende
Messungen bleiben ausdrücklich leer; es werden keine Pflichtmessungen behauptet.
Die letzte Messung kann von einem früheren Tag stammen und wird entsprechend datiert.
APK-Build und Installation sind nicht Teil dieser Oberflächenänderung.

Prüfnachweis: [Umsetzungsreview](../../reviews/2026-09-11-heute-originalnah.md).
