# Weitere Blutdruckmessgeräte für Sphygma

## Empfehlung

**Für einen ersten Gebrauchtkauf ist der Omron EVOLV HEM-7600T-E der beste Kandidat, wenn möglichst viel von Sphygmas vorhandenem Geräteprotokoll weiterverwendet werden soll.** Für eine zweite, herstellerübergreifende Protokollfamilie ist der **Beurer BM 54** besonders interessant. **QardioArm** ist ein aussichtsreiches Zusatzprojekt für direkt in der App gestartete Messungen. Das sind Entwicklungskandidaten, noch keine von Sphygma unterstützten Geräte. Die Rangfolge bewertet Anbindbarkeit und Erkenntnisgewinn, nicht die medizinische Messgenauigkeit.[^1][^2][^3][^4]

Eine sinnvolle kleine Testausstattung besteht zunächst aus **einem EVOLV und einem BM 54**, zusätzlich zum bereits vorhandenen RS7. Diese Kombination untersucht zwei unterschiedliche Wege: Wiederverwendung des proprietären Omron-Transports und einen standardnahen BLE-Import. Drei ähnliche Omron-Geräte würden weniger neue Erkenntnisse liefern. Ein modernes M7 Intelli IT AFib lohnt sich als späteres, anspruchsvolleres Vorhaben; sein Handelsname suggeriert mehr Protokollnähe zum RS7, als tatsächlich vorhanden ist.[^5]

Die Recherche wurde am **12. September 2026** abgeschlossen. Betrachtet wurden öffentliche Implementierungen, deren Parser und Sitzungsabläufe, Testdaten, modellbezogene Fehlerberichte sowie Herstellerunterlagen. Die zusätzlichen Geräte wurden nicht selbst an Hardware getestet. Aussagen über funktionierende Exemplare stammen ausdrücklich aus den jeweiligen Projekten. Gebrauchtangebote sind einzelne beobachtete Angebotspreise, keine Marktstatistik.

## Was als Beleg zählt

Vier Evidenzstufen verhindern, dass eine Modellliste mit einem funktionierenden Treiber verwechselt wird:

| Stufe | Bedeutung | Konsequenz |
|---|---|---|
| A | In Sphygma am konkreten Gerät überprüft | Bisher nur RS7 HEM-6232T; keine Übertragung auf die gesamte Marke |
| B | Externer Treiber plus konkrete Hardwarebestätigung oder nachvollziehbarer Rohdaten-Testvektor | Guter Kandidat für einen eigenen Hardwareversuch |
| C | Protokollcode vorhanden, aber Modell-, Revisions- oder Funktionsnachweis lückenhaft | Kauf nur mit bewusst akzeptiertem Entwicklungsrisiko |
| D | Herstellerfähigkeit, SDK oder Produktname ohne ausreichenden offenen Protokollnachweis | Kein Beleg für eine einfache lokale Integration |

Auch Stufe B gilt nur für den nachgewiesenen Funktionsumfang. Ein korrekt empfangener Einzelwert beweist weder vollständigen Speicherabruf noch richtige Benutzerzuordnung oder verlustfreie Wiederholung. Mehrere Projekte können außerdem von derselben ursprünglichen Implementierung abstammen: Übereinstimmung ist dann kein unabhängiger Hardwarebeweis.

Sphygmas eigene RS7-Untersuchung ist dafür der konkrete Ausgangspunkt: Advertising und tatsächlich nutzbare GATT-Dienste unterscheiden sich; Flagpositionen aus fremdem Code waren falsch; Geräteuhr, Löschen und automatische Wiederverbindung mussten separat geprüft werden. Diese bereits dokumentierten Befunde bleiben modellbezogen.[^6]

## Kandidaten im Vergleich

„Aufwand“ ist eine technische Einschätzung des zusätzlichen Gerätepfads **nach** der gemeinsamen Mehrgeräte-Vorbereitung. Er ist keine Zeitschätzung oder Funktionsgarantie.

