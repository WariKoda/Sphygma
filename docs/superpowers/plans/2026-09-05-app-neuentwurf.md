# Neuentwurf der Sphygma-Oberfläche

> **Für agentische Bearbeiter:** ERFORDERLICHER SUB-SKILL: `superpowers:subagent-driven-development` (empfohlen) oder `superpowers:executing-plans`, um diesen Plan Aufgabe für Aufgabe umzusetzen. Die Schritte tragen Kästchen (`- [ ]`) zur Nachverfolgung.

**Ziel:** Die App wird ein Blutdruck-Tagebuch mit drei Bereichen, drei umschaltbaren Gestaltungen, einer Verlaufskurve und Berichten für die Arztpraxis.

**Aufbau:** Die bestehende Schichtung bleibt unangetastet (UI → Sync → {DB | Health Connect} → Protokoll → BLE). Neu sind eine Gestaltungsabstraktion, ein Berichtsdienst und drei neu geschnittene Bildschirme. Der Steuerungsteil bekommt Zeitraumwahl und Gestaltungswahl.

**Werkzeuge:** Flutter 3.47.2, drift, `fl_chart` 1.2.0, `pdf` 3.13.0, `printing` 5.15.0, `share_plus` 13.3.0.

**Spezifikation:** `docs/superpowers/specs/2026-09-05-app-neuentwurf-design.md`

**Entwürfe:** `docs/design/entwuerfe.html` — im Browser öffnen. Zeigt die drei
Gestaltungen nebeneinander und die drei Bereiche mit echten Werten. Die
Farbwerte in Aufgabe 2 stammen von dort; wer sie ändert, ändert auch das
Dokument.

## Durchgehende Vorgaben

- **Deutsch** in allen sichtbaren Texten, Code-Bezeichner englisch.
- **Fail hard.** Fehler werden geworfen, nie durch Ersatzwerte verdeckt. Eine leere Liste darf nie einen Fehler bedeuten.
- **Kein Widget greift auf feste Farbwerte zu.** Farben und Maße kommen ausschließlich aus `SphygmaTheme`.
- **Die Klassifikation bleibt hinter `escClassificationEnabled`** (`lib/app/feature_flags.dart`). Ohne das Flag erscheint keine Einordnung, auch nicht im Bericht.
- **Nach jeder Änderung:** `flutter analyze` (0 Befunde) und `flutter test`.
- **Der Bericht ist keine ärztliche Bewertung** und trägt einen entsprechenden Hinweis.
- Bestehende Signaturen, auf die der Plan aufbaut:
  - `Measurement`: `id`, `userSlot`, `deviceSequence`, `systolic`, `diastolic`, `pulse`, `measuredAt`, `movement`, `arrhythmia`, `rawBytes`, `importedAt`, `exportedAt`
  - `MeasurementRepository.allForSlot(int)`, `.pendingExport(int)`, `.exported(int)`, `.highestSequenceFor(int)`
  - `SettingsRepository.userSlot()`, `.setUserSlot(int)`
  - `AppController`: `userSlot`, `paired`, `busy`, `status`, `measurements`, `pendingExport`, `clockLooksWrong`, `autoSyncActive`, `pair()`, `sync()`, `exportAll()`, `retractAll()`, `exportOne(Measurement)`, `retractOne(Measurement)`
  - `classifyOffice({required int systolic, required int diastolic})` → `EscCategory`

---

## Dateiaufteilung

**Neu**

| Datei | Zuständigkeit |
|---|---|
| `lib/ui/theme/sphygma_theme.dart` | Farb- und Maßtabelle als Daten, plus Zugriff über den Widget-Baum |
| `lib/ui/theme/variants.dart` | Die drei Gestaltungen als Instanzen |
| `lib/db/settings_repository.dart` | *(erweitert)* Gestaltungswahl |
| `lib/stats/period.dart` | Zeitraum als Wert, Filterung einer Messungsliste |
| `lib/ui/today_screen.dart` | Bereich „Heute" |
| `lib/ui/history_screen.dart` | Bereich „Verlauf" |
| `lib/ui/device_screen.dart` | Bereich „Gerät" |
| `lib/ui/measurement_sheet.dart` | Detail-Blatt je Messung |
| `lib/ui/widgets/reading_headline.dart` | Große Wertdarstellung, in „Heute" und im Blatt |
| `lib/ui/widgets/classification_scale.dart` | Skala mit Zeiger |
| `lib/ui/widgets/notice_card.dart` | Hinweisfeld mit aufklappbarem Inhalt |
| `lib/ui/widgets/trend_chart.dart` | Kurve |
| `lib/report/report_data.dart` | Berichtsinhalt als reine Daten |
| `lib/report/csv_report.dart` | CSV-Erzeugung |
| `lib/report/pdf_report.dart` | PDF-Erzeugung |
| `lib/report/report_service.dart` | Erzeugen und Weitergeben |

**Geändert**

| Datei | Änderung |
|---|---|
| `lib/ui/sphygma_app.dart` | Drei Bereiche statt vier, Gestaltung anwenden |
| `lib/app/app_controller.dart` | Zeitraum, Gestaltung, Bericht |
| `pubspec.yaml` | vier Pakete |

**Entfällt**

`lib/ui/home_screen.dart`, `lib/ui/measurements_screen.dart`, `lib/ui/trends_screen.dart` gehen in den drei neuen Bereichen auf. `lib/ui/pairing_screen.dart` wandert in den Gerätebereich.

---

## Aufgabe 1: Gestaltungstabelle

**Dateien**
- Neu: `lib/ui/theme/sphygma_theme.dart`
- Test: `test/ui/theme/sphygma_theme_test.dart`

**Schnittstellen**
- Liefert: `SphygmaTheme` mit den Feldern `name`, `surface`, `onSurface`, `muted`, `line`, `accent`, `categoryColors` (Map von `EscCategory` auf `Color`), `radius`, `gapSmall`, `gapLarge`, `headlineSize`, `useRoundedCards`; dazu `SphygmaTheme.of(BuildContext)` und das Widget `SphygmaThemeScope({required SphygmaTheme theme, required Widget child})`.

- [ ] **Schritt 1: Test schreiben**

