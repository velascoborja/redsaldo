import '../models/token_models.dart';

abstract class AuthRepository {
  Future<TokenSession?> loadSession();

  Future<TokenSession> exchangeCode({
    required String code,
    required String verifier,
  });

  Future<String> getValidAccessToken();

  Future<void> logout();
}
