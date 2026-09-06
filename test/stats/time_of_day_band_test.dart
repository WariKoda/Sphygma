import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/time_of_day_band.dart';

Measurement _m(DateTime at, {int sys = 120, int dia = 80, int puls = 70}) =>
    Measurement(
      id: at.millisecondsSinceEpoch,
      userSlot: 1,
      deviceSequence: at.millisecondsSinceEpoch ~/ 1000,
      systolic: sys,
      diastolic: dia,
      pulse: puls,
      measuredAt: at,
      movement: false,
      arrhythmia: false,
      rawBytes: Uint8List(14),
      importedAt: at,
      exportedAt: null,
    );

void main() {
  group('Feine Teilung in fünf Abschnitte', () {
    test('ordnet jede Stunde genau einem Abschnitt zu', () {
      final g = BandGrid.fein;
      expect(g.bandAt(TimeOfDayMinutes(5, 30)), TimeBand.nachts);
      expect(g.bandAt(TimeOfDayMinutes(6, 0)), TimeBand.morgens);
      expect(g.bandAt(TimeOfDayMinutes(9, 59)), TimeBand.morgens);
      expect(g.bandAt(TimeOfDayMinutes(10, 0)), TimeBand.vormittags);
      expect(g.bandAt(TimeOfDayMinutes(12, 0)), TimeBand.nachmittags);
      expect(g.bandAt(TimeOfDayMinutes(18, 0)), TimeBand.abends);
      expect(g.bandAt(TimeOfDayMinutes(22, 59)), TimeBand.abends);
      expect(g.bandAt(TimeOfDayMinutes(23, 0)), TimeBand.nachts);
      expect(g.bandAt(TimeOfDayMinutes(0, 0)), TimeBand.nachts);
    });

    test('deckt alle 1440 Minuten des Tages lückenlos ab', () {
      final g = BandGrid.fein;
      for (var minute = 0; minute < 1440; minute++) {
        final t = TimeOfDayMinutes(minute ~/ 60, minute % 60);
        expect(g.bandAt(t), isNotNull, reason: 'Minute $minute ohne Abschnitt');
      }
    });
  });

  group('Grobe Teilung für die Messwoche', () {
    test('teilt am Standard-Schnitt von 12 Uhr', () {
      final g = BandGrid.grob;
      expect(g.bandAt(TimeOfDayMinutes(7, 0)), TimeBand.morgens);
      expect(g.bandAt(TimeOfDayMinutes(11, 59)), TimeBand.morgens);
      expect(g.bandAt(TimeOfDayMinutes(12, 0)), TimeBand.abends);
      expect(g.bandAt(TimeOfDayMinutes(23, 30)), TimeBand.abends);
    });

    test('der Schnitt lässt sich verschieben, etwa für Schichtdienst', () {
      final g = BandGrid.grobMit(schnitt: TimeOfDayMinutes(15, 0));
      expect(g.bandAt(TimeOfDayMinutes(14, 0)), TimeBand.morgens);
      expect(g.bandAt(TimeOfDayMinutes(15, 0)), TimeBand.abends);
    });
  });

  group('Ungültige Grenzen werfen', () {
    test('ein Schnitt außerhalb des Tages ist ein Fehler', () {
      expect(() => TimeOfDayMinutes(24, 0), throwsArgumentError);
      expect(() => TimeOfDayMinutes(-1, 0), throwsArgumentError);
      expect(() => TimeOfDayMinutes(12, 60), throwsArgumentError);
    });

    test('unsortierte oder doppelte Grenzen sind ein Fehler', () {
      expect(
        () => BandGrid([
          BandBoundary(TimeOfDayMinutes(10, 0), TimeBand.morgens),
          BandBoundary(TimeOfDayMinutes(6, 0), TimeBand.vormittags),
        ]),
        throwsArgumentError,
      );
    });

    test('ein leeres Raster ist ein Fehler, kein leerer Tag', () {
      expect(() => BandGrid(const []), throwsArgumentError);
    });

    test('die geprüften Grenzen lassen sich nachträglich nicht ändern', () {
      // Sonst wäre die Prüfung wertlos — und weil fein und grob statisch
      // sind, wäre der Schaden global und dauerhaft.
      expect(() => BandGrid.fein.boundaries.clear(), throwsUnsupportedError);
      expect(
        () => BandGrid.fein.boundaries.add(
          BandBoundary(TimeOfDayMinutes(3, 0), TimeBand.nachts),
        ),
        throwsUnsupportedError,
      );
    });

    test('eine von außen geänderte Liste erreicht das Raster nicht', () {
      final eingabe = [
        BandBoundary(TimeOfDayMinutes(6, 0), TimeBand.morgens),
        BandBoundary(TimeOfDayMinutes(18, 0), TimeBand.abends),
      ];
      final grid = BandGrid(eingabe);
      eingabe.clear();

      expect(grid.boundaries.length, 2);
      expect(grid.bandAt(TimeOfDayMinutes(7, 0)), TimeBand.morgens);
    });
  });

  group('Messungen einordnen', () {
    test('gruppiert nach Abschnitt', () {
      final tag = DateTime(2026, 9, 5);
      final gruppen = groupByBand([
        _m(tag.add(const Duration(hours: 7)), sys: 130),
        _m(tag.add(const Duration(hours: 8)), sys: 134),
        _m(tag.add(const Duration(hours: 20)), sys: 124),
      ], BandGrid.fein);

      expect(gruppen[TimeBand.morgens]!.length, 2);
      expect(gruppen[TimeBand.abends]!.length, 1);
      expect(gruppen[TimeBand.nachts], isNull,
          reason: 'leere Abschnitte tauchen nicht auf');
    });

    test('Mittelwerte je Abschnitt', () {
      final tag = DateTime(2026, 9, 5);
      final mittel = averagesByBand([
        _m(tag.add(const Duration(hours: 7)), sys: 130, dia: 88),
        _m(tag.add(const Duration(hours: 8)), sys: 134, dia: 90),
        _m(tag.add(const Duration(hours: 20)), sys: 124, dia: 82),
      ], BandGrid.fein);

      expect(mittel[TimeBand.morgens]!.systolic, 132);
      expect(mittel[TimeBand.morgens]!.diastolic, 89);
      expect(mittel[TimeBand.morgens]!.count, 2);
      expect(mittel[TimeBand.abends]!.systolic, 124);
    });

    test('ohne Messungen gibt es keine Gruppen, keine leeren Mittelwerte', () {
      expect(groupByBand(const [], BandGrid.fein), isEmpty);
      expect(averagesByBand(const [], BandGrid.fein), isEmpty);
    });
  });
}
