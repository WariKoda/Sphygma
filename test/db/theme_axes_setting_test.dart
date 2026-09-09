import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
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

  test('ohne Wahl gelten die drei Standards', () async {
    expect(await settings.characteristic(), Characteristic.messinstrument);
    expect(await settings.palette(), Palette.papier);
    expect(await settings.typeface(), Typeface.system);
  });

  for (final variant in allVariants) {
    test('$variant migriert dauerhaft auf die Diagonale', () async {
      await settings.setRawSetting('theme_variant', variant.name);
      final axes = axesFor(variant);
      expect(await settings.characteristic(), axes.characteristic);
      final reopened = SettingsRepository(db);
      expect(await reopened.palette(), axes.palette);
      expect(await reopened.typeface(), axes.typeface);
      expect(await reopened.themeVariant(), variant);
      final rows = await db.select(db.appSettings).get();
      expect(
        {for (final row in rows) row.key: row.value},
        {
          'theme_characteristic': axes.characteristic.name,
          'theme_palette': axes.palette.name,
          'theme_typeface': axes.typeface.name,
        },
      );
      await reopened.setPalette(Palette.nacht);
      expect(await SettingsRepository(db).palette(), Palette.nacht);
    });
  }

  test('vorhandene neue Achsen gewinnen, fehlende erben den Altwert', () async {
    await settings.setRawSetting('theme_variant', 'diary');
    await settings.setRawSetting('theme_palette', 'flieder');
    expect(await settings.palette(), Palette.flieder);
    expect(await settings.characteristic(), Characteristic.tagebuch);
    expect(await settings.typeface(), Typeface.system);
  });

  test(
    'Setter migriert zuerst, ohne die übrigen Achsen zu verlieren',
    () async {
      await settings.setRawSetting('theme_variant', 'aura');
      await settings.setCharacteristic(Characteristic.band);
      expect(await settings.characteristic(), Characteristic.band);
      expect(await settings.palette(), Palette.nacht);
      await settings.setPalette(Palette.himmel);
      await settings.setTypeface(Typeface.system);
      expect(await settings.characteristic(), Characteristic.band);
      expect(await settings.palette(), Palette.himmel);
    },
  );

  test('alte Auswahl schreibt nur noch die drei neuen Schlüssel', () async {
    await settings.setRawSetting('theme_variant', 'aura');
    await settings.setThemeVariant(ThemeVariant.pegel);
    expect(await settings.characteristic(), Characteristic.band);
    expect(await settings.palette(), Palette.papier);
    expect(await settings.themeVariant(), ThemeVariant.pegel);
    final keys = (await db.select(db.appSettings).get()).map((r) => r.key);
    expect(keys, isNot(contains('theme_variant')));
  });

  test('unbekannte Achsen melden den Rückfall auf ihren Standard', () async {
    await settings.setRawSetting('theme_characteristic', 'entfernt');
    await settings.setRawSetting('theme_palette', 'salbei');
    await settings.setRawSetting('theme_typeface', 'unbekannt');
    final messages = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
    try {
      expect(await settings.characteristic(), Characteristic.messinstrument);
      expect(await settings.palette(), Palette.papier);
      expect(await settings.typeface(), Typeface.system);
      expect(messages, hasLength(3));
      expect(messages.join(), contains('salbei'));
    } finally {
      debugPrint = original;
    }
  });

  test('unbekannter Altwert migriert mit Meldung zum Standard', () async {
    await settings.setRawSetting('theme_variant', 'entfernt');
    expect(await settings.characteristic(), Characteristic.messinstrument);
    expect(await settings.palette(), Palette.papier);
    expect(await settings.typeface(), Typeface.system);
  });

  test('parallele Leser und Setter verlieren keine Auswahl', () async {
    await settings.setRawSetting('theme_variant', 'diary');
    await Future.wait([
      settings.characteristic(),
      settings.palette(),
      settings.typeface(),
      settings.setPalette(Palette.flieder),
    ]);
    expect(await settings.characteristic(), Characteristic.tagebuch);
    expect(await settings.palette(), Palette.flieder);
  });
}
