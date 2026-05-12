import 'package:flutter/foundation.dart';

import '../budget/budget_calculator.dart';
import '../edenred/edenred_models.dart';
import '../storage/app_preferences.dart';
import 'app_gateways.dart';

enum AppStatus {
  loading,
  unauthenticated,
  needsProductSelection,
  ready,
  error,
}

class AppController extends ChangeNotifier {
  AppController({
    required AppAuthGateway auth,
    required AppEdenredGateway api,
    required AppPreferences preferences,
    DateTime Function()? now,
  })  : _auth = auth,
        _api = api,
        _preferences = preferences,
        _now = now ?? DateTime.now;

  final AppAuthGateway _auth;
  final AppEdenredGateway _api;
  final AppPreferences _preferences;
  final DateTime Function() _now;

  AppStatus status = AppStatus.loading;
  String? errorMessage;
  List<EdenredProduct> products = <EdenredProduct>[];
  SelectedProductPreference? selectedProduct;
  EdenredBalance? balance;
  WeeklyBudgetSummary? summary;

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

  Future<void> selectProduct(EdenredProduct product) async {
    final preference = SelectedProductPreference(
      idTicket: product.idTicket,
      label: product.label,
      active: product.active,
      status: product.status,
    );
    await _preferences.saveSelectedProduct(preference);
    selectedProduct = preference;
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
      _setStatus(AppStatus.loading);
      final accessToken = await _auth.getValidAccessToken();
      final loadedBalance = await _api.fetchBalance(accessToken: accessToken, idTicket: product.idTicket);
      final transactions = await _api.fetchTransactions(accessToken: accessToken, idTicket: product.idTicket);
      selectedProduct = product;
      balance = loadedBalance;
      summary = calculateWeeklyBudget(
        weeklyLimit: _preferences.weeklyLimit,
        nowUtc: _now().toUtc(),
        transactions: transactions,
      );
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
      products = await _api.fetchProducts(accessToken: accessToken);
      final stored = _preferences.selectedProduct;
      final storedStillAvailable = stored != null &&
          products.any((product) => product.idTicket == stored.idTicket && product.active);

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