| Gerät / genaue Familie | Anbindungsweg | Speicherzugriff: belegter Stand | Evidenz | Aufwand / Kaufpriorität |
|---|---|---|---|---|
| **Omron EVOLV HEM-7600T-E** | Proprietäres Classic-BLE, Sphygma-verwandt | Profil für 1×100, eigener 14-Byte-Parser; realer Rohrecord-Test | B | Mittel; **erster Omron-Kauf** |
| Omron M7 Intelli IT **HEM-7361T-EBK**, ältere Version | Classic-BLE | Zwei Speicherbänke, 16-Byte-Records | B/C je Revision | Mittel; Alternative bei eindeutigem Typenschild |
| Omron M4 Intelli IT **HEM-7155T-Familie** | Je Modellvariante Classic oder FE4A; EBK-Profil: Classic | Mehrere Profile und Layouts; Pairingprobleme dokumentiert | B/C je Revision | Mittel bis hoch; **nicht blind nach Handelsname kaufen** |
| Omron M7 Intelli IT AFib **HEM-7380T1-EBK** | FE4A, OS-Bonding, OHQ-Sitzung | 2×100, Android-Implementierung mit realem Capture | B | Hoch; guter späterer Ausbau |
| Omron M2 Intelli IT+ **HEM-7146T2-EBK** | FE4A, anderer Pairingpfad | Profil für 1×30; Evidenz nicht gleich stark für jeden Alias | C | Hoch; kein erster Versuch |
| **Beurer BM 54** | Standardnahes BLE | Speichertransfer in vorhandenen Implementierungen; eigene Vollständigkeitsprüfung nötig | B/C | Mittel; **erster Fremdhersteller-Kauf** |
| Beurer BM 64 / BM 81 easyLock / BC 54 | Standardnahes BLE | UBPM führt modellbezogene Anwenderbestätigungen | B/C | Mittel; Folgemodelle nach BM 54 |
| Beurer BM 85 | BLE, zusätzlicher Geräteablauf | Kleine konkrete Ausleseimplementierung, bekannte Parserprobleme | C | Mittel; nur als bewusster Testkauf |
| A&D **UA-651BLE** | BLE-Standard plus Zeit-/Bondingablauf | Bis 30 gepufferte Werte; Wiederabruf/Löschverhalten kritisch | B | Mittel bis hoch; guter gezielter Testkandidat |
| Medisana **BU 530 connect / BU 540 connect** | Aktives BLE-GATT | Empfänger vorhanden, vollständige Historie nicht belegt | C | Mittel bis hoch; nach BM 54 |
| **QardioArm** | Standardwerte plus proprietäres Start/Stop | Lokale Messungssteuerung belegt; Vollhistorie nicht belegt | B für Live-Ablauf | Mittel bis hoch; **separater Live-Messpfad** |
| Microlife **BP3GY1-2N** | Proprietäres BLE | Expliziter Mehrfach-Messwertabruf in Python | B/C | Mittel; genaue US-Modellidentität beachten |
| Microlife **BP B6 Connect** | Bluetooth und USB vorhanden | Übertragbarkeit des BP3GY1-Parsers nicht nachgewiesen | D für offenen Modelltreiber | Kein erster Kauf allein wegen Markenähnlichkeit |
| Welch Allyn **1700 H-BP100-SBP**, Ver. A/B | Transtek-BLE mit Authentifizierung | Gespeicherte Werte werden übertragen, danach laut Projekt gelöscht | B | Hoch; Verlustschutz vor Komfortfunktionen |
| Veroval **BPM25 / DC318 / GCE604** | USB-Serial | Konkrete Auslesetreiber für zwei Benutzer | B | Mittel bis hoch; Android-USB zusätzlich nötig |
| Withings **BPM Connect** | Offizieller SDK-Pfad über Cloud | Kein passender einfacher Offlinepfad belegt | D | Für dieses Ziel zurückstellen |

Quellen zu Omron: [^1][^2][^5][^7]. Beurer, A&D und Medisana werden im folgenden Abschnitt näher eingegrenzt.[^32][^34][^40] Quellen zu Qardio, Microlife, Welch Allyn und Veroval: [^3][^4][^8][^9][^10][^11][^12]. Withings: [^13].

## Omron: Nähe zum RS7 gezielt nutzen

### EVOLV ist nah verwandt, aber nicht derselbe Parser

Das EVOLV-Profil in UBPM verwendet denselben proprietären Parent-Service wie Sphygmas RS7 und ebenfalls einen App-Key. Es beschreibt jedoch nur einen Benutzer, den Speicherbeginn `0x02AC` und ein eigenes Bitlayout. `hass-omron` enthält einen ausdrücklich einem HEM-7600T-E zugeordneten Rohrecord mit erwarteten Werten. Die Herstellerseite bestätigt die europäische Modellnummer und 100 Speicherplätze.[^1][^2][^14]

**Ableitung:** Framing, Kanaltransport und Teile des Pairings sind gute Wiederverwendungskandidaten. Recordparser, Speichergrenzen, Sequenznummer und Leerwert-Erkennung müssen als eigenes Profil behandelt werden. Identische Recordlänge ist kein ausreichender Grund, den RS7-Parser zu verwenden. Ein erfolgreicher erster Import muss anschließend gegen wiederholte Importe, volle Speicher und Geräte-Reset geprüft werden.

### Moderne Omron-Modelle sind eine zweite Protokollfamilie

Für HEM-7380T1 liegt mit **OmSyncer** besonders wertvolle Android-Vorarbeit vor: ein als verifiziert markiertes Profil, FE4A-Transport, Sitzungsfinalisierung, zwei Speicherbänke und eine reale Capture-Fixture. Andere Profile desselben Projekts sind ausdrücklich experimentell. Der Unterschied gehört in eine Kompatibilitätsliste und darf nicht verloren gehen.[^5][^15]

**Ableitung:** Dieses M7 ist ein guter langfristiger Kandidat, aber kein kleiner Adresswechsel im RS7-Treiber. Bonding, Handshake, mögliche Setup-/Uhr-Schreibvorgänge und TruRead müssen getrennt untersucht werden. Insbesondere darf Sphygma nicht automatisch sämtliche Schreibbefehle eines Referenzclients übernehmen. Seine bisherige Beschränkung von EEPROM-Writes auf den Pairing-Key müsste für jede zusätzliche notwendige Operation ausdrücklich fachlich geklärt werden.

M4 Intelli IT ist für einen ungezielten Gebrauchtkauf ungünstiger: Der aktuelle Profilkatalog unterscheidet mehrere HEM-7155T-Modellvarianten: HEM-7155T-EBK ist Classic zugeordnet, modernere FE4A-Profile tragen abweichende Kennungen wie HEM-7155T-MW oder K4. Ein konkreter Fehlerbericht betrifft `820f` im Pairingablauf eines HEM-7155T-EBK. Typenschildfoto und Firmware-/GATT-Erkennung sind deshalb wichtiger als die Verkaufsbezeichnung „M4“.[^7][^16]

**Omron Complete bleibt ein Sonderfall.** Für ein US-BP7900-Exemplar existiert ein BPS/RACP-Pfad in `omron-rs`; andere Projekte führen HEM-7530T als proprietäres Speicherprofil. Das belegt unterschiedliche Implementierungsannahmen, keine universelle Kompatibilität der Regionsvarianten. Ein vorhandenes EKG im Produkt ist zudem kein Beleg dafür, dass der untersuchte Blutdrucktreiber EKG-Daten ausliest.[^17]

