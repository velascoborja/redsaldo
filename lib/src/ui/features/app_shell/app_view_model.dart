import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/edenred_repository.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/weekly_budget.dart';
import '../../../domain/use_cases/calculate_weekly_budget.dart';

enum AppStatus { loading, unauthenticated, needsProductSelection, ready, error }

class AppViewModel extends ChangeNotifier {
  AppViewModel({
    required AuthRepository auth,
    required EdenredRepository edenred,
    required PreferencesRepository preferences,
    DateTime Function()? now,
  }) : _auth = auth,
       _edenred = edenred,
       _preferences = preferences,
       _now = now ?? DateTime.now;

  final AuthRepository _auth;
  final EdenredRepository _edenred;
  final PreferencesRepository _preferences;
  final DateTime Function() _now;

  AppStatus status = AppStatus.loading;
  String? errorMessage;
  List<Product> products = <Product>[];
  SelectedProduct? selectedProduct;
  Balance? balance;
  WeeklyBudgetSummary? summary;
  DateTime? lastRefreshed;

  double get weeklyLimit => _preferences.weeklyLimit;

  Future<void> bootstrap() async {
    _setStatus(AppStatus.loading);
    final session = await _auth.loadSession();
    if (session == null) {
      _setStatus(AppStatus.unauthenticated);
      return;
    }

    await _loadProductsAndRoute();
  }

  Future<void> onLoginCompleted() async {
    await _loadProductsAndRoute();
  }

  Future<void> selectProduct(Product product) async {
    final selected = SelectedProduct(
      idTicket: product.idTicket,
      label: product.label,
      active: product.active,
      status: product.status,
    );
    await _preferences.saveSelectedProduct(selected);
    selectedProduct = selected;
    await refreshDashboard();
  }

  Future<void> saveWeeklyLimit(double value) async {
    await _preferences.saveWeeklyLimit(value);
    await refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    final product = selectedProduct ?? _preferences.selectedProduct;
    if (product == null) {
      _setStatus(AppStatus.needsProductSelection);
      return;
    }

    try {
      final accessToken = await _auth.getValidAccessToken();
      final loadedBalance = await _edenred.fetchBalance(
        accessToken: accessToken,
        idTicket: product.idTicket,
      );
      final transactions = await _edenred.fetchTransactions(
        accessToken: accessToken,
        idTicket: product.idTicket,
      );
      selectedProduct = product;
      balance = loadedBalance;
      summary = calculateWeeklyBudget(
        weeklyLimit: _preferences.weeklyLimit,
        nowUtc: _now().toUtc(),
        transactions: transactions,
      );
      lastRefreshed = _now();
      _setStatus(AppStatus.ready);
    } catch (error) {
      errorMessage = error.toString();
      _setStatus(AppStatus.error);
    }
  }

  void changeProduct() {
    selectedProduct = null;
    _setStatus(AppStatus.needsProductSelection);
  }

  Future<void> logout() async {
    await _auth.logout();
    await _preferences.clearAll();
    selectedProduct = null;
    balance = null;
    summary = null;
    _setStatus(AppStatus.unauthenticated);
  }

  Future<void> _loadProductsAndRoute() async {
    try {
      _setStatus(AppStatus.loading);
      final accessToken = await _auth.getValidAccessToken();
      products = await _edenred.fetchProducts(accessToken: accessToken);
      final stored = _preferences.selectedProduct;
      final storedStillAvailable =
          stored != null &&
          products.any(
            (product) => product.idTicket == stored.idTicket && product.active,
          );

      if (!storedStillAvailable) {
        selectedProduct = null;
        _setStatus(AppStatus.needsProductSelection);
        return;
      }

      selectedProduct = stored;
      await refreshDashboard();
    } catch (error) {
      errorMessage = error.toString();
      _setStatus(AppStatus.error);
    }
  }

  void _setStatus(AppStatus value) {
    status = value;
    notifyListeners();
  }
}
