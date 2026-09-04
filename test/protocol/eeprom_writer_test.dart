// Schreibpfad ins EEPROM. Der Adressschutz ist der wichtigste Teil: er
// haelt jeden Schreibvorgang im Record-Bereich und damit weg von den
// Einstellungen, in denen Kalibrierdaten vermutet werden (CLAUDE.md).
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/protocol/ble_transport.dart';
import 'package:sphygma/protocol/eeprom_writer.dart';
import 'package:sphygma/protocol/exceptions.dart';
import 'package:sphygma/protocol/frame.dart';
import 'package:sphygma/protocol/hem6232t_device.dart';

Uint8List _frame(List<int> withoutCrc) =>
    Uint8List.fromList([...withoutCrc, xorChecksum(withoutCrc)]);

/// Bestaetigung eines Schreibvorgangs: Typ 0x81c0 mit derselben Adresse.
Uint8List _writeAck(int address) => _frame([
      0x08, 0x81, 0xc0,
      (address >> 8) & 0xff, address & 0xff,
      0x00, 0x00,
    ]);

/// Antwort auf das Ruecklesen, das [writeRecordArea] zur Pruefung fährt.
Uint8List _readResponse(int address, List<int> data) => _frame([
      8 + data.length,
      0x81, 0x00,
      (address >> 8) & 0xff, address & 0xff,
      data.length,
      ...data,
      0x00,
    ]);

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
  final slot1 = Hem6232tDevice.userStartAddresses[0];
  final slot2 = Hem6232tDevice.userStartAddresses[1];
  const size = Hem6232tDevice.recordByteSize;
  final slot2Last = slot2 + (Hem6232tDevice.recordsPerUser - 1) * size;

  group('assertInsideRecordArea', () {
    test('laesst den ersten Record von Slot 1 zu', () {
      expect(() => assertInsideRecordArea(slot1, size), returnsNormally);
    });

    test('laesst den letzten Record von Slot 2 zu', () {
      expect(() => assertInsideRecordArea(slot2Last, size), returnsNormally);
    });

    test('wirft eine Adresse vor dem Record-Bereich zurueck', () {
      // 0x02a4 ist der Settings-Schreibbereich - dort liegen vermutlich
      // Kalibrierdaten, ein Schreibvorgang dorthin ist verboten.
      expect(
        () => assertInsideRecordArea(0x02a4, size),
        throwsA(isA<ProtocolException>()),
      );
    });

    test('wirft, wenn der Bereich hinten aus Slot 2 herauslaeuft', () {
      expect(
        () => assertInsideRecordArea(slot2Last + 1, size),
        throwsA(isA<ProtocolException>()),
      );
    });

    test('wirft, wenn ein Bereich die Luecke zwischen den Slots ueberspannt',
        () {
      final slot1Last = slot1 + (Hem6232tDevice.recordsPerUser - 1) * size;
      // Slot 1 endet genau dort, wo Slot 2 beginnt; ein Bereich darf
      // trotzdem nicht ueber die Slot-Grenze hinweggehen.
      expect(
        () => assertInsideRecordArea(slot1Last, size * 2),
        throwsA(isA<ProtocolException>()),
      );
    });
  });

  group('EepromWriter.writeRecordArea', () {
    test('schreibt einen 14-Byte-Record in einem Befehl und prueft nach',
        () async {
      // 14 Nutzbytes passen in einen Rahmen (22 Bytes), seit die
      // Hoechstmenge bei 16 liegt. Danach liest die Methode zurueck.
      final written = List.filled(size, 0xff);
      final transport = _ScriptedTransport([
        _writeAck(slot2Last),
        _readResponse(slot2Last, written),
      ]);

      await EepromWriter(transport).writeRecordArea(
        startAddress: slot2Last,
        data: Uint8List.fromList(written),
      );

      // Ein Schreibbefehl plus ein Lesebefehl zur Kontrolle.
      expect(transport.sent.length, 2);
      expect(transport.sent[0][5], size);
      expect(transport.responses, isEmpty);
    });

    test('wirft, wenn das Geraet quittiert aber nichts geschrieben hat',
        () async {
      // Genau der Fall am echten Geraet: 81c0 kommt, der Speicher bleibt
      // unveraendert. Ohne Rueckleseprüfung waere das ein falscher Erfolg.
      final transport = _ScriptedTransport([
        _writeAck(slot2Last),
        _readResponse(slot2Last, List.filled(size, 0x00)),
      ]);

      await expectLater(
        EepromWriter(transport).writeRecordArea(
          startAddress: slot2Last,
          data: Uint8List.fromList(List.filled(size, 0xff)),
        ),
        throwsA(isA<ProtocolException>()),
      );
    });

    test('zerlegt einen laengeren Bereich in Bloecke zu 16 Bytes', () async {
      final written = List.filled(size * 2, 0xff);
      final transport = _ScriptedTransport([
        _writeAck(slot2),
        _writeAck(slot2 + maxWriteDataLength),
        _readResponse(slot2, written),
      ]);

      await EepromWriter(transport).writeRecordArea(
        startAddress: slot2,
        data: Uint8List.fromList(written),
      );

      expect(transport.sent.length, 3);
      expect(transport.sent[0][5], maxWriteDataLength);
      expect(transport.sent[1][5], size * 2 - maxWriteDataLength);
    });

    test('wirft bei einem Antworttyp, der keine Schreibbestaetigung ist',
        () async {
      final transport = _ScriptedTransport([
        _frame([0x08, 0x81, 0x00, 0x08, 0x60, 0x00, 0x00]),
      ]);

      await expectLater(
        EepromWriter(transport).writeRecordArea(
          startAddress: slot2,
          data: Uint8List.fromList([0xff]),
        ),
        throwsA(isA<ProtocolException>()),
      );
    });

    test('wirft, wenn das Geraet eine andere Adresse bestaetigt', () async {
      final transport = _ScriptedTransport([_writeAck(slot2 + 2)]);

      await expectLater(
        EepromWriter(transport).writeRecordArea(
          startAddress: slot2,
          data: Uint8List.fromList([0xff]),
        ),
        throwsA(isA<ProtocolException>()),
      );
    });

    test('schreibt nichts, wenn die Zieladresse ausserhalb liegt', () async {
      final transport = _ScriptedTransport([]);

      await expectLater(
        EepromWriter(transport).writeRecordArea(
          startAddress: 0x02a4,
          data: Uint8List.fromList([0xff]),
        ),
        throwsA(isA<ProtocolException>()),
      );
      expect(transport.sent, isEmpty);
    });
  });

  group('emptyRecordBytes', () {
    test('ist der Leer-Sentinel des Geraets: 14 x 0xFF', () {
      expect(emptyRecordBytes.length, Hem6232tDevice.recordByteSize);
      expect(emptyRecordBytes.every((b) => b == 0xff), isTrue);
    });
  });
}
