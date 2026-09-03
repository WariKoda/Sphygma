// Reassembliert ein Antwort-Frame aus mehreren parallelen Notify-Kanaelen.
// Spezifikation: docs/protocol/hem-6232t.md §4.
//
// Prueft absichtlich KEINE Pruefsumme - das ist Aufgabe von
// parseResponseFrame (frame.dart). Dieses Modul kennt nur die
// Kanalgeometrie, nicht das Frame-Format.
import 'dart:typed_data';

const int _channelWidth = 16;
const int _channelCount = 4;

class ChannelReassembler {
  final List<Uint8List?> _buffers = List<Uint8List?>.filled(_channelCount, null);

  /// Nimmt das Paket eines Kanals entgegen. Liefert das vollstaendig
  /// reassemblierte, auf die Gesamtlaenge gekappte Frame zurueck, sobald
  /// alle benoetigten Kanaele eingetroffen sind - sonst null.
  Uint8List? receive(int channelIndex, Uint8List packet) {
    _buffers[channelIndex] = packet;

    final channel0 = _buffers[0];
    if (channel0 == null) {
      // Ohne Kanal 0 ist die Gesamtlaenge unbekannt.
      return null;
    }

    final totalLength = channel0[0];
    final requiredChannels = (totalLength + _channelWidth - 1) ~/ _channelWidth;

    for (var i = 0; i < requiredChannels; i++) {
      if (_buffers[i] == null) {
        return null;
      }
    }

    final combined = BytesBuilder();
    for (var i = 0; i < requiredChannels; i++) {
      combined.add(_buffers[i]!);
    }
    final result = combined.toBytes().sublist(0, totalLength);

    _buffers.fillRange(0, _channelCount, null);
    return result;
  }
}
