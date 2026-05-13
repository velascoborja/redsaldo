import 'package:edenred_55_app/src/data/models/token_models.dart';
import 'package:edenred_55_app/src/data/repositories/auth_repository.dart';
import 'package:edenred_55_app/src/data/repositories/edenred_repository.dart';
import 'package:edenred_55_app/src/data/repositories/preferences_repository.dart';
import 'package:edenred_55_app/src/domain/models/product.dart';
import 'package:edenred_55_app/src/l10n/app_localizations.dart';
import 'package:edenred_55_app/src/ui/features/app_shell/app_view_model.dart';
import 'package:edenred_55_app/src/ui/features/products/views/product_picker_screen.dart';
import 'package:edenred_55_app/src/ui/features/products/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

AppViewModel _makeController({List<Product> products = const []}) {
  final vm = AppViewModel(
    auth: _FakeAuth(),
    edenred: _FakeEdenred(products: products),
    preferences: _FakePreferences(),
  );
  vm.products = products;
  vm.status = AppStatus.ready;
  return vm;
}

void main() {
  testWidgets('renders ProductCard for each product', (tester) async {
    final products = [
      const Product(idTicket: 1, label: 'Meal Card', active: true, status: ''),
      const Product(idTicket: 2, label: 'Gift Card', active: true, status: ''),
    ];
    await tester.pumpWidget(
      _wrap(ProductPickerScreen(controller: _makeController(products: products))),
    );
    expect(find.byType(ProductCard), findsNWidgets(2));
    expect(find.text('Meal Card'), findsOneWidget);
    expect(find.text('Gift Card'), findsOneWidget);
  });

  testWidgets('shows ticket ID for each product', (tester) async {
    final products = [
      const Product(idTicket: 101, label: 'Meal Card', active: true, status: ''),
    ];
    await tester.pumpWidget(
      _wrap(ProductPickerScreen(controller: _makeController(products: products))),
    );
    expect(find.text('Ticket 101'), findsOneWidget);
  });

  testWidgets('shows INACTIVE badge for inactive products', (tester) async {
    final products = [
      const Product(idTicket: 1, label: 'Old Card', active: false, status: ''),
    ];
    await tester.pumpWidget(
      _wrap(ProductPickerScreen(controller: _makeController(products: products))),
    );
    expect(find.text('INACTIVE'), findsOneWidget);
  });

  testWidgets('never shows SELECTED badge', (tester) async {
    final products = [
      const Product(idTicket: 1, label: 'Meal Card', active: true, status: ''),
    ];
    await tester.pumpWidget(
      _wrap(ProductPickerScreen(controller: _makeController(products: products))),
    );
    expect(find.text('SELECTED'), findsNothing);
  });

  testWidgets('tapping active product calls selectProduct', (tester) async {
    final products = [
      const Product(idTicket: 1, label: 'Meal Card', active: true, status: ''),
    ];
    final controller = _makeController(products: products);
    await tester.pumpWidget(_wrap(ProductPickerScreen(controller: controller)));
    await tester.tap(find.text('Meal Card'));
    await tester.pumpAndSettle();
    expect(controller.selectedProduct?.idTicket, 1);
  });

  testWidgets('shows no-products message when list is empty', (tester) async {
    await tester.pumpWidget(
      _wrap(ProductPickerScreen(controller: _makeController())),
    );
    expect(find.byType(ProductCard), findsNothing);
  });
}

class _FakeAuth implements AuthRepository {
  @override
  Future<TokenSession> exchangeCode({required String code, required String verifier}) async =>
      throw UnimplementedError();
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
  Future<List<Product>> fetchProducts({required String accessToken}) async => products;
  @override
  Future<Balance> fetchBalance({required String accessToken, required int idTicket}) async =>
      const Balance(amount: 0);
  @override
  Future<List<DomainTransaction>> fetchTransactions({
    required String accessToken,
    required int idTicket,
  }) async => const [];
}

class _FakePreferences implements PreferencesRepository {
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
  Future<void> clearSelectedProduct() async { selectedProduct = null; }
  @override
  Future<void> clearAll() async { selectedProduct = null; }
}
