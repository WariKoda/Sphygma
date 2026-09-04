// BleTransport-Implementierung gegen ein bereits verbundenes,
// service-discovertes Omron-Geraet. Reine Verdrahtung: die eigentliche
// Logik (Reassemblierung, Frame-Aufbau) liegt in lib/protocol/ und ist
// dort ohne Hardware getestet. Dieser Adapter selbst ist NICHT an
// echter Hardware verifiziert - das ist Meilenstein 1.
//
// Schreibrichtung, belegt durch den Mitschnitt der Hersteller-App
// (2026-09-04, docs/protocol/hem-6232t.md §2.2): Ein Kommando bis 16 Bytes
// geht auf TX-Kanal 0, ein laengeres wird in 16-Byte-Stuecke auf die
// folgenden Kanaele verteilt. Kanal 0 wird mit Response geschrieben, die
// Folgekanaele ohne - genau so macht es die Hersteller-App.
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../protocol/ble_transport.dart';
import '../protocol/channel_reassembler.dart';
import '../protocol/exceptions.dart';
import '../protocol/frame.dart';
import 'frame_mailbox.dart';

class FlutterBluePlusTransport implements BleTransport {
  FlutterBluePlusTransport({
    required List<BluetoothCharacteristic> txCharacteristics,
    required List<BluetoothCharacteristic> rxCharacteristics,
  })  : _tx = txCharacteristics,
        _rx = rxCharacteristics {
    if (_tx.length != txChannelCount) {
      throw ArgumentError.value(
        _tx.length,
        'txCharacteristics',
        'Hem6232tDevice.txCharacteristicUuids hat $txChannelCount Eintraege',
      );
    }
    if (_rx.length != 4) {
      throw ArgumentError.value(
        _rx.length,
        'rxCharacteristics',
        'Hem6232tDevice.rxCharacteristicUuids hat 4 Eintraege',
      );
    }
  }

  final List<BluetoothCharacteristic> _tx;
  final List<BluetoothCharacteristic> _rx;

  /// RX-Kanal 0 - das Pairing braucht ihn, weil Notify darauf das Bonding
  /// ausloest (docs/protocol/hem-6232t.md §5.1).
  BluetoothCharacteristic get rxChannel0 => _rx.first;
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
    final parts = splitIntoTxChannels(frame);
    for (var channel = 0; channel < parts.length; channel++) {
      // Folgekanaele ohne Response - so schreibt die Hersteller-App
      // (Mitschnitt 2026-09-04).
      //
      // Kanal 0 geht hier immer MIT Response, waehrend die Hersteller-App
      // kurze Kommandos (Start, Lesen, Ende) ohne sendet. Beides
      // funktioniert an der Hardware (M1 und alle Laeufe seither); mit
      // Response meldet der Stack zusaetzlich, wenn ein Write nicht
      // ankommt, und das ist uns lieber als die exakte Nachbildung.
      await _tx[channel].write(parts[channel], withoutResponse: channel > 0);
    }
  }

  /// Befund M1: Bleibt eine Antwort aus, trennt das Geraet nach ~60 s.
  /// Ohne Timeout haengt der Aufrufer dann fuer immer - deshalb hart
  /// scheitern, sobald laenger als [responseTimeout] nichts kommt.
  static const Duration responseTimeout = Duration(seconds: 10);

  @override
  Future<Uint8List> readResponse() => _mailbox.next().timeout(
        responseTimeout,
        onTimeout: () => throw ProtocolException(
          'Keine Antwort vom Geraet binnen $responseTimeout.',
        ),
      );
}