## Standard-BLE: nützlich, aber kein Vollständigkeitsversprechen

Der Bluetooth Blood Pressure Service definiert optionale Zeitstempel, Puls, Benutzerkennung und Messstatus. Bereits der normale Collector muss mehrere Messwert-Indications empfangen können; ein Gerät kann auf diesem Weg gespeicherte Werte abspielen. Neuere erweiterte Profile bieten zusätzlich RACP und nummerierte Blutdruckrecords. **Das Vorhandensein von `0x1810` beweist weder diesen erweiterten Speicherzugriff noch einen tatsächlich nutzbaren Standardpfad am konkreten Gerät.**[^18][^19]

Ein allgemeiner Sphygma-Decoder sollte deshalb variable Felder und ihre Flags korrekt lesen, mmHg/kPa unterscheiden, IEEE-11073-SFLOAT inklusive Sonderwerten behandeln und Indications zuverlässig der richtigen Characteristic zuordnen. Früh eintreffende Pakete während des Abonnementaufbaus müssen gesichert werden, statt sie zu verwerfen. Das Geräteprofil muss zusätzlich festlegen, wodurch gespeicherte Werte ausgelöst werden und woran das Ende eines Abrufs erkennbar ist. Eine feste Wartezeit kann eine Heuristik sein, aber keine bestätigte Vollständigkeit ersetzen.

### Beurer und weitere Standardkandidaten

**Beurer BM 54, Artikel 65512:** Das Herstellerangebot nennt zwei Benutzer mit jeweils 60 Speicherplätzen. Ein eigener ESP32-Client implementiert Bonding, Passkey und den Empfang über `0x2A35`; UBPM ergänzt einen Import mit Zeit und Benutzerlisten. Der ESP32-Parser selbst überspringt jedoch den Zeitstempel und verarbeitet Benutzer-/Statusfelder nicht vollständig. Damit ist das Gerät gut genug belegt, um es gezielt zu kaufen und zu testen, aber der vorhandene Code ist kein fertiger Sphygma-Importer.[^32][^33][^26]

**A&D UA-651BLE:** Hier ist die Protokollbeweislage besonders interessant. Ein unabhängiges Projekt veröffentlicht GATT-/ATT-Mitschnitte und Decoder; zusätzlich existiert Hersteller-Androidcode. Laut Gerätehandbuch werden bei fehlendem Empfänger bis zu 30 Messungen gepuffert und später übertragen. Die Uhr wird vom Empfänger gestellt, ein gekoppelter Empfänger ist vorgesehen. Herstellercode enthält eine konkrete Zeit-Schreiboperation und revisionsabhängige Verzögerungen. Das macht eine eigene Implementierung realistischer als eine bloße Annahme „Standardprofil“.[^34][^35][^36]

Der App-Anbieter Tensana berichtet allerdings, dass übertragene UA-651BLE-Werte anschließend vom Gerät gelöscht werden. **Ableitung:** Ein erster Empfang dürfte vergleichsweise leicht werden, ein verlässlich wiederholbarer Import ist anspruchsvoller. Der genaue Zeitpunkt zwischen ATT-Bestätigung, dauerhafter App-Speicherung und geräteseitigem Entfernen muss geklärt werden. Deshalb ist dieses Modell ein guter zweiter Standardprofil-Versuch, nicht zwingend der bequemste erste Alltagstreiber.[^37]

**Beurer BM 85:** Zwei öffentliche PCAPs und ein Python-Skript machen das Gerät für Reverse Engineering attraktiv. Die Referenz behandelt die Puls-Byteordnung speziell; außerdem enthält sie einen fraglichen Sekundenoffset und keine vollständige Benutzerverarbeitung. Ein fünfsekündiges Empfangsfenster ist kein belegtes Historienende. Die Herstellerunterlagen nennen zwei Benutzer mit je 60 Werten. Der eingebaute Akku ist bei gebrauchten Exemplaren ein zusätzliches Kaufkriterium.[^38][^39]

**Medisana BU 530 connect / BU 540 connect:** Eine Home-Assistant-Integration verbindet sich aktiv mit der Standard-Measurement-Characteristic. Ihr Decoder verwendet feste Offsets, übernimmt die gelesene Benutzerkennung nicht ins Ergebnis und kann nach der ersten Nachricht bereits den Abruf beenden. Das ist ein verwertbarer Ansatz, aber keine belastbare Vollhistorie. Die konkrete Modellbindung des Codes ist schwächer als beim BM 54. Die Artikelnummern 51174 beziehungsweise 51182 sollten anhand der Herstellerdokumente geprüft werden.[^40][^41]

**Nicht verwechseln:** UA-767PBT-C/Ci gehört laut A&D zu Bluetooth Classic/HDP, nicht zu BLE-GATT. UA-651SL Plus ist kein Ersatzkauf für UA-651BLE. Beurer BM 57 bleibt ein plausibler Folgekandidat, jedoch wurde kein gleich stark modellbezogener offener Treiber mit Capture gefunden. Weitere Namen wie Sanitas, Silvercrest oder Braun sollten erst nach exakter Typ- und Quellcodeprüfung auf die Einkaufsliste gelangen.[^42][^43]

