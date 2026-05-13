# History Screen — Current Week Filter

**Date:** 2026-05-13  
**Status:** Approved

## Problem

The history screen currently shows all transactions returned by the API. The requirement is to show only transactions from the current week, with an empty state when there are none.

## Decision

Use `controller.summary?.transactions` in `HistoryScreen` instead of `controller.transactions`.

`WeeklyBudgetSummary.transactions` is already filtered to the current Madrid week (Monday–Sunday, Europe/Madrid timezone) by `calculateWeeklyBudget`. This data is computed on every `refreshDashboard` call and stored in `AppViewModel.summary`.

## Scope

**One file, one line change:**

- `lib/src/ui/features/history/views/history_screen.dart`
  - `final transactions = controller.transactions;`
  - → `final transactions = controller.summary?.transactions ?? [];`

## Behaviour

| State | Result |
|---|---|
| `summary` is null (still loading) | `[]` → empty state shown |
| Current week has transactions | List shown, filtered to current week |
| Current week has no transactions | `[]` → empty state shown |

## Out of Scope

- No changes to `AppViewModel`, `calculateWeeklyBudget`, or the data layer
- No UI label changes (the "recentSpending" title remains appropriate)
- No pagination or date-range picker
