# Android-Erinnerungen: aktueller Entwurf und Grenzen

Stand 11.09.2026. Ersetzt die Untersuchung vom 08.09.2026 und deren unzutreffende
Viertelstundenzusage. Implementierung: `lib/plan/` und
`android/app/src/main/kotlin/de/bdgraue/sphygma/reminders/`.

## Verifizierte Android-Grundlagen

`setExactAndAllowWhileIdle()` wird bei verfügbarem Sonderzugriff genutzt,
ansonsten `setAndAllowWhileIdle()`. Auf neueren Android-Versionen ist der Zugriff
über `canScheduleExactAlarms()` zu prüfen. Sphygma deklariert
`SCHEDULE_EXACT_ALARM`, nicht `USE_EXACT_ALARM`.

Ungenaue Alarme haben **keine garantierte Abweichung von höchstens 15 Minuten**.
Die Android-Dokumentation nennt auf Android12+ bis zu eine Stunde ohne zusätzliche
Energiesparbeschränkungen; mit Doze oder Batteriesparen gelten weitere Grenzen.
Auch exakte Alarme sind keine Zusage sekundengenauer Zustellung.

Beim Entzug des Sonderzugriffs stoppt Android die App und löscht zukünftige exakte
Alarme. Der Berechtigungsbroadcast betrifft die Erteilung; deshalb prüft Sphygma
beim Wiederöffnen erneut. Bis dahin kann nach Entzug eine Erinnerung ausfallen.
Diese Aussagen wurden anhand der [offiziellen Alarmdokumentation](https://developer.android.com/develop/background-work/services/alarms)
erneut geprüft. Benachrichtigungsrecht und Kanalblockade werden separat behandelt.

## Sphygmas Zustandsmodell

- Drift speichert Pläne, Revisionen, Terminbelege und gewünschte Generationen.
- Android hält einen daraus abgeleiteten dauerhaften Arbeitsstand. Eine gültige
  Quittung bestätigt Generation und tatsächlichen Planungszustand.
- Feste tägliche Zeiten werden als einzelne Alarme geplant. Änderungen, Beenden
  und globales Abschalten gelten für zukünftige Termine; Historie bleibt erhalten.
- Boot, Paketupdate, Zeit- und Zeitzonenwechsel stoßen eine Neuberechnung an.
  Nach Boot werden vergangene Erinnerungen nicht gesammelt nachgeholt.
- Ein bereits registrierter, verspäteter Alarm bleibt bei gewöhnlicher App-Rückkehr
  erhalten, solange er weder erfüllt, überholt noch bereits beansprucht ist.
- Beanspruchung vor Benachrichtigungsversand verhindert doppelte Zustellung. Ein
  Prozessabbruch zwischen diesen Schritten kann eine einzelne Nachricht verlieren.
- Bei unbekannter historischer Zeitzone bleibt ein Termin mehrdeutig, statt UTC
  als scheinbar sichere Herkunft einzusetzen. Gerätezeiten werden nicht geändert.
- Geräte-Kalenderangaben werden für die Zuordnung ohne Sommerzeitnormalisierung
  verglichen. Ein UTC-Vergleichsbehälter ist keine behauptete Importzeitzone.
- Die Zuordnung von Messungen verwendet ±15 Minuten; sie ist unabhängig davon,
  wann Android eine Benachrichtigung zustellt.

## Prüfung und verbleibende Geräteabnahme

Native Unit-Tests prüfen unter anderem Generationen, Wiederholung, Zeitzonen,
Zeitänderungen, Mehrdeutigkeit, alte Quittungen, Rechtewechsel und verspätete Alarme.
Dart-/Widgettests prüfen Zuordnung, Integration, Sichtbarkeit und Fehlermeldungen.

Diese Prüfungen ersetzen keinen Gerätetest. Offen bleiben die reale Zustellung
bei ausgeschaltetem Bildschirm/Doze, Neustart, Rechteentzug/-erteilung,
Zeitzonenwechsel und Öffnen aus einer Benachrichtigung. Herstellerbeschränkungen
und erzwungenes Beenden dürfen nicht als verlässlich überbrückt dargestellt werden.
Build und Installation erfolgen nur auf separaten Auftrag. Verifizierte Ergebnisse
stehen im [Umsetzungsreview](../reviews/2026-09-11-messplan-umsetzung.md).
