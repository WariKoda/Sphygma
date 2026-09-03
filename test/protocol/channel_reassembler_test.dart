// Spezifikation: docs/protocol/hem-6232t.md §4.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphygma/protocol/channel_reassembler.dart';

void main() {
  group('ChannelReassembler', () {
    test('ein Paket, das in einen Kanal passt, ist sofort vollstaendig', () {
      final reassembler = ChannelReassembler();
      // Byte 0 = Gesamtlaenge 10; ceil(10/16) = 1 Kanal noetig.
      final channel0 = Uint8List.fromList([
        10, 1, 2, 3, 4, 5, 6, 7, 8, 9, //
        99, 99, 99, 99, 99, 99, // ueberschuessige Fuellbytes, werden gekappt
      ]);

      final result = reassembler.receive(0, channel0);

      expect(result, Uint8List.fromList([10, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
    });

    test('ein Paket ueber 2 Kanaele ist erst nach dem zweiten vollstaendig',
        () {
      final reassembler = ChannelReassembler();
      // Byte 0 = Gesamtlaenge 20; ceil(20/16) = 2 Kanaele noetig.
      final channel0 = Uint8List.fromList(
        [20, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      );
      final channel1 = Uint8List.fromList(
        [16, 17, 18, 19, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99],
      );

      final afterFirst = reassembler.receive(0, channel0);
      expect(afterFirst, isNull);

      final afterSecond = reassembler.receive(1, channel1);
      expect(
        afterSecond,
        Uint8List.fromList([
          20, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, //
          16, 17, 18, 19,
        ]),
      );
    });

    test('Kanaele duerfen ausser der Reihe eintreffen', () {
      final reassembler = ChannelReassembler();
      final channel0 = Uint8List.fromList(
        [20, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      );
      final channel1 = Uint8List.fromList(
        [16, 17, 18, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      );

      // Kanal 1 trifft zuerst ein - die Gesamtlaenge steht noch nicht fest.
      expect(reassembler.receive(1, channel1), isNull);
      expect(
        reassembler.receive(0, channel0),
        Uint8List.fromList([
          20, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, //
          16, 17, 18, 19,
        ]),
      );
    });

    test('nach Vollendung beginnt das naechste Paket mit leeren Puffern', () {
      final reassembler = ChannelReassembler();
      final first = Uint8List.fromList(
        [5, 1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      );
      reassembler.receive(0, first);

      // Zweites Paket, kleiner als das erste - darf keine Altbytes sehen.
      final second = Uint8List.fromList(
        [3, 9, 8, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      );

      expect(reassembler.receive(0, second), Uint8List.fromList([3, 9, 8]));
    });
  });
}
