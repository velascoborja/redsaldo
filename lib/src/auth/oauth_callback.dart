import '../config/edenred_config.dart';

class OAuthCallback {
  const OAuthCallback({required this.code, required this.state});

  final String code;
  final String state;

  static final RegExp _embeddedCallbackPattern = RegExp(
    r'''myedenredspain://oauth-callback\?[^'"\s]+''',
    caseSensitive: false,
  );

  static OAuthCallback parse(String input, String expectedState) {
    final rawInput = input.trim();
    final trimmedExpectedState = expectedState.trim();

    if (rawInput.isEmpty) {
      throw const OAuthCallbackException('Paste the Edenred callback URL.');
    }
    if (trimmedExpectedState.isEmpty) {
      throw const OAuthCallbackException('Expected state is required.');
    }

    final match = _embeddedCallbackPattern.firstMatch(rawInput);
    final callbackInput = match?.group(0) ?? rawInput;
    final uri = Uri.tryParse(callbackInput);

    if (uri == null ||
        uri.scheme != EdenredConfig.redirectScheme ||
        uri.host != EdenredConfig.redirectHost) {
      throw const OAuthCallbackException(
        'The callback URL must use the Edenred redirect URI.',
      );
    }

    final code = uri.queryParameters['code']?.trim() ?? '';
    if (code.isEmpty) {
      throw const OAuthCallbackException(
        'The callback URL does not contain an authorization code.',
      );
    }

    final state = uri.queryParameters['state']?.trim() ?? '';
    if (state.isEmpty) {
      throw const OAuthCallbackException(
        'The callback URL does not contain a state value.',
      );
    }
    if (state != trimmedExpectedState) {
      throw const OAuthCallbackException(
        'The callback state does not match the expected state.',
      );
    }

    return OAuthCallback(code: code, state: state);
  }
}

class OAuthCallbackException implements Exception {
  const OAuthCallbackException(this.message);

  final String message;

  @override
  String toString() => 'OAuthCallbackException: $message';
}
