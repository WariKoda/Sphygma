import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/measurement_week.dart';
import 'package:sphygma/stats/measurement_windows.dart';
import 'package:sphygma/stats/time_of_day_band.dart';

Measurement reading(int hour, int sys) => Measurement(
  id: hour,
  userSlot: 1,
  deviceSequence: hour,
  measuredAt: DateTime(2026, 9, 11, hour),
  systolic: sys,
  diastolic: 80,
  pulse: 70,
  movement: false,
  arrhythmia: false,
  rawBytes: Uint8List(14),
  importedAt: DateTime(2026, 9, 11, 23),
);

void main() {
  final readings = [
    reading(5, 100),
    reading(10, 140),
    reading(13, 160),
    reading(18, 120),
    reading(23, 180),
  ];
  test('Fenster begrenzen Wochenfelder, ohne Messungen aus Gesamtmitteln zu verlieren', () {
    final week = buildWeeks(readings).single;
    expect(week.measurements.length, 5);
    expect(week.averageWithFirstDay!.systolic, 140);
    expect(week.morningAverage!.systolic, 100);
    expect(week.eveningAverage!.systolic, 120);
    expect(week.filledFields, 2);
    expect(week.fields.expand((f) => f.measurements).map((m) => m.id).toSet(), {
      5,
      18,
    });
  });
  test('nur 13 Uhr belegt kein Morgen- oder Abendfeld', () {
    final week = buildWeeks([reading(13, 160)]).single;
    expect(week.filledFields, 0);
    expect(week.morningAverage, isNull);
    expect(week.eveningAverage, isNull);
    expect(week.averageWithFirstDay!.systolic, 160);
  });
  test(
    'Verlauf hat dieselben Mittel, außerhalb liegende Werte bleiben zugeordnet',
    () {
      final means = averagesByWindows(readings, MeasurementWindows.defaults);
      expect(means[TimeBand.morgens]!.systolic, 100);
      expect(means[TimeBand.abends]!.systolic, 120);
      expect(means[TimeBand.vormittags]!.systolic, 140);
      expect(means[TimeBand.nachmittags]!.systolic, 160);
      expect(means[TimeBand.nachts]!.systolic, 180);
    },
  );
  test('eigene Fenster wirken identisch in Verlauf und Wochenraster', () {
    final windows = MeasurementWindows(
      morningStart: 12 * 60,
      morningEnd: 14 * 60,
      eveningStart: 22 * 60,
      eveningEnd: 60,
    );
    final week = buildWeeks(readings, windows: windows).single;
    final means = averagesByWindows(readings, windows);
    expect(week.morningAverage!.systolic, 160);
    expect(week.eveningAverage!.systolic, 180);
    expect(means[TimeBand.morgens]!.systolic, week.morningAverage!.systolic);
    expect(means[TimeBand.abends]!.systolic, week.eveningAverage!.systolic);
  });
}
