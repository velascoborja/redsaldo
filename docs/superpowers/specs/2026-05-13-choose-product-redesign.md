# Choose Product Screen Redesign

**Date:** 2026-05-13
**Status:** Approved

## Goal

Make `ProductPickerScreen` use the same card-style UI as `SettingsScreen`, while keeping the AppBar. Both screens will also show the ticket ID in the card subtitle.

## Files Changed

| File | Change |
|------|--------|
| `lib/src/ui/features/products/widgets/product_card.dart` | New — shared `ProductCard` + `_Badge` |
| `lib/src/ui/features/settings/views/settings_screen.dart` | Use `ProductCard`, pass ticket label, remove local `_ProductCard`/`_Badge` |
| `lib/src/ui/features/products/views/product_picker_screen.dart` | Replace `ListTile`+`Divider` with `ProductCard`, always `isSelected: false` |

## Shared Widget: `ProductCard`

**Location:** `lib/src/ui/features/products/widgets/product_card.dart`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `product` | `Product` | The product model |
| `isSelected` | `bool` | Highlights card with red border and shows "SELECTED" badge |
| `selectedLabel` | `String` | Localized label for the selected badge |
| `inactiveLabel` | `String` | Localized label for the inactive badge |
| `ticketLabel` | `String` | Pre-formatted ticket string, e.g. "Ticket 12345" (caller builds from `loc.ticketLabel(product.idTicket)`) |
| `onTap` | `VoidCallback?` | Null for inactive products |

**Card layout (row):**
- Left: 48×48 rounded square with `Icons.credit_card` icon (`EdenredColors.slateMuted`)
- Middle (expanded column):
  - `product.label` — `titleMedium`, ellipsis overflow
  - `ticketLabel` — `bodySmall`, `EdenredColors.slateMuted`, always shown
  - `product.status` — `bodySmall`, `EdenredColors.slateMuted`, shown only when non-empty
- Right: `_Badge` — shown when `isSelected` OR `!product.active`
  - "SELECTED": red background, white text
  - "INACTIVE": gray background, muted text
  - Nothing shown when active and not selected

**Inactive state:** wrapped in `Opacity(opacity: 0.6)` when `!product.active`.

**`_Badge`** is a private widget within the same file.

## `ProductPickerScreen` Changes

- Keep `Scaffold` + `AppBar` unchanged (title "Choose product", logout icon)
- Replace `ListView.separated` body:
  - Remove `ListTile` + `Divider` separator
  - Use `ProductCard` with `SizedBox(height: 8)` as separator (matching settings padding)
  - Pass `isSelected: false` always
  - Pass `ticketLabel: loc.ticketLabel(product.idTicket)` (no status in ticket label — status shown in card body from `product.status`)
  - Keep empty state: `Center(child: Text(loc.noProducts))`
- Padding: `EdgeInsets.fromLTRB(20, 8, 20, 8)` (matching settings list padding)

## `SettingsScreen` Changes

- Import `ProductCard` from the new shared file
- Pass `ticketLabel: loc.ticketLabel(product.idTicket)` to each card
- Remove local `_ProductCard` and `_Badge` class definitions

## What Doesn't Change

- AppBar on `ProductPickerScreen` (title, logout icon)
- Settings screen header (title/subtitle/logout button)
- All localization strings (reuses existing `ticketLabel`, `selectedBadge`, `inactiveBadge`)
- `Product` model
- Routing/navigation
