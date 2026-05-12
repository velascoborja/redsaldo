class EdenredConfig {
  const EdenredConfig._();

  static const clientId = '64e8f810218f423da70866c1bd663dfd';
  static const redirectUri = 'myedenredspain://oauth-callback';
  static const ssoBaseUrl = 'https://sso.eu.edenred.io';
  static const authorizePath = '/connect/authorize';
  static const tokenPath = '/connect/token';
  static const apiBaseUrl = 'https://webservices.edenred.es/myedenred/v2/';
  static const loginScope =
      'openid email profile offline_access eres-user-api autoconnect';
  static const refreshScope = 'openid cardownership-api eres-user-api';
  static const tenant = 'es-ben';
  static const locale = 'es-ES';
  static const apiLanguage = 'EN';
  static const appVersion = '11.1.8';
  static const platform = 'android';

  static const redirectScheme = 'myedenredspain';
  static const redirectHost = 'oauth-callback';
}
