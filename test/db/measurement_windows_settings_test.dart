import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/settings_repository.dart';
import 'package:sphygma/stats/measurement_windows.dart';

void main() {
  late AppDatabase db;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());
  test('fehlender Wert nutzt Standard; Fenster überleben Repository-Neustart und Reset', () async {
    final settings = SettingsRepository(db);
    expect(
      (await settings.measurementWindows()).encode(),
      MeasurementWindows.defaults.encode(),
    );
    final changed = MeasurementWindows(
      morningStart: 360,
      morningEnd: 660,
      eveningStart: 1140,
      eveningEnd: 60,
    );
    await settings.setMeasurementWindows(changed);
    expect(
      (await SettingsRepository(db).measurementWindows()).encode(),
      changed.encode(),
    );
    await settings.setMeasurementWindows(MeasurementWindows.defaults);
    expect(
      (await settings.measurementWindows()).encode(),
      MeasurementWindows.defaults.encode(),
    );
  });
  test('beschädigte Einstellung wird nicht durch Standard kaschiert', () async {
    final settings = SettingsRepository(db);
    await settings.setRawSetting('measurement_windows', 'invalid');
    await expectLater(settings.measurementWindows(), throwsFormatException);
  });
}
