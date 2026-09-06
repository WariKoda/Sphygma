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

  Future<void> setThemeVariant(ThemeVariant variant) =>
      setRawSetting(_themeVariantKey, variant.name);

  static const String _conceptKey = 'app_concept';

  /// Das gewaehlte Konzept — die zweite Achse neben der Gestaltung. Wie dort
  /// ist ein Standard richtig: Wer nichts waehlt, bekommt die gewachsene
  /// Ordnung, nicht einen Fehler.
  Future<AppConcept> concept() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_conceptKey)))
        .getSingleOrNull();
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

  /// Schreibt einen Einstellungswert unmittelbar. Oeffentlich, weil Tests
  /// ungueltige Zustaende herstellen koennen muessen.
  Future<void> setRawSetting(String key, String value) async {
    await _db.into(_db.appSettings).insert(
          AppSettingsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }
}
