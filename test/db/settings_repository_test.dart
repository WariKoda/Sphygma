import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/ui/theme/variants.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settings;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsRepository(db);
  });

  tearDown(() => db.close());

  test('ohne Wahl ist der User-Slot null - kein stiller Default', () async {
    expect(await settings.userSlot(), isNull);
  });

  test('gewaehlter Slot wird gespeichert und ueberschrieben', () async {
    await settings.setUserSlot(2);
    expect(await settings.userSlot(), 2);

    await settings.setUserSlot(1);
    expect(await settings.userSlot(), 1);
  });

  test('nur 1 oder 2 sind gueltig', () async {
    expect(() => settings.setUserSlot(3), throwsArgumentError);
    expect(() => settings.setUserSlot(0), throwsArgumentError);
  });

  group('themeVariant', () {
    test('ohne Wahl steht das Messinstrument', () async {
      expect(await settings.themeVariant(), ThemeVariant.instrument);
    });

    test('speichert und liest die Wahl', () async {
      await settings.setThemeVariant(ThemeVariant.diary);

      expect(await settings.themeVariant(), ThemeVariant.diary);
    });

    test('ein unbekannter gespeicherter Wert faellt auf den Standard',
        () async {
      // Kann nach einem Rueckbau vorkommen. Die Gestaltung ist kein
      // korrektheitsrelevanter Wert - hier ist der Standard richtig.
      await settings.setThemeVariant(ThemeVariant.material);
      await settings.setRawSetting('theme_variant', 'gibtsnicht');

      expect(await settings.themeVariant(), ThemeVariant.instrument);
    });
  });
}
