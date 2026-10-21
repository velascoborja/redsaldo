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

- [Flutter](https://docs.flutter.dev/get-started/install) SDK `>=3.41.2`
- Dart SDK `^3.11.5`

### Run

```bash
flutter pub get
flutter run
```

### Run on iOS

Install Xcode from the Mac App Store and open it once to finish installing its
components and review the license. With Xcode installed at its default location,
configure the tools and download iOS simulator support:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS
```

CocoaPods is also required (`brew install cocoapods` if it is missing). The
project targets iOS 15 or later to match the current Flutter SDK requirement.
Use an iOS 26 or later simulator to exercise the native Liquid Glass navigation.

```bash
flutter pub get
cd ios
pod install
cd ..
open -a Simulator
flutter devices
flutter run -d <ios-simulator-id>
```

For native project settings, open `ios/Runner.xcworkspace` in Xcode after
installing pods. Running on a physical iPhone additionally requires Developer
Mode, trusting the Mac, and selecting your own signing team under Runner →
Signing & Capabilities in Xcode.

The bottom navigation uses native Liquid Glass on iOS 26+ and a matching
Flutter glass bar on Android. Older iOS versions use Cupertino tabs. The Android
approximation uses Flutter backdrop blur and a shader lens that magnifies the
navigation content inside the selected capsule. Refraction requires Impeller,
enabled in the Android manifest; other renderers retain the glass highlights.
iOS 26+ uses `native_liquid_glass`.

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
