# 🍽️ Edenred 55

A Flutter app for tracking your [Edenred](https://www.edenred.es/) meal card balance and weekly spend.

## ✨ Features

- **OAuth 2.0 + PKCE login** — secure sign-in via an in-app WebView; tokens are stored in the device's secure storage and refreshed automatically
- **Product picker** — choose which Edenred product (card) to track
- **Dashboard** — at a glance view of your available balance, weekly spend, and remaining budget
- **Configurable weekly limit** — set your own weekly spending target and see how much you have left
- **Transaction list** — this week's transactions filtered to the current Madrid-timezone week
- **Pull-to-refresh** — tap the refresh button or pull down to fetch the latest data

## 🚀 Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) SDK `^3.11.5`
- Dart SDK `^3.11.5`

### Run

```bash
flutter pub get
flutter run
```

### Test

```bash
flutter test
```

## 🏗️ Architecture

```
lib/src/
├── auth/        # OAuth 2.0 / PKCE flow, token storage & refresh
├── budget/      # Weekly budget calculator (Madrid timezone)
├── config/      # Edenred API & SSO configuration
├── edenred/     # API client and response models
├── state/       # AppController (ChangeNotifier) — app-wide state
├── storage/     # Shared preferences (weekly limit, selected product)
└── ui/          # Screens: Login, ProductPicker, Dashboard
```

State management uses [Provider](https://pub.dev/packages/provider). The `AppController` drives a simple status machine: `loading → unauthenticated → needsProductSelection → ready`.

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `webview_flutter` | In-app OAuth login |
| `flutter_secure_storage` | Encrypted token storage |
| `shared_preferences` | User preferences (limit, product) |
| `http` | Edenred API calls |
| `timezone` | Madrid-timezone week boundaries |
| `provider` | State management |
| `google_fonts` | Typography |
