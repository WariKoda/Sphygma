// Regression fuer den Geraetetest vom 2026-09-04: Das health-Plugin
// (HealthDataWriter.buildMetadata) uebernimmt die clientRecordId nur dann in
// die Health-Connect-Metadaten, wenn auch clientRecordVersion gesetzt ist.
// Ohne Version wurde jeder Export als neuer Datensatz gespeichert und das
// Loeschen per clientRecordId traf nichts - meldete aber Erfolg.
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:sphygma/sync/health_connect_sink.dart';
import 'package:sphygma/sync/health_sink.dart';

class _RecordingHealth extends Health {
  final List<Map<String, Object?>> writes = [];
  final List<Map<String, Object?>> deletes = [];

  @override
  Future<void> configure() async {}

  @override
  Future<HealthConnectSdkStatus?> getHealthConnectSdkStatus() async =>
      HealthConnectSdkStatus.sdkAvailable;

  @override
  Future<bool?> hasPermissions(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async =>
      true;

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
    writes.add({
      'type': 'bp',
      'clientRecordId': clientRecordId,
      'clientRecordVersion': clientRecordVersion,
    });
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
    writes.add({
      'type': type.name,
      'clientRecordId': clientRecordId,
      'clientRecordVersion': clientRecordVersion,
    });
    return true;
  }

  @override
  Future<bool> deleteByClientRecordId({
    required HealthDataType dataTypeKey,
    required String clientRecordId,
    String? recordId,
  }) async {
    deletes.add({'type': dataTypeKey.name, 'clientRecordId': clientRecordId});
    return true;
  }
}

void main() {
  final write = BloodPressureWrite(
    clientRecordId: 'sphygma-slot1-seq533',
    systolic: 123,
    diastolic: 78,
    pulse: 66,
    measuredAt: DateTime(2026, 9, 3, 19, 30),
    movement: false,
    arrhythmia: false,
  );

  test('Blutdruck und Puls werden mit clientRecordId UND Version geschrieben',
      () async {
    final health = _RecordingHealth();
    final sink = HealthConnectSink(health: health);

    await sink.writeBloodPressure(write);

    expect(health.writes, hasLength(2));
    final bp = health.writes[0];
    final hr = health.writes[1];
    expect(bp['type'], 'bp');
    expect(bp['clientRecordId'], 'sphygma-slot1-seq533');
    expect(bp['clientRecordVersion'], isNotNull,
        reason: 'ohne Version verwirft das Plugin die clientRecordId');
    expect(hr['type'], HealthDataType.HEART_RATE.name);
    expect(hr['clientRecordId'], 'sphygma-slot1-seq533-hr');
    expect(hr['clientRecordVersion'], isNotNull,
        reason: 'ohne Version verwirft das Plugin die clientRecordId');
  });

  test('Loeschen nutzt dieselben clientRecordIds wie das Schreiben', () async {
    final health = _RecordingHealth();
    final sink = HealthConnectSink(health: health);

    await sink.writeBloodPressure(write);
    await sink.deleteBloodPressure(write.clientRecordId);

    expect(
      health.deletes.map((d) => d['clientRecordId']).toList(),
      health.writes.map((w) => w['clientRecordId']).toList(),
    );
  });
}
