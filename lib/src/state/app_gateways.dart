import '../auth/token_models.dart';
import '../edenred/edenred_models.dart';

abstract class AppAuthGateway {
  Future<TokenSession?> loadSession();
  Future<String> getValidAccessToken();
  Future<void> logout();
}

abstract class AppEdenredGateway {
  Future<List<EdenredProduct>> fetchProducts({required String accessToken});
  Future<EdenredBalance> fetchBalance({required String accessToken, required int idTicket});
  Future<List<EdenredTransaction>> fetchTransactions({required String accessToken, required int idTicket});
}
