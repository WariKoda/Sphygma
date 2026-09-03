// Schmales Interface zwischen Protokoll- und BLE-Transportschicht.
// Bytes rein, Bytes raus - kennt keine BLE-Typen. Das haelt die
// Protokollschicht vollstaendig ohne Hardware testbar. Siehe CLAUDE.md
// "Zwei Entwurfsentscheidungen".
//
// Die konkrete Implementierung gegen flutter_blue_plus folgt in M3.
import 'dart:typed_data';

abstract class BleTransport {
  /// Schreibt ein Kommando-Frame. Fuer dieses Geraet passen alle
  /// Kommandos (<=8 Bytes) in einen einzelnen TX-Kanal.
  Future<void> writeCommand(Uint8List frame);

  /// Liefert das naechste vollstaendig reassemblierte, aber gegenueber der
  /// Pruefsumme noch ungeprueft Antwort-Frame. Die Reassemblierung ueber
  /// mehrere RX-Kanaele (docs/protocol/hem-6232t.md §4) erledigt die
  /// konkrete Implementierung mittels ChannelReassembler.
  Future<Uint8List> readResponse();
}
