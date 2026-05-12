import 'package:edenred_55_app/src/data/models/token_models.dart';
import 'package:edenred_55_app/src/data/repositories/auth_repository.dart';
import 'package:edenred_55_app/src/data/repositories/edenred_repository.dart';
import 'package:edenred_55_app/src/data/repositories/preferences_repository.dart';
import 'package:edenred_55_app/src/domain/models/product.dart';
import 'package:edenred_55_app/src/l10n/app_localizations.dart';
import 'package:edenred_55_app/src/ui/core/money.dart';
import 'package:edenred_55_app/src/ui/features/app_shell/app_view_model.dart';
import 'package:edenred_55_app/src/ui/features/app_shell/views/syncing_account_screen.dart';
import 'package:edenred_55_app/src/ui/features/auth/views/login_screen.dart';
import 'package:edenred_55_app/src/ui/features/dashboard/views/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen shows Redsaldo branding and login action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginScreen(onLogin: () {}),
      ),
    );

    expect(find.text('Redsaldo'), findsOneWidget);
    expect(
      find.text('Track your Ticket Restaurant weekly allowance.'),
      findsOneWidget,
    );
    expect(find.text('LOG IN WITH EDENRED'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(
      find.text(
        'We never store your card numbers or login credentials. Your data remains secure.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('login screen follows Spanish device locale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginScreen(onLogin: () {}),
      ),
    );

    expect(
      find.text('Controla tu saldo semanal de Ticket Restaurant.'),
      findsOneWidget,
    );
    expect(find.text('INICIAR SESIÓN CON EDENRED'), findsOneWidget);
    expect(
      find.text(
        'Nunca guardamos tus números de tarjeta ni tus credenciales. Tus datos permanecen seguros.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loading app status shows syncing account screen', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SyncingAccountScreen()));

    expect(find.text('Syncing your account'), findsOneWidget);
    expect(find.text('Fetching your balance...'), findsOneWidget);
    expect(
      find.text(
        'This should only take a moment. Securely connecting to your meal allowance provider.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('syncing-progress-ring')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('syncing-progress-ring-spinner')),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('money text formats euros', (tester) async {
    expect(formatEuros(42.66), '42.66 €');
    expect(formatEuros(-1.25), '-1.25 €');
  });

  testWidgets('dashboard default tab shows home AppBar title', (tester) async {
    final controller = _makeDashboardController();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DashboardScreen(controller: controller),
      ),
    );

    expect(find.text('Redsaldo'), findsOneWidget);
  });

  testWidgets('tapping Settings tab updates AppBar to Settings title', (
    tester,
  ) async {
    final controller = _makeDashboardController();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DashboardScreen(controller: controller),
      ),
    );

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();

    expect(find.text('Settings'), findsOneWidget);
  });
}

AppViewModel _makeDashboardController() {
  final vm = AppViewModel(
    auth: _DashFakeAuth(),
    edenred: _DashFakeEdenred(),
    preferences: _DashFakePreferences(),
  );
  vm.products = const [];
  vm.selectedProduct = null;
  vm.status = AppStatus.ready;
  return vm;
}

class _DashFakeAuth implements AuthRepository {
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

class _DashFakeEdenred implements EdenredRepository {
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

class _DashFakePreferences implements PreferencesRepository {
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
