import 'package:edenred_55_app/src/auth/oauth_callback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OAuthCallback.parse', () {
    test('extracts code and state from custom scheme callback URL', () {
      final callback = OAuthCallback.parse(
        'myedenredspain://oauth-callback?code=abc123&state=state456',
        'state456',
      );

      expect(callback.code, 'abc123');
      expect(callback.state, 'state456');
    });

    test('extracts callback URL embedded in browser error text', () {
      final callback = OAuthCallback.parse(
        "Failed to launch 'myedenredspain://oauth-callback?code=abc123&state=state456&scope=openid%20email' because the scheme does not have a registered handler.",
        'state456',
      );

      expect(callback.code, 'abc123');
      expect(callback.state, 'state456');
    });

    test('rejects invalid callback scheme', () {
      expect(
        () => OAuthCallback.parse(
          'https://oauth-callback?code=abc123&state=state456',
          'state456',
        ),
        throwsA(isA<OAuthCallbackException>()),
      );
    });

    test('rejects invalid callback host', () {
      expect(
        () => OAuthCallback.parse(
          'myedenredspain://other-host?code=abc123&state=state456',
          'state456',
        ),
        throwsA(isA<OAuthCallbackException>()),
      );
    });

    test('rejects missing authorization code', () {
      expect(
        () => OAuthCallback.parse(
          'myedenredspain://oauth-callback?state=state456',
          'state456',
        ),
        throwsA(isA<OAuthCallbackException>()),
      );
    });

    test('rejects missing state', () {
      expect(
        () => OAuthCallback.parse(
          'myedenredspain://oauth-callback?code=abc123',
          'state456',
        ),
        throwsA(isA<OAuthCallbackException>()),
      );
    });

    test('rejects unexpected state', () {
      expect(
        () => OAuthCallback.parse(
          'myedenredspain://oauth-callback?code=abc123&state=wrong-state',
          'state456',
        ),
        throwsA(isA<OAuthCallbackException>()),
      );
    });

    test('rejects blank input', () {
      expect(
        () => OAuthCallback.parse('   ', 'state456'),
        throwsA(isA<OAuthCallbackException>()),
      );
    });
  });
}
