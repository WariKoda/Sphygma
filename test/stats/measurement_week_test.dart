import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/measurement_week.dart';
import 'package:sphygma/stats/time_of_day_band.dart';

Measurement _m(int seq, DateTime at, {int sys = 128, int dia = 84}) =>
    Measurement(
      id: seq,
      userSlot: 1,
      deviceSequence: seq,
      systolic: sys,
      diastolic: dia,
      pulse: 81,
      measuredAt: at,
      movement: false,
      arrhythmia: false,
      rawBytes: Uint8List(14),
      importedAt: DateTime(2026, 9, 5, 23, 58),
      exportedAt: null,
    );

/// Montag, 10.08.2026
final _montag = DateTime(2026, 8, 10);

List<Measurement> _volleWoche(DateTime montag, {int abStelle = 1}) {
  final out = <Measurement>[];
  var seq = abStelle;
  for (var tag = 0; tag < 7; tag++) {
    for (final stunde in [7, 20]) {
      out.add(_m(seq++, montag.add(Duration(days: tag, hours: stunde))));
    }
  }
  return out;
}

void main() {
  group('Eine Woche entsteht von Montag bis Sonntag', () {
    test('vierzehn Felder, zwei je Tag', () {
      final wochen = buildWeeks(_volleWoche(_montag));

      expect(wochen, hasLength(1));
      expect(wochen.single.beginsAt, _montag);
      expect(wochen.single.filledFields, 14);
      expect(wochen.single.isComplete, isTrue);
    });

    test('eine Lücke macht die Woche unvollständig', () {
      final ms = _volleWoche(_montag)..removeAt(3);
      final woche = buildWeeks(ms).single;

      expect(woche.filledFields, 13);
      expect(woche.isComplete, isFalse);
    });

    test('mehrere Messungen in einem Feld füllen es einmal', () {
      // Zwei Messungen kurz hintereinander sind ein Messen, kein zweites Feld.
      final ms = _volleWoche(_montag)
        ..add(_m(99, _montag.add(const Duration(hours: 7, minutes: 2))));
      final woche = buildWeeks(ms).single;

      expect(woche.filledFields, 14);
      expect(woche.measurements, hasLength(15));
    });

    test('Wochen kommen neueste zuerst', () {
      final ms = [
        ..._volleWoche(_montag, abStelle: 1),
        ..._volleWoche(_montag.add(const Duration(days: 7)), abStelle: 100),
      ];
      final wochen = buildWeeks(ms);

      expect(wochen, hasLength(2));
      expect(wochen.first.beginsAt, _montag.add(const Duration(days: 7)));
    });
  });

  group('Der Wochenwert', () {
    test('lässt den ersten Tag aus, so rechnet die Praxis', () {
      final ms = <Measurement>[];
      var seq = 1;
      // Tag 1 deutlich höher als der Rest — er darf nicht durchschlagen.
      for (final stunde in [7, 20]) {
        ms.add(_m(seq++, _montag.add(Duration(hours: stunde)), sys: 160, dia: 100));
      }
      for (var tag = 1; tag < 7; tag++) {
        for (final stunde in [7, 20]) {
          ms.add(_m(seq++, _montag.add(Duration(days: tag, hours: stunde)),
              sys: 120, dia: 80));
        }
      }

      final woche = buildWeeks(ms).single;
      expect(woche.average!.systolic, 120);
      expect(woche.averageWithFirstDay!.systolic, greaterThan(120),
          reason: 'der Vollwert bleibt abrufbar');
    });

    test('eine Woche mit nur einem Tag hat keinen Wochenwert', () {
      // Nach dem Auslassen des ersten Tages bleibt nichts übrig — dann gibt
      // es keinen Wert, keine erfundene Null.
      final woche = buildWeeks([
        _m(1, _montag.add(const Duration(hours: 7))),
        _m(2, _montag.add(const Duration(hours: 20))),
      ]).single;

      expect(woche.average, isNull);
      expect(woche.averageWithFirstDay, isNotNull);
    });

    test('morgens und abends getrennt', () {
      final ms = <Measurement>[];
      var seq = 1;
      for (var tag = 0; tag < 7; tag++) {
        ms.add(_m(seq++, _montag.add(Duration(days: tag, hours: 7)), sys: 135));
        ms.add(_m(seq++, _montag.add(Duration(days: tag, hours: 20)), sys: 125));
      }

      final woche = buildWeeks(ms).single;
      expect(woche.morningAverage!.systolic, 135);
      expect(woche.eveningAverage!.systolic, 125);
    });
  });

  group('Fail hard', () {
    test('ohne Messungen gibt es keine Wochen', () {
      expect(buildWeeks(const []), isEmpty);
    });

    test('mehrere Speicherplätze zugleich sind ein Fehler', () {
      final gemischt = [
        _m(1, _montag.add(const Duration(hours: 7))),
        Measurement(
          id: 2,
          userSlot: 2,
          deviceSequence: 2,
          systolic: 120,
          diastolic: 80,
          pulse: 70,
          measuredAt: _montag.add(const Duration(hours: 20)),
          movement: false,
          arrhythmia: false,
          rawBytes: Uint8List(14),
          importedAt: DateTime(2026, 9, 5),
          exportedAt: null,
        ),
      ];

      expect(() => buildWeeks(gemischt), throwsArgumentError);
    });
  });

  group('Die Teilung morgens/abends ist einstellbar', () {
    test('ein verschobener Schnitt ordnet anders zu', () {
      final ms = [
        _m(1, _montag.add(const Duration(hours: 14)), sys: 140),
        _m(2, _montag.add(const Duration(hours: 16)), sys: 120),
      ];

      final normal = buildWeeks(ms).single;
      expect(normal.morningAverage, isNull, reason: '14 Uhr ist nachmittags');

      final spaet = buildWeeks(
        ms,
        schnitt: TimeOfDayMinutes(15, 0),
      ).single;
      expect(spaet.morningAverage!.systolic, 140);
    });
  });
}
