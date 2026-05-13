# Choose Product Screen Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the `ListTile`-based product list on `ProductPickerScreen` with the same card-style UI used by `SettingsScreen`, and show the ticket ID in both screens.

**Architecture:** Extract `_ProductCard`/`_Badge` from `settings_screen.dart` into a shared `ProductCard` widget that accepts a `ticketLabel` string. Both screens import and use this shared widget; `ProductPickerScreen` always passes `isSelected: false`.

**Tech Stack:** Flutter/Dart, `google_fonts` (already a dependency), `EdenredColors` from `lib/src/ui/core/theme.dart`.

---

### Task 1: Create shared `ProductCard` widget

**Files:**
- Create: `lib/src/ui/features/products/widgets/product_card.dart`
- Create: `test/widget/product_card_test.dart`

- [ ] **Step 1: Write the failing widget tests**

Create `test/widget/product_card_test.dart`:

```dart
import 'package:edenred_55_app/src/domain/models/product.dart';
import 'package:edenred_55_app/src/ui/features/products/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

const _active = Product(idTicket: 42, label: 'Meal Card', active: true, status: 'OK');
const _inactive = Product(idTicket: 7, label: 'Old Card', active: false, status: '');

void main() {
  testWidgets('shows label and ticket label', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _active,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 42',
        onTap: () {},
      ),
    ));
    expect(find.text('Meal Card'), findsOneWidget);
    expect(find.text('Ticket 42'), findsOneWidget);
  });

  testWidgets('shows status when non-empty', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _active,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 42',
        onTap: () {},
      ),
    ));
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('hides status when empty', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _inactive,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 7',
        onTap: null,
      ),
    ));
    expect(find.text(''), findsNothing);
  });

  testWidgets('shows SELECTED badge when isSelected', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _active,
        isSelected: true,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 42',
        onTap: () {},
      ),
    ));
    expect(find.text('SEL'), findsOneWidget);
    expect(find.text('OFF'), findsNothing);
  });

  testWidgets('shows INACTIVE badge when product is not active', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _inactive,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 7',
        onTap: null,
      ),
    ));
    expect(find.text('OFF'), findsOneWidget);
    expect(find.text('SEL'), findsNothing);
  });

  testWidgets('shows no badge for active unselected product', (tester) async {
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _active,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 42',
        onTap: () {},
      ),
    ));
    expect(find.text('SEL'), findsNothing);
    expect(find.text('OFF'), findsNothing);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(
      ProductCard(
        product: _active,
        isSelected: false,
        selectedLabel: 'SEL',
        inactiveLabel: 'OFF',
        ticketLabel: 'Ticket 42',
        onTap: () => tapped = true,
      ),
    ));
    await tester.tap(find.byType(ProductCard));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
flutter test test/widget/product_card_test.dart
```

Expected: error — `ProductCard` not defined.

- [ ] **Step 3: Create the widget**

Create `lib/src/ui/features/products/widgets/product_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/models/product.dart';
import '../../../core/theme.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.isSelected,
    required this.selectedLabel,
    required this.inactiveLabel,
    required this.ticketLabel,
    this.onTap,
    super.key,
  });

  final Product product;
  final bool isSelected;
  final String selectedLabel;
  final String inactiveLabel;
  final String ticketLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final inactive = !product.active;

    return Opacity(
      opacity: inactive ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? EdenredColors.lightSlate : EdenredColors.white,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            border: Border.all(
              color: isSelected
                  ? EdenredColors.redAlert
                  : EdenredColors.borderGray,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: EdenredColors.grayLight,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: EdenredColors.slateMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.label,
                      style: tt.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      ticketLabel,
                      style: tt.bodySmall?.copyWith(
                        color: EdenredColors.slateMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.status.isNotEmpty)
                      Text(
                        product.status,
                        style: tt.bodySmall?.copyWith(
                          color: EdenredColors.slateMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isSelected || inactive)
                _Badge(
                  label: isSelected ? selectedLabel : inactiveLabel,
                  selected: isSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? EdenredColors.redAlert : EdenredColors.grayLight,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: selected ? EdenredColors.white : EdenredColors.slateMuted,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
flutter test test/widget/product_card_test.dart
```

