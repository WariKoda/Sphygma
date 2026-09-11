import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/measurement_windows.dart';

void main() {
  test('defaults bilden getrennte Morgen- und Abendfenster ab', () {
    final windows = MeasurementWindows.defaults;

    expect(windows.morningLabel, '05:00–10:00');
    expect(windows.eveningLabel, '18:00–23:00');
    expect(windows.isMorning(DateTime(2026, 9, 11, 5)), isTrue);
    expect(windows.isMorning(DateTime(2026, 9, 11, 9, 59)), isTrue);
    expect(windows.isMorning(DateTime(2026, 9, 11, 10)), isFalse);
    expect(windows.isMorning(DateTime(2026, 9, 11, 13)), isFalse);
    expect(windows.isEvening(DateTime(2026, 9, 11, 18)), isTrue);
    expect(windows.isEvening(DateTime(2026, 9, 11, 23)), isFalse);
  });

  test('benutzerdefinierte Grenzen bleiben halb offen', () {
    final windows = MeasurementWindows(
      morningStart: 7 * 60 + 15,
      morningEnd: 11 * 60 + 30,
      eveningStart: 16 * 60 + 45,
      eveningEnd: 20 * 60,
    );

    expect(windows.morningLabel, '07:15–11:30');
    expect(windows.isMorning(DateTime(2026, 9, 11, 7, 14)), isFalse);
    expect(windows.isMorning(DateTime(2026, 9, 11, 7, 15)), isTrue);
    expect(windows.isMorning(DateTime(2026, 9, 11, 11, 30)), isFalse);
  });

  test('Fenster dürfen Mitternacht überschreiten', () {
    final windows = MeasurementWindows(
      morningStart: 23 * 60,
      morningEnd: 2 * 60,
      eveningStart: 10 * 60,
      eveningEnd: 12 * 60,
    );

    expect(windows.morningLabel, '23:00–02:00');
    expect(windows.isMorning(DateTime(2026, 9, 11, 23, 30)), isTrue);
    expect(windows.isMorning(DateTime(2026, 9, 12, 1, 59)), isTrue);
    expect(windows.isMorning(DateTime(2026, 9, 12, 2)), isFalse);
  });

  test('lehnt gleiche Grenzen und Überlappung auch über Mitternacht ab', () {
    expect(
      () => MeasurementWindows(
        morningStart: 300,
        morningEnd: 300,
        eveningStart: 1080,
        eveningEnd: 1380,
      ),
      throwsArgumentError,
    );
    expect(
      () => MeasurementWindows(
        morningStart: 300,
        morningEnd: 600,
        eveningStart: 540,
        eveningEnd: 720,
      ),
      throwsArgumentError,
    );
    expect(
      () => MeasurementWindows(
        morningStart: 1380,
        morningEnd: 120,
        eveningStart: 60,
        eveningEnd: 180,
      ),
      throwsArgumentError,
    );
  });

  test('lehnt Minuten außerhalb des Tages ab', () {
    expect(
      () => MeasurementWindows(
        morningStart: -1,
        morningEnd: 600,
        eveningStart: 1080,
        eveningEnd: 1380,
      ),
      throwsArgumentError,
    );
    expect(
      () => MeasurementWindows(
        morningStart: 300,
        morningEnd: 600,
        eveningStart: 1080,
        eveningEnd: 1440,
      ),
      throwsArgumentError,
    );
  });

  test('JSON Version 1 roundtript vier Ganzzahlen', () {
    final original = MeasurementWindows(
      morningStart: 315,
      morningEnd: 615,
      eveningStart: 1095,
      eveningEnd: 1395,
    );

    final decoded = MeasurementWindows.decode(original.encode());

    expect(decoded.morningStart, original.morningStart);
    expect(decoded.morningEnd, original.morningEnd);
    expect(decoded.eveningStart, original.eveningStart);
    expect(decoded.eveningEnd, original.eveningEnd);
    expect(original.encode(), contains('"version":1'));
  });

  test('persistierte Daten werden ohne Defaults strikt validiert', () {
    for (final invalid in [
      'kein json',
      '[]',
      '{"version":2,"morningStart":300,"morningEnd":600,'
          '"eveningStart":1080,"eveningEnd":1380}',
      '{"version":1,"morningStart":"300","morningEnd":600,'
          '"eveningStart":1080,"eveningEnd":1380}',
      '{"version":1,"morningStart":300,"morningEnd":600,'
          '"eveningStart":540,"eveningEnd":720}',
      '{"version":1,"morningStart":300,"morningEnd":600,'
          '"eveningStart":1080}',
    ]) {
      expect(() => MeasurementWindows.decode(invalid), throwsFormatException);
    }
  });
}
