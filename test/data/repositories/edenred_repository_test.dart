import 'package:edenred_55_app/src/data/models/edenred_api_models.dart';
import 'package:edenred_55_app/src/data/repositories/edenred_repository.dart';
import 'package:edenred_55_app/src/data/services/edenred_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps Edenred API models to domain models', () async {
    final repository = EdenredRepositoryImpl(
      service: FakeEdenredApiService(
        products: const <EdenredProduct>[
          EdenredProduct(
            idTicket: 123,
            label: 'Ticket Restaurant',
            active: true,
            status: 'ACTIVA',
          ),
        ],
        balance: const EdenredBalance(amount: 80),
        transactions: <EdenredTransaction>[
          EdenredTransaction(
            id: 'tx-1',
            dateUtc: DateTime.utc(2026, 5, 5, 10),
            description: 'Lunch',
            amount: -12.34,
            businessName: 'Cafe',
            city: 'Madrid',
            province: 'Madrid',
          ),
        ],
      ),
    );

    final products = await repository.fetchProducts(accessToken: 'access');
    final balance = await repository.fetchBalance(
      accessToken: 'access',
      idTicket: 123,
    );
    final transactions = await repository.fetchTransactions(
      accessToken: 'access',
      idTicket: 123,
    );

    expect(products.single.idTicket, 123);
    expect(products.single.label, 'Ticket Restaurant');
    expect(products.single.active, isTrue);
    expect(products.single.status, 'ACTIVA');
    expect(balance.amount, 80);
    expect(transactions.single.id, 'tx-1');
    expect(transactions.single.dateUtc, DateTime.utc(2026, 5, 5, 10));
    expect(transactions.single.description, 'Lunch');
    expect(transactions.single.amount, -12.34);
    expect(transactions.single.businessName, 'Cafe');
    expect(transactions.single.city, 'Madrid');
    expect(transactions.single.province, 'Madrid');
  });
}

class FakeEdenredApiService implements EdenredApiService {
  FakeEdenredApiService({
    required this.products,
    required this.balance,
    required this.transactions,
  });

  final List<EdenredProduct> products;
  final EdenredBalance balance;
  final List<EdenredTransaction> transactions;

  @override
  Future<EdenredBalance> fetchBalance({
    required String accessToken,
    required int idTicket,
  }) async {
    return balance;
  }

  @override
  Future<List<EdenredProduct>> fetchProducts({
    required String accessToken,
  }) async {
    return products;
  }

  @override
  Future<List<EdenredTransaction>> fetchTransactions({
    required String accessToken,
    required int idTicket,
  }) async {
    return transactions;
  }
}
