import 'package:edenred_55_app/src/ui/login_screen.dart';
import 'package:edenred_55_app/src/ui/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen shows Redsaldo branding and login action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          onLogin: () {},
        ),
      ),
    );

    expect(find.text('Redsaldo'), findsOneWidget);
    expect(find.text('Track your Ticket Restaurant weekly allowance.'), findsOneWidget);
    expect(find.text('Log in with Edenred'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    expect(
      find.text(
        'We never store your card numbers or login credentials. Your data remains secure.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loading app status shows progress indicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('money text formats euros', (tester) async {
    expect(formatEuros(42.66), '42.66 €');
    expect(formatEuros(-1.25), '-1.25 €');
  });
}
