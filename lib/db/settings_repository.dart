// App-Einstellungen in der DB - ohne zusaetzliche Abhaengigkeit.
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../app/concept.dart';
import '../ui/theme/variants.dart';
import 'app_database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const String _userSlotKey = 'user_slot';

  /// Der am Geraet gewaehlte User-Slot (1 oder 2) - oder null, wenn der
  /// Nutzer noch nicht gewaehlt hat. Null ist ein echter Zustand und wird
  /// nicht durch einen Default kaschiert: falsche Slot-Wahl hiesse, fremde
  /// Messungen in die eigene Gesundheitsakte zu exportieren.
  Future<int?> userSlot() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(_userSlotKey))).getSingleOrNull();
    return row == null ? null : int.parse(row.value);
  }

  Future<void> setUserSlot(int slot) async {
    if (slot != 1 && slot != 2) {
      throw ArgumentError.value(slot, 'slot', 'muss 1 oder 2 sein');
    }
    await _db
        .into(_db.appSettings)
        .insert(
          AppSettingsCompanion.insert(key: _userSlotKey, value: '$slot'),
          mode: InsertMode.insertOrReplace,
        );
  }

  static const String _themeVariantKey = 'theme_variant';

  /// Die gewaehlte Gestaltung. Anders als beim User-Slot ist hier ein
  /// Standard richtig: Eine fehlende Wahl ist kein Zustand, den der
  /// Nutzer klaeren muss.
  Future<ThemeVariant> themeVariant() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(_themeVariantKey))).getSingleOrNull();
    if (row == null) return variantFor(await characteristic());
    for (final v in allVariants) {
      if (v.name == row.value) return v;
    }
    // Gespeicherter Wert kennt niemand mehr - etwa nach dem Entfernen
    // einer Variante. Ein Wurf waere hier falsch: Die App waere wegen
    // einer Farbwahl unbenutzbar. Aber lautlos darf es auch nicht
    // passieren (Codex-Review 2026-09-05).
    debugPrint(
      '[Sphygma] Unbekannte Gestaltung "${row.value}" gespeichert, '
      'nutze ${ThemeVariant.instrument.name}.',
    );
    return ThemeVariant.instrument;
  }

  Future<void> setThemeVariant(ThemeVariant variant) async {
    await _ensureThemeAxes();
    final axes = axesFor(variant);
    await setRawSetting(_characteristicKey, axes.characteristic.name);
    await setRawSetting(_paletteKey, axes.palette.name);
    await setRawSetting(_typefaceKey, axes.typeface.name);
  }

  static const String _characteristicKey = 'theme_characteristic';
  static const String _paletteKey = 'theme_palette';
  static const String _typefaceKey = 'theme_typeface';

  Future<void>? _themeMigration;

  Future<void> _ensureThemeAxes() => _themeMigration ??= _migrateThemeAxes();

  Future<String?> _rawSetting(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  T _storedEnum<T extends Enum>(
    String? value,
    List<T> values,
    T standard,
    String label,
  ) {
    if (value == null) return standard;
    for (final candidate in values) {
      if (candidate.name == value) return candidate;
    }
    // Wie bei Konzept und alter Gestaltung: Ein entfernter Auswahlwert
    // darf den Start nicht verhindern, der Rückfall bleibt aber sichtbar.
    debugPrint(
      '[Sphygma] Unbekannte $label "$value" gespeichert, '
      'nutze ${standard.name}.',
    );
    return standard;
  }

  Future<void> _migrateThemeAxes() async {
    try {
      await _db.transaction(() async {
        final characteristic = await _rawSetting(_characteristicKey);
        final palette = await _rawSetting(_paletteKey);
        final typeface = await _rawSetting(_typefaceKey);
        if (characteristic == null || palette == null || typeface == null) {
          final legacy = _storedEnum(
            await _rawSetting(_themeVariantKey),
            allVariants,
            ThemeVariant.instrument,
            'Gestaltung',
          );
          final axes = axesFor(legacy);
          // Bestehende Achsen gewinnen auch bei einer Teilmigration.
          // insertOrIgnore schützt sie ebenso vor einem zweiten Repository.
          for (final entry in {
            _characteristicKey: axes.characteristic.name,
            _paletteKey: axes.palette.name,
            _typefaceKey: axes.typeface.name,
          }.entries) {
            await _db
                .into(_db.appSettings)
                .insert(
                  AppSettingsCompanion.insert(
                    key: entry.key,
                    value: entry.value,
                  ),
                  mode: InsertMode.insertOrIgnore,
                );
          }
        }
        // Erst nach gesicherter Übersetzung entfernen: Sonst ginge bei
        // einem Abbruch die alte Wahl verloren. Alle drei Schlüssel sind
        // zugleich die dauerhafte Markierung der abgeschlossenen Migration.
        await (_db.delete(
          _db.appSettings,
        )..where((s) => s.key.equals(_themeVariantKey))).go();
      });
    } catch (_) {
      _themeMigration = null;
      rethrow;
    }
  }

  Future<Characteristic> characteristic() async {
    await _ensureThemeAxes();
    return _storedEnum(
      await _rawSetting(_characteristicKey),
      Characteristic.values,
      Characteristic.messinstrument,
      'Charakteristik',
    );
  }

  Future<Palette> palette() async {
    await _ensureThemeAxes();
    return _storedEnum(
      await _rawSetting(_paletteKey),
      Palette.values,
      Palette.papier,
      'Palette',
    );
  }

  Future<Typeface> typeface() async {
    await _ensureThemeAxes();
    return _storedEnum(
      await _rawSetting(_typefaceKey),
      Typeface.values,
      Typeface.system,
      'Schrift',
    );
  }

  Future<void> setCharacteristic(Characteristic value) async {
    await _ensureThemeAxes();
    await setRawSetting(_characteristicKey, value.name);
  }

  Future<void> setPalette(Palette value) async {
    await _ensureThemeAxes();
    await setRawSetting(_paletteKey, value.name);
  }

  Future<void> setTypeface(Typeface value) async {
    await _ensureThemeAxes();
    await setRawSetting(_typefaceKey, value.name);
  }

  static const String _conceptKey = 'app_concept';

  /// Das gewaehlte Konzept — die zweite Achse neben der Gestaltung. Wie dort
  /// ist ein Standard richtig: Wer nichts waehlt, bekommt die gewachsene
  /// Ordnung, nicht einen Fehler.
  Future<AppConcept> concept() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(_conceptKey))).getSingleOrNull();
    if (row == null) return AppConcept.klassisch;
    for (final c in allConcepts) {
      if (c.name == row.value) return c;
    }
    // Wie bei der Gestaltung: nicht werfen, aber auch nicht lautlos. Ein
    // entferntes Konzept darf die App nicht unbenutzbar machen.
    debugPrint(
      '[Sphygma] Unbekanntes Konzept "${row.value}" gespeichert, '
      'nutze ${AppConcept.klassisch.name}.',
    );
    return AppConcept.klassisch;
  }

  Future<void> setConcept(AppConcept concept) =>
      setRawSetting(_conceptKey, concept.name);

  static const String _weekPanelKey = 'week_panel_visible';

  /// Ob das Wochenraster auf „Heute" mitgezeichnet wird.
  ///
  /// Es kam aus dem aufgeloesten Konzept „Sieben Tage" und ist dort das
  /// ganze Programm gewesen; auf „Heute" ist es ein Abschnitt unter dem
  /// letzten Wert — nuetzlich fuer den, der eine Woche lang zweimal taeglich
  /// misst, ueberfluessig fuer den, der gelegentlich einen Wert nimmt.
  /// Deshalb abschaltbar, und deshalb standardmaessig an.
  Future<bool> weekPanelVisible() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(_weekPanelKey))).getSingleOrNull();
    if (row == null) return true;
    return switch (row.value) {
      'true' => true,
      'false' => false,
      // Wie bei Gestaltung und Konzept: nicht werfen, aber auch nicht
      // lautlos. Eine unlesbare Sichtbarkeitsangabe darf die App nicht
      // unbenutzbar machen.
      _ => () {
        debugPrint(
          '[Sphygma] Unlesbare Wochenraster-Einstellung "${row.value}", '
          'zeige es.',
        );
        return true;
      }(),
    };
  }

  Future<void> setWeekPanelVisible(bool visible) =>
      setRawSetting(_weekPanelKey, '$visible');

  /// Schreibt einen Einstellungswert unmittelbar. Oeffentlich, weil Tests
  /// ungueltige Zustaende herstellen koennen muessen.
  Future<void> setRawSetting(String key, String value) async {
    await _db
        .into(_db.appSettings)
        .insert(
          AppSettingsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }
}
