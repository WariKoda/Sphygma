// Ablage des Pairing-Keys. Entscheidung (PLAN.md §1): ein Zufallskey je
// Installation. Der Key steckt danach auch im Geraet; geht er verloren,
// ist ein Neu-Pairing noetig (Risiko R-4).
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const int pairingKeyLength = 16;

abstract class PairingKeyStore {
  /// Der gespeicherte Key oder null, wenn noch keiner existiert. Null ist
  /// hier ein echter Zustand ("noch nie gepairt"), kein Ersatzwert.
  Future<Uint8List?> load();

  Future<void> save(Uint8List key);

  /// Liefert den gespeicherten Key oder erzeugt und speichert einen neuen.
  Future<Uint8List> loadOrCreate() async {
    final existing = await load();
    if (existing != null) {
      return existing;
    }
    final key = generatePairingKey();
    await save(key);
    return key;
  }
}

Uint8List generatePairingKey() {
  final random = Random.secure();
  return Uint8List.fromList(
    List.generate(pairingKeyLength, (_) => random.nextInt(256)),
  );
}

String pairingKeyToHex(Uint8List key) =>
    key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Uint8List pairingKeyFromHex(String hex) {
  if (hex.length != pairingKeyLength * 2) {
    throw FormatException(
      'Pairing-Key muss ${pairingKeyLength * 2} Hex-Zeichen haben, '
      'hat ${hex.length}',
    );
  }
  return Uint8List.fromList([
    for (var i = 0; i < hex.length; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16),
  ]);
}

/// Fuer Tests und den Spike: haelt den Key nur im Speicher.
class InMemoryPairingKeyStore extends PairingKeyStore {
  Uint8List? _key;

  @override
  Future<Uint8List?> load() async => _key;

  @override
  Future<void> save(Uint8List key) async {
    _key = Uint8List.fromList(key);
  }
}

/// Produktion: Android Keystore ueber flutter_secure_storage.
class SecureStoragePairingKeyStore extends PairingKeyStore {
  SecureStoragePairingKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _storageKey = 'omron_pairing_key';
  final FlutterSecureStorage _storage;

  @override
  Future<Uint8List?> load() async {
    final hex = await _storage.read(key: _storageKey);
    return hex == null ? null : pairingKeyFromHex(hex);
  }

  @override
  Future<void> save(Uint8List key) =>
      _storage.write(key: _storageKey, value: pairingKeyToHex(key));
}
