// Geraetekonstanten fuer den Omron HEM-6232T (RS7 Intelli IT).
// Spezifikation: docs/protocol/hem-6232t.md §1-2. Aus omblepy und UBPM
// gegenseitig bestaetigt (siehe dort, Spalte "Quelle").
class Hem6232tDevice {
  static const String parentServiceUuid = 'ecbe3980-c9a2-11e1-b1bd-0002a5d5c51b';
  static const String unlockCharacteristicUuid = 'b305b680-aee7-11e1-a730-0002a5d5c51b';

  static const List<String> txCharacteristicUuids = [
    'db5b55e0-aee7-11e1-965e-0002a5d5c51b',
    'e0b8a060-aee7-11e1-92f4-0002a5d5c51b',
    '0ae12b00-aee8-11e1-a192-0002a5d5c51b',
    '10e1ba60-aee8-11e1-89e5-0002a5d5c51b',
  ];

  static const List<String> rxCharacteristicUuids = [
    '49123040-aee8-11e1-a74d-0002a5d5c51b',
    '4d0bf320-aee8-11e1-a0d9-0002a5d5c51b',
    '5128ce60-aee8-11e1-b84b-0002a5d5c51b',
    '560f1420-aee8-11e1-8184-0002a5d5c51b',
  ];

  /// EEPROM-Startadressen je User-Slot.
  static const List<int> userStartAddresses = [0x02e8, 0x0860];
  static const int recordsPerUser = 100;
  static const int recordByteSize = 14;
  static const int transmissionBlockSize = 0x38;
}
