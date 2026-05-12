import 'package:edenred_55_app/src/auth/token_models.dart';
import 'package:edenred_55_app/src/edenred/edenred_models.dart';
import 'package:edenred_55_app/src/state/app_controller.dart';
import 'package:edenred_55_app/src/state/app_gateways.dart';
import 'package:edenred_55_app/src/storage/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('starts unauthenticated when no session exists', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = AppController(
      auth: FakeAuth(session: null),
      api: FakeApi(),
      preferences: AppPreferences(await SharedPreferences.getInstance()),
      now: () => DateTime.utc(2026, 5, 6, 12),
    );

    await controller.bootstrap();

    expect(controller.status, AppStatus.unauthenticated);
  });

  test('requires product selection after login when none is stored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = AppController(
      auth: FakeAuth(
        session: TokenSession(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAtUtc: DateTime.utc(2026, 5, 11),
        ),
      ),
      api: FakeApi(products: <EdenredProduct>[
        const EdenredProduct(idTicket: 123, label: 'Ticket Restaurant', active: true, status: 'ACTIVA'),
      ]),
      preferences: AppPreferences(await SharedPreferences.getInstance()),
      now: () => DateTime.utc(2026, 5, 6, 12),
    );

    await controller.bootstrap();

    expect(controller.status, AppStatus.needsProductSelection);
    expect(controller.products.single.idTicket, 123);
  });

  test('loads dashboard summary for selected product', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    await preferences.saveSelectedProduct(
      const SelectedProductPreference(idTicket: 123, label: 'Ticket Restaurant', active: true, status: 'ACTIVA'),
    );
    final controller = AppController(
      auth: FakeAuth(
        session: TokenSession(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAtUtc: DateTime.utc(2026, 5, 11),
        ),
      ),
      api: FakeApi(
        products: <EdenredProduct>[
          const EdenredProduct(idTicket: 123, label: 'Ticket Restaurant', active: true, status: 'ACTIVA'),
        ],
        balance: const EdenredBalance(amount: 80),
        transactions: <EdenredTransaction>[
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

class FakeAuth implements AppAuthGateway {
  FakeAuth({required this.session});

  TokenSession? session;

  @override
  Future<String> getValidAccessToken() async => session!.accessToken;

  @override
  Future<TokenSession?> loadSession() async => session;

  @override
  Future<void> logout() async {
    session = null;
  }
}

class FakeApi implements AppEdenredGateway {
  FakeApi({
    this.products = const <EdenredProduct>[],
    this.balance = const EdenredBalance(amount: 0),
    this.transactions = const <EdenredTransaction>[],
  });

  final List<EdenredProduct> products;
  final EdenredBalance balance;
  final List<EdenredTransaction> transactions;

  @override
  Future<EdenredBalance> fetchBalance({required String accessToken, required int idTicket}) async => balance;

  @override
  Future<List<EdenredProduct>> fetchProducts({required String accessToken}) async => products;

  @override
  Future<List<EdenredTransaction>> fetchTransactions({required String accessToken, required int idTicket}) async {
    return transactions;
  }
}

EdenredTransaction tx({
  required double amount,
  required DateTime dateUtc,
}) {
  return EdenredTransaction(
    id: '',
    dateUtc: dateUtc,
    description: 'test',
    amount: amount,
    businessName: '',
    city: '',
    province: '',
  );
}
