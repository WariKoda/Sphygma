// Pairing- und Unlock-Sequenz auf der Unlock-Characteristic.
// Spezifikation: docs/protocol/hem-6232t.md §5.
//
// Die Unlock-Characteristic ist NICHT Teil des Multi-Channel-Protokolls
// (kein ChannelReassembler, keine XOR-Pruefsumme) - die rohen Notify-Bytes
// tragen den Antwortcode direkt in den ersten beiden Bytes, siehe omblepy
// _callbackForUnlockChannel.
//
// Die Sequenz stammt aus omblepy und ist an der Hardware verifiziert
// (2026-09-03/04); die Android-spezifischen Abweichungen stehen in
// docs/protocol/hem-6232t.md §5.1.
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../protocol/exceptions.dart';
import 'frame_mailbox.dart';

const int _programmingModeResponse = 0x8200;
const int _keyWrittenResponse = 0x8000;
const int _unlockAcceptedResponse = 0x8100;

int _responseCode(List<int> bytes) => (bytes[0] << 8) | bytes[1];

/// Stoesst das BLE-Bonding selbst an und prueft, dass es steht.
///
/// Befund an Hardware (2026-09-04, docs/protocol/hem-6232t.md §5.1): Wer das
/// Geraet zuerst per Notify auf RX 0 zum Security Request bringt, bekommt am
/// Handy **zwei** Kopplungsdialoge - einen fuer die Anfrage des Geraets, einen
/// fuer die Just-Works-Zustimmung. Kommt [BluetoothDevice.createBond] zuerst,
/// verwirft Android die spaetere Security Request des Geraets ("Discard
/// security request", AOSP `btif_dm.cc`, `btif_dm_ble_sec_req_evt`), und es
/// bleibt bei **einem** Dialog.
///
/// [BluetoothDevice.createBond] wirft selbst, wenn die Kopplung abgelehnt wird
/// oder in den Timeout laeuft; war das Geraet schon gebondet, kehrt es sofort
/// zurueck. Die anschliessende Pruefung ist die Absicherung dagegen, mit einem
/// nur scheinbar gebondeten Geraet weiterzumachen.
Future<void> _bond(
  BluetoothDevice device,
  void Function(String message)? log,
) async {
  log?.call(
    'Kopplung anstossen - Anfrage auf dem Handy bestaetigen '
    '(kann als Benachrichtigung erscheinen)...',
  );
  await device.createBond();

  final state = await device.bondState.first;
  if (state != BluetoothBondState.bonded) {
    throw ProtocolException(
      'Bonding nicht abgeschlossen (Status $state) - ohne Bond verweigert '
      'das Geraet den Key-Programmiermodus.',
    );
  }
  log?.call('Geraet ist gebondet.');
}

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

/// Programmiert [key] (16 Bytes) als neuen Pairing-Key. Das Geraet muss
/// vorher in den Pairing-Modus versetzt worden sein (Bluetooth-Taste
/// lange druecken, bis "-P-" blinkt).
///
/// Wiederholt Schritt 2 bis zu [maxAttempts] Mal im Abstand [retryDelay],
/// weil laut omblepy das BLE-Bonding im Hintergrund noch laufen kann,
/// wenn der erste Versuch eintrifft.
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
    // omblepy aktiviert hier ZUERST Notify auf RX-Kanal 0, damit das Geraet
    // den SMP Security Request schickt, der das Bonding anstoesst. An Android
    // kostet das einen zweiten Kopplungsdialog (§5.1), deshalb bonden wir
    // selbst und aktivieren Notify erst danach.
    if (rxChannel0 != null) {
      await _bond(unlockCharacteristic.device, log);
      // Befund M1: Ohne abgeschlossenes Bonding antwortet das Geraet auf
      // 0x02 mit 82 0f (verweigert).
      await rxChannel0.setNotifyValue(true);
      log?.call('Notify auf RX0 aktiviert.');
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
