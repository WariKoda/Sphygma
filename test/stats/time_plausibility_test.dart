import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/time_plausibility.dart';

Measurement _m(int seq, DateTime at, {DateTime? importiert}) => Measurement(
      id: seq,
      userSlot: 1,
      deviceSequence: seq,
      systolic: 128,
      diastolic: 87,
      pulse: 82,
      measuredAt: at,
      movement: false,
      arrhythmia: false,
      rawBytes: Uint8List(14),
      importedAt: importiert ?? DateTime(2026, 9, 5, 23, 58),
      exportedAt: null,
    );

final _jetzt = DateTime(2026, 9, 5, 23, 59);

void main() {
  group('Ordnung der Gerätenummern', () {
    test('steigende Nummern mit steigender Zeit sind plausibel', () {
      final urteil = judgeTimestamps([
        _m(100, DateTime(2026, 9, 1, 7)),
        _m(101, DateTime(2026, 9, 2, 7)),
        _m(102, DateTime(2026, 9, 3, 7)),
      ], now: _jetzt);

      expect(urteil.values.every((u) => u.isPlausible), isTrue);
      expect(urteil[101]!.reason, isNull);
    });

    test('eine Messung, deren Zeit aus der Reihe fällt, ist fraglich', () {
      // Nr. 101 liegt der Nummer nach zwischen 100 und 102, dem Datum nach
      // aber Jahre davor. Das Gerät stand auf einer falschen Uhr.
      final urteil = judgeTimestamps([
        _m(100, DateTime(2026, 9, 1, 7)),
        _m(101, DateTime(2023, 4, 18, 11)),
        _m(102, DateTime(2026, 9, 3, 7)),
      ], now: _jetzt);

      expect(urteil[100]!.isPlausible, isTrue);
      expect(urteil[101]!.isPlausible, isFalse);
      expect(urteil[101]!.reason, contains('Reihenfolge'));
      expect(urteil[102]!.isPlausible, isTrue);
    });

    test('ein ganzer Block aus der Reihe wird vollständig erkannt', () {
      // Drei falsch datierte Messungen hintereinander: Eine reine
      // Nachbarschaftsprüfung fände sie nicht, weil beide Nachbarn selbst
      // Teil des Problems sind. Maßgeblich ist die Mehrheit — deshalb
      // braucht der Fall mehr plausible als fragliche Messungen, so wie im
      // echten Bestand, wo 111 von 114 stimmen.
      final urteil = judgeTimestamps([
        _m(100, DateTime(2026, 8, 30, 7)),
        _m(101, DateTime(2026, 8, 31, 7)),
        _m(102, DateTime(2026, 9, 1, 7)),
        _m(103, DateTime(2026, 9, 2, 7)),
        _m(104, DateTime(2023, 4, 18, 11, 2)),
        _m(105, DateTime(2023, 4, 18, 11, 5)),
        _m(106, DateTime(2023, 4, 18, 11, 8)),
        _m(107, DateTime(2026, 9, 5, 23, 57)),
      ], now: _jetzt);

      expect(urteil[104]!.isPlausible, isFalse);
      expect(urteil[105]!.isPlausible, isFalse);
      expect(urteil[106]!.isPlausible, isFalse);
      for (final nr in [100, 101, 102, 103, 107]) {
        expect(urteil[nr]!.isPlausible, isTrue, reason: 'Nr. $nr');
      }
    });

    test('bei genau hälftigem Widerspruch entscheidet die Reihenfolge', () {
      // Zwei gegen zwei: Die Mehrheit gibt nichts her. Das Ergebnis ist dann
      // willkürlich, aber deterministisch — und der Fall bedeutet ohnehin,
      // dass nur ein Blick aufs Gerät weiterhilft.
      final urteil = judgeTimestamps([
        _m(100, DateTime(2026, 9, 1, 7)),
        _m(101, DateTime(2026, 9, 2, 7)),
        _m(102, DateTime(2023, 4, 18, 11, 2)),
        _m(103, DateTime(2023, 4, 18, 11, 5)),
      ], now: _jetzt);

      final fraglich = urteil.values.where((u) => !u.isPlausible).length;
      expect(fraglich, 2, reason: 'die Hälfte bleibt übrig, welche ist offen');
    });

    test('die erste und die letzte Messung haben nur einen Nachbarn', () {
      final urteil = judgeTimestamps([
        _m(100, DateTime(2023, 1, 1)),
        _m(101, DateTime(2026, 9, 1, 7)),
        _m(102, DateTime(2026, 9, 2, 7)),
      ], now: _jetzt);

      // Ohne Vorgänger lässt sich für die erste nichts beweisen — sie gilt
      // als plausibel, statt auf Verdacht verurteilt zu werden.
      expect(urteil[100]!.isPlausible, isTrue);
    });
  });

  group('Zeitstempel in der Zukunft', () {
    test('deutlich in der Zukunft ist immer fraglich', () {
      final urteil = judgeTimestamps([
        _m(100, DateTime(2026, 9, 1, 7)),
        _m(101, DateTime(2027, 5, 1, 7)),
      ], now: _jetzt);

      expect(urteil[101]!.isPlausible, isFalse);
      expect(urteil[101]!.reason, contains('Zukunft'));
    });

    test('wenige Minuten Vorlauf sind kein Fehler', () {
      final urteil = judgeTimestamps([
        _m(100, _jetzt.add(const Duration(minutes: 5))),
      ], now: _jetzt);

      expect(urteil[100]!.isPlausible, isTrue);
    });
  });

  group('Geht die Geräteuhr falsch?', () {
    test('gemessen an der zuletzt gemessenen Messung, nicht am spätesten Datum',
        () {
      // Die höchste Nummer trägt ein Datum von 2023 — die Uhr geht falsch,
      // obwohl eine ältere Messung ein plausibles Datum hat.
      final falsch = deviceClockLooksWrong([
        _m(100, DateTime(2026, 9, 1, 7)),
        _m(101, DateTime(2026, 9, 3, 7)),
        _m(102, DateTime(2023, 4, 18, 11)),
      ], now: _jetzt);

      expect(falsch, isTrue);
    });

    test('eine echte alte Messung mit niedriger Nummer stört nicht', () {
      final falsch = deviceClockLooksWrong([
        _m(100, DateTime(2023, 4, 18, 11)),
        _m(101, DateTime(2026, 9, 3, 7)),
        _m(102, DateTime(2026, 9, 5, 23, 57)),
      ], now: _jetzt);

      expect(falsch, isFalse);
    });

    test('ohne Messungen gibt es nichts zu beanstanden', () {
      expect(deviceClockLooksWrong(const [], now: _jetzt), isFalse);
    });
  });

  group('Fail hard', () {
    test('doppelte Gerätenummern sind ein Fehler, kein Sonderfall', () {
      expect(
        () => judgeTimestamps([
          _m(100, DateTime(2026, 9, 1, 7)),
          _m(100, DateTime(2026, 9, 2, 7)),
        ], now: _jetzt),
        throwsArgumentError,
      );
    });

    test('Messungen zweier Speicherplätze zugleich sind ein Fehler', () {
      // Der Gerätezähler läuft je Platz: Nummer 100 auf Benutzer 1 und
      // Nummer 100 auf Benutzer 2 sind verschiedene Messungen. Ein Urteil
      // über beide Zeitachsen zugleich wäre bedeutungslos.
      final gemischt = [
        _m(100, DateTime(2026, 9, 1, 7)),
        Measurement(
          id: 999,
          userSlot: 2,
          deviceSequence: 100,
          systolic: 120,
          diastolic: 80,
          pulse: 70,
          measuredAt: DateTime(2026, 9, 2, 7),
          movement: false,
          arrhythmia: false,
          rawBytes: Uint8List(14),
          importedAt: DateTime(2026, 9, 5, 23, 58),
          exportedAt: null,
        ),
      ];

      expect(() => judgeTimestamps(gemischt, now: _jetzt), throwsArgumentError);
      expect(
        () => deviceClockLooksWrong(gemischt, now: _jetzt),
        throwsArgumentError,
      );
    });

    test('ein Urteil über eine unbekannte Nummer gibt es nicht', () {
      final urteil = judgeTimestamps([
        _m(100, DateTime(2026, 9, 1, 7)),
      ], now: _jetzt);

      expect(urteil[999], isNull);
    });
  });
}
