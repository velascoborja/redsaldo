import '../../domain/models/product.dart';
import '../models/edenred_api_models.dart' as api;
import '../services/edenred_api_service.dart';

abstract class EdenredRepository {
  Future<List<Product>> fetchProducts({required String accessToken});

  Future<Balance> fetchBalance({
    required String accessToken,
    required int idTicket,
  });

  Future<List<DomainTransaction>> fetchTransactions({
    required String accessToken,
    required int idTicket,
  });
}

class EdenredRepositoryImpl implements EdenredRepository {
  EdenredRepositoryImpl({required EdenredApiService service})
    : _service = service;

  final EdenredApiService _service;

  @override
  Future<List<Product>> fetchProducts({required String accessToken}) async {
    final products = await _service.fetchProducts(accessToken: accessToken);
    return products.map(_mapProduct).toList(growable: false);
  }

  @override
  Future<Balance> fetchBalance({
    required String accessToken,
    required int idTicket,
  }) async {
    final balance = await _service.fetchBalance(
      accessToken: accessToken,
      idTicket: idTicket,
    );
    return Balance(amount: balance.amount);
  }

  @override
  Future<List<DomainTransaction>> fetchTransactions({
    required String accessToken,
    required int idTicket,
  }) async {
    final transactions = await _service.fetchTransactions(
      accessToken: accessToken,
      idTicket: idTicket,
    );
    return transactions.map(_mapTransaction).toList(growable: false);
  }

  static Product _mapProduct(api.EdenredProduct product) {
    return Product(
      idTicket: product.idTicket,
      label: product.label,
      active: product.active,
      status: product.status,
    );
  }

  static DomainTransaction _mapTransaction(api.EdenredTransaction transaction) {
    return DomainTransaction(
      id: transaction.id,
      dateUtc: transaction.dateUtc,
      description: transaction.description,
      amount: transaction.amount,
      businessName: transaction.businessName,
      city: transaction.city,
      province: transaction.province,
    );
  }
}
