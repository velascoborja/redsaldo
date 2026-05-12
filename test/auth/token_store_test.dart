import 'package:edenred_55_app/src/auth/token_models.dart';
import 'package:edenred_55_app/src/auth/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TokenResponse', () {
    test('parses token JSON with defaults', () {
      final response = TokenResponse.fromJson({'access_token': 'access-123'});

      expect(response.accessToken, 'access-123');
      expect(response.refreshToken, isNull);
      expect(response.expiresIn, 0);
      expect(response.tokenType, 'Bearer');
    });

    test('rejects missing access token', () {
      expect(
        () => TokenResponse.fromJson({'expires_in': 3600}),
        throwsA(isA<TokenResponseException>()),
      );
    });
  });

  group('TokenSession', () {
    test(
      'applies 120 second expiry buffer when created from token response',
      () {
        final now = DateTime.utc(2026, 5, 11, 10);
        final response = TokenResponse.fromJson({
          'access_token': 'access-123',
          'refresh_token': 'refresh-456',
          'expires_in': 300,
        });

        final session = TokenSession.fromTokenResponse(response, now: now);

        expect(session.accessToken, 'access-123');
        expect(session.refreshToken, 'refresh-456');
        expect(session.expiresAtUtc, now.add(const Duration(seconds: 180)));
        expect(
          session.isExpired(now.add(const Duration(seconds: 179))),
          isFalse,
        );
        expect(
          session.isExpired(now.add(const Duration(seconds: 180))),
          isTrue,
        );
      },
    );

    test(
      'does not move expiry before now when token lifetime is below buffer',
      () {
        final now = DateTime.utc(2026, 5, 11, 10);
        final response = TokenResponse.fromJson({
          'access_token': 'access-123',
          'expires_in': 60,
        });

        final session = TokenSession.fromTokenResponse(response, now: now);

        expect(session.expiresAtUtc, now);
        expect(session.isExpired(now), isTrue);
      },
    );
  });

  group('TokenStore', () {
    test('saves and loads token session', () async {
      final store = TokenStore(MemorySecureTokenBackend());
      final expiresAt = DateTime.utc(2026, 5, 11, 10, 30);
      final session = TokenSession(
        accessToken: 'access-123',
        refreshToken: 'refresh-456',
        expiresAtUtc: expiresAt,
      );

      await store.save(session);

      final loaded = await store.load();
      expect(loaded, isNotNull);
      expect(loaded!.accessToken, 'access-123');
      expect(loaded.refreshToken, 'refresh-456');
      expect(loaded.expiresAtUtc, expiresAt);
    });

    test('deletes stored refresh token when saved session has none', () async {
      final backend = MemorySecureTokenBackend();
      final store = TokenStore(backend);

      await store.save(
        TokenSession(
          accessToken: 'access-123',
          refreshToken: 'refresh-456',
          expiresAtUtc: DateTime.utc(2026, 5, 11, 10, 30),
        ),
      );
      await store.save(
        TokenSession(
          accessToken: 'access-789',
          expiresAtUtc: DateTime.utc(2026, 5, 11, 11),
        ),
      );

      final loaded = await store.load();
      expect(loaded, isNotNull);
      expect(loaded!.accessToken, 'access-789');
      expect(loaded.refreshToken, isNull);
    });

    test('loads null when access token or expiry is missing', () async {
      final backend = MemorySecureTokenBackend();
      final store = TokenStore(backend);

      await backend.write(key: TokenStore.accessTokenKey, value: 'access-123');
      expect(await store.load(), isNull);

      await backend.delete(key: TokenStore.accessTokenKey);
      await backend.write(
        key: TokenStore.expiresAtUtcKey,
        value: DateTime.utc(2026, 5, 11, 10, 30).toIso8601String(),
      );
      expect(await store.load(), isNull);
    });

    test('clears all stored token values', () async {
      final backend = MemorySecureTokenBackend();
      final store = TokenStore(backend);

      await store.save(
        TokenSession(
          accessToken: 'access-123',
          refreshToken: 'refresh-456',
          expiresAtUtc: DateTime.utc(2026, 5, 11, 10, 30),
        ),
      );

      await store.clear();

      expect(await backend.read(key: TokenStore.accessTokenKey), isNull);
      expect(await backend.read(key: TokenStore.refreshTokenKey), isNull);
      expect(await backend.read(key: TokenStore.expiresAtUtcKey), isNull);
      expect(await store.load(), isNull);
    });
  });
}
