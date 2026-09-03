// Liest einen zusammenhaengenden EEPROM-Bereich blockweise ueber ein
// BleTransport. Spezifikation: docs/protocol/hem-6232t.md §3.5.
import 'dart:typed_data';

import 'ble_transport.dart';
import 'exceptions.dart';
import 'frame.dart';

/// Uebertragungsblockgroesse fuer das HEM-6232T (4 Records je Block).
/// docs/protocol/hem-6232t.md §1.
const int defaultBlockSize = 0x38;

class EepromReader {
  EepromReader(this._transport);

  final BleTransport _transport;

  /// Liest [totalLength] Bytes ab [startAddress] in Bloecken von maximal
  /// [blockSize]. Wirft [ProtocolException], wenn eine Antwort nicht zum
  /// angefragten Kommando passt - niemals ein unvollstaendiges Ergebnis.
  Future<Uint8List> readRange({
    required int startAddress,
    required int totalLength,
    int blockSize = defaultBlockSize,
  }) async {
    final result = BytesBuilder();
    var address = startAddress;
    var remaining = totalLength;

    while (remaining > 0) {
      final chunkSize = remaining < blockSize ? remaining : blockSize;
      await _transport.writeCommand(
        buildReadEepromCommand(address: address, length: chunkSize),
      );
      final raw = await _transport.readResponse();
      final response = parseResponseFrame(raw);

      if (response.type != responseTypeReadData) {
        throw ProtocolException(
          'Unerwarteter Antworttyp 0x${response.type.toRadixString(16)} '
          'beim Lesen ab 0x${address.toRadixString(16)}',
        );
      }
      if (response.address != address) {
        throw ProtocolException(
          'Antwortadresse 0x${response.address.toRadixString(16)} passt '
          'nicht zur angefragten 0x${address.toRadixString(16)}',
        );
      }

      result.add(response.data);
      address += chunkSize;
      remaining -= chunkSize;
    }

    return result.toBytes();
  }
}
