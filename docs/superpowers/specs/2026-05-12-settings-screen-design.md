# Settings Screen Design

**Date:** 2026-05-12
**Status:** Approved

## Overview

Add a Settings tab to the existing bottom navigation bar in `DashboardScreen`. The tab shows a product-card picker (replacing the raw `ListTile` style in `ProductPickerScreen`) and a Logout button. No new state or repositories are required — all data and actions are already on `AppViewModel`.

## Architecture

`DashboardScreen` acts as the tab shell. It already owns `_selectedIndex` and the `_BottomNavBar`. The body becomes an `IndexedStack` with:

- **Index 0** — existing home content (hero balance card, card balance banner, action tiles)
- **Index 2** — new `SettingsScreen` widget

The `AppBar` is made tab-aware: when the Settings tab is active it shows "Settings" as the title with no action buttons. When the Home tab is active it shows the current app title. The logout and change-product `IconButton`s are removed from the `DashboardScreen` AppBar (they move into the Settings screen body). Index 1 (History) is a placeholder for now — `IndexedStack` will show an empty `SizedBox` there.

## New File

`lib/src/ui/features/settings/views/settings_screen.dart`

**Widget:** `SettingsScreen extends StatelessWidget`
**Constructor:** `const SettingsScreen({required this.controller, super.key})`

### Layout

`SettingsScreen` is not a `Scaffold` — it lives inside the parent `DashboardScreen`'s `Scaffold.body`. It returns a `Column`:

```
SafeArea
  Column
    ├── Padding (horizontal: 20, top: 24)
    │   ├── Text("Choose a card to track")   // headline-md, bold
    │   └── Text("Select the primary account...")  // body-md, muted
    ├── Expanded
    │   └── ListView (padding: 20, gap: 8)
    │       └── _ProductCard × n
    └── Padding (horizontal: 20, bottom: 32)
        └── Logout button (centered, max-width 200)
```

### Product Card

Each card is a `GestureDetector` wrapping a `Container` with `borderRadius: 24` and:
- **Selected state** (product.idTicket == controller.selectedProduct?.idTicket): `border: 2px solid redAlert`, `background: lightSlate`, red tint overlay
- **Inactive state** (product.active == false): `border: 1px solid borderGray`, `opacity: 0.6`, `cursor: not-allowed` (disabled gesture)
- **Unselected active**: `border: 1px solid borderGray`, normal opacity, tappable

Row inside: `credit_card` icon (48×48, gray background), product `label` + `status` text, trailing badge.

Badge text/style:
- Selected → "SELECTED", `background: redAlert`, white text
- Inactive → "INACTIVE", `background: grayLight`, muted text
- Active unselected → no badge

### Logout Button

Sits at the bottom of the `Column`, outside the `Expanded` scroll area, so it stays pinned regardless of list length.

Pill-shaped outlined button (border: `borderGray`, background: `lightSlate`), centered, max-width ~200px. Icon: `Icons.logout`. Text: "LOGOUT" (label-lg, uppercase, bold). Calls `controller.logout()`.

## Localization

New keys added to `app_en.arb` and `app_es.arb`:

| Key | EN | ES |
|-----|----|----|
| `settingsTitle` | Settings | Configuración |
| `chooseCardTitle` | Choose a card to track | Elige una tarjeta |
| `chooseCardSubtitle` | Select the primary account you want to manage today. | Selecciona la cuenta principal que quieres gestionar hoy. |
| `selectedBadge` | SELECTED | SELECCIONADA |
| `inactiveBadge` | INACTIVE | INACTIVA |
| `logoutButton` | LOGOUT | CERRAR SESIÓN |

Existing `logoutTooltip` key is left in place (still used by `ProductPickerScreen`).

## DashboardScreen Changes

1. Replace the `body:` with an `IndexedStack(index: _selectedIndex, children: [homebody, SizedBox(), SettingsScreen(...)])`.
2. Make `AppBar` title/actions conditional on `_selectedIndex`:
   - index 0: current title + no actions (logout/change-product buttons removed)
   - index 2: `Text(localizations.settingsTitle)` + no actions
3. Remove the `leading` change-product `IconButton` and logout `IconButton` from the AppBar.

## Explicitly Out of Scope

- `ProductPickerScreen` is **not modified** — it remains the full-screen initial product selection flow used when `AppStatus.needsProductSelection`.
- History tab (index 1) is a stub (`SizedBox()`) — out of scope for this feature.
- No loading indicator for the `selectProduct()` call (the view model already handles refresh internally).
- No confirmation dialog before logout.
- No product icon inference — all products use `Icons.credit_card`.
