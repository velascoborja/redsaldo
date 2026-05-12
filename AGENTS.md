# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter application. The entry point is `lib/main.dart`, with app setup in `lib/src/app.dart`. Feature and infrastructure code is under `lib/src/`: `auth/` for OAuth, PKCE, tokens, and secure storage; `edenred/` for API models and client code; `budget/` for calculations; `state/` for controllers and gateways; `storage/` for preferences; and `ui/` for screens and theming. Platform projects live in `android/` and `ios/`. Tests mirror source areas under `test/`.

## Build, Test, and Development Commands

Use Flutter tooling from the repository root:

```bash
rtk flutter pub get
rtk flutter run
rtk flutter analyze
rtk flutter test
rtk flutter build apk
rtk flutter build ios
```

`flutter pub get` installs dependencies. `flutter run` starts the app on a device or simulator. `flutter analyze` enforces analyzer and lint rules. `flutter test` runs unit and widget tests. Build commands produce release artifacts; iOS builds require Xcode and CocoaPods setup.

## Coding Style & Naming Conventions

Follow Dart and Flutter defaults with two-space indentation. The analyzer includes `package:flutter_lints/flutter.yaml` plus stricter rules in `analysis_options.yaml`: always declare return types, avoid `print`, prefer `final` locals, and use trailing commas where supported. Use `snake_case.dart` file names, `PascalCase` classes/widgets, and `lowerCamelCase` methods, fields, variables, and test names. Keep UI code in `lib/src/ui/`, business logic outside widgets where practical, and use existing controllers/gateways for state and dependencies.

## Testing Guidelines

Use `flutter_test` for unit and widget coverage; mocks may use `mockito` and generated code via `build_runner` when needed. Name tests after the unit under test, for example `auth_service_test.dart` or `budget_calculator_test.dart`. Add or update tests with behavior changes, especially in auth, persistence, API parsing, and budget calculations. Run `rtk flutter test` before submitting changes, and run `rtk flutter analyze` for lint coverage.

## Commit & Pull Request Guidelines

No Git history is present in this checkout, so no repository-specific commit convention can be inferred. Use short, imperative commit subjects such as `Add token refresh handling` or `Fix budget rounding`. Pull requests should include a concise summary, test results, linked issue or task, and screenshots or recordings for UI changes. Call out configuration, platform, or migration impacts explicitly.

## Security & Configuration Tips

Do not commit secrets, client credentials, signing keys, or local machine paths. Review `lib/src/config/edenred_config.dart`, Android manifests, and iOS plist/entitlement changes carefully when editing OAuth, callback URLs, or platform permissions.
