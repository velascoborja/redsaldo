import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/edenred_config.dart';
import '../state/app_gateways.dart';
import 'token_models.dart';
import 'token_store.dart';

class EdenredAuthService implements AppAuthGateway {
  EdenredAuthService(this._client, this._tokenStore, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static final Uri _tokenUri = Uri.parse(
    '${EdenredConfig.ssoBaseUrl}${EdenredConfig.tokenPath}',
  );

  final http.Client _client;
  final TokenStore _tokenStore;
  final DateTime Function() _now;

  @override
  Future<TokenSession?> loadSession() => _tokenStore.load();

  Future<TokenSession> exchangeCode({
    required String code,
    required String verifier,
  }) {
    return _requestSession(<String, String>{
      'code': code,
      'client_id': EdenredConfig.clientId,
      'client_secret': '',
      'redirect_uri': EdenredConfig.redirectUri,
      'grant_type': 'authorization_code',
      'code_verifier': verifier,
    });
  }

  Future<TokenSession> refresh({required String refreshToken}) {
    return _requestSession(<String, String>{
      'scope': EdenredConfig.refreshScope,
      'client_id': EdenredConfig.clientId,
      'refresh_token': refreshToken,
      'grant_type': 'refresh_token',
    }, fallbackRefreshToken: refreshToken);
  }

  @override
  Future<String> getValidAccessToken() async {
    final session = await loadSession();
    if (session == null) {
      await logout();
      throw const AuthServiceException('No stored session.');
    }

    if (!session.isExpired(_now())) {
      return session.accessToken;
    }

    final refreshToken = _trimmedOrNull(session.refreshToken);
    if (refreshToken == null) {
      await logout();
      throw const AuthServiceException('Stored session has no refresh token.');
    }

    try {
      final refreshed = await refresh(refreshToken: refreshToken);
      return refreshed.accessToken;
    } on AuthServiceException {
      await logout();
      rethrow;
    } catch (_) {
      await logout();
      throw const AuthServiceException('Edenred session refresh failed.');
    }
  }

  @override
  Future<void> logout() => _tokenStore.clear();

  Future<TokenSession> _requestSession(
    Map<String, String> fields, {
    String? fallbackRefreshToken,
  }) async {
    final response = await _postToken(fields);
    final session = TokenSession.fromTokenResponse(
      _withFallbackRefreshToken(response, fallbackRefreshToken),
      now: _now().toUtc(),
    );
    await _tokenStore.save(session);

    return session;
  }

  Future<TokenResponse> _postToken(Map<String, String> fields) async {
    final response = await _client.post(
      _tokenUri,
      headers: const <String, String>{
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: fields,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthServiceException(
        'Token request failed with status ${response.statusCode}.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const AuthServiceException(
        'Edenred token response could not be parsed.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AuthServiceException(
        'Edenred token response could not be parsed.',
      );
    }

    try {
      return TokenResponse.fromJson(decoded);
    } on TokenResponseException {
      throw const AuthServiceException(
        'Edenred token response could not be parsed.',
      );
    }
  }

  static TokenResponse _withFallbackRefreshToken(
    TokenResponse response,
    String? fallbackRefreshToken,
  ) {
    final refreshToken =
        response.refreshToken ?? _trimmedOrNull(fallbackRefreshToken);
    if (refreshToken == response.refreshToken) {
      return response;
    }

    return TokenResponse(
      accessToken: response.accessToken,
      refreshToken: refreshToken,
      expiresIn: response.expiresIn,
      tokenType: response.tokenType,
    );
  }

  static String? _trimmedOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);

  final String message;

  @override
  String toString() => 'AuthServiceException: $message';
}
