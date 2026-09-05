import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';

SlotRecord _slotRecord({
  required int slot,
  required int sequence,
  int systolic = 120,
  DateTime? measuredAt,
}) =>
    SlotRecord(
      userSlot: slot,
      record: BloodPressureRecord(
        systolic: systolic,
        diastolic: 80,
        pulse: 70,
        timestamp: measuredAt ?? DateTime(2026, 9, 3, 20, 0, 0),
        arrhythmiaFlag: false,
        movementFlag: sequence.isOdd,
        sequence: sequence,
      ),
      rawBytes: Uint8List.fromList(List.filled(14, sequence & 0xff)),
    );

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
  });

  tearDown(() => db.close());

  group('highestSequenceFor', () {
    // Grundlage fuer den Autosync: Der Wert wird mit der Messungsnummer
    // aus dem Advertising verglichen (docs/protocol/hem-6232t.md §2.1).
    test('liefert die hoechste bekannte Nummer eines Slots', () async {
      await repository.importAll([
        _slotRecord(slot: 1, sequence: 0x0210),
        _slotRecord(slot: 1, sequence: 0x021d),
        _slotRecord(slot: 1, sequence: 0x0215),
        _slotRecord(slot: 2, sequence: 0x000e),
      ]);

      expect(await repository.highestSequenceFor(1), 0x021d);
      expect(await repository.highestSequenceFor(2), 0x000e);
    });

    test('null bei einem Slot ohne Messungen - kein Ersatzwert', () async {
      // 0 waere hier falsch: Es ist von "Messung mit Nummer 0" nicht zu
      // unterscheiden und wuerde einen Sync ausloesen, der nichts findet.
      expect(await repository.highestSequenceFor(1), isNull);

      await repository.importAll([_slotRecord(slot: 1, sequence: 5)]);

      expect(await repository.highestSequenceFor(2), isNull);
    });
  });

  group('Sortierung', () {
    // Angezeigt wird nach Datum, wie am Geraet abgelesen. Die
    // Messungsnummer bleibt fuer Dedup und Uhr-Pruefung zustaendig.
    test('allForSlot sortiert nach Datum, nicht nach Messungsnummer',
        () async {
      await repository.importAll([
        // Hoechste Nummer, aber aeltestes Datum: falsch gestellte Uhr.
        _slotRecord(
          slot: 1,
          sequence: 300,
          measuredAt: DateTime(2023, 4, 18, 11, 2),
        ),
        _slotRecord(
          slot: 1,
          sequence: 100,
          measuredAt: DateTime(2026, 9, 1, 8, 0),
        ),
        _slotRecord(
          slot: 1,
          sequence: 200,
          measuredAt: DateTime(2026, 9, 3, 20, 0),
        ),
      ]);

      final all = await repository.allForSlot(1);

      expect(
        all.map((m) => m.deviceSequence).toList(),
        [300, 100, 200],
        reason: 'aelteste zuerst nach Datum: 2023, dann 01.09., dann 03.09.',
      );
    });

    test('bei gleichem Datum entscheidet die Messungsnummer', () async {
      final same = DateTime(2026, 9, 3, 20, 0);
      await repository.importAll([
        _slotRecord(slot: 1, sequence: 202, measuredAt: same),
        _slotRecord(slot: 1, sequence: 201, measuredAt: same),
      ]);

      final all = await repository.allForSlot(1);

      expect(all.map((m) => m.deviceSequence).toList(), [201, 202]);
    });
  });

  group('importAll', () {
    test('legt neue Records an und meldet, wie viele neu waren', () async {
      final inserted = await repository.importAll([
        _slotRecord(slot: 1, sequence: 0x0210),
        _slotRecord(slot: 1, sequence: 0x0211),
        _slotRecord(slot: 2, sequence: 0x000e),
      ]);

      expect(inserted, 3);
      expect(await repository.allForSlot(1), hasLength(2));
      expect(await repository.allForSlot(2), hasLength(1));
    });

    test('wiederholter Import derselben Records erzeugt keine Duplikate',
        () async {
      final batch = [
        _slotRecord(slot: 1, sequence: 0x0210),
        _slotRecord(slot: 1, sequence: 0x0211),
      ];
      await repository.importAll(batch);

      final insertedAgain = await repository.importAll(batch);

      expect(insertedAgain, 0);
      expect(await repository.allForSlot(1), hasLength(2));
    });

    test('dieselbe Messungsnummer in verschiedenen Slots sind zwei Records',
        () async {
      await repository.importAll([
        _slotRecord(slot: 1, sequence: 7),
        _slotRecord(slot: 2, sequence: 7),
      ]);

      expect(await repository.allForSlot(1), hasLength(1));
      expect(await repository.allForSlot(2), hasLength(1));
    });

    test('speichert Werte, Flags, Zeit und Rohbytes', () async {
      await repository.importAll([
        _slotRecord(
          slot: 1,
          sequence: 0x0213,
          systolic: 137,
          measuredAt: DateTime(2026, 9, 3, 21, 15, 42),
        ),
      ]);

      final m = (await repository.allForSlot(1)).single;
      expect(m.systolic, 137);
      expect(m.diastolic, 80);
      expect(m.pulse, 70);
      expect(m.measuredAt, DateTime(2026, 9, 3, 21, 15, 42));
      expect(m.movement, isTrue);
      expect(m.arrhythmia, isFalse);
      expect(m.deviceSequence, 0x0213);
      expect(m.rawBytes, Uint8List.fromList(List.filled(14, 0x13)));
      expect(m.exportedAt, isNull);
    });
  });

  group('Export-Buchhaltung', () {
    test('pendingExport liefert nur unexportierte Records des Slots',
        () async {
      await repository.importAll([
        _slotRecord(slot: 1, sequence: 1),
        _slotRecord(slot: 1, sequence: 2),
        _slotRecord(slot: 2, sequence: 3),
      ]);
      final first = (await repository.pendingExport(1)).first;
      await repository.markExported([first.id], DateTime(2026, 9, 4));

      final pending = await repository.pendingExport(1);

      expect(pending, hasLength(1));
      expect(pending.single.id, isNot(first.id));
      expect(await repository.pendingExport(2), hasLength(1));
    });

    test('exported liefert nur exportierte Records; markUnexported hebt es auf',
        () async {
      await repository.importAll([
        _slotRecord(slot: 1, sequence: 1),
        _slotRecord(slot: 1, sequence: 2),
      ]);
      final all = await repository.allForSlot(1);
      await repository.markExported([all.first.id], DateTime(2026, 9, 4));

      expect(await repository.exported(1), hasLength(1));

      await repository.markUnexported([all.first.id]);

      expect(await repository.exported(1), isEmpty);
      expect(await repository.pendingExport(1), hasLength(2));
    });

    test('markExported setzt exportedAt', () async {
      await repository.importAll([_slotRecord(slot: 1, sequence: 1)]);
      final m = (await repository.allForSlot(1)).single;

      await repository.markExported([m.id], DateTime(2026, 9, 4, 8));

      final after = (await repository.allForSlot(1)).single;
      expect(after.exportedAt, DateTime(2026, 9, 4, 8));
    });
  });
}
