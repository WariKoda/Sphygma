import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/period.dart';

Measurement _m(DateTime at) => Measurement(
      id: at.millisecondsSinceEpoch,
      userSlot: 1,
      deviceSequence: at.millisecondsSinceEpoch ~/ 1000,
      systolic: 120,
      diastolic: 80,
      pulse: 70,
      measuredAt: at,
      movement: false,
      arrhythmia: false,
      rawBytes: Uint8List(14),
      importedAt: at,
      exportedAt: null,
    );

void main() {
  final now = DateTime(2026, 9, 5, 12);

  test('Woche nimmt die letzten sieben Tage', () {
    final alle = [
      _m(now.subtract(const Duration(days: 1))),
      _m(now.subtract(const Duration(days: 6))),
      _m(now.subtract(const Duration(days: 8))),
    ];

    expect(filterByPeriod(alle, Period.week, now), hasLength(2));
  });

  test('Alles nimmt jede Messung', () {
    final alle = [_m(DateTime(2019, 1, 1)), _m(now)];

    expect(filterByPeriod(alle, Period.all, now), hasLength(2));
  });

  test('Messungen in der Zukunft fallen heraus', () {
    // Kommt bei falsch gestellter Geraeteuhr vor; sie wuerden sonst jeden
    // Zeitraum verfaelschen.
    final alle = [_m(now.add(const Duration(days: 2))), _m(now)];

    expect(filterByPeriod(alle, Period.week, now), hasLength(1));
  });

  test('jeder Zeitraum hat eine Beschriftung', () {
    for (final p in Period.values) {
      expect(p.label, isNotEmpty);
    }
  });

  test('Alles hat keinen Anfang', () {
    expect(Period.all.startFrom(now), isNull);
    expect(Period.month.startFrom(now), isNotNull);
  });
}