```dart
// test/ui/theme/sphygma_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/esc_classification.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';

const _t = SphygmaTheme(
  name: 'Prüfmuster',
  surface: Color(0xFFFAF9F7),
  onSurface: Color(0xFF1B1B1A),
  muted: Color(0x991B1B1A),
  line: Color(0xFFE4E1DB),
  accent: Color(0xFF1B1B1A),
  categoryColors: {
    EscCategory.optimal: Color(0xFF7EA77E),
    EscCategory.normal: Color(0xFF7EA77E),
    EscCategory.highNormal: Color(0xFFC9B45E),
    EscCategory.grade1: Color(0xFFC07D5A),
    EscCategory.grade2: Color(0xFFC07D5A),
    EscCategory.grade3: Color(0xFFA84C3A),
  },
  radius: 8,
  gapSmall: 8,
  gapLarge: 20,
  headlineSize: 56,
  useRoundedCards: false,
);

void main() {
  testWidgets('of() liefert die eingesetzte Gestaltung', (tester) async {
    late SphygmaTheme seen;
    await tester.pumpWidget(SphygmaThemeScope(
      theme: _t,
      child: Builder(builder: (context) {
        seen = SphygmaTheme.of(context);
        return const SizedBox();
      }),
    ));

    expect(seen.name, 'Prüfmuster');
    expect(seen.headlineSize, 56);
  });

  test('jede Kategorie hat eine Farbe - keine Luecke', () {
    for (final c in EscCategory.values) {
      expect(_t.categoryColors[c], isNotNull, reason: 'fehlt: $c');
    }
  });

  testWidgets('of() wirft ohne Scope statt still einen Default zu liefern',
      (tester) async {
    await tester.pumpWidget(Builder(builder: (context) {
      expect(() => SphygmaTheme.of(context), throwsFlutterError);
      return const SizedBox();
    }));
  });
}
```

- [ ] **Schritt 2: Test ausführen, Fehlschlag bestätigen**

Ausführen: `flutter test test/ui/theme/sphygma_theme_test.dart`
Erwartet: FEHLER, `sphygma_theme.dart` fehlt.

- [ ] **Schritt 3: Umsetzen**

```dart
// lib/ui/theme/sphygma_theme.dart
// Gestaltung als Daten, nicht als fest verdrahtete Werte. Drei Varianten
// sind umschaltbar (Spezifikation vom 2026-09-05); kein Widget greift auf
// feste Farben zu, sonst waere der Wechsel ein Umbau.
import 'package:flutter/widgets.dart';

import '../../stats/esc_classification.dart';

@immutable
class SphygmaTheme {
  const SphygmaTheme({
    required this.name,
    required this.surface,
    required this.onSurface,
    required this.muted,
    required this.line,
    required this.accent,
    required this.categoryColors,
    required this.radius,
    required this.gapSmall,
    required this.gapLarge,
    required this.headlineSize,
    required this.useRoundedCards,
  });

  /// Sichtbarer Name in der Auswahl.
  final String name;

  final Color surface;
  final Color onSurface;

  /// Fuer Nebensaechliches: Einheiten, Zeitangaben, Beschriftungen.
  final Color muted;

  /// Trennlinien.
  final Color line;

  /// Betonung, etwa der Zeiger auf der Skala.
  final Color accent;

  /// Farbe je Einordnung. Hier traegt Farbe Bedeutung, nirgends sonst.
  final Map<EscCategory, Color> categoryColors;

  final double radius;
  final double gapSmall;
  final double gapLarge;
  final double headlineSize;
  final bool useRoundedCards;

  /// Wirft, wenn kein [SphygmaThemeScope] darueber liegt. Ein stiller
  /// Ersatzwert wuerde die Gestaltung unbemerkt zerfallen lassen.
  static SphygmaTheme of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_SphygmaThemeScope>();
    if (scope == null) {
      throw FlutterError(
        'SphygmaTheme.of() ohne SphygmaThemeScope aufgerufen. '
        'Der Scope gehoert oberhalb jedes Bildschirms in den Baum.',
      );
    }
    return scope.theme;
  }
}

class SphygmaThemeScope extends StatelessWidget {
  const SphygmaThemeScope({
    super.key,
    required this.theme,
    required this.child,
  });

  final SphygmaTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _SphygmaThemeScope(theme: theme, child: child);
}

class _SphygmaThemeScope extends InheritedWidget {
  const _SphygmaThemeScope({required this.theme, required super.child});

  final SphygmaTheme theme;

  @override
  bool updateShouldNotify(_SphygmaThemeScope old) => old.theme != theme;
}
```

- [ ] **Schritt 4: Test ausführen, Erfolg bestätigen**

Ausführen: `flutter test test/ui/theme/sphygma_theme_test.dart`
Erwartet: alle grün.

- [ ] **Schritt 5: Prüfen und committen**

```bash
flutter analyze && flutter test
git add lib/ui/theme/sphygma_theme.dart test/ui/theme/sphygma_theme_test.dart
git commit -m "feat(ui): Gestaltung als austauschbare Datentabelle"
```

---

## Aufgabe 2: Die drei Gestaltungen

**Dateien**
- Neu: `lib/ui/theme/variants.dart`
- Test: `test/ui/theme/variants_test.dart`

**Schnittstellen**
- Nutzt: `SphygmaTheme` aus Aufgabe 1.
- Liefert: `enum ThemeVariant { instrument, diary, material }`, `SphygmaTheme themeFor(ThemeVariant)`, `const List<ThemeVariant> allVariants`.

- [ ] **Schritt 1: Test schreiben**

```dart
// test/ui/theme/variants_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/esc_classification.dart';
import 'package:sphygma/ui/theme/variants.dart';

void main() {
  test('jede Variante ist vollstaendig', () {
    for (final v in allVariants) {
      final t = themeFor(v);
      expect(t.name, isNotEmpty, reason: '$v ohne Namen');
      expect(t.headlineSize, greaterThan(0));
      for (final c in EscCategory.values) {
        expect(t.categoryColors[c], isNotNull, reason: '$v: Farbe fehlt fuer $c');
      }
    }
  });

  test('die Varianten sind unterscheidbar', () {
    final namen = allVariants.map((v) => themeFor(v).name).toSet();

    expect(namen, hasLength(allVariants.length));
  });

  test('steigende Schwere bekommt nicht dieselbe Farbe wie optimal', () {
    for (final v in allVariants) {
      final t = themeFor(v);

      expect(
        t.categoryColors[EscCategory.grade3],
        isNot(t.categoryColors[EscCategory.optimal]),
        reason: '$v: Grad 3 sieht aus wie optimal',
      );
    }
  });
}
```

- [ ] **Schritt 2: Test ausführen, Fehlschlag bestätigen**

Ausführen: `flutter test test/ui/theme/variants_test.dart`
Erwartet: FEHLER, `variants.dart` fehlt.

- [ ] **Schritt 3: Umsetzen**

