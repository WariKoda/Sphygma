// Schreibpfad ins EEPROM. Gegenstueck zu eeprom_reader.dart, aber mit
// einem Sicherheitsnetz davor: geschrieben wird ausschliesslich in die
// Record-Bereiche der beiden User-Slots.
//
// Der Grund steht in CLAUDE.md: Im Settings-Bereich (Lesen ab 0x0260,
// Schreiben ab 0x02A4) werden Kalibrierdaten des Drucksensors vermutet.
// Ein Fehlschreiben dort kann das Messgeraet dauerhaft verfaelschen. Die
// Record-Bereiche liegen dahinter und sind davon getrennt
// (docs/protocol/hem-6232t.md §1, §8.1).
//
// BEFUND 2026-09-04: Der Record-Bereich ist schreibgeschuetzt. Das Geraet
// quittiert jeden Schreibbefehl mit 81c0 und verwirft ihn - sieben
// Versuche mit drei Fuellwerten, zwei Adressierungen und beiden
// Kanalvarianten (docs/protocol/hem-6232t.md §8.4). Diese Klasse bleibt
// als Diagnose-Werkzeug und Beleg erhalten; ihre Rueckleseprüfung macht
// den Schreibschutz sichtbar, statt einen Erfolg vorzutaeuschen.
import 'dart:typed_data';

import 'ble_transport.dart';
import 'eeprom_reader.dart';
import 'exceptions.dart';
import 'frame.dart';
import 'hem6232t_device.dart';

/// Der Leer-Sentinel des Geraets: So liefert es einen nie benutzten
/// Ringpuffer-Platz aus, und so erkennt [parseRecord] ihn wieder.
final Uint8List emptyRecordBytes =
    Uint8List.fromList(List.filled(Hem6232tDevice.recordByteSize, 0xff));

/// Wirft, wenn [length] Bytes ab [address] nicht vollstaendig innerhalb
/// **eines** der beiden Record-Bereiche liegen. Ueber eine Slot-Grenze
/// hinweg zu schreiben ist ebenfalls verboten, auch wenn die Bereiche
/// aneinandergrenzen - ein Schreibvorgang gehoert immer zu genau einem
/// Slot.
void assertInsideRecordArea(int address, int length) {
  if (length <= 0) {
    throw ArgumentError.value(length, 'length', 'muss positiv sein');
  }
  const areaLength =
      Hem6232tDevice.recordsPerUser * Hem6232tDevice.recordByteSize;

  for (final start in Hem6232tDevice.userStartAddresses) {
    if (address >= start && address + length <= start + areaLength) {
      return;
    }
  }
  throw ProtocolException(
    'Schreibversuch auf 0x${address.toRadixString(16)} ueber $length Bytes '
    'liegt nicht vollstaendig in einem Record-Bereich. Schreiben ist nur '
    'dort erlaubt - der Settings-Bereich ist tabu.',
  );
}

class EepromWriter {
  EepromWriter(this._transport);

  final BleTransport _transport;

  /// Schreibt [data] ab [startAddress] in Bloecken von hoechstens
  /// [maxWriteDataLength] Bytes und **liest zum Schluss zurueck**.
  ///
  /// Die Bestaetigung `81c0` allein ist wertlos: Im Record-Bereich
  /// quittiert das Geraet jeden Schreibbefehl und verwirft ihn
  /// (docs/protocol/hem-6232t.md §8.4). Wer sich auf die Quittung
  /// verlaesst, meldet einen Erfolg, den es nie gab. Deshalb prueft diese
  /// Methode das Ergebnis selbst und wirft, wenn die Daten nicht im
  /// Speicher stehen.
  ///
  /// Wirft bei jeder Abweichung - falscher Antworttyp, falsche Adresse,
  /// abweichender Inhalt. Ein halb geschriebener Bereich wird gemeldet,
  /// nie verschwiegen.
  Future<void> writeRecordArea({
    required int startAddress,
    required Uint8List data,
  }) async {
    assertInsideRecordArea(startAddress, data.length);

    var address = startAddress;
    var offset = 0;

    while (offset < data.length) {
      final remaining = data.length - offset;
      final chunkSize =
          remaining < maxWriteDataLength ? remaining : maxWriteDataLength;
      final chunk = Uint8List.sublistView(data, offset, offset + chunkSize);

      await _transport.writeCommand(
        buildWriteEepromCommand(address: address, data: chunk),
      );
      final response = parseResponseFrame(await _transport.readResponse());

      if (response.type != responseTypeWriteData) {
        throw ProtocolException(
          'Unerwarteter Antworttyp 0x${response.type.toRadixString(16)} '
          'beim Schreiben ab 0x${address.toRadixString(16)} - erwartet war '
          '0x${responseTypeWriteData.toRadixString(16)}',
        );
      }
      if (response.address != address) {
        throw ProtocolException(
          'Das Geraet bestaetigt Adresse '
          '0x${response.address.toRadixString(16)}, geschrieben wurde nach '
          '0x${address.toRadixString(16)}',
        );
      }

      address += chunkSize;
      offset += chunkSize;
    }

    await _verify(startAddress, data);
  }

  /// Liest den geschriebenen Bereich zurueck und vergleicht ihn Byte fuer
  /// Byte. Erst das macht aus einer Quittung einen Beleg.
  Future<void> _verify(int startAddress, Uint8List expected) async {
    // Blockgroesse nicht aus der Datenlaenge ableiten: das Laengenbyte
    // des Lesekommandos fasst nur 0xff, ein ganzer User-Slot hat aber
    // 1400 Bytes (Codex-Review 2026-09-04).
    final actual = await EepromReader(_transport).readRange(
      startAddress: startAddress,
      totalLength: expected.length,
      blockSize: expected.length < defaultBlockSize
          ? expected.length
          : defaultBlockSize,
    );
    for (var i = 0; i < expected.length; i++) {
      if (actual[i] != expected[i]) {
        throw ProtocolException(
          'Schreibvorgang ab 0x${startAddress.toRadixString(16)} wurde vom '
          'Geraet quittiert, ist aber nicht angekommen: Byte $i ist '
          '0x${actual[i].toRadixString(16)}, erwartet '
          '0x${expected[i].toRadixString(16)}. Der Record-Bereich ist '
          'schreibgeschuetzt (docs/protocol/hem-6232t.md §8.4).',
        );
      }
    }
  }
}
