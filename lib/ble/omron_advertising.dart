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
