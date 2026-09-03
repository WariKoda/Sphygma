// Frame-Format des Omron-BLE-Protokolls fuer das HEM-6232T.
// Spezifikation: docs/protocol/hem-6232t.md §3.
import 'dart:typed_data';

import 'exceptions.dart';

/// Antworttypen, siehe docs/protocol/hem-6232t.md §3.3.
const int responseTypeStart = 0x8000;
const int responseTypeReadData = 0x8100;
const int responseTypeWriteData = 0x81c0;
const int responseTypeEnd = 0x8f00;

/// XOR ueber alle Bytes. Ein wohlgeformtes Frame ergibt 0.
int xorChecksum(List<int> bytes) => bytes.fold(0, (acc, b) => acc ^ b);

final Uint8List startTransmissionFrame = Uint8List.fromList(
  [0x08, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x18],
);

final Uint8List endTransmissionFrame = Uint8List.fromList(
  [0x08, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07],
);

/// Baut ein Lesekommando: 0x08 0x0100 [addr:2] [len:1] 0x00 [xor].
/// Spezifikation: docs/protocol/hem-6232t.md §3.5.
Uint8List buildReadEepromCommand({required int address, required int length}) {
  if (length < 0 || length > 0xff) {
    throw ArgumentError.value(length, 'length', 'muss zwischen 0 und 0xff liegen');
  }
  final frame = Uint8List(8);
  frame[0] = 0x08;
  frame[1] = 0x01;
  frame[2] = 0x00;
  frame[3] = (address >> 8) & 0xff;
  frame[4] = address & 0xff;
  frame[5] = length;
  frame[6] = 0x00;
  frame[7] = xorChecksum(frame.sublist(0, 7));
  return frame;
}

/// Eine geparste Antwort des Geraets: Typ, EEPROM-Adresse und Nutzdaten.
class ResponseFrame {
  ResponseFrame({required this.type, required this.address, required this.data});

  final int type;
  final int address;
  final Uint8List data;
}

/// Parst ein vollstaendig reassembliertes Antwort-Frame.
/// Spezifikation: docs/protocol/hem-6232t.md §4 (Schritte 5-6) und §3.3.
ResponseFrame parseResponseFrame(Uint8List raw) {
  if (xorChecksum(raw) != 0) {
    throw ProtocolException(
      'Pruefsumme ungueltig: ${raw.map((b) => b.toRadixString(16)).join(' ')}',
    );
  }

  final type = (raw[1] << 8) | raw[2];
  final address = (raw[3] << 8) | raw[4];
  final expectedDataLength = raw[5];

  final Uint8List data;
  if (type == responseTypeEnd) {
    // Sonderfall: Byte 6 ist der Fehlercode, nicht laengenbestimmt.
    data = raw.sublist(6, 7);
  } else if (expectedDataLength > raw.length - 8) {
    // Geraet liefert faktisch 0xFF-Fuellung, wenn mehr Daten gemeldet
    // werden, als das Paket hergibt - als leerer Bereich behandeln.
    data = Uint8List(expectedDataLength)..fillRange(0, expectedDataLength, 0xff);
  } else {
    data = raw.sublist(6, 6 + expectedDataLength);
  }

  return ResponseFrame(type: type, address: address, data: data);
}
