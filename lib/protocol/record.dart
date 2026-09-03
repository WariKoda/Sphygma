// Record-Format des HEM-6232T (2 User-Slots, 100 Records, 14 Bytes/Record).
// Spezifikation: docs/protocol/hem-6232t.md §6.
import 'dart:typed_data';

import 'exceptions.dart';

const int recordByteSize = 14;

/// Eine einzelne Blutdruckmessung.
///
/// Flag-Zuordnung an echter Hardware verifiziert (M1, 2026-09-03; siehe
/// docs/protocol/hem-6232t.md §6.2): Bit 32 = Bewegung, Bit 33 = Arrhythmie.
/// Das entspricht UBPM; omblepy hat die beiden fuer dieses Modell vertauscht.
class BloodPressureRecord {
  BloodPressureRecord({
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.timestamp,
    required this.arrhythmiaFlag,
    required this.movementFlag,
  });

  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime timestamp;
  final bool arrhythmiaFlag;
  final bool movementFlag;
}

/// Liest [firstBitIdx]..[lastBitIdx] (inklusiv, MSB-first ueber den
/// gesamten Bytepuffer) als vorzeichenlose Ganzzahl.
int _bitsToInt(Uint8List bytes, int firstBitIdx, int lastBitIdx) {
  final big = bytes.fold<int>(0, (acc, b) => (acc << 8) | b);
  final numValidBits = lastBitIdx - firstBitIdx + 1;
  final totalBits = bytes.length * 8;
  final shifted = big >> (totalBits - (lastBitIdx + 1));
  final mask = (1 << numValidBits) - 1;
  return shifted & mask;
}

/// Parst einen 14-Byte-Record. Nur die ersten 8 Bytes tragen Messwerte.
///
/// Gibt null zurueck, wenn der Record der dokumentierte Leer-Sentinel
/// (14 x 0xFF) ist - das ist ein unbenutzter Ringpuffer-Slot, kein Fehler.
/// Wirft [ProtocolException] bei falscher Laenge.
BloodPressureRecord? parseRecord(Uint8List recordBytes) {
  if (recordBytes.length != recordByteSize) {
    throw ProtocolException(
      'Record hat ${recordBytes.length} Bytes, erwartet $recordByteSize',
    );
  }

  if (recordBytes.every((b) => b == 0xff)) {
    return null;
  }

  final bytes = recordBytes.sublist(0, 8);

  final diastolic = _bitsToInt(bytes, 0, 7);
  final systolic = _bitsToInt(bytes, 8, 15) + 25;
  final year = _bitsToInt(bytes, 18, 23) + 2000;
  final pulse = _bitsToInt(bytes, 24, 31);
  final movementFlag = _bitsToInt(bytes, 32, 32) == 1;
  final arrhythmiaFlag = _bitsToInt(bytes, 33, 33) == 1;
  final month = _bitsToInt(bytes, 34, 37);
  final day = _bitsToInt(bytes, 38, 42);
  final hour = _bitsToInt(bytes, 43, 47);
  final minute = _bitsToInt(bytes, 52, 57);
  // Das Geraet liefert hier aus ungeklaertem Grund Werte bis 63 statt 59.
  final second = _bitsToInt(bytes, 58, 63).clamp(0, 59);

  return BloodPressureRecord(
    systolic: systolic,
    diastolic: diastolic,
    pulse: pulse,
    timestamp: DateTime(year, month, day, hour, minute, second),
    arrhythmiaFlag: arrhythmiaFlag,
    movementFlag: movementFlag,
  );
}
