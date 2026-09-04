// App-Einstellungen in der DB - ohne zusaetzliche Abhaengigkeit.
import 'package:drift/drift.dart';

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
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_userSlotKey)))
        .getSingleOrNull();
    return row == null ? null : int.parse(row.value);
  }

  Future<void> setUserSlot(int slot) async {
    if (slot != 1 && slot != 2) {
      throw ArgumentError.value(slot, 'slot', 'muss 1 oder 2 sein');
    }
    await _db.into(_db.appSettings).insert(
          AppSettingsCompanion.insert(key: _userSlotKey, value: '$slot'),
          mode: InsertMode.insertOrReplace,
        );
  }

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
}
