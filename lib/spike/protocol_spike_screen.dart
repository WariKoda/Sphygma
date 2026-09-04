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

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble/flutter_blue_plus_transport.dart';
import '../ble/frame_mailbox.dart';
import '../ble/pairing.dart';
import '../ble/pairing_key_store.dart';
import '../db/app_database.dart';
import '../db/measurement_repository.dart';
import '../sync/export_service.dart';
import '../sync/health_connect_sink.dart';
import '../sync/sync_service.dart';
import '../ble/omron_advertising.dart';
import '../ble/omron_session.dart';
import '../protocol/eeprom_reader.dart';
import '../protocol/eeprom_writer.dart';
import '../protocol/exceptions.dart';
import '../protocol/frame.dart';
import '../protocol/hem6232t_device.dart';
import '../protocol/readout.dart';
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
  final List<BluetoothCharacteristic> tx;
  final List<BluetoothCharacteristic> rx;
}

class _ProtocolSpikeScreenState extends State<ProtocolSpikeScreen> {
  final List<String> _log = [];
  late final Uint8List _pairingKey = _randomKey();
  BluetoothDevice? _device;
  bool _busy = false;
  StreamSubscription<OmronAdvertisedStatus>? _watch;

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
      tx: Hem6232tDevice.txCharacteristicUuids.map(byUuid).toList(),
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
          txCharacteristics: chars.tx,
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
          txCharacteristics: chars.tx,
          rxCharacteristics: chars.rx,
        );
        await transport.enableNotifications();
        await transport.writeCommand(startTransmissionFrame);
        final startRaw = await transport.readResponse();
        parseResponseFrame(startRaw);
        // DIAGNOSE: Traegt die Start-Antwort ("read device id") Geraetezustand,
        // z. B. die Stellung des User-Schalters?
        _appendLog(
          'Start-Antwort (${startRaw.length} B): '
          '${startRaw.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );

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

  /// DIAGNOSE (M1, nur LESEN): den Settings-Bereich 0x0260..0x02A4 in
  /// 8-Byte-Schritten abtasten. Ziel: ein Byte finden, das mit der Stellung
  /// des User-Schalters kippt. Unbeantwortete Reads (10-s-Timeout) werden
  /// protokolliert und uebersprungen. Es wird NICHTS geschrieben.
  Future<void> _runProbeSettings() => _guarded(() async {
        final device = await _scanAndConnect();
        _device = device;
        final chars = await _findCharacteristics(device);
        await unlockWithPairingKey(
          unlockCharacteristic: chars.unlock,
          key: _pairingKey,
        );
        final transport = FlutterBluePlusTransport(
          txCharacteristics: chars.tx,
          rxCharacteristics: chars.rx,
        );
        await transport.enableNotifications();
        await transport.writeCommand(startTransmissionFrame);
        parseResponseFrame(await transport.readResponse());

        const base = 0x0260;
        const end = 0x02a4;
        final reader = EepromReader(transport);
        for (var offset = 0; offset < end - base; offset += 8) {
          final length = (end - base - offset).clamp(1, 8);
          try {
            final bytes = await reader.readRange(
              startAddress: base + offset,
              totalLength: length,
              blockSize: length,
            );
            _appendLog(
              'probe +0x${offset.toRadixString(16).padLeft(2, '0')}: '
              '${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
            );
          } on ProtocolException catch (e) {
            _appendLog(
              'probe +0x${offset.toRadixString(16).padLeft(2, '0')}: '
              'UNBEANTWORTET ($e)',
            );
            if (!device.isConnected) break;
          }
        }

        if (device.isConnected) {
          await transport.writeCommand(endTransmissionFrame);
          parseResponseFrame(await transport.readResponse());
          await transport.disableNotifications();
        }
        _appendLog('Fertig (Probe).');
      });

  // --- Produktionspfad (M3/M4) an Hardware validieren ---------------------
  // Eigener Key-Store (Android Keystore) und eigene DB - unabhaengig vom
  // In-Memory-Key des Spikes. Erfordert daher einmal ein neues Pairing.
  late final SyncService _syncService = SyncService(
    keyStore: SecureStoragePairingKeyStore(),
    repository: MeasurementRepository(_database),
  );
  late final AppDatabase _database = AppDatabase(driftDatabase(name: 'sphygma'));

  Future<void> _runProductionPairing() => _guarded(() async {
        _appendLog('[prod] Pairing ueber SyncService (Key -> Keystore)...');
        await _syncService.pair(log: _appendLog);
        _appendLog('[prod] Pairing erfolgreich, Key gespeichert.');
      });

  Future<void> _runProductionSync() => _guarded(() async {
        _appendLog('[prod] Sync ueber SyncService (Readout -> DB)...');
        final result = await _syncService.sync(log: _appendLog);
        _appendLog(
          '[prod] gelesen: ${result.readFromDevice}, neu gespeichert: '
          '${result.newlyStored}',
        );
        for (final slot in [1, 2]) {
          final rows = await _syncService.repository.allForSlot(slot);
          _appendLog('[prod] DB Slot $slot: ${rows.length} Messungen');
        }
      });

  late final ExportService _exportService = ExportService(
    repository: _syncService.repository,
    sink: HealthConnectSink(),
  );

  Future<void> _runProductionExport() => _guarded(() async {
        // Testlauf: bewusst nur EINE Messung, nicht die ganze Historie.
        _appendLog('[prod] Export Slot 1 -> Health Connect (limit 1)...');
        final n = await _exportService.exportPending(userSlot: 1, limit: 1);
        _appendLog('[prod] exportiert: $n Messung(en)');
        final left = await _syncService.repository.pendingExport(1);
        _appendLog('[prod] noch unexportiert Slot 1: ${left.length}');
      });

  Future<void> _runProductionRetract() => _guarded(() async {
        _appendLog('[prod] Sphygma-Daten aus Health Connect entfernen...');
        final n = await _exportService.retractExported(userSlot: 1);
        _appendLog('[prod] entfernt: $n Messung(en)');
      });

  // --- SCHREIBTEST (Machbarkeitsprobe 2026-09-04) ------------------------
  // Frage: Nimmt das Geraet einen Schreibbefehl (0x01c0) in den
  // Record-Bereich an, und steht danach wirklich 0xFF dort? omblepy
  // schreibt nur in den Settings-Bereich; fuer die Records gibt es keinen
  // Beleg. Ergebnis gehoert nach docs/protocol/hem-6232t.md.
  //
  // Stufe 1 zielt auf den letzten Platz von Slot 2. Der ist unbenutzt und
  // enthaelt bereits 0xFF - schlaegt der Schreibvorgang fehl, ist nichts
  // verloren.

  static int _recordAddress(int slotIndex, int recordIndex) =>
      Hem6232tDevice.userStartAddresses[slotIndex] +
      recordIndex * Hem6232tDevice.recordByteSize;

  String _hexBytes(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  /// Liest einen Record-Platz, schreibt [emptyRecordBytes] darauf und liest
  /// erneut. Protokolliert beide Lesungen, damit die Wirkung belegt ist.
  Future<void> _runEraseProbe({
    required int slotIndex,
    required int recordIndex,
  }) =>
      _guarded(() async {
        final address = _recordAddress(slotIndex, recordIndex);
        // Wirft, bevor irgendetwas gesendet wird, falls die Adresse nicht
        // im Record-Bereich liegt.
        assertInsideRecordArea(address, Hem6232tDevice.recordByteSize);
        _appendLog(
          '[erase] Ziel: Slot ${slotIndex + 1}, Platz $recordIndex, '
          'Adresse 0x${address.toRadixString(16)}',
        );

        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError(
            'Kein gespeicherter Pairing-Key - zuerst "5. Prod-Pairing".',
          );
        }

        final session = await OmronSession.open(log: _appendLog);
        try {
          final transport = await session.unlock(key);
          await startTransmission(transport);

          final reader = EepromReader(transport);
          final before = await reader.readRange(
            startAddress: address,
            totalLength: Hem6232tDevice.recordByteSize,
            blockSize: Hem6232tDevice.recordByteSize,
          );
          _appendLog('[erase] vorher:  ${_hexBytes(before)}');

          await EepromWriter(transport).writeRecordArea(
            startAddress: address,
            data: emptyRecordBytes,
          );
          _appendLog('[erase] Schreibbefehl bestaetigt.');

          final after = await reader.readRange(
            startAddress: address,
            totalLength: Hem6232tDevice.recordByteSize,
            blockSize: Hem6232tDevice.recordByteSize,
          );
          _appendLog('[erase] nachher: ${_hexBytes(after)}');
          _appendLog(
            after.every((b) => b == 0xff)
                ? '[erase] ERGEBNIS: Platz ist geleert.'
                : '[erase] ERGEBNIS: Platz NICHT geleert - Inhalt unveraendert '
                    'oder teilweise geschrieben.',
          );

          await endTransmission(transport);
        } finally {
          await session.close();
        }
      });

  /// NUR LESEN. Kontrolle nach dem Schreibtest: zeigt die Plaetze 94 bis 97
  /// von Slot 1. Hintergrund: In omblepy liegen Lese- und Schreibadresse
  /// derselben Einstellungen 0x44 auseinander (settingsReadAddress 0x0260,
  /// settingsWriteAddress 0x02A4). Gilt dieser Versatz fuer den ganzen
  /// Speicher, hat der Schreibbefehl auf 0x0860 in Wahrheit 0x081C
  /// getroffen - das liegt in Slot 1, Platz 95.
  Future<void> _runVerifySlot1Tail() => _guarded(() async {
        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError('Kein gespeicherter Pairing-Key.');
        }
        final session = await OmronSession.open(log: _appendLog);
        try {
          final transport = await session.unlock(key);
          await startTransmission(transport);
          final reader = EepromReader(transport);

          for (var index = 94; index <= 97; index++) {
            final address = _recordAddress(0, index);
            final bytes = await reader.readRange(
              startAddress: address,
              totalLength: Hem6232tDevice.recordByteSize,
              blockSize: Hem6232tDevice.recordByteSize,
            );
            final allEmpty = bytes.every((b) => b == 0xff);
            _appendLog(
              '[check] Slot 1 Platz $index @0x${address.toRadixString(16)}: '
              '${_hexBytes(bytes)}${allEmpty ? '  <-- LEER' : ''}',
            );
          }

          await endTransmission(transport);
        } finally {
          await session.close();
        }
      });

  /// NULLBYTE-PROBE. Klaert zwei offene Fragen auf einmal, ohne Risiko:
  ///
  /// 1. Scheitert das Schreiben ueberhaupt, oder nur der Wert 0xFF? Bei
  ///    EEPROM/Flash lassen sich Bits ohne Loeschzyklus nur von 1 auf 0
  ///    setzen; 0xFF besteht nur aus Einsen und waere damit der
  ///    denkbar unguenstigste Testwert. 0x00 setzt ausschliesslich Bits
  ///    auf 0.
  /// 2. Ist der Schreib-Adressraum gegenueber dem Lese-Adressraum
  ///    verschoben? In omblepy liegen die Settings-Adressen 0x44
  ///    auseinander. Deshalb wird nach dem Schreiben BEIDES geprueft:
  ///    das Ziel und die um 0x44 tiefer liegende Adresse.
  ///
  /// Ziel ist Slot 2 Platz 99. Auch die Versatz-Adresse faellt in einen
  /// unbenutzten Platz von Slot 2, es kann also nichts verlorengehen.
  Future<void> _runZeroWriteProbe() => _guarded(() async {
        const offsetGuess = 0x44;
        final target = _recordAddress(1, 99);
        final shifted = target - offsetGuess;
        assertInsideRecordArea(target, Hem6232tDevice.recordByteSize);
        assertInsideRecordArea(shifted, Hem6232tDevice.recordByteSize);

        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError('Kein gespeicherter Pairing-Key.');
        }
        final zeros = Uint8List(Hem6232tDevice.recordByteSize);

        final session = await OmronSession.open(log: _appendLog);
        try {
          final transport = await session.unlock(key);
          await startTransmission(transport);
          final reader = EepromReader(transport);

          Future<Uint8List> read(int address) => reader.readRange(
                startAddress: address,
                totalLength: Hem6232tDevice.recordByteSize,
                blockSize: Hem6232tDevice.recordByteSize,
              );

          _appendLog(
            '[zero] Ziel 0x${target.toRadixString(16)}, Versatz-Kandidat '
            '0x${shifted.toRadixString(16)}',
          );
          _appendLog('[zero] Ziel vorher:    ${_hexBytes(await read(target))}');
          _appendLog('[zero] Versatz vorher: ${_hexBytes(await read(shifted))}');

          await EepromWriter(transport).writeRecordArea(
            startAddress: target,
            data: zeros,
          );
          _appendLog('[zero] 14 Nullbytes geschrieben, Befehl bestaetigt.');

          final targetAfter = await read(target);
          final shiftedAfter = await read(shifted);
          _appendLog('[zero] Ziel nachher:    ${_hexBytes(targetAfter)}');
          _appendLog('[zero] Versatz nachher: ${_hexBytes(shiftedAfter)}');

          final targetChanged = targetAfter.any((b) => b != 0xff);
          final shiftedChanged = shiftedAfter.any((b) => b != 0xff);
          if (targetChanged) {
            _appendLog('[zero] ERGEBNIS: Schreiben wirkt, Adresse stimmt.');
          } else if (shiftedChanged) {
            _appendLog(
              '[zero] ERGEBNIS: Schreiben wirkt, aber um 0x44 versetzt.',
            );
          } else {
            _appendLog(
              '[zero] ERGEBNIS: keine Wirkung - der Record-Bereich ist '
              'schreibgeschuetzt.',
            );
          }

          await endTransmission(transport);
        } finally {
          await session.close();
        }
      });

  /// NUR LESEN. Vollpruefung nach den Schreibversuchen: liest beide Slots
  /// vollstaendig, meldet jeden belegten und jeden leeren Platz, sucht
  /// Luecken in der Messungsnummern-Folge und vergleicht alles mit der
  /// lokalen Datenbank. Eine Luecke oder ein fehlender Wert waere die
  /// Spur eines Schreibvorgangs.
  Future<void> _runFullMemoryAudit() => _guarded(() async {
        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError('Kein gespeicherter Pairing-Key.');
        }

        final session = await OmronSession.open(log: _appendLog);
        List<SlotRecord> records;
        try {
          final transport = await session.unlock(key);
          records = await readAllRecords(transport);
        } finally {
          await session.close();
        }
        _appendLog('[audit] vom Geraet gelesen: ${records.length} Records');

        for (final slot in [1, 2]) {
          final onDevice = records.where((r) => r.userSlot == slot).toList()
            ..sort((a, b) => a.record.sequence.compareTo(b.record.sequence));
          if (onDevice.isEmpty) {
            _appendLog('[audit] Slot $slot: keine Records auf dem Geraet');
            continue;
          }
          final first = onDevice.first.record.sequence;
          final last = onDevice.last.record.sequence;
          final expected = last - first + 1;
          _appendLog(
            '[audit] Slot $slot: ${onDevice.length} Records, Nummern '
            '$first..$last (lueckenlos waeren $expected)',
          );

          final present = onDevice.map((r) => r.record.sequence).toSet();
          final missing = [
            for (var n = first; n <= last; n++)
              if (!present.contains(n)) n,
          ];
          _appendLog(
            missing.isEmpty
                ? '[audit] Slot $slot: keine Luecke in der Nummernfolge'
                : '[audit] Slot $slot: LUECKE bei ${missing.join(', ')}',
          );

          // Gegen die Datenbank: jeder Geraete-Record muss dort mit
          // denselben Werten stehen, und jeder DB-Eintrag im Nummernbereich
          // des Geraets muss dort noch vorhanden sein.
          final stored = await _syncService.repository.allForSlot(slot);
          final bySequence = {for (final m in stored) m.deviceSequence: m};
          var mismatches = 0;
          for (final r in onDevice) {
            final m = bySequence[r.record.sequence];
            if (m == null) {
              _appendLog(
                '[audit] Slot $slot Nr ${r.record.sequence}: nur auf dem '
                'Geraet, nicht in der DB (noch nicht synchronisiert)',
              );
              continue;
            }
            if (m.systolic != r.record.systolic ||
                m.diastolic != r.record.diastolic ||
                m.pulse != r.record.pulse) {
              mismatches++;
              _appendLog(
                '[audit] Slot $slot Nr ${r.record.sequence}: WERTE WEICHEN AB '
                '(Geraet ${r.record.systolic}/${r.record.diastolic}/'
                '${r.record.pulse}, DB ${m.systolic}/${m.diastolic}/'
                '${m.pulse})',
              );
            }
          }
          _appendLog(
            mismatches == 0
                ? '[audit] Slot $slot: alle Werte stimmen mit der DB ueberein'
                : '[audit] Slot $slot: $mismatches abweichende Records',
          );

          final vanished = stored
              .where((m) =>
                  m.deviceSequence >= first &&
                  m.deviceSequence <= last &&
                  !present.contains(m.deviceSequence))
              .map((m) => m.deviceSequence)
              .toList();
          _appendLog(
            vanished.isEmpty
                ? '[audit] Slot $slot: kein DB-Eintrag ist vom Geraet '
                    'verschwunden'
                : '[audit] Slot $slot: VERSCHWUNDEN vom Geraet: '
                    '${vanished.join(', ')}',
          );
        }
        _appendLog('[audit] Fertig.');
      });

  /// NUR LESEN. Zeigt fuer jeden der 100 Plaetze eines Slots, welche
  /// Messungsnummer dort steht oder ob er leer ist. Damit laesst sich eine
  /// Luecke in der Nummernfolge einem physischen Platz zuordnen - und
  /// unterscheiden, ob sie vom Ringpuffer, von einer nie gespeicherten
  /// Messung oder von einem Schreibvorgang stammt.
  Future<void> _runSlotMap(int slotIndex) => _guarded(() async {
        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError('Kein gespeicherter Pairing-Key.');
        }
        final session = await OmronSession.open(log: _appendLog);
        try {
          final transport = await session.unlock(key);
          await startTransmission(transport);

          final bytes = await EepromReader(transport).readRange(
            startAddress: Hem6232tDevice.userStartAddresses[slotIndex],
            totalLength:
                Hem6232tDevice.recordsPerUser * Hem6232tDevice.recordByteSize,
            blockSize: Hem6232tDevice.transmissionBlockSize,
          );
          await endTransmission(transport);

          const size = Hem6232tDevice.recordByteSize;
          final empty = <int>[];
          final line = StringBuffer();
          for (var index = 0; index < Hem6232tDevice.recordsPerUser; index++) {
            final raw = bytes.sublist(index * size, (index + 1) * size);
            if (raw.every((b) => b == 0xff)) {
              empty.add(index);
              line.write('$index:LEER  ');
            } else {
              final seq = (raw[9] << 16) | (raw[10] << 8) | raw[11];
              line.write('$index:$seq  ');
            }
            if (index % 10 == 9) {
              _appendLog('[map] ${line.toString().trimRight()}');
              line.clear();
            }
          }
          _appendLog(
            empty.isEmpty
                ? '[map] Slot ${slotIndex + 1}: kein leerer Platz'
                : '[map] Slot ${slotIndex + 1}: leere Plaetze '
                    '${empty.join(', ')}',
          );
        } finally {
          await session.close();
        }
      });

  /// NUR LESEN. Gibt die Verwaltungsbytes des Settings-Bereichs roh aus
  /// und dazu die Deutung, die omblepy ihnen gibt.
  ///
  /// Deutung aus omblepy sharedDriver.py, getRecords:
  ///   lastWrittenSlot je User = Byte 1 bzw. 3 des Fensters +0x00
  ///   unreadRecords   je User = Byte 5 bzw. 7 desselben Fensters
  /// Die Deutung von +0x08 als hoechste Messungsnummer stammt aus eigener
  /// Beobachtung (docs/protocol/hem-6232t.md §8.1), nicht aus omblepy.
  ///
  /// Zweck: vor und nach einer Messung ausfuehren und die Differenz
  /// betrachten. Erst daraus laesst sich sagen, welches Byte den
  /// Schreibzeiger traegt und ob es sich bewegt.
  Future<void> _runReadCounters() => _guarded(() async {
        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError('Kein gespeicherter Pairing-Key.');
        }
        const settingsBase = 0x0260;

        final session = await OmronSession.open(log: _appendLog);
        try {
          final transport = await session.unlock(key);
          await startTransmission(transport);
          final reader = EepromReader(transport);

          Future<Uint8List> window(int offset, int length) => reader.readRange(
                startAddress: settingsBase + offset,
                totalLength: length,
                blockSize: length,
              );

          final w0 = await window(0x00, 8);
          _appendLog('[cnt] +0x00: ${_hexBytes(w0)}');
          _appendLog(
            '[cnt]   Deutung [O]: letzter Platz U1=${w0[1]}, U2=${w0[3]}; '
            'ungelesen U1=${w0[5]}, U2=${w0[7]}',
          );

          final w8 = await window(0x08, 8);
          _appendLog('[cnt] +0x08: ${_hexBytes(w8)}');
          _appendLog(
            '[cnt]   Deutung [H]: hoechste Nummer U1='
            '${(w8[0] << 8) | w8[1]}, U2=${(w8[4] << 8) | w8[5]}',
          );

          final w30 = await window(0x30, 8);
          _appendLog('[cnt] +0x30: ${_hexBytes(w30)}');

          await endTransmission(transport);
        } finally {
          await session.close();
        }
      });

  /// NUR LESEN. Vollabzug des gesamten lesbaren Zustands, zeilenweise als
  /// Hex ins Log. Zweck: zwei Abzuege maschinell gegeneinander stellen und
  /// jede Veraenderung sehen, statt einzelne Bytes zu deuten.
  ///
  /// Erfasst: die 24-Byte-Antwort auf das Start-Kommando, alle
  /// Settings-Fenster, die laut docs/protocol/hem-6232t.md §8.1 ueberhaupt
  /// antworten, und beide Record-Bereiche vollstaendig.
  ///
  /// Zeilenformat: `[dump] bereich adresse-hex bytes-hex`
  Future<void> _runFullDump() => _guarded(() async {
        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError('Kein gespeicherter Pairing-Key.');
        }

        final session = await OmronSession.open(log: _appendLog);
        try {
          final transport = await session.unlock(key);

          // Start-Antwort selbst auswerten statt verwerfen: sie traegt die
          // Geraete-ID und koennte Zustand enthalten.
          await transport.writeCommand(startTransmissionFrame);
          final startRaw = await transport.readResponse();
          _appendLog('[dump] start 0000 ${_hexBytes(startRaw)}');

          final reader = EepromReader(transport);

          // Settings: nur die antwortenden Fenster, jedes einzeln, damit
          // ein stummes Fenster die anderen nicht mitreisst.
          const settingsBase = 0x0260;
          const windows = <List<int>>[
            [0x00, 8],
            [0x08, 8],
            [0x14, 10],
            [0x20, 8],
            [0x30, 8],
            [0x38, 8],
            [0x40, 4],
          ];
          for (final w in windows) {
            final address = settingsBase + w[0];
            final label = 'set ${address.toRadixString(16).padLeft(4, '0')}';
            try {
              final bytes = await reader.readRange(
                startAddress: address,
                totalLength: w[1],
                blockSize: w[1],
              );
              _appendLog('[dump] $label ${_hexBytes(bytes)}');
            } on ProtocolException {
              // Laut §8.1 bleibt die Verbindung nach einem stummen Fenster
              // bestehen; also weiterlesen statt abbrechen.
              _appendLog('[dump] $label KEINE-ANTWORT');
            }
          }

          // Records: beide Slots vollstaendig, 14 Bytes je Zeile, damit
          // eine Zeile genau einem Platz entspricht.
          for (var slotIndex = 0; slotIndex < 2; slotIndex++) {
            final base = Hem6232tDevice.userStartAddresses[slotIndex];
            final bytes = await reader.readRange(
              startAddress: base,
              totalLength: Hem6232tDevice.recordsPerUser *
                  Hem6232tDevice.recordByteSize,
              blockSize: Hem6232tDevice.transmissionBlockSize,
            );
            const size = Hem6232tDevice.recordByteSize;
            for (var i = 0; i < Hem6232tDevice.recordsPerUser; i++) {
              final address = base + i * size;
              _appendLog(
                '[dump] rec${slotIndex + 1}-'
                '${i.toString().padLeft(2, '0')} '
                '${address.toRadixString(16).padLeft(4, '0')} '
                '${_hexBytes(bytes.sublist(i * size, (i + 1) * size))}',
              );
            }
          }

          await endTransmission(transport);
          _appendLog('[dump] ENDE');
        } finally {
          await session.close();
        }
      });

  /// VERSATZ-TEST. Der Mitschnitt der Hersteller-App (2026-09-04) zeigt,
  /// dass Lese- und Schreib-Adressraum um 0x44 auseinanderliegen: Sie liest
  /// 44 Bytes ab 0x0260 und schreibt sie nach 0x02A4 zurueck, und liest 16
  /// Bytes ab 0x028C und schreibt nach 0x02D0. Beide Male derselbe Abstand.
  /// omblepy nennt dieselben beiden Basisadressen (settingsReadAddress /
  /// settingsWriteAddress).
  ///
  /// Alle bisherigen Schreibversuche gingen an die **Lese**adresse und
  /// blieben wirkungslos. Dieser Test schreibt an Leseadresse + 0x44 und
  /// prueft danach beide Stellen.
  ///
  /// Ziel ist Slot 2 Platz 50; die Schreibadresse faellt auf Platz 54.
  /// Beide sind unbenutzt (Slot 2 hat 14 Records), es kann nichts
  /// verlorengehen.
  Future<void> _runOffsetWriteProbe() => _guarded(() async {
        const writeOffset = 0x44;
        final readTarget = _recordAddress(1, 50);
        final writeTarget = readTarget + writeOffset;
        assertInsideRecordArea(readTarget, Hem6232tDevice.recordByteSize);
        assertInsideRecordArea(writeTarget, Hem6232tDevice.recordByteSize);

        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError('Kein gespeicherter Pairing-Key.');
        }
        // Erkennbares Muster statt 0x00/0xFF, damit ein Treffer eindeutig
        // ist und sich nicht mit einem leeren Platz verwechseln laesst.
        final pattern = Uint8List.fromList(
          List.generate(Hem6232tDevice.recordByteSize, (i) => 0xa0 + i),
        );

        final session = await OmronSession.open(log: _appendLog);
        try {
          final transport = await session.unlock(key);
          await startTransmission(transport);
          final reader = EepromReader(transport);

          Future<Uint8List> read(int a) => reader.readRange(
                startAddress: a,
                totalLength: Hem6232tDevice.recordByteSize,
                blockSize: Hem6232tDevice.recordByteSize,
              );

          _appendLog(
            '[off] schreibe nach 0x${writeTarget.toRadixString(16)}, '
            'erwarte Wirkung bei 0x${readTarget.toRadixString(16)}',
          );
          _appendLog('[off] Ziel vorher:      ${_hexBytes(await read(readTarget))}');
          _appendLog('[off] Schreibadr. vorher: ${_hexBytes(await read(writeTarget))}');

          await EepromWriter(transport).writeRecordArea(
            startAddress: writeTarget,
            data: pattern,
          );
          _appendLog('[off] Muster geschrieben, Befehl bestaetigt.');

          final atRead = await read(readTarget);
          final atWrite = await read(writeTarget);
          _appendLog('[off] Ziel nachher:      ${_hexBytes(atRead)}');
          _appendLog('[off] Schreibadr. nachher: ${_hexBytes(atWrite)}');

          final hitRead = atRead[0] == 0xa0;
          final hitWrite = atWrite[0] == 0xa0;
          if (hitRead) {
            _appendLog('[off] ERGEBNIS: Treffer bei Leseadresse - Versatz 0x44 gilt!');
          } else if (hitWrite) {
            _appendLog('[off] ERGEBNIS: Treffer bei der Schreibadresse - kein Versatz.');
          } else {
            _appendLog('[off] ERGEBNIS: keine Wirkung an beiden Stellen.');
          }

          await endTransmission(transport);
        } finally {
          await session.close();
        }
      });

  /// NUR LESEN. Listet alle Services und Characteristics des Geraets mit
  /// UUID, Instanz-Id und Eigenschaften auf.
  ///
  /// Anlass: Der Mitschnitt der Hersteller-App (2026-09-04) zeigt, dass sie
  /// die Handles 0x0211 und 0x0411 anfasst - lesen und Notify aktivieren -,
  /// die in unserer Spezifikation nirgends vorkommen. Was dort liegt, ist
  /// unbekannt und koennte ein zweiter Datenweg sein.
  Future<void> _runGattDump() => _guarded(() async {
        final device = await _scanAndConnect();
        _device = device;

        for (final service in device.servicesList) {
          _appendLog('[gatt] Service ${service.uuid}');
          for (final c in service.characteristics) {
            final p = c.properties;
            final flags = [
              if (p.read) 'read',
              if (p.write) 'write',
              if (p.writeWithoutResponse) 'writeNoRsp',
              if (p.notify) 'notify',
              if (p.indicate) 'indicate',
            ].join(',');
            _appendLog(
              '[gatt]   char ${c.uuid}  inst=0x'
              '${c.instanceId.toRadixString(16).padLeft(4, '0')}  [$flags]',
            );
            for (final d in c.descriptors) {
              _appendLog(
                '[gatt]     desc ${d.uuid}  inst=0x'
                '${d.instanceId.toRadixString(16).padLeft(4, '0')}',
              );
            }
          }
        }
        _appendLog('[gatt] Fertig.');
      });

  // --- GENORMTE DIENSTE (Befund 2026-09-04) -----------------------------
  // Das GATT-Verzeichnis zeigt neben dem proprietaeren Service mehrere
  // Standard-Dienste, die weder omblepy noch UBPM noch die Hersteller-App
  // benutzen. Kennungen gegen die offizielle Liste der Bluetooth SIG
  // geprueft (assigned_numbers/uuids):
  //
  //   0x1805 Current Time     - 0x2A2B Current Time      [read,write,notify]
  //   0x181C User Data        - 0x2A9F User Control Point [write,indicate]
  //   0x1810 Blood Pressure   - 0x2A35 Measurement        [indicate]
  //   herstellereigen         - 0x2A52 Record Access Control Point
  //
  // Der Record Access Control Point ist die genormte Datensatzverwaltung.
  // Seine Befehle (GATT-Definition): 1 = Report stored records,
  // 2 = Delete stored records, 4 = Report number of stored records.
  // Zusatz 1 = All records.

  static const String _cts = '1805';
  static const String _ctsCurrentTime = '2a2b';
  static const String _racpService = '5df5e817-a945-4f81-89c0-3d4e9759c07c';
  static const String _racpChar = '2a52';
  static const String _userDataService = '181c';
  static const String _bloodPressureService = '1810';

  BluetoothCharacteristic? _findChar(
    BluetoothDevice device,
    String serviceUuid,
    String charUuid,
  ) {
    final s = Guid(serviceUuid);
    final c = Guid(charUuid);
    for (final service in device.servicesList) {
      if (service.uuid != s) continue;
      for (final ch in service.characteristics) {
        if (ch.uuid == c) return ch;
      }
    }
    return null;
  }

  /// NUR ABFRAGEND. Prueft, ob die genormten Dienste tatsaechlich
  /// implementiert sind oder nur als leere Huelle im Verzeichnis stehen.
  ///
  /// Es wird ausschliesslich gelesen und **ein** Befehl geschrieben:
  /// Record Access Control Point, Befehl 4 ("Report number of stored
  /// records"), Zusatz 1 ("All records"). Der veraendert nichts - er
  /// fragt nur die Anzahl ab. Der Loeschbefehl waere Befehl 2 und wird
  /// hier bewusst NICHT gesendet.
  Future<void> _runStandardServiceProbe() => _guarded(() async {
        final device = await _scanAndConnect();
        _device = device;

        // 1. Uhrzeit lesen - beantwortet, ob die Geraeteuhr ueberhaupt
        //    ueber den Normweg zugaenglich ist (§8.2 der Spezifikation
        //    sagt bisher: Uhr-Bytes unbekannt).
        final ct = _findChar(device, _cts, _ctsCurrentTime);
        if (ct == null) {
          _appendLog('[std] Current Time: Characteristic nicht gefunden');
        } else {
          try {
            final v = await ct.read();
            _appendLog('[std] Current Time roh: ${_hexBytes(Uint8List.fromList(v))}');
            if (v.length >= 7) {
              final year = v[0] | (v[1] << 8);
              _appendLog(
                '[std] Current Time gedeutet: $year-${v[2]}-${v[3]} '
                '${v[4]}:${v[5]}:${v[6]}',
              );
            }
          } catch (e) {
            _appendLog('[std] Current Time lesen fehlgeschlagen: $e');
          }
        }

        // 2. Blutdruck-Merkmale lesen (0x2A49) - zeigt, ob der Normdienst
        //    ueberhaupt Inhalt hat.
        final feature = _findChar(device, _bloodPressureService, '2a49');
        if (feature != null) {
          try {
            final v = await feature.read();
            _appendLog('[std] Blood Pressure Feature: ${_hexBytes(Uint8List.fromList(v))}');
          } catch (e) {
            _appendLog('[std] Blood Pressure Feature: $e');
          }
        }

        // 3. Benutzerindex des User-Data-Dienstes (0x2A9A).
        final userIndex = _findChar(device, _userDataService, '2a9a');
        if (userIndex != null) {
          try {
            final v = await userIndex.read();
            _appendLog('[std] User Index: ${_hexBytes(Uint8List.fromList(v))}');
          } catch (e) {
            _appendLog('[std] User Index: $e');
          }
        }

        // 4. Record Access Control Point: nur die Anzahl abfragen.
        final racp = _findChar(device, _racpService, _racpChar);
        if (racp == null) {
          _appendLog('[std] RACP nicht gefunden - Ende.');
          return;
        }
        final answers = FrameMailbox<Uint8List>();
        final sub = racp.onValueReceived
            .listen((b) => answers.deliver(Uint8List.fromList(b)));
        try {
          await racp.setNotifyValue(true);
          _appendLog('[std] RACP: Indications aktiviert, frage Anzahl ab...');
          await racp.write(
            Uint8List.fromList([0x04, 0x01]),
            withoutResponse: false,
          );
          final answer =
              await answers.next().timeout(const Duration(seconds: 10));
          _appendLog('[std] RACP Antwort: ${_hexBytes(answer)}');
          if (answer.length >= 4 && answer[0] == 0x05) {
            final count = answer[2] | (answer[3] << 8);
            _appendLog(
              '[std] ERGEBNIS: Der RACP lebt und meldet $count Datensaetze. '
              'Damit waere auch Befehl 2 (Delete stored records) verfuegbar.',
            );
          } else if (answer.isNotEmpty && answer[0] == 0x06) {
            _appendLog(
              '[std] ERGEBNIS: Response Code - das Geraet lehnt ab '
              '(Byte 3 ist der Grund).',
            );
          } else {
            _appendLog('[std] ERGEBNIS: unerwartete Antwort.');
          }
        } on TimeoutException {
          _appendLog(
            '[std] ERGEBNIS: keine Antwort binnen 10 s - der RACP steht '
            'wohl nur im Verzeichnis, ohne Funktion.',
          );
        } catch (e) {
          _appendLog('[std] RACP Fehler: $e');
        } finally {
          await sub.cancel();
          try {
            await racp.setNotifyValue(false);
          } catch (_) {}
        }
      });

  /// NUR ABFRAGEND, mit vorherigem Entsperren. Zweiter Anlauf auf den
  /// Record Access Control Point.
  ///
  /// Erster Versuch ohne Entsperren (Knopf 4c) scheiterte am Schreibversuch
  /// mit GATT_UNLIKELY (android-code 14). Naheliegende Erklaerung: Das
  /// Geraet gibt die genormten Dienste erst frei, wenn die proprietaere
  /// Sitzung entsperrt ist. Dieser Durchlauf entsperrt zuerst mit dem
  /// gespeicherten Pairing-Key und probiert dann drei Stufen:
  ///
  ///   1. RACP Befehl 4 ("Report number of stored records"), Zusatz 1
  ///   2. dasselbe innerhalb einer offenen Start/Ende-Klammer
  ///   3. Blutdruck-Messwert-Charakteristik abonnieren und lauschen
  ///
  /// Gesendet wird ausschliesslich Befehl 4. Der Loeschbefehl waere
  /// Befehl 2 und bleibt hier aussen vor.
  Future<void> _runRacpAfterUnlock() => _guarded(() async {
        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError(
            'Kein gespeicherter Pairing-Key - zuerst "5. Prod-Pairing".',
          );
        }

        final session = await OmronSession.open(log: _appendLog);
        try {
          final device = session.device;
          final transport = await session.unlock(key);
          _appendLog('[racp] entsperrt.');

          final racp = _findChar(device, _racpService, _racpChar);
          if (racp == null) {
            _appendLog('[racp] Characteristic nicht gefunden - Ende.');
            return;
          }

          final answers = FrameMailbox<Uint8List>();
          final sub = racp.onValueReceived
              .listen((b) => answers.deliver(Uint8List.fromList(b)));
          try {
            await racp.setNotifyValue(true);

            Future<void> ask(String stufe) async {
              try {
                await racp.write(
                  Uint8List.fromList([0x04, 0x01]),
                  withoutResponse: false,
                );
                _appendLog('[racp] $stufe: Befehl 4 gesendet, warte...');
                final a =
                    await answers.next().timeout(const Duration(seconds: 8));
                _appendLog('[racp] $stufe: Antwort ${_hexBytes(a)}');
                if (a.length >= 4 && a[0] == 0x05) {
                  _appendLog(
                    '[racp] $stufe: ERGEBNIS - ${a[2] | (a[3] << 8)} '
                    'Datensaetze gemeldet. Die Schnittstelle lebt.',
                  );
                } else if (a.isNotEmpty && a[0] == 0x06) {
                  _appendLog(
                    '[racp] $stufe: ERGEBNIS - Response Code, Grund '
                    '0x${a.length > 3 ? a[3].toRadixString(16) : "?"}',
                  );
                }
              } on TimeoutException {
                _appendLog('[racp] $stufe: keine Antwort binnen 8 s.');
              } catch (e) {
                _appendLog('[racp] $stufe: Schreibfehler $e');
              }
            }

            await ask('Stufe 1 (nur entsperrt)');

            // Stufe 2: innerhalb einer offenen Uebertragungsklammer.
            await startTransmission(transport);
            _appendLog('[racp] Uebertragung gestartet.');
            await ask('Stufe 2 (in offener Klammer)');
            await endTransmission(transport);

            // Stufe 3: auf Messwerte des Normdienstes lauschen.
            final bpm = _findChar(device, _bloodPressureService, '2a35');
            if (bpm == null) {
              _appendLog('[racp] Messwert-Characteristic nicht gefunden.');
            } else {
              final bpAnswers = FrameMailbox<Uint8List>();
              final bpSub = bpm.onValueReceived
                  .listen((b) => bpAnswers.deliver(Uint8List.fromList(b)));
              try {
                await bpm.setNotifyValue(true);
                _appendLog(
                  '[racp] Stufe 3: lausche 8 s auf den Blutdruck-Normdienst...',
                );
                final a =
                    await bpAnswers.next().timeout(const Duration(seconds: 8));
                _appendLog('[racp] Stufe 3: Messwert ${_hexBytes(a)}');
              } on TimeoutException {
                _appendLog(
                  '[racp] Stufe 3: nichts empfangen - der Normdienst sendet '
                  'von sich aus nichts.',
                );
              } finally {
                await bpSub.cancel();
                try {
                  await bpm.setNotifyValue(false);
                } catch (_) {}
              }
            }
          } finally {
            await sub.cancel();
            try {
              await racp.setNotifyValue(false);
            } catch (_) {}
          }
        } finally {
          await session.close();
        }
      });

  /// NUR SCANNEN. Fragt das Geraet ohne Verbindung, ob es neue Messungen
  /// gibt - der erste Baustein des Autosync.
  ///
  /// Liest die Messungsnummer aus dem Advertising (§2.1) und vergleicht
  /// sie mit dem Hoechststand in der lokalen Datenbank. Es wird weder
  /// verbunden noch entsperrt noch gelesen.
  Future<void> _runAdvertisingCheck() => _guarded(() async {
        _appendLog('[adv] Scan laeuft, Bluetooth-Taste druecken...');
        final result = await OmronSession.scan(
          waitForStatus: true,
          log: _appendLog,
        );
        final status = result.status;
        if (status == null) {
          _appendLog(
            '[adv] Geraet gefunden, aber ohne deutbare Herstellerdaten.',
          );
          return;
        }

        for (final slot in [1, 2]) {
          final known = await _syncService.repository.highestSequenceFor(slot);
          final onDevice = status.highestSequence(slot);
          final isNew = status.hasNewMeasurements(
            userSlot: slot,
            knownSequence: known,
          );
          _appendLog(
            '[adv] Slot $slot: Geraet $onDevice (Platzzeiger '
            '${status.writePointer(slot)}), DB ${known ?? "leer"} -> '
            '${isNew ? "NEUE MESSUNGEN" : "nichts Neues"}'
            '${isNew && known != null ? ", ${onDevice - known} Stueck" : ""}',
          );
        }
      });

  /// Dauerscan: lauscht auf das Advertising und meldet jede Aenderung.
  /// Nach einer Messung am Geraet sendet es von selbst (§2.1) - hier
  /// laesst sich pruefen, ob das zuverlaessig ankommt.
  ///
  /// Laeuft, bis der Knopf erneut gedrueckt wird. Kein Verbinden, kein
  /// Lesen, kein Schreiben.
  Future<void> _toggleWatch() async {
    if (_watch != null) {
      // Abbruch abwarten: Der Stream stoppt den Scan erst in seinem
      // finally-Block. Wer sofort neu startet, laesst den alten Scan den
      // neuen abschiessen (Codex-Review 2026-09-04).
      final running = _watch!;
      _watch = null;
      setState(() {});
      await running.cancel();
      _appendLog('[watch] gestoppt.');
      return;
    }
    _appendLog('[watch] laeuft - jetzt am Geraet messen.');
    // Die Meldungen der Reihe nach abarbeiten. Ohne diese Kette laufen
    // die DB-Abfragen mehrerer Meldungen parallel und die Ausgaben
    // koennen sich ueberholen.
    var pending = Future<void>.value();
    _watch = watchOmronStatus().listen(
      (status) {
        pending = pending.then((_) => _reportStatus(status));
      },
      onError: (Object e) => _appendLog('[watch] Fehler: $e'),
    );
    setState(() {});
  }

  Future<void> _reportStatus(OmronAdvertisedStatus status) async {
    final parts = <String>[];
    for (final slot in [1, 2]) {
      final known = await _syncService.repository.highestSequenceFor(slot);
      final onDevice = status.highestSequence(slot);
      final isNew = status.hasNewMeasurements(
        userSlot: slot,
        knownSequence: known,
      );
      parts.add(
        'Slot $slot: $onDevice/${status.writePointer(slot)}'
        '${isNew ? " NEU" : ""}',
      );
    }
    _appendLog('[watch] ${parts.join('  ')}');
  }

  /// SCHREIBT die Uhrzeit ueber den genormten Zeitdienst.
  ///
  /// Bisher wurde 0x2A2B nur gelesen (zehn Nullen) und daraus geschlossen,
  /// der Dienst sei tot. Das war ein Fehlschluss: Die Charakteristik hat
  /// Schreibrecht, und viele Geraete liefern beim Lesen Nullen, solange
  /// die Zeit nie gesetzt wurde.
  ///
  /// Format laut GATT-Definition (org.bluetooth.characteristic.current_time),
  /// zehn Bytes: Jahr uint16 little-endian, Monat, Tag, Stunde, Minute,
  /// Sekunde, Wochentag, Sekundenbruchteil, Aenderungsgrund.
  ///
  /// Risiko gering: Trifft nur die Uhr. Schlimmstenfalls geht sie danach
  /// falsch - was sie laut Referenz ohnehin zeitweise tat.
  /// Schreibt einen Befehl an einen der genormten Kontrollpunkte.
  ///
  /// Standard ist der Record Access Control Point (0x2A52) mit Befehl 2
  /// ("Delete stored records") und Zusatz 1 ("All records") laut
  /// GATT-Definition. Bisher wurde dort nur Befehl 4 gesendet und
  /// abgelehnt; daraus folgt nicht zwingend, dass auch Befehl 2 scheitert.
  ///
  /// ACHTUNG: Kann Messungen auf dem Geraet entfernen. Sie liegen in der
  /// App-Datenbank, auf dem Geraet waeren sie weg.
  ///
  /// [userDataPoint] schaltet auf den User Control Point (0x2A9F). Dessen
  /// Befehlswerte stehen nur in der kostenpflichtigen Spezifikation, sind
  /// also nicht belegt. Deshalb wird dort **nichts geraten**: Gesendet
  /// wird der Wert 0, der in Kontrollpunkten reserviert ist. Die Frage
  /// lautet allein, ob die Charakteristik ueberhaupt antwortet.
  Future<void> _runControlPointWrite({bool userDataPoint = false}) =>
      _guarded(() async {
        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError('Kein gespeicherter Pairing-Key.');
        }
        final session = await OmronSession.open(log: _appendLog);
        try {
          final device = session.device;
          await session.unlock(key);

          final target = userDataPoint
              ? _findChar(device, _userDataService, '2a9f')
              : _findChar(device, _racpService, _racpChar);
          final label = userDataPoint ? 'ucp' : 'racp2';
          if (target == null) {
            _appendLog('[$label] Characteristic nicht gefunden.');
            return;
          }

          final payload = userDataPoint
              ? Uint8List.fromList([0x00])
              : Uint8List.fromList([0x02, 0x01]);

          final answers = FrameMailbox<Uint8List>();
          final sub = target.onValueReceived
              .listen((b) => answers.deliver(Uint8List.fromList(b)));
          try {
            await target.setNotifyValue(true);
            _appendLog('[$label] sende ${_hexBytes(payload)}...');
            await target.write(payload, withoutResponse: false);
            _appendLog('[$label] Schreibbefehl angenommen.');
            final a = await answers.next().timeout(const Duration(seconds: 10));
            _appendLog('[$label] Antwort: ${_hexBytes(a)}');
            _appendLog('[$label] ERGEBNIS: Der Kontrollpunkt antwortet.');
          } on TimeoutException {
            _appendLog(
              '[$label] ERGEBNIS: angenommen, aber keine Antwort binnen 10 s.',
            );
          } catch (e) {
            _appendLog('[$label] ERGEBNIS: abgelehnt - $e');
          } finally {
            await sub.cancel();
            try {
              await target.setNotifyValue(false);
            } catch (_) {}
          }
        } finally {
          await session.close();
        }
      });

  /// Versucht die Kette Anlegen -> Zustimmen -> Benutzerdaten loeschen am
  /// User Control Point (0x2A9F).
  ///
  /// Der Scan vom 2026-09-05 sandte die Befehle **ohne Parameter** und
  /// bekam durchweg Ergebnis `04`, bei Befehl 3 dagegen `05`. Die Norm
  /// verlangt fuer das Anlegen einen Zugangscode als Argument und fuer
  /// das Zustimmen zusaetzlich den Benutzerindex; das Fehlen erklaert die
  /// Ablehnung. Hier werden die Parameter mitgesendet.
  ///
  /// Der Zugangscode ist frei waehlbar (uint16, little-endian). Antworten
  /// werden roh protokolliert; welcher Ergebniswert Erfolg bedeutet,
  /// zeigt der Vergleich.
  ///
  /// ACHTUNG: Legt bei Erfolg einen zusaetzlichen Benutzer auf dem Geraet
  /// an und versucht danach, dessen Daten zu loeschen.
  Future<void> _runUserRegisterChain() => _guarded(() async {
        const consentCode = 1234;
        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError('Kein gespeicherter Pairing-Key.');
        }
        final session = await OmronSession.open(log: _appendLog);
        try {
          await session.unlock(key);
          final ucp = _findChar(session.device, _userDataService, '2a9f');
          final userIndex = _findChar(session.device, _userDataService, '2a9a');
          if (ucp == null) {
            _appendLog('[reg] Characteristic nicht gefunden.');
            return;
          }

          final answers = FrameMailbox<Uint8List>();
          final sub = ucp.onValueReceived
              .listen((b) => answers.deliver(Uint8List.fromList(b)));
          try {
            await ucp.setNotifyValue(true);

            Future<Uint8List?> send(String was, List<int> bytes) async {
              try {
                await ucp.write(
                  Uint8List.fromList(bytes),
                  withoutResponse: false,
                );
                final a =
                    await answers.next().timeout(const Duration(seconds: 8));
                _appendLog('[reg] $was ${_hexBytes(Uint8List.fromList(bytes))}'
                    ' -> ${_hexBytes(a)}');
                return a;
              } on TimeoutException {
                _appendLog('[reg] $was -> keine Antwort');
              } catch (e) {
                _appendLog('[reg] $was -> Schreibfehler: $e');
              }
              return null;
            }

            // 1: Anlegen, mit Zugangscode als uint16 little-endian.
            final reg = await send('anlegen', [
              0x01,
              consentCode & 0xff,
              (consentCode >> 8) & 0xff,
            ]);

            // Der Benutzerindex steht danach in 0x2A9A.
            var index = 0xff;
            if (userIndex != null) {
              final v = await userIndex.read();
              if (v.isNotEmpty) index = v.first;
              _appendLog('[reg] Benutzerindex jetzt: $index');
            }
            if (reg != null && reg.length > 3) {
              _appendLog('[reg] Antwort traegt Zusatzbytes - moeglicher Index');
            }

            // 2: Zustimmen, mit Index und Zugangscode.
            await send('zustimmen', [
              0x02,
              index,
              consentCode & 0xff,
              (consentCode >> 8) & 0xff,
            ]);

            // 3: Benutzerdaten loeschen.
            await send('loeschen', [0x03]);

            _appendLog('[reg] Fertig.');
          } finally {
            await sub.cancel();
            try {
              await ucp.setNotifyValue(false);
            } catch (_) {}
          }
        } finally {
          await session.close();
        }
      });

  /// Tastet die Befehlswerte des User Control Point (0x2A9F) ab.
  ///
  /// Der Punkt antwortet strukturiert (Befund 2026-09-05: auf `00` kam
  /// `20 00 04`), ist also bedient. Seine Befehlswerte stehen aber nur in
  /// der kostenpflichtigen Spezifikation. Statt zu raten wird gemessen:
  /// Jeder Wert von 1 bis 8 wird gesendet, die Antwort protokolliert.
  ///
  /// Antwortaufbau, aus der Beobachtung abgeleitet: Byte 0 kennzeichnet
  /// die Antwort (`0x20`), Byte 1 spiegelt den gesendeten Befehl, Byte 2
  /// traegt das Ergebnis. Welcher Ergebniswert Erfolg bedeutet, zeigt der
  /// Vergleich ueber alle Befehle.
  ///
  /// ACHTUNG: Ein unterstuetzter Befehl wird auch ausgefuehrt. Nach den
  /// Namen der Norm sind darunter das Anlegen eines Benutzers, das
  /// Loeschen von Benutzerdaten und das Loeschen eines Benutzers. Welche
  /// Zahl welchen Befehl traegt, ist vorher unbekannt.
  Future<void> _runUserControlPointScan() => _guarded(() async {
        final key = await _syncService.keyStore.load();
        if (key == null) {
          throw StateError('Kein gespeicherter Pairing-Key.');
        }
        final session = await OmronSession.open(log: _appendLog);
        try {
          await session.unlock(key);
          final ucp = _findChar(session.device, _userDataService, '2a9f');
          if (ucp == null) {
            _appendLog('[scan] Characteristic nicht gefunden.');
            return;
          }

          final answers = FrameMailbox<Uint8List>();
          final sub = ucp.onValueReceived
              .listen((b) => answers.deliver(Uint8List.fromList(b)));
          try {
            await ucp.setNotifyValue(true);
            for (var op = 1; op <= 8; op++) {
              try {
                await ucp.write(
                  Uint8List.fromList([op]),
                  withoutResponse: false,
                );
                final a =
                    await answers.next().timeout(const Duration(seconds: 6));
                final ergebnis = a.length > 2 ? a[2] : -1;
                _appendLog(
                  '[scan] Befehl $op -> ${_hexBytes(a)}'
                  '${ergebnis == 0x04 ? "" : "   <-- ABWEICHEND"}',
                );
              } on TimeoutException {
                _appendLog('[scan] Befehl $op -> keine Antwort');
              } catch (e) {
                _appendLog('[scan] Befehl $op -> Schreibfehler: $e');
              }
            }
            _appendLog(
              '[scan] Fertig. Abweichende Ergebniswerte sind die Kandidaten.',
            );
          } finally {
            await sub.cancel();
            try {
              await ucp.setNotifyValue(false);
            } catch (_) {}
          }
        } finally {
          await session.close();
        }
      });

  /// Erster Versuch scheiterte zweimal mit GATT_NO_RESOURCES (0x80) - das
  /// ist ein Fehler des Android-Stacks, keine Ablehnung des Geraets.
  /// Deshalb dieselbe Schreiboperation in vier Varianten: mit und ohne
  /// vorheriges Entsperren, jeweils mit und ohne Antwort.
  Future<void> _runSetClock() => _guarded(() async {
        final key = await _syncService.keyStore.load();

        Future<void> attempt({
          required bool unlock,
          required bool withoutResponse,
        }) async {
          final name = '${unlock ? "entsperrt" : "roh"}/'
              '${withoutResponse ? "ohne Antwort" : "mit Antwort"}';
          final session = await OmronSession.open(log: (_) {});
          try {
            if (unlock) {
              if (key == null) {
                _appendLog('[clock] $name: kein Key gespeichert, uebersprungen.');
                return;
              }
              await session.unlock(key);
            }
            final ct = _findChar(session.device, _cts, _ctsCurrentTime);
            if (ct == null) {
              _appendLog('[clock] Characteristic nicht gefunden.');
              return;
            }

            final now = DateTime.now();
            final value = Uint8List.fromList([
              now.year & 0xff, (now.year >> 8) & 0xff,
              now.month, now.day, now.hour, now.minute, now.second,
              now.weekday, // 1 = Montag, wie in der Norm
              0x00, // Sekundenbruchteil
              0x01, // Aenderungsgrund: manuelle Zeitaktualisierung
            ]);
            try {
              await ct.write(value, withoutResponse: withoutResponse);
              final after = Uint8List.fromList(await ct.read());
              _appendLog(
                '[clock] $name: angenommen, danach ${_hexBytes(after)}'
                '${after.any((b) => b != 0) ? "  <-- GESETZT" : ""}',
              );
            } catch (e) {
              _appendLog('[clock] $name: abgelehnt - $e');
            }
          } finally {
            await session.close();
          }
        }

        _appendLog('[clock] vier Varianten, Taste zwischendurch druecken...');
        for (final unlock in [false, true]) {
          for (final wor in [false, true]) {
            try {
              await attempt(unlock: unlock, withoutResponse: wor);
            } on DeviceNotFoundException {
              _appendLog('[clock] Geraet sendet nicht mehr - Taste druecken.');
              return;
            }
          }
        }
        _appendLog('[clock] Fertig.');
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
    unawaited(_watch?.cancel());
    unawaited(_device?.disconnect());
    super.dispose();
  }

  /// Kompakte Knoepfe - der Spike hat inzwischen 20 davon, mit dem
  /// Standardmass laeuft die Leiste unten aus dem Bild.
  static final ButtonStyle _compact = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    minimumSize: const Size(0, 32),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textStyle: const TextStyle(fontSize: 12),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sphygma - Protokoll-Spike (M1)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runPairing(),
                  child: const Text('Pairing'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runFullReadout(),
                  child: const Text('Vollauslesen'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runReadClock(),
                  child: const Text('Uhr'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runProbeSettings(),
                  child: const Text('Settings'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runGattDump(),
                  child: const Text('GATT'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runStandardServiceProbe(),
                  child: const Text('Normdienste'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runRacpAfterUnlock(),
                  child: const Text('RACP+Unlock'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runSetClock(),
                  child: const Text('Uhr stellen'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runControlPointWrite(),
                  child: const Text('RACP Befehl 2'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy
                      ? null
                      : () => _runControlPointWrite(userDataPoint: true),
                  child: const Text('UCP Probe'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runUserControlPointScan(),
                  child: const Text('UCP Scan 1-8'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runUserRegisterChain(),
                  child: const Text('UCP Kette'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runProductionPairing(),
                  child: const Text('Prod-Pairing'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runProductionSync(),
                  child: const Text('Prod-Sync'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runAdvertisingCheck(),
                  child: const Text('Adv-Check'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: () => unawaited(_toggleWatch()),
                  child: Text(_watch == null ? 'Watch an' : 'Watch AUS'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runProductionExport(),
                  child: const Text('Export 1'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy
                      ? null
                      : () => _runEraseProbe(slotIndex: 1, recordIndex: 99),
                  child: const Text('Wr leer'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy
                      ? null
                      : () => _runEraseProbe(slotIndex: 1, recordIndex: 0),
                  child: const Text('Wr Record'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runVerifySlot1Tail(),
                  child: const Text('Slot1 94-97'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runFullMemoryAudit(),
                  child: const Text('Vollpruefung'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runSlotMap(0),
                  child: const Text('Platzkarte'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runReadCounters(),
                  child: const Text('Zaehler'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runFullDump(),
                  child: const Text('Vollabzug'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runZeroWriteProbe(),
                  child: const Text('Wr null'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runOffsetWriteProbe(),
                  child: const Text('Wr +0x44'),
                ),
                ElevatedButton(
                  style: _compact,
                  onPressed: _busy ? null : () => _runProductionRetract(),
                  child: const Text('Retract'),
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
