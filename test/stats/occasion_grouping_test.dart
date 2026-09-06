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

  group('Offene Fragen verschwinden nicht hinter Bestätigungen', () {
    test('ein Graubereich bleibt sichtbar, auch neben einer Bestätigung', () {
      // Vor 101 hat der Nutzer getrennt; zwischen 101 und 102 liegen elf
      // Minuten und damit eine offene Frage. Würde „bestätigt" gewinnen,
      // erführe der Nutzer nie, dass noch etwas zu entscheiden ist.
      final anlaesse = proposeOccasions(
        [
          _m(100, _basis),
          _m(101, _basis.add(const Duration(minutes: 2))),
          _m(102, _basis.add(const Duration(minutes: 13))),
        ],
        confirmedSplits: {101},
      );

      expect(
        anlaesse.any((a) => a.state == OccasionState.zuPruefen),
        isTrue,
        reason: 'der Übergang 101 zu 102 liegt im Graubereich',
      );
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

  group('Die offene Naht hat eine Adresse', () {
    test('ein Grenzfall nennt die Messung, um die es geht', () {
      // Elf Minuten: zu weit für "sicher zusammen", zu nah für "sicher
      // getrennt".
      final anlaesse = proposeOccasions([
        _m(200, _basis),
        _m(201, _basis.add(const Duration(minutes: 11))),
      ]);

      expect(anlaesse, hasLength(2));
      expect(anlaesse.first.state, OccasionState.zuPruefen);
      // Die Frage lautet: Gehört 201 noch zum ersten Anlass?
      expect(anlaesse.first.openSeam, 201);
      expect(anlaesse.last.openSeam, isNull);
    });

    test('ohne Grenzfall ist keine Naht offen', () {
      final anlaesse = proposeOccasions([
        _m(300, _basis),
        _m(301, _basis.add(const Duration(minutes: 2))),
      ]);

      expect(anlaesse.single.openSeam, isNull);
    });

    test('eine Entscheidung schließt die Naht', () {
      final messungen = [
        _m(400, _basis),
        _m(401, _basis.add(const Duration(minutes: 11))),
      ];

      final zusammen = proposeOccasions(messungen, confirmedJoins: {401});
      expect(zusammen, hasLength(1));
      expect(zusammen.single.openSeam, isNull);
      expect(zusammen.single.state, OccasionState.bestaetigt);

      final getrennt = proposeOccasions(messungen, confirmedSplits: {401});
      expect(getrennt, hasLength(2));
      expect(getrennt.every((o) => o.openSeam == null), isTrue);
    });
  });

  group('Eine Entscheidung lässt sich zurücknehmen', () {
    test('die bestätigte Trennung steht bei beiden Nachbarn', () {
      final anlaesse = proposeOccasions(
        [
          _m(500, _basis),
          _m(501, _basis.add(const Duration(minutes: 11))),
        ],
        confirmedSplits: {501},
      );

      expect(anlaesse, hasLength(2));
      // Gespeichert ist die Entscheidung unter 501 — der Nummer der ersten
      // Messung des rechten Anlasses. Beide Seiten müssen sie nennen können,
      // sonst löscht die Rücknahme den falschen Eintrag.
      expect(anlaesse.first.confirmedSeams, [501]);
      expect(anlaesse.last.confirmedSeams, [501]);
    });

    test('das bestätigte Zusammen steht beim gemeinsamen Anlass', () {
      final anlaesse = proposeOccasions(
        [
          _m(600, _basis),
          _m(601, _basis.add(const Duration(minutes: 11))),
        ],
        confirmedJoins: {601},
      );

      expect(anlaesse.single.confirmedSeams, [601]);
    });

    test('ohne Entscheidung ist keine Naht bestätigt', () {
      final anlaesse = proposeOccasions([
        _m(700, _basis),
        _m(701, _basis.add(const Duration(minutes: 2))),
      ]);

      expect(anlaesse.single.confirmedSeams, isEmpty);
    });

    test('jede genannte Nummer trägt wirklich eine Entscheidung', () {
      // Drei Messungen, zwei Entscheidungen: 801 angeschlossen, 802 getrennt.
      final anlaesse = proposeOccasions(
        [
          _m(800, _basis),
          _m(801, _basis.add(const Duration(minutes: 11))),
          _m(802, _basis.add(const Duration(minutes: 22))),
        ],
        confirmedJoins: {801},
        confirmedSplits: {802},
      );

      final genannt = {for (final o in anlaesse) ...o.confirmedSeams};
      expect(genannt, {801, 802});
    });
  });
}
