import 'dart:async';
import 'dart:convert';

import 'package:edenred_55_app/src/auth/auth_service.dart';
import 'package:edenred_55_app/src/auth/token_models.dart';
import 'package:edenred_55_app/src/auth/token_store.dart';
import 'package:edenred_55_app/src/config/edenred_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('EdenredAuthService', () {
    test('exchanges authorization code with Edenred form fields', () async {
      final now = DateTime.utc(2026, 5, 11, 10);
      final client = RecordingTokenClient(
        (request) => http.Response(
          jsonEncode({
            'access_token': 'access-123',
            'refresh_token': 'refresh-456',
            'expires_in': 3600,
            'token_type': 'Bearer',
          }),
          200,
          headers: {'content-type': 'application/json'},
        ),
      );
      final store = TokenStore(MemorySecureTokenBackend());
      final service = EdenredAuthService(client, store, now: () => now);

      final session = await service.exchangeCode(
        code: 'code-123',
        verifier: 'verifier-456',
      );

      expect(client.requests, hasLength(1));
      final request = client.requests.single;
      expect(request.url, Uri.parse('https://sso.eu.edenred.io/connect/token'));
      expect(request.method, 'POST');
      expect(
        request.headers['content-type'],
        startsWith('application/x-www-form-urlencoded'),
      );
      expect(request.bodyFields, {
        'code': 'code-123',
        'client_id': EdenredConfig.clientId,
        'client_secret': '',
        'redirect_uri': EdenredConfig.redirectUri,
        'grant_type': 'authorization_code',
        'code_verifier': 'verifier-456',
      });
      expect(session.accessToken, 'access-123');
      expect(session.refreshToken, 'refresh-456');
      expect(session.expiresAtUtc, now.add(const Duration(seconds: 3480)));

      final saved = await store.load();
      expect(saved, isNotNull);
      expect(saved!.accessToken, 'access-123');
      expect(saved.refreshToken, 'refresh-456');
    });

    test('refreshes token with Edenred refresh form fields', () async {
      final now = DateTime.utc(2026, 5, 11, 10);
      final client = RecordingTokenClient(
        (request) => http.Response(
          jsonEncode({
            'access_token': 'access-new',
            'refresh_token': 'refresh-new',
            'expires_in': 1800,
          }),
          200,
        ),
      );
      final store = TokenStore(MemorySecureTokenBackend());
      final service = EdenredAuthService(client, store, now: () => now);

      final session = await service.refresh(refreshToken: 'refresh-old');

      expect(client.requests, hasLength(1));
      expect(client.requests.single.bodyFields, {
        'scope': EdenredConfig.refreshScope,
        'client_id': EdenredConfig.clientId,
        'refresh_token': 'refresh-old',
        'grant_type': 'refresh_token',
      });
      expect(session.accessToken, 'access-new');

      final saved = await store.load();
      expect(saved, isNotNull);
      expect(saved!.accessToken, 'access-new');
      expect(saved.refreshToken, 'refresh-new');
    });

    test(
      'preserves existing refresh token when refresh response omits it',
      () async {
        final now = DateTime.utc(2026, 5, 11, 10);
        final client = RecordingTokenClient(
          (request) => http.Response(
            jsonEncode({'access_token': 'access-new', 'expires_in': 1800}),
            200,
          ),
        );
        final store = TokenStore(MemorySecureTokenBackend());
        final service = EdenredAuthService(client, store, now: () => now);

        final session = await service.refresh(refreshToken: 'refresh-old');

        expect(session.accessToken, 'access-new');
        expect(session.refreshToken, 'refresh-old');

        final saved = await store.load();
        expect(saved, isNotNull);
        expect(saved!.accessToken, 'access-new');
        expect(saved.refreshToken, 'refresh-old');
      },
    );

    test('uses sanitized message for malformed token JSON', () async {
      final client = RecordingTokenClient(
        (request) => http.Response('{not-json', 200),
      );
      final store = TokenStore(MemorySecureTokenBackend());
      final service = EdenredAuthService(client, store);

      final exception = await _captureAuthException(
        service.exchangeCode(code: 'code-123', verifier: 'verifier-456'),
      );

      expect(exception.message, 'Edenred token response could not be parsed.');
      expect(exception.toString(), isNot(contains('FormatException')));
      expect(exception.toString(), isNot(contains('{not-json')));
    });

    test('returns stored access token when session is still valid', () async {
      final client = RecordingTokenClient(
        (request) => fail('client should not be called for valid session'),
      );
      final store = TokenStore(MemorySecureTokenBackend());
      final now = DateTime.utc(2026, 5, 11, 10);
      await store.save(
        TokenSession(
          accessToken: 'access-valid',
          refreshToken: 'refresh-123',
          expiresAtUtc: now.add(const Duration(minutes: 5)),
        ),
      );
      final service = EdenredAuthService(client, store, now: () => now);

      final accessToken = await service.getValidAccessToken();

      expect(accessToken, 'access-valid');
      expect(client.requests, isEmpty);
    });

    test('refreshes expired session and returns new access token', () async {
      final now = DateTime.utc(2026, 5, 11, 10);
      final client = RecordingTokenClient(
        (request) => http.Response(
          jsonEncode({
            'access_token': 'access-refreshed',
            'refresh_token': 'refresh-new',
            'expires_in': 1200,
          }),
          200,
        ),
      );
      final store = TokenStore(MemorySecureTokenBackend());
      await store.save(
        TokenSession(
          accessToken: 'access-expired',
          refreshToken: 'refresh-old',
          expiresAtUtc: now,
        ),
      );
      final service = EdenredAuthService(client, store, now: () => now);

      final accessToken = await service.getValidAccessToken();

      expect(accessToken, 'access-refreshed');
      expect(client.requests.single.bodyFields['refresh_token'], 'refresh-old');
    });

    test(
      'logs out and throws when expired session has no refresh token',
      () async {
        final now = DateTime.utc(2026, 5, 11, 10);
        final client = RecordingTokenClient(
          (request) =>
              fail('client should not be called without refresh token'),
        );
        final store = TokenStore(MemorySecureTokenBackend());
        await store.save(
          TokenSession(accessToken: 'access-expired', expiresAtUtc: now),
        );
        final service = EdenredAuthService(client, store, now: () => now);

        await expectLater(
          service.getValidAccessToken(),
          throwsA(isA<AuthServiceException>()),
        );
        expect(await store.load(), isNull);
      },
    );

    test('uses sanitized message when refresh throws unexpectedly', () async {
      final now = DateTime.utc(2026, 5, 11, 10);
      final client = RecordingTokenClient(
        (request) => throw StateError('raw network failure details'),
      );
      final store = TokenStore(MemorySecureTokenBackend());
      await store.save(
        TokenSession(
          accessToken: 'access-expired',
          refreshToken: 'refresh-old',
          expiresAtUtc: now,
        ),
      );
      final service = EdenredAuthService(client, store, now: () => now);

      final exception = await _captureAuthException(
        service.getValidAccessToken(),
      );

      expect(exception.message, 'Edenred session refresh failed.');
      expect(exception.toString(), isNot(contains('StateError')));
      expect(exception.toString(), isNot(contains('raw network')));
      expect(await store.load(), isNull);
    });

    test('logs out and throws when refresh request fails', () async {
      final now = DateTime.utc(2026, 5, 11, 10);
      final client = RecordingTokenClient(
        (request) => http.Response('invalid_grant', 400),
      );
      final store = TokenStore(MemorySecureTokenBackend());
      await store.save(
        TokenSession(
          accessToken: 'access-expired',
          refreshToken: 'refresh-old',
          expiresAtUtc: now,
        ),
      );
      final service = EdenredAuthService(client, store, now: () => now);

      await expectLater(
        service.getValidAccessToken(),
        throwsA(isA<AuthServiceException>()),
      );
      expect(await store.load(), isNull);
    });
  });
}

Future<AuthServiceException> _captureAuthException(
  Future<Object?> future,
) async {
  try {
    await future;
  } on AuthServiceException catch (error) {
    return error;
  }

  fail('Expected AuthServiceException.');
}

class RecordingTokenClient extends http.BaseClient {
  RecordingTokenClient(this._handler);

  final FutureOr<http.Response> Function(http.Request request) _handler;
  final List<http.Request> requests = <http.Request>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final captured = request as http.Request;
    requests.add(captured);

    final response = await _handler(captured);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      contentLength: response.contentLength,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      request: captured,
    );
  }
}
