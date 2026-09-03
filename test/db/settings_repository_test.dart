import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/settings_repository.dart';

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
}
