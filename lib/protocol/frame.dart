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

/// Prueft, dass [address] in den 16-Bit-Adressraum des Geraets passt.
/// Fail hard statt stiller Maskierung: eine zu grosse oder negative
/// Adresse wuerde sonst ein plausibles Kommando auf eine voellig andere
/// Speicherstelle erzeugen (Codex-Review 2026-09-04).
void _assertAddressInRange(int address, int length) {
  if (address < 0 || address > 0xffff) {
    throw ArgumentError.value(
      address,
      'address',
      'muss zwischen 0x0000 und 0xffff liegen',
    );
  }
  if (address + length - 1 > 0xffff) {
    throw ArgumentError.value(
      address,
      'address',
      'Bereich von $length Bytes ab 0x${address.toRadixString(16)} laeuft '
          'ueber das Ende des 16-Bit-Adressraums hinaus',
    );
  }
}

/// Breite eines TX-Kanals in Bytes. Ein Kommando, das laenger ist, wird
/// auf mehrere Kanaele verteilt - Kanal 0 zuerst.
///
/// Belegt durch den Mitschnitt der Hersteller-App (2026-09-04): ein
/// 24-Byte-Schreibrahmen ging als 16 Bytes auf TX 0 und 8 Bytes auf TX 1.
/// omblepy nutzt dieselbe Breite (`channelWidth = 16`).
const int txChannelWidth = 16;

/// Anzahl der TX-Kanaele des Geraets. Mehr Daten passen in ein Kommando
/// nicht hinein.
const int txChannelCount = 4;

/// Zerlegt [frame] in die Stuecke, die auf die TX-Kanaele gehoeren.
/// Ein Kommando bis [txChannelWidth] Bytes ergibt genau ein Stueck.
List<Uint8List> splitIntoTxChannels(Uint8List frame) {
  if (frame.isEmpty) {
    throw ArgumentError.value(frame.length, 'frame', 'darf nicht leer sein');
  }
  if (frame.length > txChannelWidth * txChannelCount) {
    throw ArgumentError.value(
      frame.length,
      'frame',
      'passt nicht in $txChannelCount Kanaele zu je $txChannelWidth Bytes',
    );
  }
  return [
    for (var offset = 0; offset < frame.length; offset += txChannelWidth)
      Uint8List.sublistView(
        frame,
        offset,
        offset + txChannelWidth > frame.length
            ? frame.length
            : offset + txChannelWidth,
      ),
  ];
}

/// Groesste Nutzdatenmenge je Schreibbefehl. Der Rahmen kostet 8 Bytes;
/// mit 16 Nutzbytes ist er 24 Bytes lang und belegt zwei TX-Kanaele.
/// Genau diese Groesse nutzt die Hersteller-App (Mitschnitt 2026-09-04).
const int maxWriteDataLength = 16;

/// Baut ein Schreibkommando: [len] 0x01c0 [addr:2] [datalen:1] [daten]
/// 0x00 [xor]. Das Laengenbyte zaehlt die Nutzdaten plus 8 Rahmenbytes.
/// Spezifikation: docs/protocol/hem-6232t.md §3.6.
///
/// Dies ist der einzige schreibende Befehl des Protokolls. Wo er
/// eingesetzt werden darf, steht in CLAUDE.md - der Settings-Bereich ist
/// tabu, weil dort Kalibrierdaten vermutet werden.
Uint8List buildWriteEepromCommand({
  required int address,
  required Uint8List data,
}) {
  if (data.isEmpty) {
    throw ArgumentError.value(data.length, 'data', 'darf nicht leer sein');
  }
  _assertAddressInRange(address, data.length);
  if (data.length > maxWriteDataLength) {
    throw ArgumentError.value(
      data.length,
      'data',
      'hoechstens $maxWriteDataLength Bytes, sonst passt das Frame nicht in '
          'einen TX-Kanal',
    );
  }
  final frame = Uint8List(data.length + 8);
  frame[0] = data.length + 8;
  frame[1] = 0x01;
  frame[2] = 0xc0;
  frame[3] = (address >> 8) & 0xff;
  frame[4] = address & 0xff;
  frame[5] = data.length;
  frame.setRange(6, 6 + data.length, data);
  frame[frame.length - 2] = 0x00;
  frame[frame.length - 1] = xorChecksum(frame.sublist(0, frame.length - 1));
  return frame;
}

/// Baut ein Lesekommando: 0x08 0x0100 [addr:2] [len:1] 0x00 [xor].
/// Spezifikation: docs/protocol/hem-6232t.md §3.5.
Uint8List buildReadEepromCommand({required int address, required int length}) {
  if (length < 0 || length > 0xff) {
    throw ArgumentError.value(length, 'length', 'muss zwischen 0 und 0xff liegen');
  }
  _assertAddressInRange(address, length);
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
    // Fail hard: Ein Frame, das mehr Nutzdaten meldet als es traegt, ist
    // unvollstaendig - typischerweise fehlt ein RX-Kanal. Frueher wurde
    // hier mit 0xFF aufgefuellt; das ist von einem echten Leerbereich
    // nicht zu unterscheiden und liesse eine Messung stillschweigend
    // verschwinden (Codex-Review 2026-09-04).
    throw ProtocolException(
      'Antwort meldet $expectedDataLength Nutzdatenbytes, das Frame traegt '
      'aber nur ${raw.length - 8} - unvollstaendig (fehlender RX-Kanal?): '
      '${raw.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
    );
  } else {
    data = raw.sublist(6, 6 + expectedDataLength);
  }

  return ResponseFrame(type: type, address: address, data: data);
}