**Ein wichtiger Quellenwiderspruch bleibt offen:** Tensana führt auch „Omron RS7 Intelli IT“ als standardkompatibel, während Sphygmas konkrete HEM-6232T-Untersuchung keinen funktionierenden Standardmesspfad ergab. Ohne Firmware- und Ablaufvergleich lässt sich das nicht auflösen. Ebenso kann „nur einmal übertragen“ einen gelesenen Datensatz oder einen gelöschten Speicher bedeuten. Für EVOLV ist der proprietäre Speicherpfad durch Code/Testdaten belegt; die Wiederholbarkeit darf trotzdem nicht aus dem Produktnamen geschlossen werden.[^37][^6]

## QardioArm: attraktiv für direkte Messungssteuerung

**LibreArm** zeigt einen lokalen Ablauf ohne Herstellerkonto: verbinden, Messung starten beziehungsweise abbrechen, Ergebnis übernehmen. Im Quellcode werden der Blood Pressure Service und eine proprietäre Steuer-Characteristic verwendet; Start und Stop sind kleine Steuerkommandos. Das unterscheidet sich funktional von Sphygmas bisherigem Prinzip, bereits am Gerät abgeschlossene Messungen abzuholen.[^3][^20]

Die iOS-Implementierung enthält Tests für optionale Felder, negative SFLOAT-Exponenten, kPa und reservierte Werte. Der ebenfalls vorhandene Android-Port ist keine gleichwertig vollständige Referenz: Sein Parser überspringt den Gerätezeitstempel, übernimmt Benutzer- und Statusfelder nicht vollständig und behandelt den SFLOAT-Exponenten ohne Vorzeichenerweiterung. Diese Aussagen betreffen den geprüften Commit, nicht eine beliebige zukünftige Version.[^4][^21]

**Ableitung:** QardioArm ist ein plausibler dritter Testkauf, wenn eine „Messung starten“-Funktion gewünscht ist. Vollständiger Gerätespeicherimport ist durch die untersuchten LibreArm-Pfade nicht belegt. Für dieses Gerät bräuchte Sphygma zusätzlich eine saubere Messungssitzung mit Abbruch, Verbindungsverlust und Trennung von Zwischenwert und Endergebnis. Ein abgebrochener oder unvollständiger Lauf darf keinen vermeintlich fertigen Datensatz erzeugen.

## Andere Familien und USB

### Microlife

`joergmlpts/blood-pressure-monitor` benennt **BP3GY1-2N** ausdrücklich als getestetes Bluetoothgerät und **BP3GX1-5X** als USB-Gerät. Der BLE-Code besitzt einen Messwertabruf, sammelt mehrere Records und setzt vorher automatisch die Uhr; gegebenenfalls wird auch die Patientenkennung geschrieben. Sein Parser übernimmt aus zehn Bytes nur Messwerte und Kalenderkomponenten, keine umfassend ausgewerteten Zusatzflags.[^8][^9]

Das ist nützliche Protokollvorarbeit, aber kein Nachweis für BP A6 BT oder BP B6 Connect. Für B6 bestätigt das Handbuch Bluetooth, USB und Speicherfunktionen; die konkrete Kompatibilität mit dem genannten Python-Protokoll bleibt offen. Microlife bietet zudem aktuelle Hersteller-SDKs an. Eine verfügbare SDK-Datei ersetzt jedoch weder eine offene Protokolldokumentation noch die Prüfung ihrer Nutzungsbedingungen.[^22][^23]

### Welch Allyn / Transtek

Der Python-Treiber für **Welch Allyn 1700 H-BP100-SBP** dokumentiert Tests mit Ver. A und Ver. B sowie Authentifizierung, Zeitsetzung und Datentransfer. Der 1500 wird lediglich als wahrscheinlich kompatibel genannt. Besonders relevant: Laut Projekt werden abgeholte Messungen vom Gerät entfernt. Der Client quittiert einzelne Pakete.[^10][^24]

**Ableitung:** Technisch interessante Vorarbeit, aber kein bevorzugter erster Kauf. Vor dem Quittieren müsste Sphygma jedes Ergebnis dauerhaft sichern. Ein Absturz zwischen Empfang und Speicherung wäre bei einem erneut lesbaren Omron-Speicher ärgerlich; bei einem konsumierenden Transfer kann er endgültigen Verlust bedeuten. Das Wiederholungs- und Quittierungsverhalten müsste am konkreten Exemplar zuerst geprüft werden.

### Veroval und Beurer mit USB

Für Veroval **BPM25**, **DC318/Duo Control** und **GCE604/Upper Arm** existieren konkrete USB-Serial-Treiber. UBPM nennt zu diesen Geräten Tester; für BPM25 liegt zusätzlich ein kleiner MIT-lizenzierter Python-Treiber vor. Die Schnittstelle bietet einen sinnvollen Alternativweg, wenn ein passendes Gerät bereits vorhanden oder sehr günstig ist.[^11][^12]

Für Sphygma ist USB trotzdem eine neue Transportschicht: Android-USB-Host, Berechtigungen, unterstützter USB-Serial-/HID-Chip und passendes Datenkabel müssen funktionieren. Ein Desktop-Erfolg mit QSerialPort beweist das nicht. Ältere Beurer-USB-Modelle besitzen laut UBPM teilweise unterschiedliche HID-/Serial-Varianten; auch dort muss die Hardwareversion stimmen.[^1]

### Zurückstellen: Withings und iHealth-SDK als vermeintlich einfache Abkürzung

Der offizielle Withings-Mobile-SDK-Pfad synchronisiert Daten laut Hersteller immer über die Withings-Cloud und benötigt anschließend die Data API. Damit passt er nicht zu einer einfachen lokalen Sphygma-Geräteanbindung.[^13]

