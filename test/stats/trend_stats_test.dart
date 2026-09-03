// Trendansicht (PLAN.md M6): Morgen-/Abendmittel und 7-Tage-Durchschnitt
// als reine Funktionen ueber Messwerte.
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/stats/trend_stats.dart';

Reading r(DateTime at, int sys, int dia, [int pulse = 70]) =>
    Reading(measuredAt: at, systolic: sys, diastolic: dia, pulse: pulse);

void main() {
  final now = DateTime(2026, 9, 3, 21, 0);

  group('TrendStats.compute', () {
    test('7-Tage-Durchschnitt beruecksichtigt nur die letzten 7 Tage', () {
      final stats = TrendStats.compute([
        r(DateTime(2026, 9, 3, 8), 120, 80, 60),
        r(DateTime(2026, 9, 1, 8), 130, 90, 70),
        r(DateTime(2026, 8, 20, 8), 200, 120, 99), // zu alt
      ], now: now);

      expect(stats.last7Days!.systolic, 125);
      expect(stats.last7Days!.diastolic, 85);
      expect(stats.last7Days!.pulse, 65);
      expect(stats.last7Days!.count, 2);
    });

    test('Morgen = vor 12 Uhr, Abend = ab 18 Uhr, dazwischen zaehlt nicht',
        () {
      final stats = TrendStats.compute([
        r(DateTime(2026, 9, 3, 7), 110, 70),
        r(DateTime(2026, 9, 3, 11, 59), 120, 80),
        r(DateTime(2026, 9, 3, 14), 180, 110), // Mittag, weder noch
        r(DateTime(2026, 9, 3, 19), 130, 85),
      ], now: now);

      expect(stats.morning!.systolic, 115);
      expect(stats.morning!.count, 2);
      expect(stats.evening!.systolic, 130);
      expect(stats.evening!.count, 1);
    });

    test('ohne Messungen sind die Mittelwerte null, nicht 0', () {
      final stats = TrendStats.compute([], now: now);

      expect(stats.last7Days, isNull);
      expect(stats.morning, isNull);
      expect(stats.evening, isNull);
    });

    test('Mittelwerte werden kaufmaennisch gerundet', () {
      final stats = TrendStats.compute([
        r(DateTime(2026, 9, 3, 8), 121, 80),
        r(DateTime(2026, 9, 3, 9), 122, 81),
      ], now: now);

      expect(stats.last7Days!.systolic, 122); // 121.5 -> 122
      expect(stats.last7Days!.diastolic, 81); // 80.5 -> 81
    });
  });
}
