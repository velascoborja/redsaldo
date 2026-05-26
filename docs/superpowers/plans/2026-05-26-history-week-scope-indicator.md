# History Week Scope Indicator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a date-range chip and explanatory subtitle below the "Recent spending" heading in the History screen so users know they are seeing the current week only.

**Architecture:** Two new elements are inserted into the existing `ListView` in `HistoryScreen.build`, directly after the title: a `_WeekChip` widget that renders the pre-computed `range.label` string (e.g. "20 May – 26 May"), followed by a single line of explanatory body text from `AppLocalizations`. A new localization key `showingThisWeekOnly` carries the user-facing sentence.

**Tech Stack:** Flutter widgets, `google_fonts`, `AppLocalizations` (ARB + `flutter gen-l10n`), `EdenredColors`.

---

## File Map

| File | Change |
|------|--------|
| `lib/l10n/app_en.arb` | Add `showingThisWeekOnly` key |
| `lib/l10n/app_es.arb` | Add translated key |
| `lib/src/l10n/app_localizations.dart` | **Generated** — do not edit by hand |
| `lib/src/l10n/app_localizations_en.dart` | **Generated** — do not edit by hand |
| `lib/src/l10n/app_localizations_es.dart` | **Generated** — do not edit by hand |
| `lib/src/ui/features/history/views/history_screen.dart` | Add `_WeekChip` widget; insert chip + subtitle in `HistoryScreen.build` |
| `test/widget/history_screen_test.dart` | Add two tests: chip visible, explanatory text visible |

---

### Task 1: Add localization strings and regenerate

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_es.arb`

- [ ] **Step 1: Add the English string**

In `lib/l10n/app_en.arb`, add the new key after `"recentSpending"`:

```json
  "recentSpending": "Recent spending",
  "showingThisWeekOnly": "Showing this week's transactions only",
```

- [ ] **Step 2: Add the Spanish string**

In `lib/l10n/app_es.arb`, add the new key after `"recentSpending"`:

```json
  "recentSpending": "Gastos recientes",
  "showingThisWeekOnly": "Mostrando solo las transacciones de esta semana",
```

- [ ] **Step 3: Regenerate localization files**

```bash
flutter gen-l10n
```

Expected: no errors. The command reads `l10n.yaml` and writes to `lib/src/l10n/`.

- [ ] **Step 4: Verify the key was generated**

```bash
grep "showingThisWeekOnly" lib/src/l10n/app_localizations.dart
```

Expected output (one match):

```
  String get showingThisWeekOnly;
```

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_en.arb lib/l10n/app_es.arb lib/src/l10n/
git commit -m "feat: add showingThisWeekOnly localization string"
```

---

### Task 2: Add tests, implement widget, verify

**Files:**
- Modify: `test/widget/history_screen_test.dart`
- Modify: `lib/src/ui/features/history/views/history_screen.dart`

- [ ] **Step 1: Write the failing tests**

Add two new `testWidgets` calls in `test/widget/history_screen_test.dart`, after the existing three tests:

```dart
testWidgets('shows week range chip when transactions exist', (tester) async {
  final controller = _makeController(
    weekTransactions: [
      _tx(businessName: 'Burger Palace', amount: -8.50),
    ],
  );

  await tester.pumpWidget(_wrap(HistoryScreen(controller: controller)));

  // The chip displays the label from WeekRange — '12 May - 18 May' in the test helper.
  expect(find.text('12 May - 18 May'), findsOneWidget);
});

testWidgets('shows explanatory subtitle when transactions exist', (
  tester,
) async {
  final controller = _makeController(
    weekTransactions: [
      _tx(businessName: 'Burger Palace', amount: -8.50),
    ],
  );

  await tester.pumpWidget(_wrap(HistoryScreen(controller: controller)));

  expect(
    find.text("Showing this week's transactions only"),
    findsOneWidget,
  );
});
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
flutter test test/widget/history_screen_test.dart --name "shows week range chip|shows explanatory subtitle"
```

Expected: both tests FAIL with "Expected: exactly one matching node; Actual: found 0".

- [ ] **Step 3: Implement `_WeekChip` and wire it into `HistoryScreen`**

Replace the entire `history_screen.dart` with the following (everything outside `_TransactionCard`, `_TransactionIcon`, `_NotCountedBadge`, and `_EmptyState` is changed):

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../domain/models/product.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/theme.dart';
import '../../app_shell/app_view_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.controller, super.key});

  final AppViewModel controller;

  @override
  Widget build(BuildContext context) {
    final transactions = controller.summary?.transactions ?? [];
    final loc = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return transactions.isEmpty
        ? _EmptyState()
        : SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.refreshDashboard,
              color: EdenredColors.redAlert,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Text(
                    loc.recentSpending,
                    style: tt.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  _WeekChip(label: controller.summary!.range.label),
                  const SizedBox(height: 4),
                  Text(
                    loc.showingThisWeekOnly,
                    style: tt.bodySmall?.copyWith(
                      color: EdenredColors.slateLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final t in transactions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TransactionCard(transaction: t),
                    ),
                ],
              ),
            ),
          );
  }
}

// ── Week Chip ─────────────────────────────────────────────────────────────────

class _WeekChip extends StatelessWidget {
  const _WeekChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: const BoxDecoration(
            color: Color(0xFFF0EDEF),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: EdenredColors.redAlert,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: EdenredColors.navyDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Transaction Card ──────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final DomainTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isTopUp = transaction.amount >= 0;
    final dayLabel = intl.DateFormat('EEE').format(transaction.dateUtc.toLocal());
    final displayName = transaction.businessName.isNotEmpty
        ? transaction.businessName
        : transaction.description;

    final sign = isTopUp ? '+' : '';
    final amountText = '$sign${transaction.amount.toStringAsFixed(2)} EUR';
    final amountColor = isTopUp ? EdenredColors.slateLight : EdenredColors.navyDark;

    return Container(
      decoration: const BoxDecoration(
        color: EdenredColors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _TransactionIcon(isTopUp: isTopUp),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: tt.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dayLabel,
                      style: tt.bodySmall?.copyWith(
                        color: EdenredColors.slateLight,
                        height: 1.2,
                      ),
                    ),
                    if (isTopUp) ...[
                      const SizedBox(width: 6),
                      _NotCountedBadge(),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amountText,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({required this.isTopUp});

  final bool isTopUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFF0EDEF),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Icon(
        isTopUp ? Icons.account_balance : Icons.restaurant,
        size: 22,
        color: EdenredColors.navyDark,
      ),
    );
  }
}

class _NotCountedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: EdenredColors.slateLight),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(
        AppLocalizations.of(context).notCounted,
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: EdenredColors.slateLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EDEF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 36,
                  color: EdenredColors.slateLight,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                loc.noTransactionsTitle,
                style: tt.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.noTransactionsBody,
                style: tt.bodySmall?.copyWith(color: EdenredColors.slateLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run all history screen tests**

```bash
flutter test test/widget/history_screen_test.dart
```

Expected: all 5 tests pass (3 existing + 2 new).

- [ ] **Step 5: Run the full test suite to catch regressions**

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add test/widget/history_screen_test.dart \
        lib/src/ui/features/history/views/history_screen.dart
git commit -m "feat: add week scope chip and subtitle to history screen"
```