```dart
// lib/ui/theme/variants.dart
// Drei Handschriften fuer dieselbe Struktur. Der Nutzer waehlt unter
// "Geraet"; die Wahl liegt in SettingsRepository.
import 'package:flutter/widgets.dart';

import '../../stats/esc_classification.dart';
import 'sphygma_theme.dart';

enum ThemeVariant { instrument, diary, material }

const List<ThemeVariant> allVariants = ThemeVariant.values;

/// Gruen fuer unauffaellig, Gelb fuer Grenzbereich, Rot fuer erhoeht.
/// Zurueckhaltend gewaehlt: Es geht um Einordnung, nicht um Alarm.
const Map<EscCategory, Color> _calmScale = {
  EscCategory.optimal: Color(0xFF7EA77E),
  EscCategory.normal: Color(0xFF7EA77E),
  EscCategory.highNormal: Color(0xFFC9B45E),
  EscCategory.grade1: Color(0xFFC07D5A),
  EscCategory.grade2: Color(0xFFB05F42),
  EscCategory.grade3: Color(0xFFA84C3A),
};

const Map<EscCategory, Color> _vividScale = {
  EscCategory.optimal: Color(0xFF3FA35F),
  EscCategory.normal: Color(0xFF3FA35F),
  EscCategory.highNormal: Color(0xFFE0A93B),
  EscCategory.grade1: Color(0xFFE07A3B),
  EscCategory.grade2: Color(0xFFD9553C),
  EscCategory.grade3: Color(0xFFC33A2E),
};

SphygmaTheme themeFor(ThemeVariant variant) => switch (variant) {
      ThemeVariant.instrument => const SphygmaTheme(
          name: 'Messinstrument',
          surface: Color(0xFFFAF9F7),
          onSurface: Color(0xFF1B1B1A),
          muted: Color(0x8A1B1B1A),
          line: Color(0xFFE4E1DB),
          accent: Color(0xFF1B1B1A),
          categoryColors: _calmScale,
          radius: 4,
          gapSmall: 8,
          gapLarge: 22,
          headlineSize: 56,
          useRoundedCards: false,
        ),
      ThemeVariant.diary => const SphygmaTheme(
          name: 'Tagebuch',
          surface: Color(0xFFF2F5FB),
          onSurface: Color(0xFF182034),
          muted: Color(0x8A182034),
          line: Color(0xFFE2E8F3),
          accent: Color(0xFF4F7FD8),
          categoryColors: _vividScale,
          radius: 18,
          gapSmall: 10,
          gapLarge: 18,
          headlineSize: 48,
          useRoundedCards: true,
        ),
      ThemeVariant.material => const SphygmaTheme(
          name: 'Material',
          surface: Color(0xFFFEF7FF),
          onSurface: Color(0xFF1D1B20),
          muted: Color(0xFF49454F),
          line: Color(0xFFE7E0EC),
          accent: Color(0xFF6750A4),
          categoryColors: _vividScale,
          radius: 12,
          gapSmall: 8,
          gapLarge: 16,
          headlineSize: 44,
          useRoundedCards: true,
        ),
    };
```

- [ ] **Schritt 4: Test ausführen, Erfolg bestätigen**

Ausführen: `flutter test test/ui/theme/variants_test.dart`
Erwartet: alle grün.

- [ ] **Schritt 5: Prüfen und committen**

```bash
flutter analyze && flutter test
git add lib/ui/theme/variants.dart test/ui/theme/variants_test.dart
git commit -m "feat(ui): drei Gestaltungsvarianten"
```

---

## Aufgabe 3: Gestaltungswahl speichern

**Dateien**
- Ändern: `lib/db/settings_repository.dart`
- Test: `test/db/settings_repository_test.dart`

**Schnittstellen**
- Nutzt: `ThemeVariant` aus Aufgabe 2.
- Liefert: `SettingsRepository.themeVariant()` → `Future<ThemeVariant>` (Standard `ThemeVariant.instrument`), `.setThemeVariant(ThemeVariant)` → `Future<void>`.

Hinweis zum Standardwert: Anders als beim Speicherplatz ist ein Standard hier richtig. Eine fehlende Gestaltungswahl ist kein Zustand, den der Nutzer klären muss.

- [ ] **Schritt 1: Test schreiben**

An `test/db/settings_repository_test.dart` anhängen, innerhalb von `main()`:

```dart
  group('themeVariant', () {
    test('ohne Wahl steht das Messinstrument', () async {
      expect(await repository.themeVariant(), ThemeVariant.instrument);
    });

    test('speichert und liest die Wahl', () async {
      await repository.setThemeVariant(ThemeVariant.diary);

      expect(await repository.themeVariant(), ThemeVariant.diary);
    });

    test('ein unbekannter gespeicherter Wert faellt auf den Standard',
        () async {
      // Kann nach einem Rueckbau vorkommen. Die Gestaltung ist kein
      // korrektheitsrelevanter Wert - hier ist der Standard richtig.
      await repository.setThemeVariant(ThemeVariant.material);
      await repository.setRawSetting('theme_variant', 'gibtsnicht');

      expect(await repository.themeVariant(), ThemeVariant.instrument);
    });
  });
```

Am Kopf der Testdatei ergänzen:

```dart
import 'package:sphygma/ui/theme/variants.dart';
```

- [ ] **Schritt 2: Test ausführen, Fehlschlag bestätigen**

Ausführen: `flutter test test/db/settings_repository_test.dart`
Erwartet: FEHLER, `themeVariant` fehlt.

- [ ] **Schritt 3: Umsetzen**

In `lib/db/settings_repository.dart` einfügen, vor der schließenden Klammer der Klasse:

```dart
  static const String _themeVariantKey = 'theme_variant';

  /// Die gewaehlte Gestaltung. Anders als beim User-Slot ist hier ein
  /// Standard richtig: Eine fehlende Wahl ist kein Zustand, den der
  /// Nutzer klaeren muss.
  Future<ThemeVariant> themeVariant() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_themeVariantKey)))
        .getSingleOrNull();
    if (row == null) return ThemeVariant.instrument;
    for (final v in allVariants) {
      if (v.name == row.value) return v;
    }
    return ThemeVariant.instrument;
  }

  Future<void> setThemeVariant(ThemeVariant variant) =>
      setRawSetting(_themeVariantKey, variant.name);

  /// Schreibt einen Einstellungswert unmittelbar. Oeffentlich, weil Tests
  /// ungueltige Zustaende herstellen koennen muessen.
  Future<void> setRawSetting(String key, String value) async {
    await _db.into(_db.appSettings).insert(
          AppSettingsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }
```

Und am Kopf der Datei:

```dart
import '../ui/theme/variants.dart';
```

- [ ] **Schritt 4: Test ausführen, Erfolg bestätigen**

Ausführen: `flutter test test/db/settings_repository_test.dart`
Erwartet: alle grün.

