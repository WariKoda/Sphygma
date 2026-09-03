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
    if (!mounted) return;
    setState(() => _log.add(message));
  }

  Future<BluetoothDevice> _scanAndConnect() async {
    final existing = _device;
    if (existing != null && existing.isConnected) {
      return existing;
    }

    _appendLog(
      'Suche nach Geraet (Service ${Hem6232tDevice.parentServiceUuid})...',
    );
    await FlutterBluePlus.startScan(
      withServices: [Guid(Hem6232tDevice.parentServiceUuid)],
      timeout: const Duration(seconds: 15),
    );
    final results = await FlutterBluePlus.scanResults
        .firstWhere((results) => results.isNotEmpty)
        .timeout(const Duration(seconds: 16));
    await FlutterBluePlus.stopScan();

    final device = results.first.device;
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
            final record = parseRecord(
              bytes.sublist(offset, offset + Hem6232tDevice.recordByteSize),
            );
            if (record == null) continue;
            recordCount++;
            _appendLog(
              '  User ${userIndex + 1}: ${record.timestamp} '
              'sys=${record.systolic} dia=${record.diastolic} '
              'bpm=${record.pulse} ihb(roh)=${record.arrhythmiaFlag} '
              'mov(roh)=${record.movementFlag}',
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
