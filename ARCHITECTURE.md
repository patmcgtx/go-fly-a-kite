# GoFlyAKite Architecture

## Overview

GoFlyAKite is an iOS app that reminds you of weather-related events: flying a kite when wind will be high, dropping the faucet when it's going to freeze, or grabbing an umbrella when it's going to rain. It uses a pragmatic hybrid of MVVM and SwiftData reactivity, with protocol-based services for testability — the same architectural style as MapPlus, adapted to a weather-reminder domain.

**Core frameworks:** SwiftUI, SwiftData, WeatherKit, CoreLocation, UserNotifications

---

## Directory Structure

```
GoFlyAKite/
├── GoFlyAKite/               # App source code
│   ├── Common/                 # App entry point (GoFlyAKiteApp.swift), Environment, shared types
│   ├── Extensions/              # Swift extensions
│   ├── Persistence/              # SwiftData models + containers/stores
│   ├── Preferences/               # App settings / AppStorage keys
│   ├── Services/                   # Business logic and external APIs
│   ├── Theming/                     # Reserved for future use — no theming need yet
│   └── Views/                        # SwiftUI views (incl. Views/View Models/)
├── GoFlyAKiteTests/             # Unit tests (Swift Testing)
└── GoFlyAKiteUITests/           # UI tests
```

## Concurrency

Modern Swift Concurrency (async/await) is used for all concurrency needs.

---

## Layers

### 1. Persistence Layer (SwiftData Models)

One `@Model` type forms the data model for this first pass:

| Model | Role |
|---|---|
| `WeatherWatch` | Core entity — the user's configured "watch me for this condition at this place" (kind, label, location, enabled flag) |

`EventKind` (kite/faucet/umbrella) is stored directly as an enum property on `WeatherWatch` rather than as a separate related model — it's a closed, small set that belongs to exactly one watch, unlike MapPlus's `LandmarkCategory`, which needed a real many-to-many relationship because categories are independently managed.

**CloudKit-forward-compat note:** every `WeatherWatch` property has a default value, and no `#Unique` constraints are used anywhere in the model. This is deliberate — CloudKit requires all properties to have a default or be optional, and doesn't support `#Unique` constraints. iCloud sync is deferred for now (see Future Work), but the model is designed so adding it later won't require reworking the schema.

Fetched weather data is **not persisted** — it's transient, in-memory-only state (`WeatherSnapshot`, see Service Layer) held by the view model. Persisting it would introduce a stale-data problem with no current benefit.

`ModelContainers.swift` provides factory methods for both production and in-memory test containers.

`WeatherWatchStore` is a thin service over SwiftData for committing/deleting watches from view models.

### 2. Service Layer

Services encapsulate external API calls and business logic behind protocols. Each service has a real implementation and a mock for testing.

| Protocol | Real Implementation | Purpose |
|---|---|---|
| `WeatherService` | `WeatherKitWeatherService` | Fetch current conditions for a coordinate via WeatherKit, returned as a `WeatherSnapshot` |
| `LocationService` | `CoreLocationService` | Get the user's current location (permission handling + `CLLocationManager`) |
| `NotificationService` | `UserNotificationService` | Request notification authorization; schedule/cancel local reminders per watch |

Services are injected into views via SwiftUI `@Environment` values (defined in `Environment.swift`), allowing easy swapping of mocks in tests without constructor changes.

**Why `WeatherService` returns `WeatherSnapshot`, not WeatherKit's own types:** WeatherKit's types (`WeatherKit.CurrentWeather`, `DayWeather`, etc.) have no public initializers, so a mock can't construct them. `WeatherSnapshot` is GoFlyAKite's own plain value type (wind speed, precipitation chance, low temperature); `WeatherKitWeatherService` converts internally.

#### Mock service

All mock services belong under `GoFlyAKite/Services/Mock services`.

Mock services should be surrounded by `#if DEBUG` and `#endif // DEBUG` so they only build for development.

#### No-protocol exceptions

Not every piece of logic needs a protocol + mock — only things that wrap an external dependency that isn't already swappable in tests:

- `WeatherWatchStore` is a thin wrapper over `ModelContext`, which is already swappable via in-memory containers, so it doesn't need its own protocol/mock.
- `WeatherAlertEvaluator` is a pure function (`static func isTriggered(kind:snapshot:) -> Bool`) with no external dependency — it's tested directly with literal `WeatherSnapshot` values.