- [ ] **Schritt 5: Prüfen und committen**

```bash
flutter analyze && flutter test
git add lib/db/settings_repository.dart test/db/settings_repository_test.dart
git commit -m "feat(db): Gestaltungswahl speichern"
```

---

## Aufgabe 4: Zeitraum

**Dateien**
- Neu: `lib/stats/period.dart`
- Test: `test/stats/period_test.dart`

**Schnittstellen**
- Liefert: `enum Period { week, month, year, all }` mit `String get label` und `DateTime? startFrom(DateTime now)`; dazu `List<Measurement> filterByPeriod(List<Measurement> all, Period period, DateTime now)`.

- [ ] **Schritt 1: Test schreiben**

```dart
// test/stats/period_test.dart
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/period.dart';

Measurement _m(DateTime at) => Measurement(
      id: at.millisecondsSinceEpoch,
      userSlot: 1,
      deviceSequence: at.millisecondsSinceEpoch ~/ 1000,
      systolic: 120,
      diastolic: 80,
      pulse: 70,
      measuredAt: at,
      movement: false,
      arrhythmia: false,
      rawBytes: Uint8List(14),
      importedAt: at,
      exportedAt: null,
    );

void main() {
  final now = DateTime(2026, 9, 5, 12);

  test('Woche nimmt die letzten sieben Tage', () {
    final alle = [
      _m(now.subtract(const Duration(days: 1))),
      _m(now.subtract(const Duration(days: 6))),
      _m(now.subtract(const Duration(days: 8))),
    ];

    expect(filterByPeriod(alle, Period.week, now), hasLength(2));
  });

  test('Alles nimmt jede Messung', () {
    final alle = [_m(DateTime(2019, 1, 1)), _m(now)];

    expect(filterByPeriod(alle, Period.all, now), hasLength(2));
  });

  test('Messungen in der Zukunft fallen heraus', () {
    // Kommt bei falsch gestellter Geraeteuhr vor; sie wuerden sonst jeden
    // Zeitraum verfaelschen.
    final alle = [_m(now.add(const Duration(days: 2))), _m(now)];

    expect(filterByPeriod(alle, Period.week, now), hasLength(1));
  });

  test('jeder Zeitraum hat eine Beschriftung', () {
    for (final p in Period.values) {
      expect(p.label, isNotEmpty);
    }
  });

  test('Alles hat keinen Anfang', () {
    expect(Period.all.startFrom(now), isNull);
    expect(Period.month.startFrom(now), isNotNull);
  });
}
```

- [ ] **Schritt 2: Test ausführen, Fehlschlag bestätigen**

Ausführen: `flutter test test/stats/period_test.dart`
Erwartet: FEHLER, `period.dart` fehlt.

- [ ] **Schritt 3: Umsetzen**

```dart
// lib/stats/period.dart
// Zeitraumwahl im Verlauf. Rein rechnend, ohne Flutter, damit ohne
// Oberflaeche pruefbar.
import '../db/app_database.dart';

enum Period {
  week('Woche', Duration(days: 7)),
  month('Monat', Duration(days: 30)),
  year('Jahr', Duration(days: 365)),
  all('Alles', null);

  const Period(this.label, this._span);

  final String label;
  final Duration? _span;

  /// Anfang des Zeitraums, oder null fuer "Alles".
  DateTime? startFrom(DateTime now) =>
      _span == null ? null : now.subtract(_span);
}

/// Messungen im gewaehlten Zeitraum, aelteste zuerst.
///
/// Messungen mit einem Zeitstempel in der Zukunft fallen heraus: Bei
/// falsch gestellter Geraeteuhr kommen sie vor und wuerden jeden
/// Zeitraum verfaelschen (docs/protocol/hem-6232t.md §8.2).
List<Measurement> filterByPeriod(
  List<Measurement> all,
  Period period,
  DateTime now,
) {
  final start = period.startFrom(now);
  return [
    for (final m in all)
      if (!m.measuredAt.isAfter(now) &&
          (start == null || !m.measuredAt.isBefore(start)))
        m,
  ]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
}
```

- [ ] **Schritt 4: Test ausführen, Erfolg bestätigen**

Ausführen: `flutter test test/stats/period_test.dart`
Erwartet: alle grün.

- [ ] **Schritt 5: Prüfen und committen**

```bash
flutter analyze && flutter test
git add lib/stats/period.dart test/stats/period_test.dart
git commit -m "feat(stats): Zeitraumwahl fuer den Verlauf"
```

---

## Aufgabe 5: Steuerungsteil erweitern

**Dateien**
- Ändern: `lib/app/app_controller.dart`
- Test: `test/app/app_controller_view_test.dart`

**Schnittstellen**
- Nutzt: `Period`, `filterByPeriod` (Aufgabe 4), `ThemeVariant`, `themeFor` (Aufgabe 2), `SettingsRepository.themeVariant()` (Aufgabe 3).
- Liefert: `AppController.period` (`Period`, Standard `Period.week`), `.setPeriod(Period)`, `.themeVariant` (`ThemeVariant`), `.setThemeVariant(ThemeVariant)`, `.measurementsInPeriod` (gefiltert, älteste zuerst), `.latest` (`Measurement?`).

- [ ] **Schritt 1: Test schreiben**

```dart
// test/app/app_controller_view_test.dart
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/stats/period.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _rec(int seq, DateTime at) => SlotRecord(
      userSlot: 1,
      record: BloodPressureRecord(
        systolic: 120,
        diastolic: 80,
        pulse: 70,
        timestamp: at,
        arrhythmiaFlag: false,
        movementFlag: false,
        sequence: seq,
      ),
      rawBytes: Uint8List(14),
    );

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late AppController controller;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    final keyStore = InMemoryPairingKeyStore();
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService:
          ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    await controller.setUserSlot(1);
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  test('der Standardzeitraum ist die Woche', () {
    expect(controller.period, Period.week);
  });

  test('setPeriod filtert die Messungen', () async {
    final now = DateTime.now();
    await repository.importAll([
      _rec(1, now.subtract(const Duration(days: 2))),
      _rec(2, now.subtract(const Duration(days: 40))),
    ]);
    await controller.refreshForTest();

    expect(controller.measurementsInPeriod, hasLength(1));

    await controller.setPeriod(Period.all);

    expect(controller.measurementsInPeriod, hasLength(2));
  });

  test('latest ist die neueste Messung, unabhaengig vom Zeitraum', () async {
    final now = DateTime.now();
    await repository.importAll([
      _rec(1, now.subtract(const Duration(days: 40))),
      _rec(2, now.subtract(const Duration(days: 1))),
    ]);
    await controller.refreshForTest();

    expect(controller.latest?.deviceSequence, 2);
  });

  test('latest ist null, solange nichts gespeichert ist', () {
    expect(controller.latest, isNull);
  });

  test('die Gestaltung laesst sich wechseln und wird gespeichert', () async {
    expect(controller.themeVariant, ThemeVariant.instrument);

    await controller.setThemeVariant(ThemeVariant.diary);

    expect(controller.themeVariant, ThemeVariant.diary);
    expect(await SettingsRepository(db).themeVariant(), ThemeVariant.diary);
  });
}
```

