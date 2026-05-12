import 'package:edenred_55_app/src/data/models/token_models.dart';
import 'package:edenred_55_app/src/data/repositories/auth_repository.dart';
import 'package:edenred_55_app/src/data/repositories/edenred_repository.dart';
import 'package:edenred_55_app/src/data/repositories/preferences_repository.dart';
import 'package:edenred_55_app/src/data/services/app_preferences_service.dart';
import 'package:edenred_55_app/src/domain/models/product.dart';
import 'package:edenred_55_app/src/ui/features/app_shell/app_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('starts unauthenticated when no session exists', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = AppViewModel(
      auth: FakeAuth(session: null),
      edenred: FakeEdenredRepository(),
      preferences: PreferencesRepositoryImpl(
        preferences: AppPreferences(await SharedPreferences.getInstance()),
      ),
      now: () => DateTime.utc(2026, 5, 6, 12),
    );

    await controller.bootstrap();

    expect(controller.status, AppStatus.unauthenticated);
  });

  test('requires product selection after login when none is stored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = AppViewModel(
      auth: FakeAuth(
        session: TokenSession(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAtUtc: DateTime.utc(2026, 5, 11),
        ),
      ),
      edenred: FakeEdenredRepository(
        products: <Product>[
          const Product(
            idTicket: 123,
            label: 'Ticket Restaurant',
            active: true,
            status: 'ACTIVA',
          ),
        ],
      ),
      preferences: PreferencesRepositoryImpl(
        preferences: AppPreferences(await SharedPreferences.getInstance()),
      ),
      now: () => DateTime.utc(2026, 5, 6, 12),
    );

    await controller.bootstrap();

    expect(controller.status, AppStatus.needsProductSelection);
    expect(controller.products.single.idTicket, 123);
  });

  test('loads dashboard summary for selected product', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = PreferencesRepositoryImpl(
      preferences: AppPreferences(await SharedPreferences.getInstance()),
    );
    await preferences.saveSelectedProduct(
      const SelectedProduct(
        idTicket: 123,
        label: 'Ticket Restaurant',
        active: true,
        status: 'ACTIVA',
      ),
    );
    final controller = AppViewModel(
      auth: FakeAuth(
        session: TokenSession(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAtUtc: DateTime.utc(2026, 5, 11),
        ),
      ),
      edenred: FakeEdenredRepository(
        products: <Product>[
          const Product(
            idTicket: 123,
            label: 'Ticket Restaurant',
            active: true,
            status: 'ACTIVA',
          ),
        ],
        balance: const Balance(amount: 80),
        transactions: <DomainTransaction>[
          tx(amount: -10, dateUtc: DateTime.utc(2026, 5, 5, 10)),
        ],
      ),
      preferences: preferences,
      now: () => DateTime.utc(2026, 5, 6, 12),
    );

    await controller.bootstrap();

    expect(controller.status, AppStatus.ready);
    expect(controller.balance?.amount, 80);
    expect(controller.summary?.weeklySpend, 10);
    expect(controller.summary?.remaining, 45);
  });
}

class FakeAuth implements AuthRepository {
  FakeAuth({required this.session});

  TokenSession? session;

  @override
  Future<TokenSession> exchangeCode({
    required String code,
    required String verifier,
  }) async {
    return session!;
  }

  @override
  Future<String> getValidAccessToken() async => session!.accessToken;

  @override
  Future<TokenSession?> loadSession() async => session;

  @override
  Future<void> logout() async {
    session = null;
  }
}

class FakeEdenredRepository implements EdenredRepository {
  FakeEdenredRepository({
    this.products = const <Product>[],
    this.balance = const Balance(amount: 0),
    this.transactions = const <DomainTransaction>[],
  });

  final List<Product> products;
  final Balance balance;
  final List<DomainTransaction> transactions;

  @override
  Future<Balance> fetchBalance({
    required String accessToken,
    required int idTicket,
  }) async {
    return balance;
  }

  @override
  Future<List<Product>> fetchProducts({required String accessToken}) async {
    return products;
  }

  @override
  Future<List<DomainTransaction>> fetchTransactions({
    required String accessToken,
    required int idTicket,
  }) async {
    return transactions;
  }
}

DomainTransaction tx({required double amount, required DateTime dateUtc}) {
  return DomainTransaction(
    id: '',
    dateUtc: dateUtc,
    description: 'test',
    amount: amount,
    businessName: '',
    city: '',
    province: '',
  );
}
