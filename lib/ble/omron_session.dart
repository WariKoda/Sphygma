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
import '../protocol/readout.dart';
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

/// Was ein Scan ueber das Geraet herausgefunden hat.
///
/// [status] ist null, wenn das Advertising keine deutbaren Omron-Daten
/// trug - das kommt vor und ist kein Fehler (docs/protocol/hem-6232t.md
/// §2.1). Das Geraet selbst wurde in dem Fall trotzdem gefunden.
class OmronScanResult {
  const OmronScanResult({required this.device, required this.status});

  final BluetoothDevice device;
  final OmronAdvertisedStatus? status;
}

/// Lauscht dauerhaft auf das Advertising des Geraets und meldet jede
/// Aenderung des Gerätestands.
///
/// Das HEM-6232T sendet nach jeder Messung von selbst (§2.1) - genau
/// darauf reagiert auch die Hersteller-App. Der Datenstrom liefert nur
/// dann etwas, wenn sich Messungsnummer oder Platzzeiger gegenueber der
/// letzten Meldung geaendert haben; das dauernde Wiederholen desselben
/// Advertisings wird verschluckt.
///
/// Der Aufrufer muss das Abo beenden - sonst laeuft der Scan weiter und
/// kostet Akku.
Stream<OmronAdvertisedStatus> watchOmronStatus({
  Duration? removeIfGone,
}) async* {
  await FlutterBluePlus.startScan(
    continuousUpdates: true,
    // Ein Bruchteil der Advertising-Pakete genuegt: Das Geraet sendet
    // mehrmals je Sekunde, wir wollen nur mitbekommen, dass sich etwas
    // geaendert hat.
    continuousDivisor: 8,
    removeIfGone: removeIfGone,
  );
  try {
    OmronAdvertisedStatus? last;
    await for (final results in FlutterBluePlus.scanResults) {
      for (final r in results) {
        if (!isOmronAdvertisingName(r.advertisementData.advName)) continue;
        final status = parseOmronStatus(r.advertisementData.manufacturerData);
        if (status == null) continue;
        if (last != null && status.sameAs(last)) continue;
        last = status;
        yield status;
      }
    }
  } finally {
    await FlutterBluePlus.stopScan();
  }
}

class OmronSession {
  OmronSession._(this._device, this._unlock, this.transport);

  final BluetoothDevice _device;
  final BluetoothCharacteristic _unlock;
  final FlutterBluePlusTransport transport;

  /// Das verbundene Geraet. Wird gebraucht, um neben dem proprietaeren
  /// Protokoll auch die genormten GATT-Dienste anzusprechen
  /// (docs/protocol/hem-6232t.md §2.2).
  BluetoothDevice get device => _device;

  static const Duration scanTimeout = Duration(seconds: 15);

  /// Sucht das Geraet (per Name, Scan endet beim ersten Treffer), verbindet
  /// und loest die Characteristics auf. Bei GATT_ERROR (133), einem
  /// transienten Android-Fehler, wird einmal neu verbunden.
  static Future<OmronSession> open({
    Duration scanTimeout = scanTimeout,
    void Function(String message)? log,
  }) async {
    final device = (await scan(timeout: scanTimeout, log: log)).device;
    log?.call('Gefunden: ${device.remoteId}. Verbinde...');

    for (var attempt = 1; ; attempt++) {
      try {
        await device.connect(license: License.nonprofit);
        await device.discoverServices();
        final chars = _findCharacteristics(device);
        final transport = FlutterBluePlusTransport(
          txCharacteristics: chars.tx,
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

  /// Sucht das Geraet und gibt zurueck, was das Advertising verraet.
  ///
  /// Die Herstellerdaten tragen Messungsnummer und Platzzeiger beider
  /// Slots (§2.1); damit laesst sich ohne Verbindung entscheiden, ob es
  /// ueberhaupt etwas zu holen gibt.
  /// [waitForStatus] entscheidet, worauf der Scan wartet:
  ///
  /// * `false` (Standard): beim ersten Treffer sofort beenden. So braucht
  ///   es [open], denn im Pairing-Modus verfaellt das Fenster, wenn man
  ///   die volle Scan-Dauer abwartet (§2.1).
  /// * `true`: weiterscannen, bis auch die Herstellerdaten eingetroffen
  ///   sind - fuer den reinen Statuscheck, wo genau die gebraucht werden.
  ///   Kommen keine, endet der Scan im Timeout und liefert das Geraet
  ///   ohne Status.
  static Future<OmronScanResult> scan({
    Duration timeout = scanTimeout,
    bool waitForStatus = false,
    void Function(String message)? log,
  }) async {
    final seen = <String>{};
    BluetoothDevice? match;
    OmronAdvertisedStatus? status;

    await FlutterBluePlus.startScan(timeout: timeout);
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        seen.add(r.device.remoteId.str);
        if (!isOmronAdvertisingName(r.advertisementData.advName)) continue;

        // Name und Herstellerdaten koennen in getrennten Paketen kommen -
        // im Mitschnitt vom 2026-09-04 trug das Scan-Response nur den
        // Namen, die Herstellerdaten steckten im Advertising davor. Wer
        // beim ersten Treffer aufhoert, bekommt womoeglich nie einen
        // Status. Deshalb: Geraet merken, Status nachtragen, sobald er
        // auftaucht.
        match ??= r.device;
        status ??= parseOmronStatus(r.advertisementData.manufacturerData);

        if (!waitForStatus || status != null) {
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
    return OmronScanResult(device: device, status: status);
  }

  static ({
    BluetoothCharacteristic unlock,
    List<BluetoothCharacteristic> tx,
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
      tx: Hem6232tDevice.txCharacteristicUuids.map(byUuid).toList(),
      rx: Hem6232tDevice.rxCharacteristicUuids.map(byUuid).toList(),
    );
  }

  /// Erstmaliges Pairing: Geraet muss im Pairing-Modus sein ("-P-").
  /// Nach dem Key-Write folgt in derselben Sitzung einmal Start/Ende
  /// (Spezifikation §5 Schritt 4) - ohne das uebernimmt ein zuvor nie
  /// gepaartes Geraet das Pairing nicht.
  Future<void> pair(Uint8List key, {void Function(String)? log}) async {
    await writeNewPairingKey(
      unlockCharacteristic: _unlock,
      key: key,
      rxChannel0: transport.rxChannel0,
      log: log,
    );
    log?.call('Key geschrieben. Bestaetige das Pairing mit Start/Ende...');
    await transport.enableNotifications();
    await confirmPairing(transport);
    log?.call('Pairing vom Geraet bestaetigt.');
  }

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
