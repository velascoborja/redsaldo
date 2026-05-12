import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/token_models.dart';

abstract class SecureTokenBackend {
  Future<String?> read({required String key});

  Future<void> write({required String key, required String value});

  Future<void> delete({required String key});
}

class FlutterSecureTokenBackend implements SecureTokenBackend {
  const FlutterSecureTokenBackend([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);
}

class MemorySecureTokenBackend implements SecureTokenBackend {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read({required String key}) async => _values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }
}

class TokenStore {
  const TokenStore(this._backend);

  static const accessTokenKey = 'edenred.access_token';
  static const refreshTokenKey = 'edenred.refresh_token';
  static const expiresAtUtcKey = 'edenred.expires_at_utc';

  final SecureTokenBackend _backend;

  Future<TokenSession?> load() async {
    final accessToken = await _backend.read(key: accessTokenKey);
    final expiresAtValue = await _backend.read(key: expiresAtUtcKey);

    if (accessToken == null || accessToken.trim().isEmpty) {
      return null;
    }
    if (expiresAtValue == null || expiresAtValue.trim().isEmpty) {
      return null;
    }

    final expiresAt = DateTime.tryParse(expiresAtValue);
    if (expiresAt == null) {
      return null;
    }

    final refreshToken = await _backend.read(key: refreshTokenKey);

    return TokenSession(
      accessToken: accessToken,
      refreshToken: _emptyToNull(refreshToken),
      expiresAtUtc: expiresAt.toUtc(),
    );
  }

  Future<void> save(TokenSession session) async {
    await _backend.write(key: accessTokenKey, value: session.accessToken);
    await _backend.write(
      key: expiresAtUtcKey,
      value: session.expiresAtUtc.toUtc().toIso8601String(),
    );

    final refreshToken = _emptyToNull(session.refreshToken);
    if (refreshToken == null) {
      await _backend.delete(key: refreshTokenKey);
    } else {
      await _backend.write(key: refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> clear() async {
    await _backend.delete(key: accessTokenKey);
    await _backend.delete(key: refreshTokenKey);
    await _backend.delete(key: expiresAtUtcKey);
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
