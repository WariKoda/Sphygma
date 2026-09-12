# B — Darstellung und Filter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans. Work task-by-task. No commits, APK builds or installation without explicit user request.

**Goal:** Eine konsistente, in allen Formen nutzbare Messungsansicht mit Filtern, interaktiven Kurven und abschaltbaren Heute-Abschnitten.

**Architecture:** Eine reine Auswahlfunktion liefert die Eingabe für Liste, Kurve und normale Kennzahlen. Theme-Bausteine bestimmen weiter die Form. UI-Selektion verwendet Messungs-IDs statt Listenindizes.

**Tech Stack:** Flutter-Widgets, vorhandenes CustomPainter-Diagramm, Dart-Rechenfunktionen; keine zusätzliche Chartbibliothek.

## Global Constraints

[Gemeinsame Constraints](2026-09-11-messungen-phasen-messplan.md#global-constraints)
und Teil A gelten. Reale Ausgangsdateien: `history_screen.dart`, `today_screen.dart`,
`chart_geometry.dart`, `trend_chart.dart`, `reading_headline.dart`, `reading_panel.dart`.
B setzt die neuen `MetadataStore`-/`PhaseStore`-Daten aus A voraus.

## B1 — Ein Filter für den gesamten Verlauf

**Dateien:** neu `lib/stats/measurement_filter.dart`, `lib/ui/metadata/history_filter_sheet.dart`,
`test/stats/measurement_filter_test.dart`, `test/ui/history_filter_test.dart`;
ändern `lib/app/app_controller.dart`, `lib/ui/history_screen.dart`.

**Neue Verträge und Kernlogik:**

```dart
enum MatchMode { any, all }
enum MembershipFilter { unrestricted, selected, unassigned }

class HistoryFilter {
  const HistoryFilter({
    this.tagIds = const {}, this.tagMode = MatchMode.any,
    this.tags = MembershipFilter.unrestricted,
    this.phaseIds = const {}, this.phaseMode = MatchMode.any,
    this.phases = MembershipFilter.unrestricted,
  });
  final Set<int> tagIds;
  final Set<int> phaseIds;
  final MatchMode tagMode;
  final MatchMode phaseMode;
  final MembershipFilter tags;
  final MembershipFilter phases;
}

bool matchesMembership(Set<int> actual, Set<int> selected,
    MembershipFilter filter, MatchMode mode) => switch (filter) {
  MembershipFilter.unrestricted => true,
  MembershipFilter.unassigned => actual.isEmpty,
  MembershipFilter.selected => selected.isNotEmpty &&
    (mode == MatchMode.all
      ? actual.containsAll(selected)
      : selected.any(actual.contains)),
};
```

Neue Funktion `List<Measurement> applyHistoryFilter(List<Measurement> inPeriod,
HistoryFilter filter, {required Map<int, Set<int>> tagIdsBySequence,
required Map<int, Set<int>> phaseIdsBySequence})`: filtert jede Messung genau einmal
mit `matchesMembership(tags) && matchesMembership(phases)`. Die leere Auswahl von
IDs setzt die UI auf `unrestricted`; ausgewählte und unassigned Modi nicht mischen.
`inPeriod` kommt aus vorhandenem `filterByPeriod`; aus fehlenden Map-Einträgen folgt
hier tatsächlich keine Zuordnung, nicht ein unterdrückter DB-Lesefehler.

- [x] **Rot:** Auswahlfälle als reine Tests anlegen:

```dart
expect(matchesMembership({1}, {1, 2}, MembershipFilter.selected, MatchMode.any), isTrue);
expect(matchesMembership({1}, {1, 2}, MembershipFilter.selected, MatchMode.all), isFalse);
expect(matchesMembership({1, 2}, {1, 2}, MembershipFilter.selected, MatchMode.all), isTrue);
expect(matchesMembership({}, {}, MembershipFilter.unassigned, MatchMode.any), isTrue);
```

  Zusätzlich echte Messungen mit zwei Phasen und zwei Tags durch `applyHistoryFilter`
  schicken: gleiche ID nur einmal, Zeitraum UND Tags UND Phasen, leere Trefferliste,
  Filter nach gelöschtem Tag, Reset, Slotwechsel und disabled Phasen prüfen.
- [x] **Rot ausführen:** `flutter test --no-pub test/stats/measurement_filter_test.dart test/ui/history_filter_test.dart`.
- [x] **Implementieren:** Controller führt `HistoryFilter historyFilter` und Getter
  `filteredMeasurements`; Rohbestand/Intake-Grenze unverändert. Liste, `PeriodAverages`,
  Tageszeiten und Chart erhalten dieselbe Auswahl. Aktive Filter + „x von y Messungen“
  (y=Zeitraumauswahl vor Metadatenfilter) + „Filter zurücksetzen“. Tags/Phasen im Sheet
  wählen; ANY/ALL erst bei mindestens zwei IDs anzeigen. Slotwechsel/Phasen-deaktivieren
  entfernt unpassende aktive Filter und Auswahlzustände. Löschen einer verwendeten ID
  entfernt sie aus dem Filter, statt dauerhaft eine unerklärte leere Ansicht zu zeigen.
- [x] **Wochenwerte behandeln:** Bestehende `_Wochenwert.stats` nur ohne Tag-/Phasenfilter
  und beim bisherigen Zeitraum Woche. Text erklärt dann weiterhin den vorhandenen
  Berechnungsumfang; keine geänderte Klassifikation oder andere medizinische Rechenregel.
- [x] **Grün:** dieselben Tests plus `flutter test --no-pub test/ui/history_screen_test.dart test/stats`, Analyse.
  Widgettest liest die sichtbare Trefferzahl und Mittelwerte, nicht nur interne Filterflags.

## B2 — Interaktives Blutdruck-/Pulsdiagramm

**Dateien:** ändern `lib/stats/chart_geometry.dart`, `lib/ui/widgets/trend_chart.dart`,
`lib/ui/history_screen.dart`; neu `lib/ui/widgets/chart_selection_summary.dart`;
ändern `test/stats/chart_geometry_test.dart`, `test/ui/widgets/trend_chart_test.dart`.

**Neuer Vertrag:** `enum ChartMetric { bloodPressure, pulse }` in chart_geometry.dart.
`ChartGeometry.fit` erhält optional `ChartMetric metric=ChartMetric.bloodPressure`;
Ergebnis zusätzlich `List<Offset> pulsePoints` und `List<int> measurementIds`.
`TrendChart` erhält metric und `ValueChanged<int>? onMeasurementSelected`.
Punktselektion bleibt beim Wechsel der Metrik auf derselben Messungs-ID.

- [x] **Rot:** Geometrie mit Messzeiten 08:00/08:05/10:00 bei Breite120: x=0/5/120;
  eine Messung mittig, gleiche Zeiten endliche Koordinaten, konstante Pulswerte keine
  Division durch null, Pulse ohne Blutdruck-Schwellenlinie. Widgettest tippt einen
  Punkt, sieht Datum, SYS/DIA/Puls, öffnet dasselbe Messungsdetail und bearbeitet Tags.
- [x] **Rot ausführen:** `flutter test --no-pub test/stats/chart_geometry_test.dart test/ui/widgets/trend_chart_test.dart`.
- [x] **Geometrie ersetzen:** Bei mehreren verschiedenen Zeiten linearer Zeitabstand:

```dart
double timeX(DateTime at, DateTime first, DateTime last, double width) {
  final span = last.difference(first).inMicroseconds;
  if (span == 0) return width / 2;
  return at.difference(first).inMicroseconds / span * width;
}
```

  Chronologisch sortieren, bei gleichem Zeitpunkt nach Gerätenummer. Positive Größe
  und nichtleere Eingabe wie bisher verlangen. SYS/DIA gemeinsam skalieren, Puls separat.
  Nicht plausible Messzeiten aus der Kurve ausschließen und Anzahl sichtbar nennen;
  dieselben Messungen bleiben in der Liste zugänglich. Plausibilitätsprüfung aus A3
  verwenden, nicht auf der gefilterten Teilmenge neu urteilen.
- [x] **Painter/Interaktion:** Gerade Linien; alle SYS-Punkte gefüllt und DIA-Punkte
  offen, Legende und Achsenwerte mit Einheiten. Nächstes x bei Touch auswählen;
  bei übereinanderliegenden Zeiten über Vorher/Nächste navigieren. `Semantics` und
  Textzusammenfassung ermöglichen denselben Zugang ohne präzises Tippen. Filterwechsel
  verwirft eine nicht mehr vorhandene Auswahl; kein falsches Detail durch alte Indizes.
- [x] **Grün:** Geometrie/Widgettests, `flutter test --no-pub test/ui/theme`;
  `flutter test --no-pub --dart-define=SPHYGMA_ESC=true test/ui/widgets/trend_chart_test.dart`;
  Analyse. 320px Breite, große Systemschrift, leere Liste und ein einzelner Wert prüfen.

## B3 — Heute, Sichtbarkeit und letzter Abgleich

**Dateien:** ändern `lib/ui/today_screen.dart`, `lib/ui/widgets/reading_headline.dart`,
`lib/ui/widgets/reading_panel.dart`, `lib/ui/settings_screen.dart`,
`lib/db/settings_repository.dart`, `lib/app/app_controller.dart`;
neu `lib/ui/widgets/today_summary.dart`; ändern `test/ui/today_screen_test.dart`,
`test/ui/widgets/reading_headline_test.dart`, `test/ui/settings_screen_test.dart`;
neu `test/app/last_sync_test.dart`.

**Neue Settings-Verträge:**

```dart
// Methods to add to SettingsRepository:
Future<bool> recentMeasurementsVisible(); // key recent_measurements_visible, default true
Future<void> setRecentMeasurementsVisible(bool value);
Future<DateTime?> lastSuccessfulSyncAt(); // key last_successful_sync_at; missing means unknown
Future<void> setLastSuccessfulSyncAt(DateTime value);
```

Datetime als UTC-ISO8601 mit Zeitzonenkennung speichern, lokal formatieren.
Fehlendes Datum: „Noch nicht erfasst“, nicht `importedAt` als angeblichen letzten
Sync verwenden. Ungültig gespeicherter Wert wird explizit gemeldet.

- [x] **Rot:** Nach erfolgreichem Readout ohne neue Werte ist lastSuccessfulSyncAt
  gesetzt; nach Readoutfehler unverändert; bei anschließendem Exportfehler trotzdem
  gesetzt. Neustart lädt dieselbe Zeit. Sichtbarkeitsschalter wirken unabhängig:
  Wochenraster aus/letzte an und umgekehrt, beide aus; Messkarte bleibt sichtbar.
- [x] **Rot ausführen:** `flutter test --no-pub test/app/last_sync_test.dart test/ui/today_screen_test.dart test/ui/settings_screen_test.dart`.
- [x] **Sync-Hook:** Zeit nach erfolgreichem `syncService.sync` und vor `_autoExport`
  speichern. Uhr als bestehender/neuer optionaler `DateTime Function()`-Parameter
  injizieren, damit Tests feste Zeiten verwenden. Importergebnis und fehlgeschlagene
  Statuspersistenz im Fehlertext unterscheidbar halten; kein erneut erfundener Import.
- [x] **Heute gestalten:** ReadingHeadline behält formeigene SYS/DIA-Darstellung;
  gemeinsamer Puls-/Einheitenbereich und Datum. Tap öffnet vorhandenes Detailblatt.
  TodaySummary berechnet den Mittelwert aller heutigen Einzelmessungen samt Anzahl;
  keine Anlassaggregation. „Letzte Messungen“ zeigt die vorhandenen letzten fünf
  weiteren Messungen, jetzt antippbar. Über Mitternacht `AtDayChange` auch für
  Zusammenfassung verwenden. Keine Autosync-Warnkarte wieder hinzufügen.
- [x] **Grün:** genannte Tests, `flutter test --no-pub test/ui test/app`, Analyse.
  Darstellung in jeder Charakteristik und mit Textskalierung2 ohne Overflow;
  gespeicherte historische Messung bleibt korrekt datiert, auch wenn heute leer ist.
