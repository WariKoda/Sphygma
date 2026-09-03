import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_sink.dart';

class FakeHealthSink implements HealthSink {
  final List<BloodPressureWrite> written = [];
  final List<String> deleted = [];
  bool failNext = false;

  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {
    if (failNext) {
      failNext = false;
      throw StateError('Health Connect nicht erreichbar');
    }
    written.add(write);
  }

  @override
  Future<void> deleteBloodPressure(String clientRecordId) async {
    deleted.add(clientRecordId);
  }
}

SlotRecord _rec(int slot, int seq, {bool movement = false, bool ihb = false}) =>
    SlotRecord(
      userSlot: slot,
      record: BloodPressureRecord(
        systolic: 120 + seq,
        diastolic: 80,
        pulse: 70,
        timestamp: DateTime(2026, 9, 3, 8, 0, seq),
        arrhythmiaFlag: ihb,
        movementFlag: movement,
        sequence: seq,
      ),
      rawBytes: Uint8List(14),
    );

void main() {
  late AppDatabase db;
  late MeasurementRepository repository;
  late FakeHealthSink sink;
  late ExportService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementRepository(db);
    sink = FakeHealthSink();
    service = ExportService(repository: repository, sink: sink);
  });

  tearDown(() => db.close());

  test('exportiert nur den gewaehlten Slot und markiert die Datensaetze',
      () async {
    await repository.importAll([_rec(1, 1), _rec(1, 2), _rec(2, 3)]);

    final exported = await service.exportPending(userSlot: 1);

    expect(exported, 2);
    expect(sink.written, hasLength(2));
    expect(await repository.pendingExport(1), isEmpty);
    expect(await repository.pendingExport(2), hasLength(1));
  });

  test('clientRecordId ist deterministisch aus Slot und Messungsnummer',
      () async {
    await repository.importAll([_rec(2, 0x0214)]);

    await service.exportPending(userSlot: 2);

    expect(sink.written.single.clientRecordId, 'sphygma-slot2-seq532');
  });

  test('uebergibt Werte, Zeit, Puls und beide Flags', () async {
    await repository.importAll([_rec(1, 5, movement: true, ihb: true)]);

    await service.exportPending(userSlot: 1);

    final w = sink.written.single;
    expect(w.systolic, 125);
    expect(w.diastolic, 80);
    expect(w.pulse, 70);
    expect(w.measuredAt, DateTime(2026, 9, 3, 8, 0, 5));
    expect(w.movement, isTrue);
    expect(w.arrhythmia, isTrue);
  });

  test('zweiter Export ohne neue Daten schreibt nichts', () async {
    await repository.importAll([_rec(1, 1)]);
    await service.exportPending(userSlot: 1);

    final again = await service.exportPending(userSlot: 1);

    expect(again, 0);
    expect(sink.written, hasLength(1));
  });

  test('limit begrenzt den Export auf die aeltesten n Messungen', () async {
    await repository.importAll([_rec(1, 1), _rec(1, 2), _rec(1, 3)]);

    final exported = await service.exportPending(userSlot: 1, limit: 1);

    expect(exported, 1);
    expect(sink.written.single.clientRecordId, 'sphygma-slot1-seq1');
    expect(await repository.pendingExport(1), hasLength(2));
  });

  test('retractExported loescht alles Exportierte des Slots in der Senke '
      'und setzt die Markierung zurueck', () async {
    await repository.importAll([_rec(1, 1), _rec(1, 2), _rec(2, 3)]);
    await service.exportPending(userSlot: 1);
    await service.exportPending(userSlot: 2);

    final retracted = await service.retractExported(userSlot: 1);

    expect(retracted, 2);
    expect(sink.deleted, unorderedEquals(['sphygma-slot1-seq1', 'sphygma-slot1-seq2']));
    expect(await repository.pendingExport(1), hasLength(2));
    expect(await repository.pendingExport(2), isEmpty);
  });

  test('scheitert die Senke, bleibt der Datensatz unexportiert und der '
      'Fehler kommt durch', () async {
    await repository.importAll([_rec(1, 1)]);
    sink.failNext = true;

    await expectLater(
      service.exportPending(userSlot: 1),
      throwsA(isA<StateError>()),
    );
    expect(await repository.pendingExport(1), hasLength(1));
  });
}
