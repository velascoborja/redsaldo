# Layered Architecture Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the Flutter app into data, domain, and UI layers while preserving existing behavior.

**Architecture:** Keep `provider` and `ChangeNotifier`, but make UI depend on repositories and domain models instead of raw API/storage DTOs. Move external API, secure storage, and shared preferences code into `data`, pure app concepts and budget logic into `domain`, and screens/ViewModels into feature-based `ui` folders.

**Tech Stack:** Flutter, Dart, provider, http, shared_preferences, flutter_secure_storage, timezone, flutter_test.

---

## File Structure

- Create `lib/src/domain/models/product.dart`: immutable product, balance, transaction, selected product domain models.
- Create `lib/src/domain/models/weekly_budget.dart`: immutable week range and weekly budget summary domain models.
- Create `lib/src/domain/use_cases/calculate_weekly_budget.dart`: Madrid-week budget calculation moved from `budget_calculator.dart`.
- Create `lib/src/data/models/edenred_api_models.dart`: existing Edenred JSON parsing models.
- Create `lib/src/data/models/token_models.dart`: existing token response/session models.
- Create `lib/src/data/models/selected_product_preference.dart`: persisted selected-product DTO.
- Create `lib/src/data/services/edenred_api_service.dart`: existing Edenred HTTP service returning API models.
- Create `lib/src/data/services/auth_service.dart`: existing token HTTP service implementing auth repository behavior.
- Create `lib/src/data/services/token_store.dart`: existing secure token backend/store.
- Create `lib/src/data/services/app_preferences_service.dart`: existing shared preferences wrapper.
- Create `lib/src/data/repositories/auth_repository.dart`: auth repository interface.
- Create `lib/src/data/repositories/edenred_repository.dart`: repository interface and implementation mapping API models to domain models.
- Create `lib/src/data/repositories/preferences_repository.dart`: repository interface and implementation mapping persisted DTOs to domain models.
- Create `lib/src/ui/features/app_shell/app_view_model.dart`: renamed `AppController` depending on repositories and use case.
- Move `lib/src/app.dart` to keep app root but update imports and dependencies.
- Move screens into `lib/src/ui/features/auth/views/`, `lib/src/ui/features/dashboard/views/`, and `lib/src/ui/features/products/views/`.
- Move `lib/src/ui/money.dart` and `lib/src/ui/theme.dart` into `lib/src/ui/core/`.
- Delete or leave no longer imported legacy files after all references are moved.
- Update tests to new import paths and add repository tests for API/storage-to-domain mapping.

## Task 1: Domain Models and Budget Use Case

**Files:**
- Create: `lib/src/domain/models/product.dart`
- Create: `lib/src/domain/models/weekly_budget.dart`
- Create: `lib/src/domain/use_cases/calculate_weekly_budget.dart`
- Modify: `test/budget/budget_calculator_test.dart`

- [ ] **Step 1: Update the budget test imports and transaction type**

Use `DomainTransaction` from `domain/models/product.dart` and `calculateWeeklyBudget` from `domain/use_cases/calculate_weekly_budget.dart`. Keep all current expectations unchanged.

- [ ] **Step 2: Run the focused budget test and verify RED**

Run: `rtk flutter test test/budget/budget_calculator_test.dart`

Expected: FAIL because the new domain/use-case files do not exist yet.

- [ ] **Step 3: Add domain models and budget use case**

Move the current `WeekRange`, `WeeklyBudgetSummary`, `currentMadridWeek`, `calculateWeeklyBudget`, and `roundCurrency` behavior into the domain use case. The transaction input type must be `DomainTransaction`, with the same fields currently used by UI/tests.

- [ ] **Step 4: Run the focused budget test and verify GREEN**

Run: `rtk flutter test test/budget/budget_calculator_test.dart`

Expected: PASS with the same budget behavior.

## Task 2: Data Models and Services

**Files:**
- Create: `lib/src/data/models/edenred_api_models.dart`
- Create: `lib/src/data/models/token_models.dart`
- Create: `lib/src/data/models/selected_product_preference.dart`
- Create: `lib/src/data/services/edenred_api_service.dart`
- Create: `lib/src/data/services/auth_service.dart`
- Create: `lib/src/data/services/token_store.dart`
- Create: `lib/src/data/services/app_preferences_service.dart`
- Modify tests under `test/auth/`, `test/edenred/`, and `test/storage/`

- [ ] **Step 1: Update test imports to the target data paths**

Change tests to import token models, token store, auth service, Edenred API models/service, and app preferences service from `lib/src/data/...`.

- [ ] **Step 2: Run focused data tests and verify RED**

Run: `rtk flutter test test/auth test/edenred test/storage`

Expected: FAIL because the target data files do not exist yet.

- [ ] **Step 3: Move existing data code into the data layer**

Move current implementations without changing parsing, storage keys, exception messages, or public method behavior. Rename `EdenredApi` to `EdenredApiService`; keep `EdenredAuthService`, `TokenStore`, `FlutterSecureTokenBackend`, `AppPreferences`, and their exceptions with compatible APIs.