### 3. ViewModel Layer

ViewModels use the `@Observable` macro and are bound to `@MainActor`. They orchestrate service calls, manage multi-step interaction states via enums, and expose reactive properties to views.

| ViewModel | Drives | Key Responsibility |
|---|---|---|
| `WatchListViewModel` | `WatchListView` | Per-watch weather load state, add-sheet visibility |
| `AddWatchViewModel` | `AddWatchForm` | Create mode, location-capture lifecycle, save state |

State machines are represented as enums with associated values, for example:

```swift
enum LocationCaptureState {
    case notCaptured
    case capturing
    case captured(CLLocationCoordinate2D)
    case failed(GoFlyAKiteError)
}

enum WeatherLoadState {
    case idle
    case loading
    case loaded(WeatherSnapshot, triggered: Bool)
    case failed(GoFlyAKiteError)
}
```

### 4. View Layer

Views are SwiftUI and generally own no business logic — they bind to a ViewModel or SwiftData `@Query`, and forward user actions to the ViewModel.

Use a dedicated ViewModel when a view needs async work, service orchestration, explicit error handling, or a multi-step state machine. Keep a view view-only when it is purely presentational or limited to lightweight local UI state such as disclosure, sheet, or picker selection.

| View | Role |
|---|---|
| `WatchListView` | Primary list of configured weather watches, with per-row weather status |
| `AddWatchForm` | Create a new watch — kind picker, label, capture current location |
| `WatchRow` | Presentational row showing one watch + its current weather load state |

Top-level persistent state (all watches) is fetched reactively with `@Query`, which auto-updates when SwiftData models change.

---

## Data Flow

### Adding a Weather Watch (end-to-end example)

```
User taps "+" on WatchListView
  → WatchListViewModel.isShowingAddWatchSheet = true
  → AddWatchForm presented
  → User picks a kind (kite/faucet/umbrella) and taps "Use current location"
  → AddWatchViewModel.captureLocation()
  → LocationService → CLLocationCoordinate2D
  → LocationCaptureState becomes .captured(coordinate)
  → User taps Save
  → AddWatchViewModel.save(using: WeatherWatchStore)
  → WeatherWatchStore.commit() inserts WeatherWatch into SwiftData
  → @Query in WatchListView auto-observes change
  → New row appears in the list
```

---

## Key Patterns

**Protocol-based services with environment injection** — every external dependency is behind a protocol, injected via `@Environment`, and mocked in tests.

**@Observable ViewModels** — uses Swift 5.9+ `@Observable` macro rather than `ObservableObject`/Combine.

**State machine enums** — multi-step flows (location capture, weather load, save) are modeled as enums with associated values rather than multiple boolean flags.

**View-model boundary** — async loading, service-backed interaction flows, and recoverable error states belong in a ViewModel; simple rendering and lightweight local presentation state can stay in the view.

**SwiftData reactivity** — `@Query` replaces explicit fetch/refresh cycles; the view layer reacts automatically to model changes.

---

## Localization

See LOCALIZATION.md for localization instructions.

---

## Testing

Tests live under `GoFlyAKiteTests/` and use the **Swift Testing** framework (`@Test` macros).

- ViewModels are tested by injecting mock services and asserting state transitions
- SwiftData operations use in-memory containers from `ModelContainers.inMemorySampleContainer()`
- Parameterized tests (`@Test(arguments:)`) cover multi-case scenarios
- Mock service implementations (`MockWeatherService`, `MockLocationService`, `MockNotificationService`) mirror the protocols exactly and are used for tests and DEBUG previews
- `WeatherAlertEvaluator` is tested directly with literal `WeatherSnapshot` values — no mock needed

---

## Future Work

These are explicitly out of scope for this first pass, deferred by design:

- **iCloud/CloudKit sync** — the README calls for it, and the `WeatherWatch` model above is designed to accommodate it later (defaults on every property, no `#Unique`), but it isn't wired up yet. Adding it means switching `ModelConfiguration` to a CloudKit-backed one and enabling the iCloud/CloudKit capability + container entitlement.
- **Multiplatform** — iPad/Mac/watch/TV targets from the README are future additions; this pass is iOS-only (iPhone/iPad).
- **`WatchDetailView`** and any kind/enabled filtering UI — not required to prove the architecture end-to-end.
- **`Theming/`** — the folder is part of the layered pattern but intentionally left unpopulated until there's a real theming need.
