import 'dart:typed_data';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:sphygma/db/app_database.dart';
import 'package:sphygma/db/measurement_repository.dart';
import 'package:sphygma/protocol/readout.dart';
import 'package:sphygma/protocol/record.dart';
import 'package:sphygma/sync/export_service.dart';
import 'package:sphygma/sync/health_connect_sink.dart';
import 'package:sphygma/sync/health_sink.dart';

class RecordingSink implements HealthSink {
  final writes = <String>[];
  @override
  Future<void> writeBloodPressure(BloodPressureWrite w) async {
    writes.add(w.clientRecordId);
  }

  @override
  Future<void> deleteBloodPressure(String id) async {}
}

class PartialHealth extends Health {
  final stored = <String>{};
  final deletes = <String>[];
  bool failPulse = true;
  bool failDelete = false;
  bool failPulseDelete = false;
  @override
  Future<void> configure() async {}
  @override
  Future<HealthConnectSdkStatus?> getHealthConnectSdkStatus() async =>
      HealthConnectSdkStatus.sdkAvailable;
  @override
  Future<bool?> hasPermissions(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async => true;
  @override
  Future<bool> writeBloodPressure({
    required int systolic,
    required int diastolic,
    required DateTime startTime,
    String? clientRecordId,
    double? clientRecordVersion,
    DateTime? endTime,
    RecordingMethod recordingMethod = RecordingMethod.automatic,
  }) async {
    stored.add(clientRecordId!);
    return true;
  }

  @override
  Future<bool> writeHealthData({
    required double value,
    HealthDataUnit? unit,
    required HealthDataType type,
    required DateTime startTime,
    String? clientRecordId,
    double? clientRecordVersion,
    DateTime? endTime,
    RecordingMethod recordingMethod = RecordingMethod.automatic,
  }) async {
    if (failPulse) return false;
    stored.add(clientRecordId!);
    return true;
  }

  @override
  Future<bool> deleteByClientRecordId({
    required HealthDataType dataTypeKey,
    required String clientRecordId,
    String? recordId,
  }) async {
    deletes.add(clientRecordId);
    if (failDelete || (failPulseDelete && clientRecordId.endsWith('-hr'))) {
      throw StateError('delete failed');
    }
    stored.remove(clientRecordId);
    return true;
  }
}

SlotRecord record(int seq) => SlotRecord(
  userSlot: 1,
  record: BloodPressureRecord(
    systolic: 120,
    diastolic: 80,
    pulse: 70,
    timestamp: DateTime(2026, 9, 10, 8, seq),
    arrhythmiaFlag: false,
    movementFlag: false,
    sequence: seq,
  ),
  rawBytes: Uint8List(14),
);

void main() {
  test('manueller Rückzug bleibt beim automatischen Export bestehen', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = MeasurementRepository(db);
    final sink = RecordingSink();
    final service = ExportService(repository: repo, sink: sink);
    await repo.importAll([record(1)]);
    await service.exportPending(userSlot: 1);
    await service.retractExported(userSlot: 1);
    await repo.importAll([record(2)]);
    await service.exportPending(userSlot: 1, onlyNew: true);
    expect(sink.writes, ['sphygma-slot1-seq1', 'sphygma-slot1-seq2']);
    await service.exportPending(userSlot: 1);
    expect(sink.writes.last, 'sphygma-slot1-seq1');
    expect(sink.writes, hasLength(3));
  });

