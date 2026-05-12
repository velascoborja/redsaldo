import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../config/edenred_config.dart';

class PkcePair {
  const PkcePair({required this.verifier, required this.challenge});

  final String verifier;
  final String challenge;

  static const challengeMethod = 'S256';

  static PkcePair generate() {
    final verifier = _base64UrlNoPadding(_secureBytes(32));
    final challenge = _base64UrlNoPadding(
      sha256.convert(ascii.encode(verifier)).bytes,
    );

    return PkcePair(verifier: verifier, challenge: challenge);
  }

  static String createState() {
    final bytes = _secureBytes(16);

    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));

    return [
      hex.take(4).join(),
      hex.skip(4).take(2).join(),
      hex.skip(6).take(2).join(),
      hex.skip(8).take(2).join(),
      hex.skip(10).join(),
    ].join('-');
  }

  static String buildAuthorizeUrl(String state, String challenge) {
    return Uri.parse(
          '${EdenredConfig.ssoBaseUrl}${EdenredConfig.authorizePath}',
        )
        .replace(
          queryParameters: {
            'response_type': 'code',
            'client_id': EdenredConfig.clientId,
            'scope': EdenredConfig.loginScope,
            'prompt': 'login',
            'display': 'wap',
            'redirect_uri': EdenredConfig.redirectUri,
            'state': state,
            'nonce': state,
            'acr_values': 'tenant:${EdenredConfig.tenant}',
            'ui_locales': EdenredConfig.locale,
            'code_challenge': challenge,
            'code_challenge_method': challengeMethod,
          },
        )
        .toString();
  }

  static List<int> _secureBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  static String _base64UrlNoPadding(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
