// Wegwerf-App fuer Meilenstein 1 (PLAN.md): Pairing + Voll-Readout auf den
// Bildschirm loggen. Keine DB, kein Health Connect, keine gestaltete UI -
// wird ersetzt, sobald M1 erfolgreich war. UNVERIFIZIERT an Hardware.
//
// Abweichung von "ein Knopf": zwei Knoepfe (Pairing / Vollauslesen), damit
// der Lesepfad wiederholt getestet werden kann, ohne bei jedem Versuch neu
// physisch in den Pairing-Modus wechseln zu muessen.
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble/flutter_blue_plus_transport.dart';
import '../ble/pairing.dart';
import '../protocol/eeprom_reader.dart';
import '../protocol/frame.dart';
import '../protocol/hem6232t_device.dart';
import '../protocol/record.dart';

class ProtocolSpikeScreen extends StatefulWidget {
  const ProtocolSpikeScreen({super.key});

  @override
  State<ProtocolSpikeScreen> createState() => _ProtocolSpikeScreenState();
}

class _DeviceCharacteristics {
  _DeviceCharacteristics({
    required this.unlock,
    required this.tx,
    required this.rx,
  });

  final BluetoothCharacteristic unlock;
  final BluetoothCharacteristic tx;
  final List<BluetoothCharacteristic> rx;
}

class _ProtocolSpikeScreenState extends State<ProtocolSpikeScreen> {
  final List<String> _log = [];
  late final Uint8List _pairingKey = _randomKey();
  BluetoothDevice? _device;
  bool _busy = false;

