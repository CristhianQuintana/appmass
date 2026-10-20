import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const secureAuthStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(storageNamespace: 'mass_auth'),
);

/// Persistencia de sesión cifrada con el almacén del sistema.
class SecureLocalStorage extends LocalStorage {
  SecureLocalStorage({
    required this.persistSessionKey,
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? secureAuthStorage;

  final String persistSessionKey;
  final FlutterSecureStorage _storage;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() {
    return _storage.containsKey(key: persistSessionKey);
  }

  @override
  Future<String?> accessToken() {
    return _storage.read(key: persistSessionKey);
  }

  @override
  Future<void> removePersistedSession() {
    return _storage.delete(key: persistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _storage.write(key: persistSessionKey, value: persistSessionString);
  }
}

/// Guarda el verificador PKCE fuera de SharedPreferences.
class SecureGotrueStorage extends GotrueAsyncStorage {
  SecureGotrueStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? secureAuthStorage;

  final FlutterSecureStorage _storage;

  @override
  Future<String?> getItem({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> setItem({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> removeItem({required String key}) {
    return _storage.delete(key: key);
  }
}
