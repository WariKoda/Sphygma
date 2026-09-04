// Schritt 4 des Pairings (docs/protocol/hem-6232t.md §5): nach dem
// Key-Write einmal Start/Ende fahren, sonst uebernimmt ein zuvor nie
// gepaartes Geraet (z. B. nach Werksreset, Handbuch §6.3) das Pairing nicht.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/protocol/ble_transport.dart';
import 'package:sphygma/protocol/exceptions.dart';
import 'package:sphygma/protocol/frame.dart';
import 'package:sphygma/protocol/readout.dart';

Uint8List _frame(List<int> withoutCrc) =>
    Uint8List.fromList([...withoutCrc, xorChecksum(withoutCrc)]);

final _startOk = _frame([0x08, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00]);
final _endOk = _frame([0x08, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00]);

class _ScriptedTransport implements BleTransport {
  _ScriptedTransport(this.responses);

  final List<Uint8List> responses;
  final List<Uint8List> sent = [];

  @override
  Future<void> writeCommand(Uint8List frame) async => sent.add(frame);

  @override
  Future<Uint8List> readResponse() async => responses.removeAt(0);
}

void main() {
  test('sendet genau Start und Ende, in dieser Reihenfolge', () async {
    final transport = _ScriptedTransport([_startOk, _endOk]);

    await confirmPairing(transport);

    expect(transport.sent, [startTransmissionFrame, endTransmissionFrame]);
    expect(transport.responses, isEmpty);
  });

  test('wirft, wenn das Geraet den Start nicht bestaetigt', () async {
    final refused = _frame([0x08, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00]);
    final transport = _ScriptedTransport([refused, _endOk]);

    await expectLater(
      confirmPairing(transport),
      throwsA(isA<ProtocolException>()),
    );
    expect(transport.sent, [startTransmissionFrame]);
  });

  test('wirft, wenn das Ende einen Fehlercode traegt', () async {
    final endError = _frame([0x08, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x03]);
    final transport = _ScriptedTransport([_startOk, endError]);

    await expectLater(
      confirmPairing(transport),
      throwsA(isA<ProtocolException>()),
    );
  });
}