- [ ] **Step 4: Run focused data tests and verify GREEN**

Run: `rtk flutter test test/auth test/edenred test/storage`

Expected: PASS.

## Task 3: Repository Boundaries

**Files:**
- Create: `lib/src/data/repositories/auth_repository.dart`
- Create: `lib/src/data/repositories/edenred_repository.dart`
- Create: `lib/src/data/repositories/preferences_repository.dart`
- Create: `test/data/repositories/edenred_repository_test.dart`
- Create: `test/data/repositories/preferences_repository_test.dart`

- [ ] **Step 1: Add repository tests first**

Add tests proving `EdenredRepositoryImpl` maps `EdenredProductApiModel`, `EdenredBalanceApiModel`, and `EdenredTransactionApiModel` into domain models, and `PreferencesRepositoryImpl` stores and reloads selected products and weekly limits without changing persisted keys.

- [ ] **Step 2: Run repository tests and verify RED**

Run: `rtk flutter test test/data/repositories`

Expected: FAIL because repositories do not exist yet.

- [ ] **Step 3: Implement repositories**

Define small repository interfaces and implementations. `AuthRepository` is implemented by the auth service or by a thin adapter. `EdenredRepositoryImpl` consumes `EdenredApiService` and maps API models to domain models. `PreferencesRepositoryImpl` consumes `AppPreferences` and maps `SelectedProductPreference` to/from `SelectedProduct`.

- [ ] **Step 4: Run repository tests and verify GREEN**

Run: `rtk flutter test test/data/repositories`

Expected: PASS.

## Task 4: App ViewModel and Feature UI Folders

**Files:**
- Create: `lib/src/ui/features/app_shell/app_view_model.dart`
- Create/move: `lib/src/ui/features/auth/views/login_screen.dart`
- Create/move: `lib/src/ui/features/auth/views/login_webview_screen.dart`
- Create/move: `lib/src/ui/features/dashboard/views/dashboard_screen.dart`
- Create/move: `lib/src/ui/features/products/views/product_picker_screen.dart`
- Create/move: `lib/src/ui/core/money.dart`
- Create/move: `lib/src/ui/core/theme.dart`
- Modify: `test/state/app_controller_test.dart`
- Modify: `test/widget/app_flow_test.dart`

- [ ] **Step 1: Update app state tests to target `AppViewModel`**

Rename test imports and fake dependencies to repository interfaces. Keep existing test names and assertions unless the type name changed.

- [ ] **Step 2: Run app state/widget tests and verify RED**

Run: `rtk flutter test test/state/app_controller_test.dart test/widget/app_flow_test.dart`

Expected: FAIL because `AppViewModel` and moved UI files do not exist yet.

- [ ] **Step 3: Move and adapt the ViewModel**

Move `AppController` logic into `AppViewModel`. Keep the same status enum values, public commands, status transitions, error handling, and data exposed to screens. Replace direct preference/API usage with repositories and `calculateWeeklyBudget`.

- [ ] **Step 4: Move views and core UI helpers**

Move screens and presentation helpers into the target UI folders. Update imports only; do not redesign widgets or change localized text.

- [ ] **Step 5: Run app state/widget tests and verify GREEN**

Run: `rtk flutter test test/state/app_controller_test.dart test/widget/app_flow_test.dart`

Expected: PASS.

## Task 5: App Wiring and Legacy Cleanup

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/src/app.dart`
- Delete: old moved files under `lib/src/auth/`, `lib/src/edenred/`, `lib/src/budget/`, `lib/src/state/`, `lib/src/storage/`, and flat `lib/src/ui/` where no longer imported.
- Modify: any remaining tests with stale imports.

- [ ] **Step 1: Update dependency injection**

Construct services and repositories in `main.dart`, then pass repositories/services needed by `Edenred55App`. Keep `http.Client`, `SharedPreferences`, and `TokenStore` construction behavior unchanged.

- [ ] **Step 2: Update root app imports and provider wiring**

Use `ChangeNotifierProvider<AppViewModel>` and route on the same status values to the moved feature views.

- [ ] **Step 3: Remove stale imports and old files**

Use `rtk rg "src/(auth|edenred|budget|state|storage)|src/ui/(dashboard_screen|login_screen|login_webview_screen|money|product_picker_screen|theme)" lib test` to find stale references, then remove legacy files only after no references remain.

- [ ] **Step 4: Run analyzer**

Run: `rtk flutter analyze`

Expected: PASS with no analyzer errors.

- [ ] **Step 5: Run full test suite**

Run: `rtk flutter test`

Expected: PASS.

## Self-Review

- Spec coverage: Tasks cover data services, repositories, domain models/use case, ViewModel, feature UI folders, DI, stale cleanup, and verification.
- Placeholder scan: No placeholder sections remain.
- Type consistency: Domain product/balance/transaction/selected product names are used consistently; API models are explicitly suffixed with `ApiModel`; app UI state becomes `AppViewModel`.
