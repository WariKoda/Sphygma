import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/app/concept.dart';
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

  test('ohne Wahl gilt die gewachsene Ordnung', () async {
    expect(await settings.concept(), AppConcept.klassisch);
  });

  test('die Wahl wird gespeichert und gelesen', () async {
    await settings.setConcept(AppConcept.tagesprofil);
    expect(await settings.concept(), AppConcept.tagesprofil);
  });

  test('jedes Konzept lässt sich wählen', () async {
    for (final c in allConcepts) {
      await settings.setConcept(c);
      expect(await settings.concept(), c);
    }
  });

  test('ein unbekannter gespeicherter Wert macht die App nicht unbenutzbar',
      () async {
    await settings.setRawSetting('app_concept', 'gibtesnichtmehr');
    expect(await settings.concept(), AppConcept.klassisch);
  });

  test('Konzept und Gestaltung sind unabhängig', () async {
    await settings.setConcept(AppConcept.phase);
    await settings.setThemeVariant(ThemeVariant.diary);

    expect(await settings.concept(), AppConcept.phase);
    expect(await settings.themeVariant(), ThemeVariant.diary);
  });

  test('jedes Konzept nennt Einheit und Beschreibung', () {
    for (final c in allConcepts) {
      expect(c.label, isNotEmpty);
      expect(c.unit, isNotEmpty);
      expect(c.description, isNotEmpty);
    }
  });
}
