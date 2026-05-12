import 'package:edenred_55_app/src/l10n/app_localizations.dart';
import 'package:edenred_55_app/src/ui/core/money.dart';
import 'package:edenred_55_app/src/ui/features/app_shell/views/syncing_account_screen.dart';
import 'package:edenred_55_app/src/ui/features/auth/views/login_screen.dart';
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
}
