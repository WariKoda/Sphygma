// Eine BLE-Sitzung mit dem HEM-6232T: suchen, verbinden, Characteristics
// finden, entsperren, Transport bereitstellen - und in jedem Fall wieder
// aufraeumen. Alle Geraete-Eigenheiten stammen aus Meilenstein 1
// (docs/protocol/hem-6232t.md §2.1, §5.1; CLAUDE.md "BLE-Eigenheiten").
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../protocol/ble_transport.dart';
import '../protocol/exceptions.dart';
import '../protocol/hem6232t_device.dart';
import 'flutter_blue_plus_transport.dart';
import 'omron_advertising.dart';
import 'pairing.dart';

/// Wird geworfen, wenn im Scan kein Omron auftaucht - typischerweise, weil
/// das Geraet nicht sendet (es tut das nur nach Tastendruck).
class DeviceNotFoundException implements Exception {
  DeviceNotFoundException(this.othersSeen);

  final int othersSeen;

  @override
  String toString() =>
      'DeviceNotFoundException: kein Omron gefunden ($othersSeen andere '
      'Geraete gesehen). Bluetooth-Taste am Geraet kurz druecken.';
}

class OmronSession {
  OmronSession._(this._device, this._unlock, this.transport);

  final BluetoothDevice _device;
  final BluetoothCharacteristic _unlock;
  final FlutterBluePlusTransport transport;

  static const Duration scanTimeout = Duration(seconds: 15);

  /// Sucht das Geraet (per Name, Scan endet beim ersten Treffer), verbindet
  /// und loest die Characteristics auf. Bei GATT_ERROR (133), einem
  /// transienten Android-Fehler, wird einmal neu verbunden.
  static Future<OmronSession> open({
    Duration scanTimeout = scanTimeout,
    void Function(String message)? log,
  }) async {
    final device = await _scan(scanTimeout, log);
    log?.call('Gefunden: ${device.remoteId}. Verbinde...');

    for (var attempt = 1; ; attempt++) {
      try {
        await device.connect(license: License.nonprofit);
        await device.discoverServices();
        final chars = _findCharacteristics(device);
        final transport = FlutterBluePlusTransport(
          txCharacteristic: chars.tx,
          rxCharacteristics: chars.rx,
        );
        return OmronSession._(device, chars.unlock, transport);
      } on FlutterBluePlusException catch (e) {
        // Befund M1: android-code 133 (GATT_ERROR) kommt vor, wenn das Geraet
        // die vorige Verbindung gerade erst abbaut. Einmal wiederholen.
        if (attempt == 1 && e.code == 133) {
          log?.call('GATT_ERROR 133 - verbinde einmal neu.');
          await device.disconnect();
          await Future<void>.delayed(const Duration(seconds: 2));
          continue;
        }
        await device.disconnect();
        rethrow;
      }
    }
  }

  static Future<BluetoothDevice> _scan(
    Duration timeout,
    void Function(String message)? log,
  ) async {
    final seen = <String>{};
    BluetoothDevice? match;

    await FlutterBluePlus.startScan(timeout: timeout);
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        if (!seen.add(r.device.remoteId.str)) continue;
        if (match == null && isOmronAdvertisingName(r.advertisementData.advName)) {
          match = r.device;
          // Scan sofort beenden, sonst verfaellt das Pairing-Fenster.
          unawaited(FlutterBluePlus.stopScan());
        }
      }
    });
    try {
      await FlutterBluePlus.isScanning
          .where((scanning) => !scanning)
          .first
          .timeout(timeout + const Duration(seconds: 5));
    } finally {
      await subscription.cancel();
    }

    final device = match;
    if (device == null) {
      throw DeviceNotFoundException(seen.length);
    }
    return device;
  }

  static ({
    BluetoothCharacteristic unlock,
    BluetoothCharacteristic tx,
    List<BluetoothCharacteristic> rx,
  }) _findCharacteristics(BluetoothDevice device) {
    final parentUuid = Guid(Hem6232tDevice.parentServiceUuid);
    final parent = device.servicesList.firstWhere(
      (s) => s.uuid == parentUuid,
      orElse: () => throw ProtocolException(
        'Parent-Service ${Hem6232tDevice.parentServiceUuid} nicht gefunden - '
        'ist das wirklich ein HEM-6232T?',
      ),
    );
    BluetoothCharacteristic byUuid(String uuid) {
      final target = Guid(uuid);
      return parent.characteristics.firstWhere(
        (c) => c.uuid == target,
        orElse: () =>
            throw ProtocolException('Characteristic $uuid nicht gefunden.'),
      );
    }

    return (
      unlock: byUuid(Hem6232tDevice.unlockCharacteristicUuid),
      tx: byUuid(Hem6232tDevice.txCharacteristicUuids.first),
      rx: Hem6232tDevice.rxCharacteristicUuids.map(byUuid).toList(),
    );
  }

  /// Erstmaliges Pairing: Geraet muss im Pairing-Modus sein ("-P-").
  Future<void> pair(Uint8List key, {void Function(String)? log}) =>
      writeNewPairingKey(
        unlockCharacteristic: _unlock,
        key: key,
        rxChannel0: transport.rxChannel0,
        log: log,
      );

  /// Entsperren mit dem gespeicherten Key und Notifications aktivieren.
  /// Danach ist [transport] einsatzbereit.
  Future<BleTransport> unlock(Uint8List key) async {
    await unlockWithPairingKey(unlockCharacteristic: _unlock, key: key);
    await transport.enableNotifications();
    return transport;
  }

  /// Raeumt immer auf - Notify-Abos, Verbindung. Fehler beim Aufraeumen
  /// werden verschluckt, damit sie den eigentlichen Fehler nicht verdecken.
  Future<void> close() async {
    try {
      await transport.disableNotifications();
    } catch (_) {}
    try {
      await _device.disconnect();
    } catch (_) {}
  }
}
