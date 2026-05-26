# History Screen — Week Scope Indicator

**Date:** 2026-05-26

## Problem

The History screen shows only the current week's transactions but gives no visual signal of this. Users see a list with no explanation of why older transactions are absent.

## Solution

Add two elements directly below the "Recent spending" heading:

1. **Date-range chip** — a pill with a red dot and the current week's date range (e.g. "20 May – 26 May"), sourced from `controller.summary!.range.label`.
2. **Explanatory line** — small grey text reading "Showing this week's transactions only" (new `AppLocalizations` key: `showingThisWeekOnly`).

## Visual Design

```
Recent spending
[● 20 May – 26 May]          ← pill: bg #F0EDEF, red dot, navyDark text, rounded
Showing this week's           ← bodySmall, slateLight colour
transactions only
```

Chip styling mirrors the existing `_NotCountedBadge`: background `Color(0xFFF0EDEF)`, border-radius 20, `Manrope` 11px semi-bold.

## Scope

| File | Change |
|------|--------|
| `lib/src/ui/features/history/views/history_screen.dart` | Add `_WeekChip` widget; insert chip + explanatory text in `HistoryScreen.build` |
| `lib/src/l10n/app_en.arb` | Add `showingThisWeekOnly` key |
| `lib/src/l10n/app_es.arb` | Add translated string |

No changes to `AppViewModel`, domain models, or routing.

## Constraints

- Both elements are inside the non-empty branch where `controller.summary` is guaranteed non-null.
- `range.label` is already formatted for display; no additional date formatting needed.
- Spacing: 8 px gap between title and chip, 4 px between chip and explanatory text, existing 16 px gap to the list unchanged.

## Out of Scope

- Showing transactions from multiple weeks
- A date-range picker or filter UI
- Changes to the empty state
