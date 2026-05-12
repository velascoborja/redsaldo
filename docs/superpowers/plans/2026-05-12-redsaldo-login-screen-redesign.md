# Redsaldo Login Screen Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the minimal `LoginScreen` with a hero-image-driven welcome screen matching the "Login - Hero Statement" Stitch design, renaming the app to "Redsaldo" within that screen.

**Architecture:** Single-file change to `lib/src/ui/login_screen.dart`. A full-bleed hero image fills the top half via `Expanded`, with icon, title, subtitle, login button, and security message stacked below in a padded `Column`. No new dependencies required.

**Tech Stack:** Flutter, Material 3, `Image.network`, `flutter_test` for widget tests.

---

### Task 1: Update the widget test to expect the new UI

**Files:**
- Modify: `test/widget/app_flow_test.dart:7-18`

The existing test checks for `'Edenred 55'` (the old AppBar title) and `'Login with Edenred'` (old button text). Replace it with assertions for the new screen content.

- [ ] **Step 1: Replace the existing login screen test**

Open `test/widget/app_flow_test.dart` and replace the `'login screen exposes Edenred login action'` test with:

```dart
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
```

The full file after the change:

```dart
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
```

- [ ] **Step 2: Run the test to confirm it fails**

```bash
flutter test test/widget/app_flow_test.dart
```

Expected output: FAIL — `Expected: exactly one matching node, Found: no matching nodes` for `'Redsaldo'` (the current screen shows "Edenred 55").

---

### Task 2: Implement the new LoginScreen

**Files:**
- Modify: `lib/src/ui/login_screen.dart`

- [ ] **Step 1: Replace the contents of `login_screen.dart`**

```dart
import 'package:flutter/material.dart';

const _heroImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBdQXQnQxxTM9AHc_PF0NgBUK9lq6Ze6IIGFy2Cl5-fibJqROl355sJ0FNLtjTRH2G5IdgEO6ilAklQ4EuIIdrk9GL2YEPrUVWnD_-KTPWEz7jwr_07JYl4ofScA_jY0dBRUVa-vvOJjFzDgSBIDzu8sxgExm9QN2uu_k0YkmlTI4yLUSEWYydpVBRR44mSrHzW3n02Qh3PuDzbuJB8w5CNZYYsrBAykjaeabu98FqXjybjW3duO9rgYExv2Gr1gslNdi_1JtHQEfU';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    required this.onLogin,
    super.key,
  });

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              _heroImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 48,
                  color: colors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Redsaldo',
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your Ticket Restaurant weekly allowance.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onLogin,
                  child: const Text('Log in with Edenred'),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'We never store your card numbers or login credentials. Your data remains secure.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run the test to confirm it passes**

```bash
flutter test test/widget/app_flow_test.dart
```

Expected output:
```
00:00 +3: All tests passed!
```

- [ ] **Step 3: Run the full test suite to check for regressions**

```bash
flutter test
```

Expected output: all tests pass. If any other test fails, investigate before committing.

- [ ] **Step 4: Commit**

```bash
git add lib/src/ui/login_screen.dart test/widget/app_flow_test.dart
git commit -m "feat: redesign login screen with Redsaldo hero image layout"
```