- [ ] **Schritt 2: Test ausführen, Fehlschlag bestätigen**

Ausführen: `flutter test test/app/app_controller_view_test.dart`
Erwartet: FEHLER, `period` und `themeVariant` fehlen.

- [ ] **Schritt 3: Umsetzen**

In `lib/app/app_controller.dart` bei den Zustandsfeldern ergänzen:

```dart
  /// Gewaehlter Zeitraum im Verlauf.
  Period period = Period.week;

  /// Gewaehlte Gestaltung. Wird in [init] aus der DB geladen.
  ThemeVariant themeVariant = ThemeVariant.instrument;

  /// Die neueste Messung, unabhaengig vom Zeitraum. Null heisst: noch
  /// keine Messung gespeichert - ein echter Zustand, kein Fehler.
  Measurement? get latest => measurements.isEmpty ? null : measurements.first;

  /// Messungen im gewaehlten Zeitraum, aelteste zuerst.
  List<Measurement> get measurementsInPeriod =>
      filterByPeriod(measurements, period, DateTime.now());

  Future<void> setPeriod(Period value) async {
    period = value;
    notifyListeners();
  }

  Future<void> setThemeVariant(ThemeVariant value) async {
    await settings.setThemeVariant(value);
    themeVariant = value;
    notifyListeners();
  }

  /// Nur fuer Tests: erzwingt das Neuladen aus der DB.
  @visibleForTesting
  Future<void> refreshForTest() => _refresh();
```

In `init()` nach `paired = ...` ergänzen:

```dart
    themeVariant = await settings.themeVariant();
```

Am Kopf der Datei ergänzen:

```dart
import '../stats/period.dart';
import '../ui/theme/variants.dart';
```

Hinweis: `measurements` ist bereits neueste-zuerst sortiert (`_refresh` dreht die Liste um), deshalb ist `measurements.first` die neueste.

- [ ] **Schritt 4: Test ausführen, Erfolg bestätigen**

Ausführen: `flutter test test/app/app_controller_view_test.dart`
Erwartet: alle grün.

- [ ] **Schritt 5: Prüfen und committen**

```bash
flutter analyze && flutter test
git add lib/app/app_controller.dart test/app/app_controller_view_test.dart
git commit -m "feat(app): Zeitraum und Gestaltung im Steuerungsteil"
```

---

## Aufgabe 6: Bausteine der Oberfläche

**Dateien**
- Neu: `lib/ui/widgets/reading_headline.dart`
- Neu: `lib/ui/widgets/classification_scale.dart`
- Neu: `lib/ui/widgets/notice_card.dart`
- Test: `test/ui/widgets/widgets_test.dart`

**Schnittstellen**
- Nutzt: `SphygmaTheme.of` (Aufgabe 1), `allVariants`/`themeFor` (Aufgabe 2), `classifyOffice`, `escClassificationEnabled`.
- Liefert:
  - `ReadingHeadline({required int systolic, required int diastolic, required int pulse, required DateTime measuredAt})`
  - `ClassificationScale({required EscCategory category})`
  - `NoticeCard({required String title, required String message, String? details})` — `details` erzeugt einen Aufklapper.

- [ ] **Schritt 1: Test schreiben**

```dart
// test/ui/widgets/widgets_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/esc_classification.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/widgets/classification_scale.dart';
import 'package:sphygma/ui/widgets/notice_card.dart';
import 'package:sphygma/ui/widgets/reading_headline.dart';

Widget _wrap(ThemeVariant v, Widget child) => MaterialApp(
      home: SphygmaThemeScope(
        theme: themeFor(v),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('ReadingHeadline in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('zeigt Werte und Puls (${v.name})', (tester) async {
        await tester.pumpWidget(_wrap(
          v,
          ReadingHeadline(
            systolic: 128,
            diastolic: 87,
            pulse: 82,
            measuredAt: DateTime(2026, 9, 5, 23, 57),
          ),
        ));

        expect(find.textContaining('128'), findsOneWidget);
        expect(find.textContaining('87'), findsOneWidget);
        expect(find.textContaining('82'), findsOneWidget);
      });
    }
  });

  group('ClassificationScale in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('baut ohne Fehler (${v.name})', (tester) async {
        await tester.pumpWidget(_wrap(
          v,
          const ClassificationScale(category: EscCategory.highNormal),
        ));

        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('NoticeCard zeigt Titel und Text', (tester) async {
    await tester.pumpWidget(_wrap(
      ThemeVariant.instrument,
      const NoticeCard(title: 'Geraeteuhr', message: 'Datum weicht ab.'),
    ));

    expect(find.text('Geraeteuhr'), findsOneWidget);
    expect(find.text('Datum weicht ab.'), findsOneWidget);
  });

  testWidgets('NoticeCard klappt Einzelheiten erst auf Tippen auf',
      (tester) async {
    await tester.pumpWidget(_wrap(
      ThemeVariant.instrument,
      const NoticeCard(
        title: 'Geraeteuhr',
        message: 'Datum weicht ab.',
        details: 'Batterien herausnehmen und wieder einlegen.',
      ),
    ));

    expect(find.textContaining('Batterien'), findsNothing);

    await tester.tap(find.text('Anleitung anzeigen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Batterien'), findsOneWidget);
  });
}
```

- [ ] **Schritt 2: Test ausführen, Fehlschlag bestätigen**

Ausführen: `flutter test test/ui/widgets/widgets_test.dart`
Erwartet: FEHLER, die drei Dateien fehlen.

- [ ] **Schritt 3: Umsetzen**

```dart
// lib/ui/widgets/reading_headline.dart
// Die grosse Wertdarstellung. Steht auf "Heute" und im Detail-Blatt.
import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

class ReadingHeadline extends StatelessWidget {
  const ReadingHeadline({
    super.key,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.measuredAt,
  });

  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime measuredAt;

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final zeit = '${_twoDigits(measuredAt.day)}.'
        '${_twoDigits(measuredAt.month)}.${measuredAt.year}, '
        '${_twoDigits(measuredAt.hour)}:${_twoDigits(measuredAt.minute)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          zeit,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.4,
            color: t.muted,
          ),
        ),
        SizedBox(height: t.gapSmall),
        Text(
          '$systolic/$diastolic',
          style: TextStyle(
            fontSize: t.headlineSize,
            height: 1,
            fontWeight: FontWeight.w300,
            letterSpacing: -1.5,
            color: t.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(height: t.gapSmall / 2),
        Text(
          'mmHg · Puls $pulse',
          style: TextStyle(fontSize: 12, color: t.muted),
        ),
      ],
    );
  }
}
```