iHealth veröffentlicht einen React-Native-Wrapper und Modell-APIs, verlangt unter Android aber eine bereitgestellte Lizenzdatei zur SDK-Authentifizierung. Das ist eine andere Abhängigkeit als ein vollständig nachvollziehbarer freier BLE-Treiber. Ohne belegten offenen Protokollpfad für das exakte Kaufmodell würde ich iHealth nicht vor EVOLV oder BM 54 priorisieren.[^25]

## Konkrete Unvollständigkeiten in fremden Implementierungen

| Beobachtung | Warum sie für Sphygma zählt |
|---|---|
| UBPMs generischer BLE-Decoder arbeitet im geprüften Stand mit 19-Byte-Records und festen Feldpositionen | Das ist nicht allgemein gültig für alle optionalen Felder des Standardprofils.[^26] |
| LibreArm Android signiert den SFLOAT-Exponenten nicht und überspringt den Zeitstempel | Eine funktionierende Standard-mmHg-Messung deckt diese Fehler nicht auf.[^4] |
| Microlife-Python setzt die Uhr vor dem Abruf und wertet nicht alle Recordbytes aus | Lesefunktion und verändernde Operation sind zu trennen; unbekannte Flags bleiben unbekannt.[^9] |
| Welch-Allyn-Treiber beschreibt Abruf mit anschließendem Löschen | Dauerhafte Speicherung und Quittierung brauchen einen anderen Ablauf.[^10][^24] |
| Omron-Profile unterscheiden Alias, Firmware und Transportgeneration | Gleicher Produktname bedeutet nicht gleiches Pairing oder Speicherlayout.[^7][^16] |
| Mehrere Referenzen stammen voneinander ab | Zwei übereinstimmende Parser sind nicht automatisch zwei unabhängige Messversuche. |

Die Projekte liefern Suchraum, Kommandos und oft hervorragende Testdaten. Übernommen werden sollte die **prüfbare Erkenntnis**, zusammen mit Gegenbeispielen und klarer Kennzeichnung des nachgewiesenen Umfangs.

## Notwendige Vorbereitung in Sphygma

Die folgenden Punkte ergeben sich aus dem aktuellen Repository, nicht aus fremden Gerätebehauptungen. Sie sind Entwurfsempfehlungen; im Rahmen dieser Recherche wurde kein Gerätecode geändert.[^27]

**1. Geräteidentität vor zweitem Import.** Messungen werden heute über `(userSlot, deviceSequence)` dedupliziert. Health-Connect-IDs verwenden ebenfalls Slot und Sequenz. Zwei Geräte können dieselbe Sequenz besitzen; selbst ein Gerätetausch ist damit relevant. Eine stabile interne Geräteidentität muss in Import, Metadatenbezügen und Export berücksichtigt werden. Bestehende Health-Connect-IDs dürfen bei der Migration nicht einfach neu erzeugt werden, sonst drohen doppelte Exporte.

**2. Person und Gerätespeicherplatz trennen.** „Benutzer 1“ auf Gerät A ist nicht automatisch dieselbe Person wie „Benutzer 1“ auf Gerät B. Eine ausdrückliche Zuordnung muss das entscheiden. Ein Einbenutzergerät wie EVOLV oder ein anonymer Standardrecord darf nicht stillschweigend dem falschen vorhandenen Bestand zugeordnet werden.

**3. Profile statt verstreuter Modellabfragen.** Ein Geräteprofil beschreibt Erkennung, Transport, Pairing, Speicherorganisation, Recordparser und Fähigkeiten. Gemeinsames Framing kann wiederverwendet werden, während das Bitlayout modellbezogen bleibt. Der Pairing-Key ist derzeit unter einem globalen Speicherkey abgelegt und muss ebenfalls pro Geräteidentität verwaltet werden.

**4. Fehlende Daten ausdrücken.** Standardmessungen können Puls, Gerätezeit oder Statusfelder weglassen. Das aktuelle interne Recordmodell verlangt mehrere dieser Angaben. „Kein Arrhythmieflag übertragen“ darf nicht zu „keine Arrhythmie“ werden; eine fehlende Gerätezeit nicht unbemerkt zur Handyzeit. Rohpayload, Parser-/Profilversion und Zeitquelle sollten nachvollziehbar bleiben.

**5. Dedup ohne echte Sequenz nicht erfinden.** Manche Geräte übertragen keine dauerhafte Recordnummer. Ein Zeitstempel allein ist bei verstellter Uhr und mehreren Messungen pro Minute ungeeignet. Ein profilabhängiges Verfahren muss vorhandene Identifikatoren, Rohdaten und wiederholte Übertragungen prüfen; nicht unterscheidbare Fälle brauchen einen ausdrücklichen Zustand statt eines geratenen Zählers.

**6. Automatischer Abgleich als eigene Fähigkeit.** „Nach einer Messung auffindbar“, „Speicher nur nach Tastendruck abrufbar“ und „Messung muss in der App gestartet werden“ sind verschiedene Bedienabläufe. Sphygma sollte pro Geräteprofil nur tatsächlich getestete Möglichkeiten anbieten.

### Quellen und Wiederverwendung

Sphygma ist MIT-lizenziert und verwendet UBPM bereits als Gegenprobe statt als kopierte Implementierung. Das sollte auch für neue Geräte gelten: Lizenzangaben getrennt erfassen, Protokollbefunde selbst dokumentieren und neue Decoder anhand von Testvektoren prüfen. Öffentlicher Quellcode, ein offizielles SDK und eine freie Lizenz sind drei unterschiedliche Eigenschaften. Der Microlife-Pythoncode sowie LibreArm tragen MIT-Lizenzen; UBPM trägt GPL-3.0. Daraus folgt noch keine pauschale Aussage zur Zulässigkeit einer konkreten Codeübernahme.[^6][^44]

