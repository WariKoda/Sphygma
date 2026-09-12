# Einheitliche Oberfläche — Umsetzung

**Ziel:** Alle Produktionsansichten verwenden die klare Hierarchie der freigegebenen Blutdruck-/Pulskarten. Umsetzung vom Nutzer am 12.09.2026 ausdrücklich beauftragt.

**Architektur:** Gemeinsame Kartenköpfe und Messungszeilen statt lokaler Kopien. Material-Komponenten erhalten Farben, Schrift und Radien aus SphygmaTheme. Die sechs Charakteristiken behalten ihre Strukturmerkmale; Daten, Berechnungen und Aktionen bleiben unverändert.

## Arbeitspakete

- [x] Gemeinsame Grundlage: `widgets/panel_header.dart`, `section_header.dart`, `theme/material_theme.dart`, `sphygma_app.dart`. Kartenkopf mit Titel, optionalem Icon/Untertitel/Aktion; Umbruch bei großer Schrift. Material-Theme deckt dunkle Palette, Dialoge, Blätter, Eingaben, Chips und Buttons ab. Regression: Nachtpalette muss auch bei Material-Widgets dunkel bleiben.
- [x] Heute: `this_week_panel.dart`, `week_grid.dart`, `today_screen.dart`, `today_vitals.dart`. Wochenmittel als eigene Kennzahl; Raster mit mindestens 48 Pixel hohen Feldern und horizontaler Scrollmöglichkeit bei großer Schrift. Letzte Messungen mit getrenntem Blutdruck/Puls und Zeit. Leere Felder, Datumswechsel und Abschaltbarkeit erhalten.
- [x] Verlauf/gemeinsame Messungszeile: `history_screen.dart`, `widgets/measurement_list_item.dart`, `stat_tiles.dart`, `notice_card.dart`. Einheitliche Zeit-/Wert-/Statusstruktur; Virtualisierung beibehalten; Filter umbruchfähig; Überschriften ohne Versalien.
- [x] Einstellungen/Messplan: `settings_screen.dart`, `plan/*.dart`, `setting_row.dart`, `measurement_windows_editor.dart`. Gemeinsame Köpfe, Abstände, lesbare Beschriftungen, flexible Aktionen. Funktionen und Erinnerungszustände unverändert.
- [x] Detailblätter/Metadaten: `measurement_sheet.dart`, `metadata/*.dart`, `phases/*.dart`, `intake_choice_sheet.dart`. Einheitliche Abschnitte und Felder, responsive Listen/Aktionen, bestehende Speicherabläufe erhalten.
- [x] Prüfung: gezielte Widgettests zuerst, anschließend `flutter analyze` und gesamte Testsuite. Alle Formen bei schmalem Bildschirm/doppelter Schrift sowie helle/dunkle Material-Elemente prüfen. Sichtprüfung mit gerenderten Widgetbildern. Keine APK/Installation und kein Commit ohne aktuellen Auftrag.

## Gestaltungsregeln

Kartenkopf 18 Pixel/semibold; Zwischenüberschrift 15 Pixel/semibold; Erklärung 13–14 Pixel. Messwerte deutlich größer und tabellarisch, Einheiten ausdrücklich benennen. Palette bestimmt Farben, Form bestimmt Linien/Flächen/Radien; keine neue dekorative Kategorienfarbe. Bei Platzmangel umordnen oder Raster scrollbar machen, keine Zahlen verkleinern oder abschneiden. Gemeinsame Aktionen behalten ausreichend große Touchflächen.

## Prüfstand

`flutter analyze`: ohne Befund. `flutter test`: 688 Tests bestanden. `flutter test --dart-define=SPHYGMA_ESC=true`: ebenfalls 688 Tests bestanden. Sechs reale Widget-Renderings visuell geprüft; große Schrift zusätzlich interaktiv in Widgettests geprüft. In bestehenden Datenbanktests erscheinen Drift-Hinweise zu mehreren Testdatenbank-Instanzen. Auf anschließenden Installationsauftrag eine ARM64-Debug-APK mit Versionscode 2006 und `SPHYGMA_ESC=true` gebaut. Am 12.09.2026 per `adb install -r` als Update von 2005 installiert; Paketversion 2006 und App-Start (`Status: ok`, laufender Prozess) verifiziert. App-Daten nicht gelöscht. Kein Commit.