```dart
// lib/ui/widgets/classification_scale.dart
// Schmale Skala mit Zeiger. Hier - und nur hier - traegt Farbe Bedeutung.
import 'package:flutter/material.dart';

import '../../stats/esc_classification.dart';
import '../theme/sphygma_theme.dart';

class ClassificationScale extends StatelessWidget {
  const ClassificationScale({super.key, required this.category});

  final EscCategory category;

  /// Position des Zeigers: Mitte des jeweiligen Abschnitts.
  double get _position =>
      (category.index + 0.5) / EscCategory.values.length;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: 12,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      for (final c in EscCategory.values)
                        Expanded(
                          child: Container(
                            height: 3,
                            color: t.categoryColors[c],
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * _position - 1,
                  top: 0,
                  child: Container(width: 2, height: 12, color: t.accent),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: t.gapSmall),
        Text(
          _label(category),
          style: TextStyle(fontSize: 13, color: t.onSurface),
        ),
      ],
    );
  }

  static String _label(EscCategory c) => switch (c) {
        EscCategory.optimal => 'Optimal',
        EscCategory.normal => 'Normal',
        EscCategory.highNormal => 'Hochnormal',
        EscCategory.grade1 => 'Bluthochdruck Grad 1',
        EscCategory.grade2 => 'Bluthochdruck Grad 2',
        EscCategory.grade3 => 'Bluthochdruck Grad 3',
      };
}
```

```dart
// lib/ui/widgets/notice_card.dart
// Hinweisfeld auf "Heute". Erscheint nur, wenn es etwas zu sagen gibt -
// nie als dauerhafte Verzierung.
import 'package:flutter/material.dart';

import '../theme/sphygma_theme.dart';

class NoticeCard extends StatefulWidget {
  const NoticeCard({
    super.key,
    required this.title,
    required this.message,
    this.details,
  });

  final String title;
  final String message;

  /// Laengerer Text, der erst auf Tippen erscheint - etwa die Anleitung
  /// zum Stellen der Geraeteuhr.
  final String? details;

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: t.gapSmall),
      padding: EdgeInsets.all(t.gapSmall + 4),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: t.categoryColors.values.last,
            width: 3,
          ),
        ),
        borderRadius: widget.details == null && !t.useRoundedCards
            ? null
            : BorderRadius.circular(t.radius),
        color: t.line.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: t.onSurface,
            ),
          ),
          SizedBox(height: t.gapSmall / 2),
          Text(
            widget.message,
            style: TextStyle(fontSize: 12, color: t.onSurface),
          ),
          if (widget.details != null) ...[
            SizedBox(height: t.gapSmall / 2),
            GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: Text(
                _open ? 'Anleitung ausblenden' : 'Anleitung anzeigen',
                style: TextStyle(
                  fontSize: 12,
                  color: t.accent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            if (_open) ...[
              SizedBox(height: t.gapSmall),
              Text(
                widget.details!,
                style: TextStyle(fontSize: 12, color: t.muted, height: 1.5),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Schritt 4: Test ausführen, Erfolg bestätigen**

Ausführen: `flutter test test/ui/widgets/widgets_test.dart`
Erwartet: alle grün, jeder Baustein in allen drei Gestaltungen.

- [ ] **Schritt 5: Prüfen und committen**

```bash
flutter analyze && flutter test
git add lib/ui/widgets test/ui/widgets
git commit -m "feat(ui): Bausteine fuer Wert, Einordnung und Hinweis"
```

---

## Aufgabe 7: Bereich „Heute"

**Dateien**
- Neu: `lib/ui/today_screen.dart`
- Test: `test/ui/today_screen_test.dart`

**Schnittstellen**
- Nutzt: `ReadingHeadline`, `ClassificationScale`, `NoticeCard` (Aufgabe 6), `SphygmaTheme.of` (Aufgabe 1), `AppController.latest`, `.paired`, `.clockLooksWrong`, `.autoSyncActive`, `.measurements`.
- Liefert: `TodayScreen({required AppController controller})`.
- Der Anleitungstext steht als `const String clockInstructions` in derselben Datei, damit ihn auch der Gerätebereich nutzen kann.

- [ ] **Schritt 1: Test schreiben**

```dart
// test/ui/today_screen_test.dart
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';
import 'package:sphygma/ui/today_screen.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