  test('Teilexport bleibt nach Neustart rückziehbar', () async {
    final dir = await Directory.systemTemp.createTemp('sphygma-export-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    var repo = MeasurementRepository(db);
    final health = PartialHealth();
    var service = ExportService(
      repository: repo,
      sink: HealthConnectSink(health: health),
    );
    await repo.importAll([record(1)]);
    await expectLater(
      service.exportPending(userSlot: 1),
      throwsA(isA<HealthConnectWriteException>()),
    );
    expect(health.stored, {'sphygma-slot1-seq1'});
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    repo = MeasurementRepository(db);
    service = ExportService(
      repository: repo,
      sink: HealthConnectSink(health: health),
    );
    expect(await service.retractExported(userSlot: 1), 1);
    expect(health.stored, isEmpty);
    expect(await service.exportPending(userSlot: 1, onlyNew: true), 0);
  });

  test(
    'fehlgeschlagener Rückzug sperrt automatischen Retry nach Neustart',
    () async {
      final dir = await Directory.systemTemp.createTemp('sphygma-retract-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/db.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      var repo = MeasurementRepository(db);
      final health = PartialHealth();
      var service = ExportService(
        repository: repo,
        sink: HealthConnectSink(health: health),
      );
      await repo.importAll([record(1)]);
      await expectLater(
        service.exportPending(userSlot: 1),
        throwsA(isA<HealthConnectWriteException>()),
      );
      health.failDelete = true;
      await expectLater(
        service.retractExported(userSlot: 1),
        throwsA(isA<StateError>()),
      );
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);
      repo = MeasurementRepository(db);
      service = ExportService(
        repository: repo,
        sink: HealthConnectSink(health: health),
      );
      health.failPulse = false;
      expect(await service.exportPending(userSlot: 1, onlyNew: true), 0);
      health.failDelete = false;
      expect(await service.retractExported(userSlot: 1), 1);
      expect(health.stored, isEmpty);
    },
  );

  test(
    'Teilexport lässt sich mit denselben IDs vollständig wiederholen',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = MeasurementRepository(db);
      final health = PartialHealth();
      final service = ExportService(
        repository: repo,
        sink: HealthConnectSink(health: health),
      );
      await repo.importAll([record(1)]);
      final id = (await repo.allForSlot(1)).single.id;
      expect(await repo.exportStatesForSlot(1), isEmpty);
      await expectLater(
        service.exportPending(userSlot: 1),
        throwsA(isA<HealthConnectWriteException>()),
      );
      expect(await repo.exportStatesForSlot(1), {
        id: MeasurementExportState.pendingWrite,
      });
      health.failPulse = false;
      expect(await service.exportPending(userSlot: 1, onlyNew: true), 1);
      expect(health.stored, {'sphygma-slot1-seq1', 'sphygma-slot1-seq1-hr'});
      expect(await repo.exportStatesForSlot(1), {
        id: MeasurementExportState.exported,
      });
    },
  );

  test(
    'partieller Delete bleibt sichtbar und kann wiederholt werden',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = MeasurementRepository(db);
      final health = PartialHealth()..failPulse = false;
      final service = ExportService(
        repository: repo,
        sink: HealthConnectSink(health: health),
      );
      await repo.importAll([record(1)]);
      await service.exportPending(userSlot: 1);
      final m = (await repo.allForSlot(1)).single;
      health.failPulseDelete = true;
      await expectLater(service.retractOne(m), throwsA(isA<StateError>()));
      expect(health.stored, {'sphygma-slot1-seq1-hr'});
      expect(await repo.exportStatesForSlot(1), {
        m.id: MeasurementExportState.pendingRetraction,
      });
      expect(await service.exportPending(userSlot: 1, onlyNew: true), 0);
      health.failPulseDelete = false;
      expect(await service.retractExported(userSlot: 1), 1);
      expect(health.stored, isEmpty);
      expect(await repo.exportStatesForSlot(1), {
        m.id: MeasurementExportState.retracted,
      });
      await service.exportOne(m);
      expect(await repo.exportStatesForSlot(1), {
        m.id: MeasurementExportState.exported,
      });
    },
  );

  test(
    'gesamte Rückzugsentscheidung bleibt bei frühem Deletefehler erhalten',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = MeasurementRepository(db);
      final health = PartialHealth()..failPulse = false;
      final service = ExportService(
        repository: repo,
        sink: HealthConnectSink(health: health),
      );
      await repo.importAll([record(1), record(2)]);
      await service.exportPending(userSlot: 1, limit: 1);
      health.failPulse = true;
      await expectLater(
        service.exportPending(userSlot: 1),
        throwsA(isA<HealthConnectWriteException>()),
      );
      health.failDelete = true;
      await expectLater(
        service.retractExported(userSlot: 1),
        throwsA(isA<StateError>()),
      );
      final states = await repo.exportStatesForSlot(1);
      expect(states, hasLength(2));
      expect(
        states.values,
        everyElement(MeasurementExportState.pendingRetraction),
      );
      health.failPulse = false;
      expect(await service.exportPending(userSlot: 1, onlyNew: true), 0);
      health.failDelete = false;
      expect(await service.retractExported(userSlot: 1), 2);
      expect(health.stored, isEmpty);
    },
  );

  test(
    'Aufnahmegrenze verdeckt keinen möglichen Teilexport beim Rückzug',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = MeasurementRepository(db);
      final health = PartialHealth();
      final service = ExportService(
        repository: repo,
        sink: HealthConnectSink(health: health),
      );
      await repo.importAll([record(1)]);
      await expectLater(
        service.exportPending(userSlot: 1),
        throwsA(isA<HealthConnectWriteException>()),
      );
      await repo.setIntakeFloor(1, 2);
      expect(await repo.allForSlot(1), isEmpty);
      expect(await service.retractExported(userSlot: 1), 1);
      expect(health.stored, isEmpty);
    },
  );
}
