import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A secure storage helper that uses iOS Keychain and Android Keystore (EncryptedSharedPreferences)
/// to encrypt and save sensitive data like API keys locally.
class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();


  /// Saves a value securely with a given key
  static Future<void> save(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // In case of a corrupted Android Keystore (e.g. app restore), attempt to delete and rewrite
      try {
        await _storage.delete(key: key);
        await _storage.write(key: key, value: value);
      } catch (_) {}
    }
  }

  /// Reads a secure value. Returns null if key doesn't exist or on error.
  static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  /// Deletes a key from secure storage
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  /// Clears all secure storage entries
  static Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