SlotRecord _rec(int seq, DateTime at, {int systolic = 128}) => SlotRecord(
      userSlot: 1,
      record: BloodPressureRecord(
        systolic: systolic,
        diastolic: 87,
        pulse: 82,
        timestamp: at,
        arrhythmiaFlag: false,
        movementFlag: false,
        sequence: seq,
      ),
      rawBytes: Uint8List(14),
    );

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  Future<AppController> boot({bool paired = true}) async {
    if (paired) await keyStore.save(Uint8List(16));
    final c = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await c.init();
    await c.setUserSlot(1);
    return c;
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) =>
      tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(v),
          child: Scaffold(body: TodayScreen(controller: controller)),
        ),
      ));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    keyStore = InMemoryPairingKeyStore();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  group('in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('zeigt die letzte Messung (${v.name})', (tester) async {
        controller = await boot();
        await repository.importAll([_rec(1, DateTime.now())]);
        await controller.refreshForTest();

        await pumpWith(tester, v);

        expect(find.textContaining('128'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('ohne Messungen fordert er zum Messen auf, statt leer zu sein',
      (tester) async {
    controller = await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Noch keine Messung'), findsOneWidget);
  });

  testWidgets('ohne Kopplung erscheint ein Hinweis', (tester) async {
    controller = await boot(paired: false);

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Nicht gekoppelt'), findsOneWidget);
  });

  testWidgets('bei falscher Uhr steht der Hinweis samt Anleitung da',
      (tester) async {
    controller = await boot();
    // Ein Datum weit in der Vergangenheit loest die Pruefung aus.
    await repository.importAll([_rec(1, DateTime(2023, 4, 18))]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Geraeteuhr'), findsOneWidget);

    await tester.tap(find.text('Anleitung anzeigen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Batterien'), findsOneWidget);
  });

  testWidgets('zeigt hoechstens fuenf der letzten Messungen', (tester) async {
    controller = await boot();
    final now = DateTime.now();
    await repository.importAll([
      for (var i = 0; i < 9; i++)
        _rec(i + 1, now.subtract(Duration(hours: i)), systolic: 120 + i),
    ]);
    await controller.refreshForTest();

    await pumpWith(tester, ThemeVariant.instrument);

    // Die aelteste (120) darf nicht mehr dabei sein.
    expect(find.textContaining('/87').evaluate().length, lessThanOrEqualTo(6));
  });
}
```

- [ ] **Schritt 2: Test ausführen, Fehlschlag bestätigen**

Ausführen: `flutter test test/ui/today_screen_test.dart`
Erwartet: FEHLER, `today_screen.dart` fehlt.

- [ ] **Schritt 3: Umsetzen**

```dart
// lib/ui/today_screen.dart
// Der Bildschirm beim Oeffnen. Vorn steht der Wert, nicht die Technik.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../app/feature_flags.dart';
import '../db/app_database.dart';
import '../stats/esc_classification.dart';
import 'theme/sphygma_theme.dart';
import 'widgets/classification_scale.dart';
import 'widgets/notice_card.dart';
import 'widgets/reading_headline.dart';

/// Die Schritte aus dem Handbuch HEM-6232T-E. Die Uhr laesst sich nicht
/// per Bluetooth stellen (docs/protocol/hem-6232t.md §8.7), also bleibt
/// nur, sie zu erklaeren.
const String clockInstructions =
    'Batterien herausnehmen und wieder einlegen. Dann die Taste gedrueckt '
    'halten, bis das Jahr blinkt. Jahr, Monat, Tag, Stunde und Minute '
    'nacheinander mit START/STOP bestaetigen; die andere Taste aendert den '
    'Wert, gehalten springt sie schnell. Zum Schluss START/STOP druecken, '
    'um zu speichern.';

/// Wie viele der letzten Messungen unter dem grossen Wert erscheinen.
const int _recentCount = 5;

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final latest = controller.latest;

    return Container(
      color: t.surface,
      child: ListView(
        padding: EdgeInsets.all(t.gapLarge),
        children: [
          if (latest == null)
            _EmptyState(paired: controller.paired)
          else ...[
            ReadingHeadline(
              systolic: latest.systolic,
              diastolic: latest.diastolic,
              pulse: latest.pulse,
              measuredAt: latest.measuredAt,
            ),
            if (escClassificationEnabled) ...[
              SizedBox(height: t.gapLarge),
              ClassificationScale(
                category: classifyOffice(
                  systolic: latest.systolic,
                  diastolic: latest.diastolic,
                ),
              ),
            ],
          ],
          ..._notices(),
          if (controller.measurements.length > 1) ...[
            SizedBox(height: t.gapLarge),
            Text(
              'LETZTE TAGE',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.6,
                color: t.muted,
              ),
            ),
            for (final m in controller.measurements.skip(1).take(_recentCount))
              _RecentRow(measurement: m),
          ],
        ],
      ),
    );
  }

  /// Hinweise erscheinen nur, wenn es etwas zu sagen gibt.
  List<Widget> _notices() => [
        if (!controller.paired)
          const NoticeCard(
            title: 'Nicht gekoppelt',
            message: 'Ohne Kopplung kann Sphygma keine Messungen holen. '
                'Unter "Geraet" einrichten.',
          ),
        if (controller.clockLooksWrong)
          const NoticeCard(
            title: 'Geraeteuhr geht falsch',
            message: 'Die neueste Messung traegt ein unplausibles Datum. '
                'Sphygma kann die Uhr nicht stellen, das geht nur am Geraet.',
            details: clockInstructions,
          ),
        if (controller.paired && !controller.autoSyncActive)
          const NoticeCard(
            title: 'Kein automatischer Abgleich',
            message: 'Neue Messungen werden nicht von selbst geholt. '
                'Unter "Geraet" laesst sich der Abgleich von Hand ausloesen.',
          ),
      ];
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.paired});

  final bool paired;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.gapLarge * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Noch keine Messung',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: t.onSurface,
            ),
          ),
          SizedBox(height: t.gapSmall),
          Text(
            paired
                ? 'Miss am Geraet - Sphygma holt die Messung von selbst.'
                : 'Zuerst unter "Geraet" koppeln.',
            style: TextStyle(fontSize: 13, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.measurement});

  final Measurement measurement;

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final m = measurement;

    return Container(
      padding: EdgeInsets.symmetric(vertical: t.gapSmall + 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${m.systolic}/${m.diastolic} · ${m.pulse}',
            style: TextStyle(
              fontSize: 13,
              color: t.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            '${_two(m.measuredAt.day)}.${_two(m.measuredAt.month)}. '
            '${_two(m.measuredAt.hour)}:${_two(m.measuredAt.minute)}',
            style: TextStyle(fontSize: 12, color: t.muted),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Schritt 4: Test ausführen, Erfolg bestätigen**

Ausführen: `flutter test test/ui/today_screen_test.dart`
Erwartet: alle grün.

- [ ] **Schritt 5: Prüfen und committen**

```bash
flutter analyze && flutter test
git add lib/ui/today_screen.dart test/ui/today_screen_test.dart
git commit -m "feat(ui): Bereich Heute mit Hinweisfeldern"
```

---

## Aufgabe 8: Bereich „Gerät"

**Dateien**
- Neu: `lib/ui/device_screen.dart`
- Test: `test/ui/device_screen_test.dart`

**Schnittstellen**
- Nutzt: `SphygmaTheme.of`, `allVariants`/`themeFor`, `clockInstructions` (Aufgabe 7), `AppController.paired`, `.userSlot`, `.autoSyncActive`, `.measurements`, `.pendingExport`, `.busy`, `.themeVariant`, `.pair()`, `.sync()`, `.exportAll()`, `.retractAll()`, `.setUserSlot(int)`, `.setThemeVariant(ThemeVariant)`.
- Liefert: `DeviceScreen({required AppController controller})`.

- [ ] **Schritt 1: Test schreiben**

```dart
// test/ui/device_screen_test.dart
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/app_controller.dart';
import 'package:sphygma/ble/pairing_key_store.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';
import 'package:sphygma/sync/sync_service.dart';
import 'package:sphygma/ui/device_screen.dart';
import 'package:sphygma/ui/theme/sphygma_theme.dart';
import 'package:sphygma/ui/theme/variants.dart';

class _NoopSink implements HealthSink {
  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {}
  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {}
}

void main() {
  late AppDatabase db;
  late InMemoryPairingKeyStore keyStore;
  late AppController controller;

  Future<void> boot({bool paired = true, bool withSlot = true}) async {
    if (paired) await keyStore.save(Uint8List(16));
    final repository = MeasurementRepository(db);
    controller = AppController(
      settings: SettingsRepository(db),
      keyStore: keyStore,
      repository: repository,
      syncService: SyncService(keyStore: keyStore, repository: repository),
      exportService: ExportService(repository: repository, sink: _NoopSink()),
      statusStream: () => const Stream.empty(),
    );
    await controller.init();
    if (withSlot) await controller.setUserSlot(1);
  }

  Future<void> pumpWith(WidgetTester tester, ThemeVariant v) =>
      tester.pumpWidget(MaterialApp(
        home: SphygmaThemeScope(
          theme: themeFor(v),
          child: Scaffold(body: DeviceScreen(controller: controller)),
        ),
      ));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    keyStore = InMemoryPairingKeyStore();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  group('in jeder Gestaltung', () {
    for (final v in allVariants) {
      testWidgets('baut ohne Fehler (${v.name})', (tester) async {
        await boot();

        await pumpWith(tester, v);

        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('zeigt den Zustand des automatischen Abgleichs',
      (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.textContaining('Automatischer Abgleich'), findsOneWidget);
  });

  testWidgets('ohne Kopplung fuehrt der Knopf zum Koppeln', (tester) async {
    await boot(paired: false);

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('Koppeln'), findsOneWidget);
  });

  testWidgets('die Speicherplatzwahl erscheint nur ohne Kopplung',
      (tester) async {
    await boot(paired: false, withSlot: false);

    await pumpWith(tester, ThemeVariant.instrument);

    expect(find.text('Benutzer 1'), findsOneWidget);
  });

  testWidgets('die Gestaltung laesst sich umschalten', (tester) async {
    await boot();

    await pumpWith(tester, ThemeVariant.instrument);
    await tester.tap(find.text('Tagebuch'));
    await tester.pumpAndSettle();

    expect(controller.themeVariant, ThemeVariant.diary);
  });
}
```

- [ ] **Schritt 2: Test ausführen, Fehlschlag bestätigen**

Ausführen: `flutter test test/ui/device_screen_test.dart`
Erwartet: FEHLER, `device_screen.dart` fehlt.

- [ ] **Schritt 3: Umsetzen**

```dart
// lib/ui/device_screen.dart
// Alles Technische an einem Ort: Geraet, Abgleich, Health Connect,
// Gestaltung. Vorn auf "Heute" stoert es damit nicht mehr.
import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import 'theme/sphygma_theme.dart';
import 'theme/variants.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);
    final c = controller;

    return Container(
      color: t.surface,
      child: ListView(
        padding: EdgeInsets.all(t.gapLarge),
        children: [
          _Section(title: 'Geraet'),
          _Row(
            label: 'RS7 Intelli IT',
            value: c.paired ? 'gekoppelt' : 'nicht gekoppelt',
          ),
          if (c.userSlot != null)
            _Row(label: 'Speicherplatz', value: 'Benutzer ${c.userSlot}'),
          if (!c.paired) ...[
            SizedBox(height: t.gapSmall),
            Text(
              'Welcher Speicherplatz gehoert dir am Geraet?',
              style: TextStyle(fontSize: 12, color: t.muted),
            ),
            SizedBox(height: t.gapSmall),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('Benutzer 1')),
                ButtonSegment(value: 2, label: Text('Benutzer 2')),
              ],
              selected: {c.userSlot ?? 1},
              onSelectionChanged: (s) =>
                  s.isEmpty ? null : c.setUserSlot(s.first),
            ),
            SizedBox(height: t.gapSmall),
            Text(
              'Zum Koppeln die Bluetooth-Taste am Geraet lange druecken, '
              'bis "-P-" blinkt.',
              style: TextStyle(fontSize: 12, color: t.muted),
            ),
            _Button(
              label: 'Koppeln',
              filled: true,
              onPressed: c.busy || c.userSlot == null ? null : c.pair,
            ),
          ],

          _Section(title: 'Abgleich'),
          _Row(
            label: 'Automatischer Abgleich',
            value: c.autoSyncActive ? 'wartet auf Messungen' : 'aus',
            dot: c.autoSyncActive,
          ),
          _Row(label: 'Gespeichert', value: '${c.measurements.length} Messungen'),
          _Button(
            label: 'Jetzt abgleichen',
            filled: true,
            onPressed: c.busy || !c.paired ? null : c.sync,
          ),
          if (c.status != null) ...[
            SizedBox(height: t.gapSmall),
            Text(c.status!, style: TextStyle(fontSize: 12, color: t.muted)),
          ],

          _Section(title: 'Health Connect'),
          _Row(
            label: 'Uebertragen',
            value: '${c.measurements.length - c.pendingExport} '
                'von ${c.measurements.length}',
          ),
          _Button(
            label: 'Alle uebertragen',
            onPressed: c.busy || c.pendingExport == 0 ? null : c.exportAll,
          ),
          _Button(
            label: 'Uebertragene entfernen',
            onPressed: c.busy ? null : c.retractAll,
          ),

          _Section(title: 'Gestaltung'),
          for (final v in allVariants)
            RadioListTile<ThemeVariant>(
              value: v,
              groupValue: c.themeVariant,
              onChanged: (chosen) =>
                  chosen == null ? null : c.setThemeVariant(chosen),
              title: Text(
                themeFor(v).name,
                style: TextStyle(fontSize: 14, color: t.onSurface),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: t.gapLarge, bottom: t.gapSmall),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: t.muted),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.dot = false});

  final String label;
  final String value;

  /// Gruener Punkt vor dem Text - zeigt einen laufenden Zustand an.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: t.gapSmall + 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (dot) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.categoryColors.values.first,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(label, style: TextStyle(fontSize: 13, color: t.onSurface)),
            ],
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final t = SphygmaTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: t.gapSmall),
      child: SizedBox(
        width: double.infinity,
        child: filled
            ? FilledButton(onPressed: onPressed, child: Text(label))
            : OutlinedButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}
```

- [ ] **Schritt 4: Test ausführen, Erfolg bestätigen**

Ausführen: `flutter test test/ui/device_screen_test.dart`
Erwartet: alle grün.

- [ ] **Schritt 5: Prüfen und committen**

```bash
flutter analyze && flutter test
git add lib/ui/device_screen.dart test/ui/device_screen_test.dart
git commit -m "feat(ui): Bereich Geraet mit Abgleich-Zustand und Gestaltungswahl"
```

---

*Die Aufgaben 9 und 10 — Verlauf mit Kurve und Detail-Blatt — sowie die Berichte folgen. Sie hängen von Aufgabe 7 und 8 ab und werden nach deren Umsetzung ergänzt.*
