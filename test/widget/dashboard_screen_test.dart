// test/widget/dashboard_screen_test.dart
import 'package:edenred_55_app/src/data/models/token_models.dart';
import 'package:edenred_55_app/src/data/repositories/auth_repository.dart';
import 'package:edenred_55_app/src/data/repositories/edenred_repository.dart';
import 'package:edenred_55_app/src/data/repositories/preferences_repository.dart';
import 'package:edenred_55_app/src/domain/models/product.dart';
import 'package:edenred_55_app/src/domain/models/weekly_budget.dart';
import 'package:edenred_55_app/src/l10n/app_localizations.dart';
import 'package:edenred_55_app/src/ui/features/app_shell/app_view_model.dart';
import 'package:edenred_55_app/src/ui/features/dashboard/views/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(tz.initializeTimeZones);

  for (final (spent, limit, expected) in [
    (0.0, 55.0, '0 € spent of 55 € limit'),
    (5.50, 55.25, '5.50 € spent of 55.25 € limit'),
    (5.0, 55.25, '5 € spent of 55.25 € limit'),
  ]) {
    testWidgets('spent and limit display as $expected', (tester) async {
      final controller = _makeController();
      addTearDown(controller.dispose);
      controller.summary = WeeklyBudgetSummary(
        weeklyLimit: limit,
        weeklySpend: spent,
        remaining: limit - spent,
        range: WeekRange(
          startUtc: DateTime.utc(2026, 10, 19),
          endUtc: DateTime.utc(2026, 10, 25),
          label: '',
        ),
        transactions: const [],
      );

      await tester.pumpWidget(_wrap(DashboardScreen(controller: controller)));

      expect(find.text(expected), findsOneWidget);
    });
  }

  for (final (amount, expected) in [
    (55.0, '55'),
    (55.50, '55.50'),
    (55.01, '55.01'),
    (55.999, '56'),
  ]) {
    testWidgets('remaining amount $amount displays as $expected', (tester) async {
      final controller = _makeController();
      addTearDown(controller.dispose);
      await controller.saveWeeklyLimit(amount);

      await tester.pumpWidget(_wrap(DashboardScreen(controller: controller)));

      expect(find.text(expected), findsOneWidget);
      if (!expected.contains('.')) {
        expect(find.text('$expected.00'), findsNothing);
      }
    });
  }

  testWidgets('Edit Limit opens a bottom sheet, not a dialog', (tester) async {
    final controller = _makeController();
    await tester.pumpWidget(_wrap(DashboardScreen(controller: controller)));

    await tester.ensureVisible(find.text('Edit Limit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Limit'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('55 €'), findsOneWidget);
    expect(find.text('60 €'), findsOneWidget);
    expect(find.text('75 €'), findsOneWidget);
  });

  testWidgets('tapping a preset chip updates the text field value', (
    tester,
  ) async {
    final controller = _makeController();
    await tester.pumpWidget(_wrap(DashboardScreen(controller: controller)));

    await tester.ensureVisible(find.text('Edit Limit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Limit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('60 €'));
    await tester.pump();

    final tf = tester.widget<TextField>(find.byType(TextField));
    expect(tf.controller?.text, equals('60.00'));
  });
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

AppViewModel _makeController({double weeklyLimit = 55.0}) {
  return AppViewModel(
    auth: _FakeAuth(),
    edenred: _FakeEdenred(),
    preferences: _FakePreferences(weeklyLimit: weeklyLimit),
  );
}

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

class _FakePreferences implements PreferencesRepository {
  _FakePreferences({this.weeklyLimit = 55.0});

  @override
  final double weeklyLimit;

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
