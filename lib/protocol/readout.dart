// Voll-Readout beider User-Slots. Reine Orchestrierung ueber BleTransport:
// Start -> beide Slots blockweise lesen -> Records parsen -> Ende.
// Spezifikation: docs/protocol/hem-6232t.md §2.3 (PLAN.md) bzw. §1, §3.
//
// Kein "new record counter", keine Zeitsynchronisation: beides braeuchte
// EEPROM-Writes, die tabu sind. Stattdessen immer alles lesen und in der
// App ueber die Messungsnummer deduplizieren.
import 'dart:typed_data';

import 'ble_transport.dart';
import 'eeprom_reader.dart';
import 'exceptions.dart';
import 'frame.dart';
import 'hem6232t_device.dart';
import 'record.dart';

/// Eine gelesene Messung samt Herkunft.
class SlotRecord {
  SlotRecord({
    required this.userSlot,
    required this.record,
    required this.rawBytes,
  });

  /// 1-basiert, wie am Geraet beschriftet.
  final int userSlot;
  final BloodPressureRecord record;

  /// Die 14 Rohbytes - fuer Nachvollziehbarkeit und spaetere Auswertung
  /// der noch ungeklaerten Bytes (docs/protocol/hem-6232t.md §6.3).
  final Uint8List rawBytes;
}

/// Liest alle belegten Records beider Slots. Wirft [ProtocolException] bei
/// jeder Abweichung vom erwarteten Ablauf; eine leere Liste bedeutet
/// ausschliesslich "Geraet ohne gespeicherte Messungen".
Future<List<SlotRecord>> readAllRecords(BleTransport transport) async {
  await transport.writeCommand(startTransmissionFrame);
  final start = parseResponseFrame(await transport.readResponse());
  if (start.type != responseTypeStart) {
    throw ProtocolException(
      'Unerwartete Antwort auf Start: 0x${start.type.toRadixString(16)}',
    );
  }

  final reader = EepromReader(transport);
  final result = <SlotRecord>[];
  const recordSize = Hem6232tDevice.recordByteSize;

  for (var slotIndex = 0;
      slotIndex < Hem6232tDevice.userStartAddresses.length;
      slotIndex++) {
    final bytes = await reader.readRange(
      startAddress: Hem6232tDevice.userStartAddresses[slotIndex],
      totalLength: Hem6232tDevice.recordsPerUser * recordSize,
      blockSize: Hem6232tDevice.transmissionBlockSize,
    );
    for (var offset = 0; offset < bytes.length; offset += recordSize) {
      final raw = bytes.sublist(offset, offset + recordSize);
      final record = parseRecord(raw);
      if (record == null) continue;
      result.add(
        SlotRecord(userSlot: slotIndex + 1, record: record, rawBytes: raw),
      );
    }
  }

  await transport.writeCommand(endTransmissionFrame);
  final end = parseResponseFrame(await transport.readResponse());
  if (end.type != responseTypeEnd) {
    throw ProtocolException(
      'Unerwartete Antwort auf Ende: 0x${end.type.toRadixString(16)}',
    );
  }
  if (end.data.isNotEmpty && end.data[0] != 0) {
    throw ProtocolException(
      'Geraet meldet Fehlercode ${end.data[0]} beim Beenden der Uebertragung',
    );
  }
  return result;
}
