// Voll-Readout beider User-Slots ueber ein BleTransport - reine
// Orchestrierung, ohne Bluetooth testbar (docs/protocol/hem-6232t.md §2.3).
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/protocol/ble_transport.dart';
import 'package:sphygma/protocol/exceptions.dart';
import 'package:sphygma/protocol/frame.dart';
import 'package:sphygma/protocol/hem6232t_device.dart';
import 'package:sphygma/protocol/readout.dart';

Uint8List _hex(String hex) => Uint8List.fromList([
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ]);

Uint8List _frame(List<int> withoutCrc) =>
    Uint8List.fromList([...withoutCrc, xorChecksum(withoutCrc)]);

Uint8List _readResponse(int address, List<int> data) => _frame([
      8 + data.length,
      0x81, 0x00,
      (address >> 8) & 0xff, address & 0xff,
      data.length,
      ...data,
      0x00,
    ]);

final _startOk = _frame([0x08, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00]);
final _endOk = _frame([0x08, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00]);
Uint8List _endWithError(int code) =>
    _frame([0x08, 0x8f, 0x00, 0x00, 0x00, 0x00, code]);

/// Simuliert das EEPROM: beantwortet Lesebefehle aus einem Byte-Abbild.
class EepromImageTransport implements BleTransport {
  EepromImageTransport(this.image, {this.endResponse}) ;

  final Map<int, int> image;
  Uint8List? endResponse;
  final List<Uint8List> sent = [];
  final List<Uint8List> _pending = [];

  @override
  Future<void> writeCommand(Uint8List frame) async {
    sent.add(frame);
    final type = (frame[1] << 8) | frame[2];
    if (type == 0x0000) {
      _pending.add(_startOk);
    } else if (type == 0x0100) {
      final address = (frame[3] << 8) | frame[4];
      final length = frame[5];
      final data = [for (var i = 0; i < length; i++) image[address + i] ?? 0xff];
      _pending.add(_readResponse(address, data));
    } else if (type == 0x0f00) {
      _pending.add(endResponse ?? _endOk);
    } else {
      throw StateError('unerwartetes Kommando ${frame.map((b) => b.toRadixString(16))}');
    }
  }

  @override
  Future<Uint8List> readResponse() async => _pending.removeAt(0);
}

Map<int, int> _imageWith(Map<int, String> recordsAtAddress) {
  final image = <int, int>{};
  recordsAtAddress.forEach((address, hex) {
    final bytes = _hex(hex);
    for (var i = 0; i < bytes.length; i++) {
      image[address + i] = bytes[i];
    }
  });
  return image;
}

void main() {
  final slot1 = Hem6232tDevice.userStartAddresses[0];
  final slot2 = Hem6232tDevice.userStartAddresses[1];
  const size = Hem6232tDevice.recordByteSize;

  group('readAllRecords', () {
    test('liest beide Slots, ueberspringt leere Records, traegt den Slot ein',
        () async {
      final transport = EepromImageTransport(_imageWith({
        slot1: '4c5d574892531efa1200020e8679',
        slot1 + size: '5263573a11121d340000020c02fd',
        slot2: '5b74574251131d892000020d639c',
      }));

      final records = await readAllRecords(transport);

      expect(records, hasLength(3));
      expect(records.where((r) => r.userSlot == 1), hasLength(2));
      expect(records.where((r) => r.userSlot == 2), hasLength(1));
      expect(records.first.record.sequence, 0x020e);
      expect(records.last.record.arrhythmiaFlag, isTrue);
      expect(records.first.rawBytes, _hex('4c5d574892531efa1200020e8679'));
    });

    test('sendet Start zuerst und Ende zuletzt', () async {
      final transport = EepromImageTransport({});

      await readAllRecords(transport);

      expect(transport.sent.first, startTransmissionFrame);
      expect(transport.sent.last, endTransmissionFrame);
    });

    test('leeres Geraet ergibt leere Liste - das ist kein Fehler', () async {
      expect(await readAllRecords(EepromImageTransport({})), isEmpty);
    });

    test('wirft, wenn das Geraet beim Ende einen Fehlercode meldet',
        () async {
      final transport =
          EepromImageTransport({}, endResponse: _endWithError(0x03));

      expect(
        () => readAllRecords(transport),
        throwsA(isA<ProtocolException>()),
      );
    });
  });
}
