import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/period_averages.dart';

Measurement _m(int sys, int dia, int pulse, DateTime at) => Measurement(
      id: at.millisecondsSinceEpoch,
      userSlot: 1,
      deviceSequence: at.millisecondsSinceEpoch,
      systolic: sys,
      diastolic: dia,
      pulse: pulse,
      measuredAt: at,
      movement: false,
      arrhythmia: false,
      rawBytes: Uint8List(14),
      importedAt: at,
      exportedAt: null,
    );

void main() {
  group('PeriodAverages', () {
    test('teilt nach morgens (vor 12) und abends (ab 18)', () {
      final averages = PeriodAverages.of([
        _m(120, 80, 70, DateTime(2026, 9, 1, 7)),
        _m(130, 90, 80, DateTime(2026, 9, 1, 20)),
      ]);

      expect(averages.overall!.systolic, 125);
      expect(averages.overall!.count, 2);
      expect(averages.morning!.systolic, 120);
      expect(averages.evening!.systolic, 130);
    });

    test('der Nachmittag zaehlt nur in den Gesamtwert', () {
      final averages = PeriodAverages.of([
        _m(140, 95, 85, DateTime(2026, 9, 1, 15)),
      ]);

      expect(averages.overall!.count, 1);
      expect(averages.morning, isNull);
      expect(averages.evening, isNull);
    });

    test('ohne Messungen gibt es kein Objekt, keine Nullen', () {
      final averages = PeriodAverages.of(const []);

      expect(averages.overall, isNull);
      expect(averages.morning, isNull);
      expect(averages.evening, isNull);
    });
  });

  group('groupByDay', () {
    test('gruppiert nach Kalendertag, neuester Tag zuerst', () {
      final groups = groupByDay([
        _m(120, 80, 70, DateTime(2026, 9, 1, 7)),
        _m(121, 81, 71, DateTime(2026, 9, 1, 20)),
        _m(122, 82, 72, DateTime(2026, 9, 3, 9)),
      ]);

      expect(groups.length, 2);
      expect(groups.first.day, DateTime(2026, 9, 3));
      expect(groups.last.day, DateTime(2026, 9, 1));
    });

    test('innerhalb eines Tages steht die neueste Messung oben', () {
      final groups = groupByDay([
        _m(120, 80, 70, DateTime(2026, 9, 1, 7)),
        _m(121, 81, 71, DateTime(2026, 9, 1, 20)),
      ]);

      expect(groups.single.measurements.first.systolic, 121);
      expect(groups.single.measurements.last.systolic, 120);
    });

    test('leer bleibt leer', () {
      expect(groupByDay(const []), isEmpty);
    });
  });
}
