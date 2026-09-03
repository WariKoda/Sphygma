// Pairing- und Unlock-Sequenz auf der Unlock-Characteristic.
// Spezifikation: docs/protocol/hem-6232t.md §5.
//
// Die Unlock-Characteristic ist NICHT Teil des Multi-Channel-Protokolls
// (kein ChannelReassembler, keine XOR-Pruefsumme) - die rohen Notify-Bytes
// tragen den Antwortcode direkt in den ersten beiden Bytes, siehe omblepy
// _callbackForUnlockChannel.
//
// UNVERIFIZIERT (Meilenstein 1): Diese Sequenz ist aus omblepy
// uebernommen, aber an diesem Geraet noch nie ausgefuehrt worden.
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../protocol/exceptions.dart';
import 'frame_mailbox.dart';

const int _programmingModeResponse = 0x8200;
const int _keyWrittenResponse = 0x8000;
const int _unlockAcceptedResponse = 0x8100;

int _responseCode(List<int> bytes) => (bytes[0] << 8) | bytes[1];

/// Programmiert [key] (16 Bytes) als neuen Pairing-Key. Das Geraet muss
/// vorher in den Pairing-Modus versetzt worden sein (Bluetooth-Taste
/// lange druecken, bis "-P-" blinkt).
///
/// Wiederholt Schritt 2 bis zu [maxAttempts] Mal im Abstand [retryDelay],
/// weil laut omblepy das BLE-Bonding im Hintergrund noch laufen kann,
/// wenn der erste Versuch eintrifft.
/// Wartet, bis das Geraet gebondet ist. Kommt binnen [requestWindow] gar
/// keine Kopplungsanfrage (Status bleibt none), wird das Bonding explizit
/// per createBond() angestossen. Wird eine laufende Kopplung abgelehnt oder
/// laeuft in den Timeout, wird geworfen - nie still weitergemacht.
Future<void> _awaitBonded(
  BluetoothDevice device,
  void Function(String message)? log, {
  Duration requestWindow = const Duration(seconds: 8),
  Duration confirmWindow = const Duration(seconds: 45),
}) async {
  log?.call(
    'Warte auf Bonding - Kopplungsanfrage auf dem Handy binnen 30 s '
    'bestaetigen (kann als Benachrichtigung erscheinen)...',
  );
  var sawBonding = false;
  final deadline = DateTime.now().add(confirmWindow);
  final requestDeadline = DateTime.now().add(requestWindow);

  await for (final state in device.bondState.timeout(confirmWindow)) {
    log?.call('Bond-Status: $state');
    if (state == BluetoothBondState.bonded) return;
    if (state == BluetoothBondState.bonding) {
      sawBonding = true;
      continue;
    }
    // state == none
    if (sawBonding) {
      throw ProtocolException(
        'Bonding abgebrochen oder abgelehnt (Status wieder none).',
      );
    }
    if (DateTime.now().isAfter(requestDeadline)) {
      log?.call('Keine Kopplungsanfrage vom Geraet - createBond() explizit.');
      await device.createBond();
      return;
    }
    if (DateTime.now().isAfter(deadline)) break;
  }
  throw ProtocolException('Bonding nicht binnen $confirmWindow abgeschlossen.');
}

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

Future<void> writeNewPairingKey({
  required BluetoothCharacteristic unlockCharacteristic,
  required Uint8List key,
  BluetoothCharacteristic? rxChannel0,
  void Function(String message)? log,
  int maxAttempts = 10,
  Duration retryDelay = const Duration(seconds: 1),
  Duration responseTimeout = const Duration(seconds: 5),
}) async {
  if (key.length != 16) {
    throw ArgumentError.value(key.length, 'key', 'muss 16 Bytes lang sein');
  }

  final responses = FrameMailbox<Uint8List>();
  final subscription = unlockCharacteristic.onValueReceived.listen(
    (bytes) => responses.deliver(Uint8List.fromList(bytes)),
  );

  try {
    // Wie omblepy (writeNewUnlockKey): ZUERST Notify auf RX-Kanal 0 - laut
    // dortigem Kommentar loest das den SMP Security Request des Geraets
    // aus, der das BLE-Bonding anstoesst. Erst danach die Unlock-Sequenz.
    if (rxChannel0 != null) {
      await rxChannel0.setNotifyValue(true);
      log?.call('Notify auf RX0 aktiviert (soll Bonding ausloesen).');
      // Befund M1: Ohne abgeschlossenes Bonding antwortet das Geraet auf
      // 0x02 mit 82 0f (verweigert). Android zeigt die Kopplungsanfrage als
      // Benachrichtigung und bricht nach 30 s mit SMP_RSP_TIMEOUT ab.
      await _awaitBonded(unlockCharacteristic.device, log);
    }
    await unlockCharacteristic.setNotifyValue(true);

    var enteredProgrammingMode = false;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      await unlockCharacteristic.write(
        Uint8List.fromList([0x02, ...List.filled(16, 0x00)]),
        withoutResponse: false,
      );
      final response = await responses.next().timeout(responseTimeout);
      log?.call('Versuch $attempt: Antwort ${_hex(response)}');
      if (_responseCode(response) == _programmingModeResponse) {
        enteredProgrammingMode = true;
        break;
      }
      if (attempt < maxAttempts) {
        await Future<void>.delayed(retryDelay);
      }
    }
    if (!enteredProgrammingMode) {
      throw ProtocolException(
        'Konnte nach $maxAttempts Versuchen nicht in den '
        'Key-Programmiermodus wechseln. Ist das Geraet im Pairing-Modus '
        '("-P-" blinkt)?',
      );
    }

    await unlockCharacteristic.write(
      Uint8List.fromList([0x00, ...key]),
      withoutResponse: false,
    );
    final keyResponse = await responses.next().timeout(responseTimeout);
    if (_responseCode(keyResponse) != _keyWrittenResponse) {
      throw ProtocolException(
        'Programmieren des neuen Keys fehlgeschlagen: '
        '${keyResponse.map((b) => b.toRadixString(16)).join(' ')}',
      );
    }
  } finally {
    await subscription.cancel();
  }
}

/// Entsperrt eine bereits gepaarte Sitzung mit dem gespeicherten [key].
Future<void> unlockWithPairingKey({
  required BluetoothCharacteristic unlockCharacteristic,
  required Uint8List key,
  Duration responseTimeout = const Duration(seconds: 5),
}) async {
  if (key.length != 16) {
    throw ArgumentError.value(key.length, 'key', 'muss 16 Bytes lang sein');
  }

  final responses = FrameMailbox<Uint8List>();
  final subscription = unlockCharacteristic.onValueReceived.listen(
    (bytes) => responses.deliver(Uint8List.fromList(bytes)),
  );

  try {
    await unlockCharacteristic.setNotifyValue(true);
    await unlockCharacteristic.write(
      Uint8List.fromList([0x01, ...key]),
      withoutResponse: false,
    );
    final response = await responses.next().timeout(responseTimeout);
    if (_responseCode(response) != _unlockAcceptedResponse) {
      throw ProtocolException(
        'Entsperren fehlgeschlagen - der eingegebene Key passt nicht zum '
        'gespeicherten.',
      );
    }
  } finally {
    await subscription.cancel();
  }
}
