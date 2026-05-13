import 'package:edenred_55_app/src/data/models/token_models.dart';
import 'package:edenred_55_app/src/data/repositories/auth_repository.dart';
import 'package:edenred_55_app/src/data/repositories/edenred_repository.dart';
import 'package:edenred_55_app/src/data/repositories/preferences_repository.dart';
import 'package:edenred_55_app/src/domain/models/product.dart';
import 'package:edenred_55_app/src/l10n/app_localizations.dart';
import 'package:edenred_55_app/src/ui/features/app_shell/app_view_model.dart';
import 'package:edenred_55_app/src/ui/features/settings/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders product labels and badges', (tester) async {
    final products = [
      const Product(
        idTicket: 1,
        label: 'Ticket Restaurant',
        active: true,
        status: 'Daily Allowance Active',
      ),
      const Product(
        idTicket: 2,
        label: 'Corporate Card',
        active: false,
        status: 'Setup required',
      ),
    ];
    final controller = _makeController(
      products: products,
      selectedProduct: const SelectedProduct(
        idTicket: 1,
        label: 'Ticket Restaurant',
        active: true,
        status: 'Daily Allowance Active',
      ),
    );

    await tester.pumpWidget(_wrap(SettingsScreen(controller: controller)));

    expect(find.text('Ticket Restaurant'), findsOneWidget);
    expect(find.text('Corporate Card'), findsOneWidget);
    expect(find.text('SELECTED'), findsOneWidget);
    expect(find.text('INACTIVE'), findsOneWidget);
  });

  testWidgets('tapping active unselected product updates selection', (
    tester,
  ) async {
    final products = [
      const Product(
        idTicket: 1,
        label: 'Ticket Restaurant',
        active: true,
        status: '',
      ),
      const Product(idTicket: 2, label: 'Meal Card', active: true, status: ''),
    ];
    final controller = _makeController(
      products: products,
      selectedProduct: const SelectedProduct(
        idTicket: 1,
        label: 'Ticket Restaurant',
        active: true,
        status: '',
      ),
    );

    await tester.pumpWidget(_wrap(SettingsScreen(controller: controller)));
    await tester.tap(find.text('Meal Card'));
    await tester.pumpAndSettle();

    expect(controller.selectedProduct?.idTicket, 2);
  });

  testWidgets('tapping inactive product does not change selection', (
    tester,
  ) async {
    final products = [
      const Product(
        idTicket: 1,
        label: 'Active Card',
        active: true,
        status: '',
      ),
      const Product(
        idTicket: 2,
        label: 'Inactive Card',
        active: false,
        status: '',
      ),
    ];
    final controller = _makeController(
      products: products,
      selectedProduct: const SelectedProduct(
        idTicket: 1,
        label: 'Active Card',
        active: true,
        status: '',
      ),
    );

    await tester.pumpWidget(_wrap(SettingsScreen(controller: controller)));
    await tester.tap(find.text('Inactive Card'));
    await tester.pumpAndSettle();

    expect(controller.selectedProduct?.idTicket, 1);
  });

  testWidgets('tapping logout button triggers logout', (tester) async {
    final controller = _makeController();

    await tester.pumpWidget(_wrap(SettingsScreen(controller: controller)));
    await tester.tap(find.text('LOGOUT'));
    await tester.pumpAndSettle();

    expect(controller.status, AppStatus.unauthenticated);
  });

  testWidgets('shows ticket ID for each product', (tester) async {
    final products = [
      const Product(idTicket: 101, label: 'Meal Card', active: true, status: ''),
      const Product(idTicket: 202, label: 'Gift Card', active: true, status: ''),
    ];
    final controller = _makeController(
      products: products,
      selectedProduct: const SelectedProduct(
        idTicket: 101,
        label: 'Meal Card',
        active: true,
        status: '',
      ),
    );

    await tester.pumpWidget(_wrap(SettingsScreen(controller: controller)));

    expect(find.text('Ticket 101'), findsOneWidget);
    expect(find.text('Ticket 202'), findsOneWidget);
  });
}

AppViewModel _makeController({
  List<Product> products = const [],
  SelectedProduct? selectedProduct,
}) {
  final vm = AppViewModel(
    auth: _FakeAuth(),
    edenred: _FakeEdenred(products: products),
    preferences: _FakePreferences(selectedProduct: selectedProduct),
  );
  vm.products = products;
  vm.selectedProduct = selectedProduct;
  vm.status = AppStatus.ready;
  return vm;
}

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

class _FakeAuth implements AuthRepository {
  @override
  Future<TokenSession> exchangeCode({
    required String code,
    required String verifier,
  }) async => throw UnimplementedError();

  @override
  Future<String> getValidAccessToken() async => 'token';

  @override
  Future<TokenSession?> loadSession() async => null;

  @override
  Future<void> logout() async {}
}

class _FakeEdenred implements EdenredRepository {
  _FakeEdenred({this.products = const []});
  final List<Product> products;

  @override
  Future<List<Product>> fetchProducts({required String accessToken}) async =>
      products;

  @override
  Future<Balance> fetchBalance({
    required String accessToken,
    required int idTicket,
  }) async => const Balance(amount: 0);

  @override
  Future<List<DomainTransaction>> fetchTransactions({
    required String accessToken,
    required int idTicket,
  }) async => const [];
}

class _FakePreferences implements PreferencesRepository {
  _FakePreferences({this.selectedProduct});

  @override
  double get weeklyLimit => 50.0;

  @override
  SelectedProduct? selectedProduct;

  @override
  Future<void> saveWeeklyLimit(double value) async {}

  @override
  Future<void> saveSelectedProduct(SelectedProduct product) async {
    selectedProduct = product;
  }

  @override
  Future<void> clearSelectedProduct() async {
    selectedProduct = null;
  }

  @override
  Future<void> clearAll() async {
    selectedProduct = null;
  }
}
