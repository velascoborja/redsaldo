// test/widget/history_screen_test.dart
import 'package:edenred_55_app/src/data/models/token_models.dart';
import 'package:edenred_55_app/src/data/repositories/auth_repository.dart';
import 'package:edenred_55_app/src/data/repositories/edenred_repository.dart';
import 'package:edenred_55_app/src/data/repositories/preferences_repository.dart';
import 'package:edenred_55_app/src/domain/models/product.dart';
import 'package:edenred_55_app/src/domain/models/weekly_budget.dart';
import 'package:edenred_55_app/src/l10n/app_localizations.dart';
import 'package:edenred_55_app/src/ui/features/app_shell/app_view_model.dart';
import 'package:edenred_55_app/src/ui/features/history/views/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows current-week transactions from summary', (tester) async {
    final controller = _makeController(
      weekTransactions: [
        _tx(businessName: 'Burger Palace', amount: -8.50),
      ],
    );

    await tester.pumpWidget(_wrap(HistoryScreen(controller: controller)));

    expect(find.text('Burger Palace'), findsOneWidget);
  });

  testWidgets('shows empty state when summary has no transactions', (
    tester,
  ) async {
    final controller = _makeController(weekTransactions: []);

    await tester.pumpWidget(_wrap(HistoryScreen(controller: controller)));

    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
  });

  testWidgets('shows empty state when summary is null', (tester) async {
    final controller = _makeController(weekTransactions: null);

    await tester.pumpWidget(_wrap(HistoryScreen(controller: controller)));

    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
  });
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

/// Pass null for weekTransactions to leave summary as null.
AppViewModel _makeController({
  required List<DomainTransaction>? weekTransactions,
}) {
  final vm = AppViewModel(
    auth: _HistoryFakeAuth(),
    edenred: _HistoryFakeEdenred(),
    preferences: _HistoryFakePreferences(),
  );
  vm.status = AppStatus.ready;
  if (weekTransactions != null) {
    vm.summary = WeeklyBudgetSummary(
      weeklyLimit: 50,
      weeklySpend: 0,
      remaining: 50,
      range: WeekRange(
        startUtc: DateTime.utc(2026, 5, 12),
        endUtc: DateTime.utc(2026, 5, 18, 23, 59, 59, 999),
        label: '12 May - 18 May',
      ),
      transactions: weekTransactions,
    );
  }
  return vm;
}

DomainTransaction _tx({required String businessName, required double amount}) {
  return DomainTransaction(
    id: '1',
    dateUtc: DateTime.utc(2026, 5, 13),
    description: 'test',
    amount: amount,
    businessName: businessName,
    city: '',
    province: '',
  );
}

class _HistoryFakeAuth implements AuthRepository {
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

class _HistoryFakeEdenred implements EdenredRepository {
  @override
  Future<List<Product>> fetchProducts({required String accessToken}) async =>
      const [];

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

class _HistoryFakePreferences implements PreferencesRepository {
  @override
  double get weeklyLimit => 50.0;

  @override
  SelectedProduct? get selectedProduct => null;

  @override
  Future<void> saveWeeklyLimit(double value) async {}

  @override
  Future<void> saveSelectedProduct(SelectedProduct product) async {}

  @override
  Future<void> clearSelectedProduct() async {}

  @override
  Future<void> clearAll() async {}
}
