# History Screen — Current Week Filter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Filter the history transaction list to show only the current week's transactions, using the already-computed `summary.transactions` field.

**Architecture:** `HistoryScreen` reads `controller.summary?.transactions ?? []` instead of `controller.transactions`. `WeeklyBudgetSummary.transactions` is filtered to the current Monday–Sunday Madrid-timezone week by `calculateWeeklyBudget`, which already runs on every refresh. No new logic required.

**Tech Stack:** Flutter, flutter_test widget tests

---

## Files

- **Modify:** `lib/src/ui/features/history/views/history_screen.dart:17` — change data source from `controller.transactions` to `controller.summary?.transactions ?? []`
- **Create:** `test/widget/history_screen_test.dart` — widget tests for the filtered behaviour

---

### Task 1: Write failing widget test for HistoryScreen

**Files:**
- Create: `test/widget/history_screen_test.dart`

- [ ] **Step 1: Create the test file with the failing test first**

```dart
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
  // This test FAILS before the fix: currently the screen reads controller.transactions
  // (which is empty), so the week transaction never appears.
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
    auth: _FakeAuth(),
    edenred: _FakeEdenred(),
    preferences: _FakePreferences(),
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
```

- [ ] **Step 2: Run the tests to confirm the first test fails**

```bash
flutter test test/widget/history_screen_test.dart --no-pub
```

Expected output:
```
✗ shows current-week transactions from summary
  Expected: exactly one matching node in the widget tree
  Actual: _WidgetTypeFinder:<Text matching "Burger Palace">
  Which: means zero widgets with that criteria were found.
✓ shows empty state when summary has no transactions
✓ shows empty state when summary is null
```

---

### Task 2: Implement the fix

**Files:**
- Modify: `lib/src/ui/features/history/views/history_screen.dart:17`

- [ ] **Step 3: Change the data source in HistoryScreen**

In `lib/src/ui/features/history/views/history_screen.dart`, replace line 17:

```dart
// Before
final transactions = controller.transactions;
```

```dart
// After
final transactions = controller.summary?.transactions ?? [];
```

---

### Task 3: Verify and commit

- [ ] **Step 4: Run all tests and confirm all pass**

```bash
flutter test test/widget/history_screen_test.dart --no-pub
```

Expected output:
```
✓ shows current-week transactions from summary
✓ shows empty state when summary has no transactions
✓ shows empty state when summary is null
All tests passed!
```

Then run the full suite to check for regressions:

```bash
flutter test --no-pub
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add test/widget/history_screen_test.dart lib/src/ui/features/history/views/history_screen.dart
git commit -m "feat: filter history list to current week via summary.transactions"
```
