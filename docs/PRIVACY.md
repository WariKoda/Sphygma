# Datenschutzerklärung — Sphygma

Stand: 2026-09-11. Entwurf; vor Veröffentlichung Kontaktdaten des Verantwortlichen ergänzen.

## Was Sphygma tut

Sphygma liest Blutdruckmessungen (systolischer und diastolischer Wert, Puls, Zeitpunkt,
Hinweise auf Körperbewegung und unregelmäßigen Puls) aus einem Omron RS7 Intelli IT
(HEM-6232T) per Bluetooth aus, speichert sie **lokal auf deinem Gerät** und schreibt auf deinen
Wunsch Blutdruck und Puls nach **Health Connect**.

## Welche Daten verarbeitet werden

- Messwerte des Blutdruckmessgeräts (siehe oben)
- Ein zufällig erzeugter Pairing-Schlüssel für die Verbindung zum Messgerät, gespeichert im
  geschützten Speicher des Android-Systems
- Deine Wahl, welcher Benutzer-Speicherplatz des Geräts (User 1 oder 2) dir gehört
- Einstellungen zur Darstellung, zum automatischen Abgleich und zum Export
- Deine Entscheidung, welche bisherigen Messungen du übernehmen möchtest
- Bemerkungen und Tags an einzelnen Messungen, benannte Phasen mit Zeiträumen und
  manuelle Phasenzuordnungen
- Messpläne mit täglichen Zeiten, Änderungen, Terminzuordnungen und lokalem
  Erinnerungsstatus einschließlich Zeit- und Zeitzonenwechseln
- Historische Anlassentscheidungen aus älteren Versionen bleiben bei einem Update
  in der lokalen Datenbank erhalten; die Anlassfunktion ist entfallen
- Export- und Rückzugsstatus, damit fehlgeschlagene Übertragungen erneut versucht und
  zurückgezogene Messungen nicht automatisch wieder übertragen werden

## Wo die Daten liegen

- **Lokal auf deinem Gerät.** Sphygma hat keinen Server, keine Konten und keinen eigenen
  Cloud-Dienst. Android-Cloud-Backups und der automatische Android-Gerätetransfer der
  App-Daten sind ausdrücklich ausgeschlossen; das gilt auch für Einstellungen und den
  Pairing-Schlüssel.
- **Health Connect**, mit deiner Schreibberechtigung. Du kannst Messungen einzeln oder
  gesammelt übertragen. Wenn der automatische Export eingeschaltet ist, überträgt Sphygma
  neue übernommene Messungen nach einem erfolgreichen Abgleich automatisch. Sphygma
  schreibt ausschließlich Blutdruck und Puls und **liest keine Daten** aus Health Connect.
  Du kannst jede einzelne oder alle von Sphygma geschriebenen Messungen jederzeit aus der App
  heraus wieder aus Health Connect entfernen; die Berechtigung kannst du in Health Connect
  jederzeit entziehen.

## Erinnerungen

Bei aktiviertem Messplan kann Android lokale Benachrichtigungen anzeigen. Ihr Text
nennt den Messplan und den Speicherplatz, keine Blutdruckwerte, Tags oder Bemerkungen.
Die Anzeige auf dem Sperrbildschirm richtet sich nach deinen Android-Einstellungen.
Die App fragt bei Aktivierung nach den erforderlichen Rechten. Das Abschalten der
Messplanfunktion stoppt ihre Erinnerungen. Es gibt keine anderen Erinnerungsarten.

## Sicherung und Gerätewechsel

Sphygma bietet derzeit keine eigene Backup- oder Wiederherstellungsfunktion. Beim Verlust
des Telefons, Löschen der App-Daten oder einer Neuinstallation gehen die lokale Historie,
Einstellungen, Tags, Bemerkungen, Phasen, Messpläne und Zuordnungen verloren. Auf einem neuen Telefon
musst du das Messgerät erneut koppeln. Erneut auslesen lassen sich nur Messungen, die noch
im Messgerät vorhanden sind; frühere Entscheidungen und ältere Messungen lassen sich daraus
nicht wiederherstellen. Health Connect ist eine Export-Senke und wird nicht zum
Wiederherstellen der Sphygma-Datenbank verwendet.

Die Android-Konfiguration sperrt Cloud-Sicherung und Gerätetransfer getrennt entsprechend
der [Android-Dokumentation zu Auto Backup](https://developer.android.com/identity/data/autobackup).
Diese Regeln betreffen die privaten Sphygma-App-Daten. Bereits nach Health Connect
exportierte Daten werden von Health Connect verwaltet.

## Was Sphygma nicht tut

- Keine eigene Übertragung von Gesundheitsdaten an Server oder Analyse-Dienste
- Keine Werbung, kein Tracking, keine Analyse-Dienste
- Kein Schreiben in das Blutdruckmessgerät außer dem Pairing-Schlüssel

## Technische Hinweise

- Die Bluetooth-Bibliothek `flutter_blue_plus` kann beim **Erstellen** der App (nicht bei der
  Nutzung) eine Build-Telemetrie an ihren Hersteller senden (App-Name, Paketname, Version,
  Datum). Diese enthält keine Nutzer- oder Gesundheitsdaten.
- Sphygma ist ein privates Open-Source-Projekt (MIT-Lizenz). Es ersetzt keine ärztliche
  Bewertung.

## Löschung

Deinstallation der App löscht alle lokal gespeicherten Daten und den Pairing-Schlüssel. In
Health Connect geschriebene Daten löschst du vorher über die App oder in Health Connect unter
„App-Daten löschen".

**Hinweis zum Messgerät:** Das Löschen des Speichers am Omron-Gerät entfernt die Messwerte
nur aus der Anzeige. Auch das Zurücksetzen auf die Werkseinstellungen löscht sie nicht — es
entfernt die Bluetooth-Kopplung, nicht die Messwerte. Über Bluetooth bleiben sie lesbar, bis
sie durch neue Messungen überschrieben sind (100 Messungen je Benutzer, also bis zu 200
insgesamt). Sphygma kann daran nichts ändern, weil die App grundsätzlich nichts in das Gerät
schreibt. Wer das Gerät weitergibt, sollte das wissen; sicher entfernt sind die Werte erst,
wenn genügend neue Messungen sie überschrieben haben.

## Verantwortlicher

<Name, Anschrift, E-Mail — vor Veröffentlichung eintragen>