  static Uint8List _randomKey() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
  }

  void _appendLog(String message) {
    // Auch in die Konsole, damit `flutter run` den Ablauf zeigt - der
    // Bildschirm allein ist fuer den Beobachter am Rechner unsichtbar.
    debugPrint('[spike] $message');
    if (!mounted) return;
    setState(() => _log.add(message));
  }

  Future<BluetoothDevice> _scanAndConnect() async {
    final existing = _device;
    if (existing != null && existing.isConnected) {
      return existing;
    }

    // DIAGNOSE (M1): ungefilterter Scan. Ein Scan mit withServices fand
    // nichts - Hypothese: das Geraet bewirbt den Parent-Service nicht im
    // Advertising, er ist erst nach dem Verbinden per GATT sichtbar.
    // omblepy und UBPM filtern beim Scan ebenfalls nicht nach Service.
    _appendLog('Ungefilterter Scan, 15 s. Jedes gesehene Geraet wird geloggt...');
    final parentUuid = Guid(Hem6232tDevice.parentServiceUuid);
    final seen = <String>{};
    BluetoothDevice? match;

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final id = r.device.remoteId.str;
        if (!seen.add(id)) continue;
        final name = r.advertisementData.advName;
        final services = r.advertisementData.serviceUuids;
        _appendLog(
          '  seen: $id  rssi=${r.rssi}  name="$name"  services=$services',
        );
        final byService = services.contains(parentUuid);
        final byName = RegExp(r'blesmart|omron|hem', caseSensitive: false)
            .hasMatch(name);
        if (match == null && (byService || byName)) {
          match = r.device;
          _appendLog('  -> Kandidat (${byService ? 'Service' : 'Name'}): $id');
          // Befund M1: Wer die vollen 15 s weiterscannt, verliert das
          // Pairing-Fenster - GATT_CONNECTION_TIMEOUT beim Verbinden.
          unawaited(FlutterBluePlus.stopScan());
        }
      }
    });
    await FlutterBluePlus.isScanning
        .where((scanning) => !scanning)
        .first
        .timeout(const Duration(seconds: 20));
    await subscription.cancel();

    final device = match;
    if (device == null) {
      throw StateError(
        'Kein Omron gefunden. ${seen.length} andere Geraete gesehen. '
        'War "-P-" waehrend des Scans am Blinken?',
      );
    }
    _appendLog('Gefunden: ${device.remoteId}. Verbinde...');
    await device.connect(license: License.nonprofit);

    _appendLog('Verbunden. Discovere Services...');
    await device.discoverServices();
    return device;
  }

  Future<_DeviceCharacteristics> _findCharacteristics(
    BluetoothDevice device,
  ) async {
    final parentServiceUuid = Guid(Hem6232tDevice.parentServiceUuid);
    final parentService = device.servicesList.firstWhere(
      (service) => service.uuid == parentServiceUuid,
      orElse: () => throw StateError(
        'Parent-Service $parentServiceUuid nicht auf dem Geraet gefunden.',
      ),
    );

    BluetoothCharacteristic byUuid(String uuid) {
      final target = Guid(uuid);
      return parentService.characteristics.firstWhere(
        (c) => c.uuid == target,
        orElse: () => throw StateError('Characteristic $uuid nicht gefunden.'),
      );
    }

    return _DeviceCharacteristics(
      unlock: byUuid(Hem6232tDevice.unlockCharacteristicUuid),
      tx: byUuid(Hem6232tDevice.txCharacteristicUuids.first),
      rx: Hem6232tDevice.rxCharacteristicUuids.map(byUuid).toList(),
    );
  }

  Future<void> _guarded(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e, stackTrace) {
      _appendLog('FEHLER: $e');
      debugPrint('$e\n$stackTrace');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runPairing() => _guarded(() async {
        final device = await _scanAndConnect();
        _device = device;
        final chars = await _findCharacteristics(device);

        final hexKey =
            _pairingKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        _appendLog('Schreibe neuen Pairing-Key $hexKey...');
        _appendLog(
          'Geraet muss jetzt im Pairing-Modus sein ("-P-" blinkt im Display).',
        );
        await writeNewPairingKey(
          unlockCharacteristic: chars.unlock,
          key: _pairingKey,
          rxChannel0: chars.rx.first,
          log: _appendLog,
        );
        _appendLog('Pairing erfolgreich.');
      });

  Future<void> _runFullReadout() => _guarded(() async {
        final device = await _scanAndConnect();
        _device = device;
        final chars = await _findCharacteristics(device);

        _appendLog('Entsperre mit dem in dieser App-Sitzung erzeugten Key...');
        await unlockWithPairingKey(
          unlockCharacteristic: chars.unlock,
          key: _pairingKey,
        );

        final transport = FlutterBluePlusTransport(
          txCharacteristic: chars.tx,
          rxCharacteristics: chars.rx,
        );
        await transport.enableNotifications();

        _appendLog('Starte Uebertragung...');
        await transport.writeCommand(startTransmissionFrame);
        final startResponse = parseResponseFrame(await transport.readResponse());
        if (startResponse.type != responseTypeStart) {
          throw StateError(
            'Unerwartete Startantwort: 0x${startResponse.type.toRadixString(16)}',
          );
        }

        final reader = EepromReader(transport);
        for (var userIndex = 0;
            userIndex < Hem6232tDevice.userStartAddresses.length;
            userIndex++) {
          _appendLog('Lese User ${userIndex + 1}...');
          final bytes = await reader.readRange(
            startAddress: Hem6232tDevice.userStartAddresses[userIndex],
            totalLength:
                Hem6232tDevice.recordsPerUser * Hem6232tDevice.recordByteSize,
            blockSize: Hem6232tDevice.transmissionBlockSize,
          );

          var recordCount = 0;
          for (var offset = 0;
              offset < bytes.length;
              offset += Hem6232tDevice.recordByteSize) {
            final raw = bytes.sublist(
              offset,
              offset + Hem6232tDevice.recordByteSize,
            );
            final record = parseRecord(raw);
            if (record == null) continue;
            recordCount++;
            final hex =
                raw.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
            _appendLog(
              '  User ${userIndex + 1}: ${record.timestamp} '
              'sys=${record.systolic} dia=${record.diastolic} '
              'bpm=${record.pulse} ihb(roh)=${record.arrhythmiaFlag} '
              'mov(roh)=${record.movementFlag} raw=$hex',
            );
          }
          _appendLog('User ${userIndex + 1}: $recordCount Messungen.');
        }

        _appendLog('Beende Uebertragung...');
        await transport.writeCommand(endTransmissionFrame);
        final endResponse = parseResponseFrame(await transport.readResponse());
        if (endResponse.data.isNotEmpty && endResponse.data[0] != 0) {
          _appendLog(
            'WARNUNG: Geraet meldet Fehlercode ${endResponse.data[0]} bei Ende.',
          );
        }
        await transport.disableNotifications();
        _appendLog('Fertig.');
      });

  /// DIAGNOSE (M1, nur LESEN): Settings-Bereich 0x0260..0x02A4 dumpen und
  /// die Geraeteuhr nach omblepys (unbestaetigter) Deutung anzeigen.
  /// Es wird NICHTS geschrieben - Kalibrierdaten liegen vermutlich hier.
  Future<void> _runReadClock() => _guarded(() async {
        final device = await _scanAndConnect();
        _device = device;
        final chars = await _findCharacteristics(device);
        await unlockWithPairingKey(
          unlockCharacteristic: chars.unlock,
          key: _pairingKey,
        );
        final transport = FlutterBluePlusTransport(
          txCharacteristic: chars.tx,
          rxCharacteristics: chars.rx,
        );
        await transport.enableNotifications();
        await transport.writeCommand(startTransmissionFrame);
        parseResponseFrame(await transport.readResponse());

        // Befund M1: Ein 0x38-Byte-Read ab 0x0260 bleibt unbeantwortet, das
        // Geraet trennt nach 60 s. omblepy liest den Settings-Bereich nur in
        // zwei kleinen Abschnitten mit blockSize == Laenge - genau so hier.
        const settingsBase = 0x0260;
        final reader = EepromReader(transport);
        final unread = await reader.readRange(
          startAddress: settingsBase + 0x00,
          totalLength: 8,
          blockSize: 8,
        );
        _appendLog(
          'Settings +0x00 (unread counter, 8 B): '
          '${unread.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );
        final t = await reader.readRange(
          startAddress: settingsBase + 0x14,
          totalLength: 10,
          blockSize: 10,
        );
        // omblepy hem-6232t.py, auskommentiert, "probably not correct":
        // Slice [0x14:0x1e], darin Bytes [2:8] = month, year, hour, day,
        // second, minute.
        _appendLog(
          'Uhr (omblepy-Deutung, unbestaetigt): '
          '20${t[3]}-${t[2]}-${t[5]} ${t[4]}:${t[7]}:${t[6]}  '
          'roh=${t.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );

        await transport.writeCommand(endTransmissionFrame);
        parseResponseFrame(await transport.readResponse());
        await transport.disableNotifications();
        _appendLog('Fertig (Uhr).');
      });

  /// Hot-Reload-Helfer fuer den Spike: ein haengender Durchlauf (Geraet
  /// trennt, kein Timeout) liess _busy sonst dauerhaft auf true.
  @override
  void reassemble() {
    super.reassemble();
    _busy = false;
  }

  @override
  void dispose() {
    unawaited(_device?.disconnect());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sphygma - Protokoll-Spike (M1)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _busy ? null : () => _runPairing(),
                  child: const Text('1. Pairing'),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : () => _runFullReadout(),
                  child: const Text('2. Vollauslesen'),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : () => _runReadClock(),
                  child: const Text('3. Uhr lesen'),
                ),
              ],
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _log.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  _log[index],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
