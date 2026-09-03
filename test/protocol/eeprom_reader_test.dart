import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/protocol/ble_transport.dart';
import 'package:sphygma/protocol/eeprom_reader.dart';
import 'package:sphygma/protocol/exceptions.dart';
import 'package:sphygma/protocol/frame.dart';

/// Test-Doppel: liefert vorbereitete Antworten der Reihe nach und
/// zeichnet die gesendeten Kommandos auf. Reassemblierung ist hier kein
/// Thema - die Antworten sind bereits vollstaendige, geprueft aufgebaute
/// Frames (das ist Aufgabe von ChannelReassembler + parseResponseFrame,
/// nicht des Readers).
class FakeBleTransport implements BleTransport {
  FakeBleTransport(this._responses);

  final List<Uint8List> _responses;
  final List<Uint8List> sentCommands = [];
  int _responseIndex = 0;

  @override
  Future<void> writeCommand(Uint8List frame) async {
    sentCommands.add(frame);
  }

  @override
  Future<Uint8List> readResponse() async => _responses[_responseIndex++];
}

Uint8List _readResponse({required int address, required List<int> data}) {
  final header = [
    8 + data.length,
    0x81, 0x00,
    (address >> 8) & 0xff, address & 0xff,
    data.length,
    ...data,
    0x00,
  ];
  return Uint8List.fromList([...header, xorChecksum(header)]);
}

void main() {
  group('EepromReader.readRange', () {
    test('liest in einem Block, wenn totalLength <= blockSize passt', () async {
      final transport = FakeBleTransport([
        _readResponse(address: 0x0260, data: [1, 2, 3, 4]),
      ]);
      final reader = EepromReader(transport);

      final result = await reader.readRange(
        startAddress: 0x0260,
        totalLength: 4,
        blockSize: 0x38,
      );

      expect(result, Uint8List.fromList([1, 2, 3, 4]));
      expect(transport.sentCommands, hasLength(1));
      expect(
        transport.sentCommands.single,
        buildReadEepromCommand(address: 0x0260, length: 4),
      );
    });

    test('liest ueber mehrere Bloecke und erhoeht die Adresse dazwischen',
        () async {
      final transport = FakeBleTransport([
        _readResponse(address: 0x0000, data: [1, 2]),
        _readResponse(address: 0x0002, data: [3, 4]),
        _readResponse(address: 0x0004, data: [5]),
      ]);
      final reader = EepromReader(transport);

      final result = await reader.readRange(
        startAddress: 0x0000,
        totalLength: 5,
        blockSize: 2,
      );

      expect(result, Uint8List.fromList([1, 2, 3, 4, 5]));
      expect(transport.sentCommands, hasLength(3));
      expect(
        transport.sentCommands[2],
        buildReadEepromCommand(address: 0x0004, length: 1),
      );
    });

    test('wirft ProtocolException, wenn die Antwortadresse nicht passt',
        () async {
      final transport = FakeBleTransport([
        _readResponse(address: 0x9999, data: [1, 2]),
      ]);
      final reader = EepromReader(transport);

      expect(
        () => reader.readRange(startAddress: 0x0000, totalLength: 2),
        throwsA(isA<ProtocolException>()),
      );
    });

    test('wirft ProtocolException bei unerwartetem Antworttyp', () async {
      // 0x81c0 (Schreib-Bestaetigung) statt 0x8100 (Lese-Antwort).
      final header = [8, 0x81, 0xc0, 0x00, 0x00, 0x00, 0x00];
      final wrongType = Uint8List.fromList([...header, xorChecksum(header)]);
      final transport = FakeBleTransport([wrongType]);
      final reader = EepromReader(transport);

      expect(
        () => reader.readRange(startAddress: 0x0000, totalLength: 2),
        throwsA(isA<ProtocolException>()),
      );
    });
  });
}
