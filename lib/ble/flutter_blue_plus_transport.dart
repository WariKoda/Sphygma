// BleTransport-Implementierung gegen ein bereits verbundenes,
// service-discovertes Omron-Geraet. Reine Verdrahtung: die eigentliche
// Logik (Reassemblierung, Frame-Aufbau) liegt in lib/protocol/ und ist
// dort ohne Hardware getestet. Dieser Adapter selbst ist NICHT an
// echter Hardware verifiziert - das ist Meilenstein 1.
//
// UNVERIFIZIERT, an Hardware zu pruefen (M1):
// - ob withoutResponse:false fuer TX-Writes korrekt ist. omblepy nutzt
//   auf diesem Geraet effektiv einen einzelnen TX-Kanal mit dem
//   bleak-Default; welches GATT-Write-Mode das Omron-Geraet erwartet,
//   ist aus den Referenzimplementierungen nicht eindeutig ableitbar.
//   Bei Fehlschlag withoutResponse:true probieren.
// - ob wirklich alle 4 RX-Kanaele noetig sind oder 2 reichen (siehe
//   docs/protocol/hem-6232t.md §2, Abweichung zwischen omblepy und UBPM).
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../protocol/ble_transport.dart';
import '../protocol/channel_reassembler.dart';
import 'frame_mailbox.dart';

class FlutterBluePlusTransport implements BleTransport {
  FlutterBluePlusTransport({
    required BluetoothCharacteristic txCharacteristic,
    required List<BluetoothCharacteristic> rxCharacteristics,
  })  : _tx = txCharacteristic,
        _rx = rxCharacteristics {
    if (_rx.length != 4) {
      throw ArgumentError.value(
        _rx.length,
        'rxCharacteristics',
        'Hem6232tDevice.rxCharacteristicUuids hat 4 Eintraege',
      );
    }
  }

  final BluetoothCharacteristic _tx;
  final List<BluetoothCharacteristic> _rx;
  final ChannelReassembler _reassembler = ChannelReassembler();
  final FrameMailbox<Uint8List> _mailbox = FrameMailbox<Uint8List>();
  final List<StreamSubscription<List<int>>> _subscriptions = [];

  /// Aktiviert Notifications auf allen 4 RX-Kanaelen. Vor der ersten
  /// Kommunikation aufzurufen (nach [BluetoothDevice.discoverServices]).
  Future<void> enableNotifications() async {
    for (var channelIndex = 0; channelIndex < _rx.length; channelIndex++) {
      final characteristic = _rx[channelIndex];
      await characteristic.setNotifyValue(true);
      _subscriptions.add(
        characteristic.onValueReceived.listen((bytes) {
          final frame = _reassembler.receive(
            channelIndex,
            Uint8List.fromList(bytes),
          );
          if (frame != null) {
            _mailbox.deliver(frame);
          }
        }),
      );
    }
  }

  Future<void> disableNotifications() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    for (final characteristic in _rx) {
      await characteristic.setNotifyValue(false);
    }
  }

  @override
  Future<void> writeCommand(Uint8List frame) async {
    await _tx.write(frame, withoutResponse: false);
  }

  @override
  Future<Uint8List> readResponse() => _mailbox.next();
}
