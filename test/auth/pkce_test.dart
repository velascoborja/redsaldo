import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:edenred_55_app/src/data/services/pkce.dart';
import 'package:edenred_55_app/src/config/edenred_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EdenredConfig', () {
    test('defines android platform', () {
      expect(EdenredConfig.platform, 'android');
    });
  });

  group('PkcePair', () {
    test('generate returns URL-safe verifier and matching S256 challenge', () {
      final pair = PkcePair.generate();
      final expectedChallenge = base64Url
          .encode(sha256.convert(ascii.encode(pair.verifier)).bytes)
          .replaceAll('=', '');

      expect(pair.verifier, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
      expect(pair.challenge, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
      expect(pair.verifier, isNot(contains('=')));
      expect(pair.challenge, isNot(contains('=')));
      expect(pair.challenge, expectedChallenge);
    });

    test('createState returns UUID-like lowercase hex string', () {
      final state = PkcePair.createState();

      expect(
        state,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(state, state.toLowerCase());
    });

    test('buildAuthorizeUrl includes Edenred production OAuth parameters', () {
      final uri = Uri.parse(
        PkcePair.buildAuthorizeUrl('abc-state', 'challenge-value'),
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'sso.eu.edenred.io');
      expect(uri.path, '/connect/authorize');
      expect(uri.queryParameters['response_type'], 'code');
      expect(
        uri.queryParameters['client_id'],
        '64e8f810218f423da70866c1bd663dfd',
      );
      expect(
        uri.queryParameters['scope'],
        'openid email profile offline_access eres-user-api autoconnect',
      );
      expect(uri.queryParameters['prompt'], 'login');
      expect(uri.queryParameters['display'], 'wap');
      expect(
        uri.queryParameters['redirect_uri'],
        'myedenredspain://oauth-callback',
      );
      expect(uri.queryParameters['state'], 'abc-state');
      expect(uri.queryParameters['nonce'], 'abc-state');
      expect(uri.queryParameters['acr_values'], 'tenant:es-ben');
      expect(uri.queryParameters['ui_locales'], 'es-ES');
      expect(uri.queryParameters['code_challenge'], 'challenge-value');
      expect(uri.queryParameters['code_challenge_method'], 'S256');
    });
  });
}
