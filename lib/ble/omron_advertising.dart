// Erkennung des Geraets im BLE-Scan.
//
// Befund M1 (docs/protocol/hem-6232t.md §2.1): Das HEM-6232T bewirbt im
// Advertising nur den Standard-Service 0x1810, nicht den proprietaeren
// Parent-Service - ein Service-Filter findet es nie. Erkannt wird es am
// Namen: "BLEsmart_<id><mac>" im Pairing-Modus, "BLESmart_..." im
// Normalmodus (Gross-/Kleinschreibung des "s" unterscheidet den Modus).

const String _prefix = 'blesmart_';

bool isOmronAdvertisingName(String advertisedName) =>
    advertisedName.toLowerCase().startsWith(_prefix);

/// Firmenkennung Omron Healthcare, wie sie im Advertising steht und wie
/// flutter_blue_plus sie als Schluessel in
/// [AdvertisementData.manufacturerData] liefert.
const int omronManufacturerId = 0x020e;

/// Kuerzeste Herstellerdaten, die sich deuten lassen.
const int _minStatusLength = 8;

/// Gerätestand aus dem Advertising: hoechste Messungsnummer und
/// Platzzeiger je Benutzer-Slot.
///
/// Belegt am 2026-09-04 per Bluetooth-HCI-Mitschnitt und Differenzmessung
/// (docs/protocol/hem-6232t.md §2.1): Zwei Messungen liessen Nummer und
/// Platzzeiger um genau 2 steigen, und die Werte decken sich mit den aus
/// dem EEPROM gelesenen Zaehlern bei 0x0268 und 0x0260.
///
/// Aufbau der Nutzdaten hinter der Firmenkennung:
///
/// | Byte | Inhalt |
/// |---|---|
/// | 0–1 | unveraendert ueber alle Aufzeichnungen |
/// | 2–3 | hoechste Messungsnummer Slot 1, little-endian |
/// | 4 | Platzzeiger Slot 1 |
/// | 5–6 | hoechste Messungsnummer Slot 2, little-endian |
/// | 7 | Platzzeiger Slot 2 |
///
/// Der Wert ist ohne Verbindung zu haben - kein Entsperren, kein Lesen,
/// kein Schreiben ins Geraet.
class OmronAdvertisedStatus {
  const OmronAdvertisedStatus._(this._sequences, this._pointers);

  final List<int> _sequences;
  final List<int> _pointers;

  static int _slotIndex(int userSlot) {
    if (userSlot != 1 && userSlot != 2) {
      throw ArgumentError.value(userSlot, 'userSlot', 'muss 1 oder 2 sein');
    }
    return userSlot - 1;
  }

  /// Hoechste Messungsnummer, die das Geraet fuer [userSlot] kennt.
  int highestSequence(int userSlot) => _sequences[_slotIndex(userSlot)];

  /// Platz, auf den die naechste Messung dieses Slots geschrieben wird.
  int writePointer(int userSlot) => _pointers[_slotIndex(userSlot)];

  /// Ob [other] denselben Gerätestand beschreibt. Dient dazu, das
  /// staendig wiederholte Advertising auf echte Aenderungen zu
  /// reduzieren.
  bool sameAs(OmronAdvertisedStatus other) =>
      _sequences[0] == other._sequences[0] &&
      _sequences[1] == other._sequences[1] &&
      _pointers[0] == other._pointers[0] &&
      _pointers[1] == other._pointers[1];

  /// Ob das Geraet fuer [userSlot] Messungen hat, die ueber
  /// [knownSequence] hinausgehen. [knownSequence] ist der eigene
  /// Hoechststand, oder null, wenn noch nichts gespeichert ist.
  ///
  /// Ein **hoeherer** eigener Stand meldet bewusst nichts Neues: Das
  /// passiert nach einem Geraetetausch, und ungefragt zu synchronisieren
  /// waere dort falsch.
  bool hasNewMeasurements({required int userSlot, required int? knownSequence}) {
    final onDevice = highestSequence(userSlot);
    if (onDevice == 0) return false;
    return knownSequence == null || onDevice > knownSequence;
  }
}

/// Deutet die Omron-Herstellerdaten aus einem Advertising-Paket.
///
/// Gibt null zurueck, wenn kein Omron-Eintrag dabei ist oder er zu kurz
/// zum Deuten waere. Null heisst hier "keine Aussage moeglich" - das ist
/// ein echter Zustand, kein Fehler: Jeder Scan sieht fremde Geraete, und
/// das Omron selbst sendet nur nach Tastendruck oder Messung.
OmronAdvertisedStatus? parseOmronStatus(Map<int, List<int>> manufacturerData) {
  final bytes = manufacturerData[omronManufacturerId];
  if (bytes == null || bytes.length < _minStatusLength) {
    return null;
  }
  return OmronAdvertisedStatus._(
    [bytes[2] | (bytes[3] << 8), bytes[5] | (bytes[6] << 8)],
    [bytes[4], bytes[7]],
  );
}
