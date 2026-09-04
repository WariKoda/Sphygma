# Datenschutzerklärung — Sphygma

Stand: 2026-09-03. Entwurf; vor Veröffentlichung Kontaktdaten des Verantwortlichen ergänzen.

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

## Wo die Daten liegen

- **Nur auf deinem Gerät.** Sphygma hat keinen Server, keine Konten, keine Cloud.
- **Health Connect**, nur wenn du den Export auslöst und die Berechtigung erteilst. Sphygma
  schreibt ausschließlich Blutdruck und Puls und **liest keine Daten** aus Health Connect.
  Du kannst jede einzelne oder alle von Sphygma geschriebenen Messungen jederzeit aus der App
  heraus wieder aus Health Connect entfernen; die Berechtigung kannst du in Health Connect
  jederzeit entziehen.

## Was Sphygma nicht tut

- Keine Übertragung von Gesundheitsdaten an Dritte
- Keine Werbung, kein Tracking, keine Analyse-Dienste
- Kein Schreiben in das Blutdruckmessgerät außer dem Pairing-Schlüssel

## Technische Hinweise

- Die Bluetooth-Bibliothek `flutter_blue_plus` kann beim **Erstellen** der App (nicht bei der
  Nutzung) eine Build-Telemetrie an ihren Hersteller senden (App-Name, Paketname, Version,
  Datum). Diese enthält keine Nutzer- oder Gesundheitsdaten.
- Sphygma ist ein privates Open-Source-Projekt (MIT-Lizenz) und **kein Medizinprodukt**. Es
  ersetzt keine ärztliche Bewertung.

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
