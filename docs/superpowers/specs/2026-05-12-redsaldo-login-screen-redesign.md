# Redsaldo Login Screen Redesign

**Date:** 2026-05-12  
**Status:** Approved  
**Source design:** Google Stitch — "Login - Hero Statement" (`projects/5753257348471869008/screens/d396720b61bd49038214b10063bff653`)

## Goal

Replace the current minimal `LoginScreen` with a hero-image-driven welcome screen that matches the Stitch design. The app is being renamed from "Edenred 55" to "Redsaldo" in this screen.

## Scope

- **In scope:** `lib/src/ui/login_screen.dart` only
- **Out of scope:** App title in `MaterialApp`, other screens, routing, auth logic

## Layout

Vertical stack, non-scrollable, full-screen `Scaffold` (no `AppBar`).

```
┌─────────────────────────────────────┐
│                                     │
│      Hero image (food/lunch)        │  Expanded, BoxFit.cover
│                                     │
├─────────────────────────────────────┤
│                                     │
│   [account_balance_wallet icon]     │  size 48, theme primary color
│   Redsaldo                          │  headlineLarge, bold
│   Track your Ticket Restaurant      │  bodyMedium, color scheme onSurface
│   weekly allowance.                 │
│                                     │
│   [Log in with Edenred]             │  FilledButton, full width
│                                     │
│   🔒 We never store your card       │  bodySmall, muted (onSurfaceVariant)
│      numbers or login credentials.  │
│      Your data remains secure.      │
│                                     │
└─────────────────────────────────────┘
```

## Components

| Element | Widget | Notes |
|---|---|---|
| Hero image | `Image.network` inside `Expanded` | `BoxFit.cover`, width: double.infinity |
| Wallet icon | `Icon(Icons.account_balance_wallet)` | size 48, `colorScheme.primary` |
| App name | `Text('Redsaldo')` | `headlineLarge`, `fontWeight.bold` |
| Subtitle | `Text('Track your Ticket Restaurant weekly allowance.')` | `bodyMedium` |
| Login button | `FilledButton` | Full width, existing `onLogin` callback |
| Security row | `Row` with `Icon(Icons.shield)` + `Text` | `bodySmall`, `colorScheme.onSurfaceVariant` |

## Image

- **URL:** `https://lh3.googleusercontent.com/aida-public/AB6AXuBdQXQnQxxTM9AHc_PF0NgBUK9lq6Ze6IIGFy2Cl5-fibJqROl355sJ0FNLtjTRH2G5IdgEO6ilAklQ4EuIIdrk9GL2YEPrUVWnD_-KTPWEz7jwr_07JYl4ofScA_jY0dBRUVa-vvOJjFzDgSBIDzu8sxgExm9QN2uu_k0YkmlTI4yLUSEWYydpVBRR44mSrHzW3n02Qh3PuDzbuJB8w5CNZYYsrBAykjaeabu98FqXjybjW3duO9rgYExv2Gr1gslNdi_1JtHQEfU`
- **Source:** Google-hosted (AIDA public), referenced directly

## Colors / Theme

No new colors introduced. All colors pulled from the existing `Theme.of(context).colorScheme` (seed: `Color(0xffd62828)`).

## Security Message

> "We never store your card numbers or login credentials. Your data remains secure."

Displayed below the button with a `shield` icon prefix, in `bodySmall` / `onSurfaceVariant`.

## What Does Not Change

- `LoginScreen` public API: still takes `onLogin: VoidCallback` and `key`
- Auth logic, routing, all other screens
- `MaterialApp` title ("Edenred 55")
