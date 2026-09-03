// Health-Connect-Anbindung ueber das health-Paket (PLAN.md §4.1). Duennes
// Glue; die Export-Logik liegt in export_service.dart.
//
// Health Connect kennt fuer Blutdruck keine Bewegungs-/Arrhythmie-Flags -
// writeBloodPressure() nimmt nur Systole, Diastole und Zeit. Die Flags
// bleiben deshalb in der lokalen DB (Source of Truth) und werden dort
// angezeigt, nicht exportiert.
import 'package:health/health.dart';

import 'health_sink.dart';

class HealthConnectUnavailableException implements Exception {
  HealthConnectUnavailableException(this.status);

  final HealthConnectSdkStatus? status;

  @override
  String toString() =>
      'HealthConnectUnavailableException: Health Connect nicht verfuegbar '
      '($status).';
}

class HealthConnectPermissionDeniedException implements Exception {
  @override
  String toString() =>
      'HealthConnectPermissionDeniedException: Schreibrecht fuer Blutdruck/'
      'Puls wurde nicht erteilt.';
}

class HealthConnectWriteException implements Exception {
  HealthConnectWriteException(this.clientRecordId);

  final String clientRecordId;

  @override
  String toString() =>
      'HealthConnectWriteException: Health Connect hat $clientRecordId '
      'nicht angenommen.';
}

class HealthConnectSink implements HealthSink {
  HealthConnectSink({Health? health}) : _health = health ?? Health();

  final Health _health;
  bool _configured = false;

  static const List<HealthDataType> _types = [
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.HEART_RATE,
  ];
  static const List<HealthDataAccess> _writeOnly = [
    HealthDataAccess.WRITE,
    HealthDataAccess.WRITE,
    HealthDataAccess.WRITE,
  ];

  /// Prueft Verfuegbarkeit und holt die Schreibrechte (zeigt bei Bedarf den
  /// Health-Connect-Dialog). Wirft, statt still ohne Rechte weiterzumachen.
  Future<void> ensureReady() async {
    if (!_configured) {
      await _health.configure();
      _configured = true;
    }
    final status = await _health.getHealthConnectSdkStatus();
    if (status != HealthConnectSdkStatus.sdkAvailable) {
      throw HealthConnectUnavailableException(status);
    }
    final granted = await _health.hasPermissions(_types, permissions: _writeOnly);
    if (granted != true) {
      final ok = await _health.requestAuthorization(_types, permissions: _writeOnly);
      if (!ok) {
        throw HealthConnectPermissionDeniedException();
      }
    }
  }

  @override
  Future<void> writeBloodPressure(BloodPressureWrite write) async {
    await ensureReady();
    final bpOk = await _health.writeBloodPressure(
      systolic: write.systolic,
      diastolic: write.diastolic,
      startTime: write.measuredAt,
      clientRecordId: write.clientRecordId,
      recordingMethod: RecordingMethod.automatic,
    );
    if (!bpOk) {
      throw HealthConnectWriteException(write.clientRecordId);
    }
    final hrOk = await _health.writeHealthData(
      value: write.pulse.toDouble(),
      type: HealthDataType.HEART_RATE,
      startTime: write.measuredAt,
      clientRecordId: '${write.clientRecordId}-hr',
      recordingMethod: RecordingMethod.automatic,
    );
    if (!hrOk) {
      throw HealthConnectWriteException('${write.clientRecordId}-hr');
    }
  }
}
