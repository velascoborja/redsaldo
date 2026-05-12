# Layered Architecture Refactor Design

## Purpose

Refactor the Flutter app to follow the requested layered architecture while preserving existing behavior. The refactor is internal: login, PKCE callback handling, token refresh, Edenred API parsing, selected product persistence, weekly budget calculations, localization, and screen behavior must remain unchanged.

## Current State

The app is small and functional, but several responsibilities are mixed:

- `AppController` acts as both UI state holder and orchestration layer for auth, Edenred API calls, preferences, and budget calculation.
- `EdenredApi` returns models that are consumed directly by UI state.
- `SelectedProductPreference` is a storage DTO that also represents selected product state.
- UI screens live in a flat `ui/` directory and depend directly on the app controller.

## Target Structure

Use the skill's hybrid structure: group data and domain by type, and group UI by feature.

```text
lib/src/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── models/
│   └── use_cases/
└── ui/
    ├── core/
    └── features/
        ├── app_shell/
        ├── auth/
        ├── dashboard/
        └── products/
```

## Data Layer

Data services wrap external systems and platform storage:

- Auth HTTP/token storage remains in data services.
- Edenred HTTP calls remain in a data service.
- Shared preferences access remains in a data service.

Repositories become the single source of truth for ViewModels:

- `AuthRepository` exposes session loading, token exchange, valid access-token retrieval, and logout behavior.
- `EdenredRepository` exposes products, balance, and transactions as domain models.
- `PreferencesRepository` exposes weekly limit and selected product persistence as domain concepts.

Existing tolerant parsing and error messages are preserved unless tests prove the current behavior differs from the refactor.

## Domain Layer

Domain models represent app concepts without UI or platform dependencies:

- Product
- Balance
- Transaction
- Selected product
- Week range
- Weekly budget summary

The current weekly budget calculation moves into a use case. It keeps the same Madrid week boundaries, rounding rules, negative-transaction spend logic, and date label format.

## UI Layer

The UI continues to use `provider` and `ChangeNotifier`.

- `AppController` becomes `AppViewModel` in the app-shell feature.
- Views remain lean Flutter widgets and receive state/commands from the ViewModel.
- Login, login webview, dashboard, and product picker move under feature folders.
- Shared presentation helpers such as theme and money formatting move under `ui/core/`.

The root app remains responsible for creating dependencies and wiring `ChangeNotifierProvider`.

## Dependency Flow

Allowed dependency direction:

```text
ui -> domain
ui -> data repositories
data repositories -> data services
data repositories -> domain
data services -> data models
domain -> no data or ui dependencies
```

UI must not call raw HTTP services or parse persistence DTOs directly.

## Testing

Update existing tests to the new paths and boundaries.

Required verification:

- `rtk flutter analyze`
- `rtk flutter test`

Focused expectations:

- Existing auth, token store, Edenred API, Edenred model, budget, preferences, app flow, and app state tests continue to pass.
- Add or adapt repository/ViewModel tests only where the moved boundary would otherwise leave behavior uncovered.

## Non-Goals

- No visual redesign.
- No new state management package.
- No generated model framework migration.
- No API contract changes.
- No persistence key changes.
- No intentional behavior changes.