openScale ist vor allem wegen seiner Waagentreiber auffindbar; diese belegen keine Unterstützung gleichnamiger Blutdruckgeräte. Im untersuchten Gadgetbridge-Mirror wurde kein passender eigenständiger Adapter als positive Quelle gefunden. Das sind begrenzte Suchbefunde, keine Behauptung, dass entsprechende Unterstützung grundsätzlich unmöglich wäre.[^45]

## Gebrauchtkauf und Preisbeispiele

Die folgenden öffentlich sichtbaren Einzelanzeigen wurden am Recherchetag gefunden. Die Preise sind **Angebotspreise ohne Versand**, keine Aussage über erzielte Verkaufspreise, Marktmittel oder fortbestehende Verfügbarkeit. Verkäuferangaben zu Gesundheit, Genauigkeit oder App-Kompatibilität wurden nicht als technische Belege verwendet.

| Kandidat | Beobachteter Preis | Anzeige |
|---|---:|---|
| Beurer BM 54 | 25 € | Rhaunen, Anzeige vom 09.07.2026[^28] |
| Beurer BM 54 | 30 € | Düsseldorf, Anzeige vom 22.08.2026[^29] |
| QardioArm | 33 € | Rödermark, Anzeige vom 18.08.2026[^30] |
| Omron EVOLV | 60 € | Kleinmachnow, Anzeige vom 23.07.2026; genaue HEM-Nummer vor Kauf bestätigen[^31] |

Für die technische Beschaffung würde ich zunächst nach **„Omron HEM-7600T-E“** und **„Beurer BM 54“** suchen. Vor einer Zusage sind Fotos von Typenschild und Anschlussseite sowie die Funktionsbestätigung für Display, Tasten, Bluetooth und Manschette sinnvoll. Bei USB-Geräten gehört das passende Datenkabel dazu. Ein Angebot mit „App funktioniert nicht mehr“ kann beim QardioArm interessant sein, ersetzt aber keine Prüfung, ob die Hardware noch eine Messung startet und abschließt.

Ein Gerät nach dem anderen zu beschaffen hält die Untersuchung überschaubar. Erst wenn Discovery, Pairing und mindestens ein plausibler vollständiger Import gelungen sind, lohnt sich ein zweites Exemplar derselben Familie. Nicht nach dem bloßen Schriftzug „Bluetooth“, „Intelli IT“ oder „Connect“ kaufen.

## Hardware-Abnahme je neuem Modell

Die Abnahme sollte als wiederholbare Versuchsreihe mit Rohbytes und Displayvergleich geführt werden. Eine erfolgreiche Demo allein reicht nicht für eine veröffentlichte Kompatibilitätszusage.

1. **Identität:** vollständige Typnummer, Region, Firmware, Bluetoothdienste und Erkennungsmerkmale festhalten. Pairing nach Batteriewechsel und nach vorheriger Hersteller-App-Bindung prüfen.
2. **Ergebnis:** SYS, DIA, Puls, Gerätezeit und Benutzerkennung anhand mehrerer natürlich entstandener Messungen mit dem Display vergleichen. Vorhandene Fehler-/Statusanzeigen separat zuordnen; nichts medizinisch provozieren, um ein Flag zu erhalten.
3. **Historie:** Einzelmessung, mehrere offline entstandene Messungen und erneut angeforderter Speicher. Vollständigkeitsende, Reihenfolge und maximaler Speicher dürfen nicht nur geschätzt werden.
4. **Wiederholung:** denselben Speicher zweimal importieren; Verbindung während Transfer unterbrechen; App nach Empfang beenden und neu starten. Keine Duplikate, keine unbemerkten Lücken.
5. **Zeit und Herkunft:** Geräteuhr zurückstellen, zwei Messungen mit gleicher Minutenangabe, mehrere Benutzer und zweites Gerät mit gleicher Sequenz. Alte Messungen dürfen weder verschoben noch überschrieben werden.
6. **Seiteneffekte:** vor und nach dem Abruf prüfen, ob Uhr, Zähler, „ungelesen“-Status, Pairingpartner oder gespeicherte Records verändert wurden. Bei konsumierendem Transfer zuerst die dauerhafte Ablage absichern.
7. **Alltag:** zwei aufeinanderfolgende neue Messungen bei geöffneter App, Bluetooth aus/an, App-Neustart und Gerät längere Zeit außer Reichweite. Automatik nur zusagen, wenn genau dieser Ablauf bestanden wurde.
8. **Export:** Wiederholung, Abbruch und erneuter Export nach Health Connect; Geräteherkunft und vorhandene Exportidentitäten müssen erhalten bleiben.

Daraus sollten pro exaktem Profil getrennte Statusangaben entstehen: **Erkennung**, **Pairing**, **neue Werte**, **Gerätespeicher**, **Benutzer**, **Zeit/Flags**, **Wiederholung**, **Automatik**. Ein einziges grünes „unterstützt“ verdeckt zu viele offene Fragen.

## Quellen

Die folgenden Quellcode-Permalinks halten den untersuchten Stand fest. Herstellerseiten und Anzeigen wurden am 12.09.2026 abgerufen; ein fehlendes Publikationsdatum wurde nicht ergänzt. Die Feststellungen aus dem Sphygma-Repository sind ausdrücklich lokale Projektbefunde.

