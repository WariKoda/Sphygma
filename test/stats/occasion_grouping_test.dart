import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/stats/occasion_grouping.dart';

Measurement _m(
  int seq,
  DateTime at, {
  int sys = 128,
  int dia = 87,
  int puls = 82,
  bool bewegung = false,
  bool arrhythmie = false,
}) =>
    Measurement(
      id: seq,
      userSlot: 1,
      deviceSequence: seq,
      systolic: sys,
      diastolic: dia,
      pulse: puls,
      measuredAt: at,
      movement: bewegung,
      arrhythmia: arrhythmie,
      rawBytes: Uint8List(14),
      importedAt: DateTime(2026, 9, 5, 23, 58),
      exportedAt: null,
    );

final _basis = DateTime(2026, 9, 5, 20, 0);

void main() {
  group('Was zusammengehört', () {
    test('zwei Messungen kurz hintereinander sind ein Anlass', () {
      final anlaesse = proposeOccasions([
        _m(100, _basis),
        _m(101, _basis.add(const Duration(minutes: 2))),
      ]);

      expect(anlaesse, hasLength(1));
      expect(anlaesse.single.measurements, hasLength(2));
      expect(anlaesse.single.state, OccasionState.sicher);
    });

    test('eine Lücke in der Nummernfolge trennt, auch bei kurzer Zeit', () {
      // Fehlt eine Nummer, wurde dazwischen gemessen — die fehlende Messung
      // liegt vielleicht auf dem anderen Speicherplatz oder wurde nie
      // eingelesen. Zusammenfassen hieße, über eine Lücke hinweg zu mitteln.
      final anlaesse = proposeOccasions([
        _m(100, _basis),
        _m(102, _basis.add(const Duration(minutes: 2))),
      ]);

      expect(anlaesse, hasLength(2));
    });

    test('ein großer Zeitabstand trennt, auch bei fortlaufender Nummer', () {
      final anlaesse = proposeOccasions([
        _m(100, _basis),
        _m(101, _basis.add(const Duration(hours: 12))),
      ]);

      expect(anlaesse, hasLength(2));
    });

    test('drei Messungen in Folge bilden einen Anlass', () {
      final anlaesse = proposeOccasions([
        _m(100, _basis),
        _m(101, _basis.add(const Duration(minutes: 2))),
        _m(102, _basis.add(const Duration(minutes: 4))),
      ]);

      expect(anlaesse, hasLength(1));
      expect(anlaesse.single.measurements, hasLength(3));
    });
  });

  group('Grenzfälle bleiben offen', () {
    test('knapp über der Schwelle wird nicht still getrennt', () {
      final anlaesse = proposeOccasions([
        _m(100, _basis),
        _m(101, _basis.add(const Duration(minutes: 11))),
      ]);

      // Elf Minuten: über der Schwelle von zehn, aber nicht weit genug, um
      // sicher zu sein. Der Vorschlag trennt, meldet sich aber zur Prüfung.
      expect(anlaesse, hasLength(2));
      expect(anlaesse.any((a) => a.state == OccasionState.zuPruefen), isTrue);
    });

    test('weit auseinander ist sicher getrennt, ohne Nachfrage', () {
      final anlaesse = proposeOccasions([
        _m(100, _basis),
        _m(101, _basis.add(const Duration(hours: 3))),
      ]);

      expect(anlaesse.every((a) => a.state == OccasionState.sicher), isTrue);
    });
  });

  group('Das Ergebnis eines Anlasses', () {
    test('mittelt über die Messungen ohne Bewegungskennzeichen', () {
      final anlass = proposeOccasions([
        _m(100, _basis, sys: 140, dia: 95, puls: 90, bewegung: true),
        _m(101, _basis.add(const Duration(minutes: 2)), sys: 126, dia: 84),
        _m(102, _basis.add(const Duration(minutes: 4)), sys: 128, dia: 86),
      ]).single;

      expect(anlass.result.systolic, 127);
      expect(anlass.result.diastolic, 85);
      expect(anlass.usedMeasurements, hasLength(2));
      expect(anlass.rule, contains('ohne Bewegung'));
    });

    test('trägt jede Messung Bewegung, zählen alle', () {
      // Sonst bliebe kein Wert übrig — und kein Ergebnis wäre schlechter als
      // ein Ergebnis mit dem Hinweis, worauf es beruht.
      final anlass = proposeOccasions([
        _m(100, _basis, sys: 140, dia: 90, bewegung: true),
        _m(101, _basis.add(const Duration(minutes: 2)), sys: 130, dia: 86,
            bewegung: true),
      ]).single;

      expect(anlass.result.systolic, 135);
      expect(anlass.usedMeasurements, hasLength(2));
      expect(anlass.rule, contains('alle'));
    });

    test('unregelmäßiger Puls schließt eine Messung nicht aus', () {
      // Arrhythmie ist ein Befund, kein Messfehler — sie darf den Wert nicht
      // aus dem Ergebnis werfen.
      final anlass = proposeOccasions([
        _m(100, _basis, sys: 130, dia: 88, arrhythmie: true),
        _m(101, _basis.add(const Duration(minutes: 2)), sys: 126, dia: 84),
      ]).single;

      expect(anlass.usedMeasurements, hasLength(2));
      expect(anlass.result.systolic, 128);
    });

    test('ein Anlass mit einer Messung hat deren Wert', () {
      final anlass = proposeOccasions([
        _m(100, _basis, sys: 131, dia: 89),
      ]).single;

      expect(anlass.result.systolic, 131);
      expect(anlass.measurements, hasLength(1));
    });
  });

  group('Bestätigte Entscheidungen überstimmen den Vorschlag', () {
    test('eine bestätigte Trennung wird nicht wieder zusammengefasst', () {
      final anlaesse = proposeOccasions(
        [
          _m(100, _basis),
          _m(101, _basis.add(const Duration(minutes: 2))),
        ],
        confirmedSplits: {101},
      );

      expect(anlaesse, hasLength(2));
      expect(anlaesse.every((a) => a.state == OccasionState.bestaetigt), isTrue);
    });

    test('eine bestätigte Zusammenfassung überbrückt die Zeitschwelle', () {
      final anlaesse = proposeOccasions(
        [
          _m(100, _basis),
          _m(101, _basis.add(const Duration(minutes: 25))),
        ],
        confirmedJoins: {101},
      );

      expect(anlaesse, hasLength(1));
      expect(anlaesse.single.state, OccasionState.bestaetigt);
    });
  });

  group('Fail hard', () {
    test('mehrere Speicherplätze zugleich sind ein Fehler', () {
      final gemischt = [
        _m(100, _basis),
        Measurement(
          id: 999,
          userSlot: 2,
          deviceSequence: 101,
          systolic: 120,
          diastolic: 80,
          pulse: 70,
          measuredAt: _basis.add(const Duration(minutes: 2)),
          movement: false,
          arrhythmia: false,
          rawBytes: Uint8List(14),
          importedAt: DateTime(2026, 9, 5, 23, 58),
          exportedAt: null,
        ),
      ];

      expect(() => proposeOccasions(gemischt), throwsArgumentError);
    });

    test('ohne Messungen gibt es keine Anlässe', () {
      expect(proposeOccasions(const []), isEmpty);
    });

    test('eine widersprüchliche Entscheidung wirft', () {
      expect(
        () => proposeOccasions(
          [_m(100, _basis), _m(101, _basis.add(const Duration(minutes: 2)))],
          confirmedSplits: {101},
          confirmedJoins: {101},
        ),
        throwsArgumentError,
      );
    });
  });
}