Expected: All 7 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/ui/features/products/widgets/product_card.dart test/widget/product_card_test.dart
git commit -m "feat: add shared ProductCard widget extracted from settings"
```

---

### Task 2: Migrate `SettingsScreen` to use shared `ProductCard`

**Files:**
- Modify: `lib/src/ui/features/settings/views/settings_screen.dart`
- Modify: `test/widget/settings_screen_test.dart`

- [ ] **Step 1: Add a failing test for ticket ID visibility in settings**

Open `test/widget/settings_screen_test.dart`. Add this test inside `main()`, before the closing `}`:

```dart
testWidgets('shows ticket ID for each product', (tester) async {
  final products = [
    const Product(idTicket: 101, label: 'Meal Card', active: true, status: ''),
    const Product(idTicket: 202, label: 'Gift Card', active: true, status: ''),
  ];
  final controller = _makeController(
    products: products,
    selectedProduct: const SelectedProduct(
      idTicket: 101,
      label: 'Meal Card',
      active: true,
      status: '',
    ),
  );

  await tester.pumpWidget(_wrap(SettingsScreen(controller: controller)));

  expect(find.text('Ticket 101'), findsOneWidget);
  expect(find.text('Ticket 202'), findsOneWidget);
});
```

- [ ] **Step 2: Run to confirm the new test fails**

```bash
flutter test test/widget/settings_screen_test.dart
```

Expected: "Ticket 101" / "Ticket 202" not found.

- [ ] **Step 3: Replace `SettingsScreen` implementation**

Replace the full contents of `lib/src/ui/features/settings/views/settings_screen.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../domain/models/product.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/theme.dart';
import '../../app_shell/app_view_model.dart';
import '../../products/widgets/product_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.controller, super.key});

  final AppViewModel controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final products = controller.products;
    final selectedId = controller.selectedProduct?.idTicket;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.chooseCardTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.chooseCardSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: EdenredColors.slateMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = products[index];
                final isSelected = product.idTicket == selectedId;
                return ProductCard(
                  product: product,
                  isSelected: isSelected,
                  selectedLabel: loc.selectedBadge,
                  inactiveLabel: loc.inactiveBadge,
                  ticketLabel: loc.ticketLabel(product.idTicket),
                  onTap: product.active
                      ? () => controller.selectProduct(product)
                      : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Center(
              child: SizedBox(
                width: 200,
                child: OutlinedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(
                    Icons.logout,
                    color: EdenredColors.navyDark,
                  ),
                  label: Text(
                    loc.logoutButton,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: EdenredColors.navyDark,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: EdenredColors.lightSlate,
                    side: const BorderSide(color: EdenredColors.borderGray),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

Note: the `Product` import is kept because `products` is used as a typed list internally and removing it may cause analysis warnings.

- [ ] **Step 4: Run all settings tests**

```bash
flutter test test/widget/settings_screen_test.dart
```

Expected: All 5 tests pass (4 existing + 1 new).

- [ ] **Step 5: Commit**

```bash
git add lib/src/ui/features/settings/views/settings_screen.dart test/widget/settings_screen_test.dart
git commit -m "feat: migrate SettingsScreen to shared ProductCard, show ticket ID"
```

---

### Task 3: Update `ProductPickerScreen` to card style

**Files:**
- Modify: `lib/src/ui/features/products/views/product_picker_screen.dart`
- Create: `test/widget/product_picker_screen_test.dart`

- [ ] **Step 1: Write the failing widget tests**

Create `test/widget/product_picker_screen_test.dart`:

```dart
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
```

- [ ] **Step 2: Run to confirm tests fail**

```bash
flutter test test/widget/product_picker_screen_test.dart
```

Expected: failures — `ProductCard` not found in widget tree, "Ticket 101" not found, etc.

- [ ] **Step 3: Update `ProductPickerScreen`**

Replace the full contents of `lib/src/ui/features/products/views/product_picker_screen.dart` with:

```dart
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../app_shell/app_view_model.dart';
import '../widgets/product_card.dart';

class ProductPickerScreen extends StatelessWidget {
  const ProductPickerScreen({required this.controller, super.key});

  final AppViewModel controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.chooseProduct),
        actions: <Widget>[
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
            tooltip: loc.logoutTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: controller.products.isEmpty
            ? Center(child: Text(loc.noProducts))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                itemCount: controller.products.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return ProductCard(
                    product: product,
                    isSelected: false,
                    selectedLabel: loc.selectedBadge,
                    inactiveLabel: loc.inactiveBadge,
                    ticketLabel: loc.ticketLabel(product.idTicket),
                    onTap: product.active
                        ? () => controller.selectProduct(product)
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run all tests**

```bash
flutter test
```

Expected: All tests pass (65 existing + 7 product_card + 1 settings + 6 picker = 79 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/ui/features/products/views/product_picker_screen.dart test/widget/product_picker_screen_test.dart
git commit -m "feat: update ProductPickerScreen to card style matching settings"
```