[^1]: [UBPM: unterstützte Modelle und Tester](https://codeberg.org/LazyT/ubpm/src/commit/748ce8504185ae96dbdbd1cff5352d1eef2c046d/README.md).

[^2]: [hass-omron: Recordparser-Tests mit EVOLV-Rohrecord](https://github.com/eigger/hass-omron/blob/48b9009cc35ccdf57d28259587ffe92699695df2/tests/test_record_parsers.py).

[^3]: [LibreArm: Funktionsumfang und lokaler Betrieb](https://github.com/ptylr/LibreArm/blob/65ef2aa0895b8a7242afa3c1c351024c42fb7791/README.md).

[^4]: [LibreArm Android: BpClient und Decoder](https://github.com/agreenbhm/LibreArm_Android/blob/415735a08a0dd71b86a192dd57a0309528087ed5/app/src/main/java/com/ptylr/librearm/ble/BpClient.kt).

[^5]: [OmSyncer: Geräteprofile und Verifizierungsstatus](https://github.com/thiagokokada/OmSyncer/blob/a30f3be7d28d73989f4a71596b3292767741fba4/app/src/main/java/com/github/thiagokokada/omronsyncer/omron/OmronDeviceRegistry.kt).

[^6]: [Sphygma: eigene HEM-6232T-Hardwarebefunde](../protocol/hem-6232t.md).

[^7]: [hass-omron: Modell- und Revisionskatalog](https://github.com/eigger/hass-omron/blob/48b9009cc35ccdf57d28259587ffe92699695df2/custom_components/omron/omron_ble/device_catalog.py).

[^8]: [Microlife-Python: getestete Modellnummern](https://github.com/joergmlpts/blood-pressure-monitor/blob/fe6923849c407fb1cd5ccc30e57b7fb016d0dc3a/README.md).

[^9]: [Microlife-Python: BLE-Sitzung und Recordparser](https://github.com/joergmlpts/blood-pressure-monitor/blob/fe6923849c407fb1cd5ccc30e57b7fb016d0dc3a/bpm_bt.py).

[^10]: [Welch-Allyn-Treiber: Hardwaretests und Löschverhalten](https://github.com/casebeer/welch-allyn-bp100-python/blob/e4723ac3d01d21af5998ecd80809566ffad5c2ed/README.md).

[^11]: [cpresser/veroval: BPM25-Auslesetreiber](https://github.com/cpresser/veroval).

[^12]: [UBPM: Hartmann DC318-Import](https://codeberg.org/LazyT/ubpm/src/commit/748ce8504185ae96dbdbd1cff5352d1eef2c046d/sources/plugins/vendor/hartmann/dc318/DialogImport.cpp); [UBPM: Modellbestätigungen](https://codeberg.org/LazyT/ubpm/src/commit/748ce8504185ae96dbdbd1cff5352d1eef2c046d/README.md).

[^13]: [Withings: Mobile SDK, Cloud-Synchronisation und Data API](https://developer.withings.com/sdk/).

[^14]: [Omron: EVOLV HEM-7600T-E](https://www.omron-healthcare.com/products/evolv); [UBPM: modellbezogene Omron-Speicherprofile](https://codeberg.org/LazyT/ubpm/src/commit/748ce8504185ae96dbdbd1cff5352d1eef2c046d/sources/plugins/vendor/omron/bluetooth/omron-bluetooth.json).

[^15]: [OmSyncer: realer HEM-7380T1-Capture vom 10.03.2026](https://github.com/thiagokokada/OmSyncer/blob/a30f3be7d28d73989f4a71596b3292767741fba4/app/src/test/resources/fixtures/hem_7380t1_real_capture_20260310.txt).

[^16]: [hass-omron Issue 34: HEM-7155T-EBK-Pairingfehler](https://github.com/eigger/hass-omron/issues/34).

[^17]: [omron-rs: BPS-Implementierung](https://github.com/wildcommitter/omron-rs/blob/e9729d0e435abc0a0a0e9e35378b20bd35426b35/src/bps.rs); [omron-rs: getestetes BP7900 und Umfang](https://github.com/wildcommitter/omron-rs/blob/e9729d0e435abc0a0a0e9e35378b20bd35426b35/README.md).

[^18]: [Bluetooth SIG: Blood Pressure Service 1.1.1](https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/BLS_v1.1.1/out/en/index-en.html).

[^19]: [Bluetooth SIG: Blood Pressure Profile 1.1.1](https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/BLP_v1.1.1/out/en/index-en.html).

[^20]: [LibreArm: Qardio-BLE-Steuerung](https://github.com/ptylr/LibreArm/blob/65ef2aa0895b8a7242afa3c1c351024c42fb7791/Core/BPClient.swift).

[^21]: [LibreArm: Messwert- und SFLOAT-Tests](https://github.com/ptylr/LibreArm/blob/65ef2aa0895b8a7242afa3c1c351024c42fb7791/LibreArmTests/BloodPressureMeasurementTests.swift).

[^22]: [Microlife: B6-Connect-Handbuch, Ausgabe 2025](https://www.microlife.com/media/3401/download/IB%20BP%20B6%20Connect%20S-V11%202025.pdf?v=13).

[^23]: [Microlife: Hersteller-SDKs](https://www.microlife.com/support/developers-1).

[^24]: [Welch-Allyn-Treiber: Transtek-Authentifizierung und Quittierung](https://github.com/casebeer/welch-allyn-bp100-python/blob/e4723ac3d01d21af5998ecd80809566ffad5c2ed/bp100/TranstekController.py).

[^25]: [iHealth: offizieller React-Native-SDK-Wrapper und Lizenzdatei](https://github.com/MyVitals/iHealth-rn-sdk).

[^26]: [UBPM: generischer BLE-Import und feste Offsets](https://codeberg.org/LazyT/ubpm/src/commit/748ce8504185ae96dbdbd1cff5352d1eef2c046d/sources/plugins/vendor/generic/bluetooth/DialogImport.cpp); [UBPM: Recordstruktur](https://codeberg.org/LazyT/ubpm/src/commit/748ce8504185ae96dbdbd1cff5352d1eef2c046d/sources/plugins/vendor/generic/bluetooth/DialogImport.h).

[^27]: [Sphygma: Datenbankschema](../../lib/db/app_database.dart); [Exportidentität](../../lib/sync/export_service.dart); [Pairing-Key-Speicher](../../lib/ble/pairing_key_store.dart); [Recordmodell](../../lib/protocol/record.dart).

[^28]: [Kleinanzeigen: BM 54, 25 €, Rhaunen, 09.07.2026](https://www.kleinanzeigen.de/s-anzeige/blutdruckmessgeraet-beurer-bm-54-mit-ovp/3454915437-224-17488).

[^29]: [Kleinanzeigen: BM 54, 30 €, Düsseldorf, 22.08.2026](https://www.kleinanzeigen.de/s-anzeige/beurer-bm-54-blutdruckmessgeraet-oberarm-mit-puls-messgeraet/3491162485-224-2100).

[^30]: [Kleinanzeigen: QardioArm, 33 €, Rödermark, 18.08.2026](https://www.kleinanzeigen.de/s-anzeige/qardioarm-blutdruckmessgeraet-fuer-smartphone-app/3488305383-224-4514).

[^31]: [Kleinanzeigen: EVOLV, 60 €, Kleinmachnow, 23.07.2026](https://www.kleinanzeigen.de/s-anzeige/omron-evolv-oberarm-blutdruckmessgeraet-app-kompatibel-mit-etui/3466323096-224-7775).

[^32]: [Beurer: BM 54, Artikel 65512](https://www.beurer.com/de/p/65512/).

[^33]: [ESP32 BM54: BLE-Client](https://github.com/bfabio/esp32-beurer-bm54/blob/936bb62031c74faa153693f0495d23c992b7d58e/main/ble_bp_client.c); [ESP32 BM54: Decoder](https://github.com/bfabio/esp32-beurer-bm54/blob/936bb62031c74faa153693f0495d23c992b7d58e/main/bp_parser.c).

[^34]: [A&D: UA-651BLE-Handbuch](https://aandd.jp/products/manual/medical/ua651ble_en.pdf).

[^35]: [ThingML-BLE: UA-651BLE-Protokollmitschnitte](https://github.com/HEADS-project/ThingML-BLE/blob/a7aa1580ece9e520f777601093a07b39fcb26d7b/Documentation/AND_Medical_UA651BLE.md).

[^36]: [A&D: offizieller Android-Empfänger](https://github.com/andengineering/AndroidSampleCode/blob/fc24d44695539c21805114f3be9158d9e1932a7a/app/src/main/java/jp/co/aandd/cdltestapp/ble/BleReceivedService.java).

[^37]: [Tensana: eigene BLE-Kompatibilitäts- und Transferangaben](https://www.tensana.app/en/faq/bluetooth-ble.html).

[^38]: [ble-stuff: BM85-Decoder](https://github.com/smurfix/ble-stuff/blob/86457cbcde4be71f1730ab35dbfa6f9ca5ee7741/beurer.py); [ble-stuff: Mitschnitte](https://github.com/smurfix/ble-stuff/tree/86457cbcde4be71f1730ab35dbfa6f9ca5ee7741/Logs).

[^39]: [Beurer: BM85-Herstellerhandbuch](https://res.cloudinary.com/beurer/image/upload/v1712217543/stibo-live/65803_BM85_2024-03-06_04_IM2_BEU_EN.pdf).

[^40]: [Medisana-HA-Integration: Parser und Empfangsablauf](https://github.com/bkbilly/medisanabp_ble/blob/bf505a7ef1e8c8a3bf999cb1c7981e53be43be93/custom_components/medisanabp_ble/medisana_bp/parser.py).

[^41]: [Medisana: Unterlagen Artikel 51174](https://www.medisana.com/en/Docs?artnum=51174); [Medisana: Unterlagen Artikel 51182](https://www.medisana.com/en/Docs?artnum=51182).

[^42]: [A&D: UA-767PBT-C, Bluetooth Classic](https://www.aandd.jp/products/medical/pdf/ua767pbtc.pdf); [A&D: UA-767PBT-Ci-Handbuch](https://aandd.jp/products/manual/medical/ua767pbtci_de.pdf).

[^43]: [A&D: UA-651SL Plus](https://medical.andprecision.com/wp-content/uploads/2020/09/UA-651SL-Plus-brochure.pdf); [Beurer: BM57-Handbuch](https://pim.beurer.com/images/attribut/658.22_BM57_2020-02-10_03_IM1_BEU.pdf).

[^44]: [Sphygma: Lizenz](../../LICENSE); [UBPM: Lizenz](https://codeberg.org/LazyT/ubpm/src/commit/748ce8504185ae96dbdbd1cff5352d1eef2c046d/LICENSE); [Microlife-Python: Lizenz](https://github.com/joergmlpts/blood-pressure-monitor/blob/fe6923849c407fb1cd5ccc30e57b7fb016d0dc3a/LICENSE); [LibreArm: Lizenz](https://github.com/ptylr/LibreArm/blob/65ef2aa0895b8a7242afa3c1c351024c42fb7791/LICENSE).

[^45]: [openScale: untersuchter Bluetooth-Treiberbaum](https://github.com/oliexdev/openScale/tree/573beb1d3588bd73597fb8a2da7474bf465157d2/android_app/app/src/main/java/com/health/openscale/core/bluetooth); [Gadgetbridge: untersuchter GitHub-Mirror](https://github.com/Freeyourgadget/Gadgetbridge/tree/a0948ee1cbc2a870f91d313f8e37df5f524465f7).
