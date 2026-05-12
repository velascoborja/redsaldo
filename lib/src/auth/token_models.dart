import 'dart:math';

class TokenResponse {
  const TokenResponse({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final String tokenType;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    final accessToken = _optionalTrimmedString(json['access_token']) ?? '';
    if (accessToken.isEmpty) {
      throw const TokenResponseException(
        'Token response is missing access_token.',
      );
    }

    return TokenResponse(
      accessToken: accessToken,
      refreshToken: _optionalTrimmedString(json['refresh_token']),
      expiresIn: _parseExpiresIn(json['expires_in']),
      tokenType: _optionalTrimmedString(json['token_type']) ?? 'Bearer',
    );
  }

  static String? _optionalTrimmedString(Object? value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int _parseExpiresIn(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }
}

class TokenSession {
  TokenSession({
    required this.accessToken,
    this.refreshToken,
    required DateTime expiresAtUtc,
  }) : expiresAtUtc = expiresAtUtc.isUtc ? expiresAtUtc : expiresAtUtc.toUtc();

  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAtUtc;

  factory TokenSession.fromTokenResponse(
    TokenResponse response, {
    required DateTime now,
  }) {
    final bufferedSeconds = max(response.expiresIn - 120, 0);

    return TokenSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiresAtUtc: now.toUtc().add(Duration(seconds: bufferedSeconds)),
    );
  }

  bool isExpired(DateTime now) => !expiresAtUtc.isAfter(now.toUtc());
}

class TokenResponseException implements Exception {
  const TokenResponseException(this.message);

  final String message;

  @override
  String toString() => 'TokenResponseException: $message';
}
