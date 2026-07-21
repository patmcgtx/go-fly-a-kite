# Architecture Scaffolding Plan (executed)

> This is the plan used to scaffold GoFlyAKite's initial architecture, based on the MapPlus app's patterns. It's kept here for reference — the work described below has been implemented (see `ARCHITECTURE.md` for the resulting design as it stands today).

# Scaffold GoFlyAKite's architecture from MapPlus's pattern

## Context

GoFlyAKite is a new iOS app (weather-event reminders: kite/wind, faucet/freeze, umbrella/rain) currently just the default Xcode SwiftUI+SwiftData template. The user wants its architecture based on their existing app MapPlus (`/Users/patmcg/Code/mapplus`), which has an established layered pattern (protocol-based services + `@Environment` DI + selective `@Observable` MVVM + SwiftData + Swift Testing), documented in `ARCHITECTURE.md`/`CLAUDE.md`. The user already copied `ARCHITECTURE.md`, `CLAUDE.md`, and `LOCALIZATION.md` from MapPlus verbatim into GoFlyAKite's repo root — these still describe MapPlus's domain (Landmark, MapKit, FoundationModels) and need to be rewritten for GoFlyAKite, not lightly edited.

Confirmed decisions:
- **CloudKit/iCloud sync: deferred.** Build local-only SwiftData now (matches MapPlus's own pattern); design models so they won't fight CloudKit later.
- **Weather data: WeatherKit** (first-party, no API key — fits MapPlus's "first-party frameworks only" style).
- **Platforms: iOS only** for this pass (README's iPad/Mac/watch/TV ambitions are future work).

Two things on disk contradict "matches MapPlus's clean local-only state," found while confirming current state:
- `GoFlyAKite.entitlements` already contains `aps-environment` + `com.apple.developer.icloud-services: [CloudKit]` + empty `icloud-container-identifiers` — leftover Xcode capability-toggle cruft. It's **not wired into the build** (no `CODE_SIGN_ENTITLEMENTS` setting in `project.pbxproj` references it), so it's inert, but should be reset to an empty `<dict/>` for hygiene since CloudKit is deferred.
- `Info.plist` has a stray `UIBackgroundModes: [remote-notification]` — also template cruft, unrelated to anything in scope. Drop it; add `NSLocationWhenInUseUsageDescription` instead (needed for the location service).
- Project is also still scoped to `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx xros xrsimulator"` / `TARGETED_DEVICE_FAMILY = "1,2,7"` — multi-platform template default. Since scope is iOS-only for now, narrow **Supported Destinations to iPhone/iPad** — but do this in Xcode's UI, not by hand-editing `project.pbxproj` (fragile/error-prone to hand-edit).

**Also flagging, not blocking:** live `WeatherKitWeatherService` calls need the WeatherKit capability enabled in Xcode Signing & Capabilities (adds `com.apple.developer.weatherkit` entitlement) plus a paid Apple Developer Program membership — a manual, out-of-band step. Code will compile without it; only real device/simulator runs against live weather will fail auth until it's done.

---

## Domain model

One core `@Model`, not MapPlus's three — this domain doesn't need a many-to-many category system yet:

**`Persistence/EventKind.swift`**
```swift
enum EventKind: String, Codable, CaseIterable, Identifiable {
    case kite, faucet, umbrella
    var id: Self { self }
    var symbolName: String { ... }   // SF Symbol per kind
    var titleKey: String { ... }     // localization key
}
```

**`Persistence/WeatherWatch.swift`**
```swift
@Model
final class WeatherWatch {
    var kind: EventKind = EventKind.kite
    var label: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var isEnabled: Bool = true
    var createdAt: Date = Date.now

    var coordinate: CLLocationCoordinate2D {  // computed, not persisted
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(kind: EventKind, label: String, latitude: Double, longitude: Double) { ... }
}
```
Why: lat/lon as plain `Double`s (not a stored `CLLocationCoordinate2D`, which isn't model-storable) with a computed convenience accessor; `EventKind` stored directly rather than as a related `@Model` (closed 3-case set, one-per-watch, no independent lifecycle — MapPlus's `LandmarkCategory` needed a real relationship because categories are independently managed and many-to-many). **Every property has a default and none use `#Unique`** — deliberate CloudKit-forward-compat, since CloudKit requires defaults/optionals and doesn't support `#Unique`. No persisted weather cache or "triggered occurrence" model — fetched weather is transient/in-memory only (`WeatherSnapshot`, below); persisting it would just create a stale-data problem with no current payoff.

Delete (don't adapt) the template's `Item.swift` and `ContentView.swift` — no relationship to this domain, and MapPlus's `@main` shows its root view directly with no generic wrapper view.

---

## Service layer

| Protocol | Real impl | Purpose | Mock |
|---|---|---|---|
| `WeatherService` | `WeatherKitWeatherService` | Fetch conditions for a coordinate → `WeatherSnapshot` | `MockWeatherService` |
| `LocationService` | `CoreLocationService` | One-shot "get current location" (permission + `CLLocationManager`, `CheckedContinuation`-bridged like MapPlus's location service) | `MockLocationService` |
| `NotificationService` | `UserNotificationService` | Request notification auth; schedule/cancel local reminders per watch (`UNUserNotificationCenter`) | `MockNotificationService` |

Mocks live in `Services/Mock services/` (confirmed the convention from the copied `ARCHITECTURE.md`/`CLAUDE.md` — both consistently say this, not "Test Support/Mock services"), `#if DEBUG` wrapped, configurable.

**Key adaptation MapPlus didn't need:** WeatherKit's types (`WeatherKit.CurrentWeather`, `DayWeather`, etc.) have no public initializers, so a mock can't construct them. `WeatherService` must return GoFlyAKite's own value type:
```swift
struct WeatherSnapshot: Equatable {
    var windSpeedMPH: Double
    var precipitationChance: Double  // 0...1
    var lowTemperatureF: Double
}
```
`WeatherKitWeatherService` converts internally.

**No-protocol exceptions** (same reasoning MapPlus used for its SwiftData-backed `CategorySelectionService`/`LandmarkStore` — thin wrappers over an already-swappable dependency don't need a mock):
- `WeatherWatchStore` — thin `ModelContext` commit/delete wrapper for the ViewModels.
- `WeatherAlertEvaluator` — pure function, `static func isTriggered(kind:snapshot:) -> Bool` (wind/temp/precip thresholds per kind). Tested directly with literal `WeatherSnapshot` values — no mock needed since it has no external dependency.

---

## ViewModels and Views (minimal first pass)

Two-screen pair, mirroring MapPlus's `MainMapView` + `LandmarkForm`:

- **`Views/WatchListView.swift`** — top-level screen. `@Query private var watches: [WeatherWatch]` for the persistent list (direct in the view, matching MapPlus's rule); `@State private var viewModel = WatchListViewModel()` for weather-load orchestration. "+" → `.sheet` presenting `AddWatchForm`. No coordinator, matching MapPlus.
- **`Views/View Models/WatchListViewModel.swift`** — `@Observable @MainActor`, owns a `[PersistentIdentifier: WeatherLoadState]` dict and `refreshWeather(for:using:)`.
  ```swift
  enum WeatherLoadState {
      case idle, loading
      case loaded(WeatherSnapshot, triggered: Bool)
      case failed(GoFlyAKiteError)
  }
  ```
- **`Views/Components/WatchRow.swift`** — purely presentational, no ViewModel (per MapPlus's view/VM boundary rule).
- **`Views/AddWatchForm.swift`** + **`Views/View Models/AddWatchViewModel.swift`** — kind picker, label field, "use current location" button driving:
  ```swift
  enum LocationCaptureState {
      case notCaptured, capturing
      case captured(CLLocationCoordinate2D)
      case failed(GoFlyAKiteError)
  }
  ```
  `save(using: WeatherWatchStore)` mirrors `LandmarkFormViewModel.save(using: LandmarkStore)`.
- **`Common/GoFlyAKiteError.swift`** — `LocalizedError` enum (`locationPermissionDenied`, `locationUnavailable`, `weatherFetchFailed`, `notificationPermissionDenied`, `saveFailed`), mirrors `MapPlusError`.

Deferred past this pass (note in ARCHITECTURE.md as planned next work): a `WatchDetailView`, any kind/enabled filtering UI, `Theming/` (left as an empty/unpopulated layer — no theming need yet, avoid over-building the skeleton), `Preferences/AppStorageKeys.swift` (optional — add one real key only if useful now, nothing else depends on it).

---

## File list

All paths relative to `/Users/patmcg/Code/go-fly-a-kite/`.

**Delete:** `GoFlyAKite/GoFlyAKite/Item.swift`, `GoFlyAKite/GoFlyAKite/ContentView.swift`, `GoFlyAKite/GoFlyAKiteTests/GoFlyAKiteTests.swift` (placeholder, replaced by real tests).

**Modify:** `GoFlyAKite/GoFlyAKite/GoFlyAKiteApp.swift` (new `@main` body), `Info.plist` (add location usage string, drop `UIBackgroundModes`), `GoFlyAKite.entitlements` (reset to empty `<dict/>`), `ARCHITECTURE.md`, `CLAUDE.md`, `LOCALIZATION.md` (rewritten, see below).

**Create:**
- `Common/`: `Environment.swift`, `InjectLiveServicesModifier.swift`, `InjectMockServicesModifier.swift` (`#if DEBUG`), `GoFlyAKiteError.swift`
- `Persistence/`: `WeatherWatch.swift`, `EventKind.swift`, `ModelContainers.swift`, `WeatherWatchStore.swift`, `Sample Data/SampleWeatherWatches.swift`
- `Services/Weather/`: `WeatherService.swift`, `WeatherSnapshot.swift`, `WeatherKitWeatherService.swift`
- `Services/Location/`: `LocationService.swift`, `CoreLocationService.swift`
- `Services/Notifications/`: `NotificationService.swift`, `UserNotificationService.swift`
- `Services/Alerts/`: `WeatherAlertEvaluator.swift`
- `Services/Mock services/`: `MockWeatherService.swift`, `MockLocationService.swift`, `MockNotificationService.swift` (all `#if DEBUG`)
- `Views/`: `WatchListView.swift`, `AddWatchForm.swift`, `Components/WatchRow.swift`, `View Models/WatchListViewModel.swift`, `View Models/AddWatchViewModel.swift`
- `Extensions/String+Localized.swift`
- `Localizable.xcstrings` — create via Xcode's File > New > Strings Catalog (don't hand-author the JSON), seed keys: `watch-list-title`, `add-watch`, `kite`, `faucet`, `umbrella`, `save`, `cancel`, `use-current-location`, `location-permission-denied`, `weather-fetch-failed`
- Tests: `GoFlyAKiteTests/Persistence/WeatherWatchTests.swift`, `Services/WeatherAlertEvaluatorTests.swift`, `ViewModels/WatchListViewModelTests.swift`, `ViewModels/AddWatchViewModelTests.swift`

`.claude/settings.local.json`: leave as-is (just a stale local permission grant, harmless).

---

## Doc rewrite plan

**`ARCHITECTURE.md`** — rewrite, not edit; nearly every noun changes: overview → weather-reminder description, frameworks → SwiftUI/SwiftData/WeatherKit/CoreLocation/UserNotifications (drop MapKit/FoundationModels); directory tree `MapPlus/`→`GoFlyAKite/` (mark `Theming/` as reserved/unused); Persistence/Service/ViewModel/View tables replaced per above, with a new called-out paragraph on the CloudKit-forward-compat model design; Data Flow walkthrough rewritten as "Adding a Weather Watch" (same shape: tap + → sheet → capture location → save → `@Query` auto-updates → row appears); Key Patterns section kept **almost verbatim** (drop only the on-device-AI bullet); add a new **Future Work** section listing the three deferrals (CloudKit sync + forward-compat note, multiplatform, `WatchDetailView`/filtering).

**`CLAUDE.md`** — Project Context rewritten; Coding Standards/Specific Rules/"When Making Changes"/"Common Pitfalls"/"Questions to Ask"/"Summary" are generic process content — **keep essentially as-is**, just swap path references and example type names to GoFlyAKite's. **Drop the "Current Test Failures (as of 2026-06-14)" section entirely** — it's stale MapPlus-specific debugging state referencing MapPlus's own mock bugs; carrying it forward (even reworded) would fabricate a false history for a codebase with zero tests yet. Start a "known issues" section empty if one is wanted at all.

**`LOCALIZATION.md`** — mechanics (String Catalog, `.localized` extension, kebab-case/24-char rule, adding strings/languages, Info.plist localization, testing) are generic — **keep as-is**. Replace MapPlus's example keys with GoFlyAKite's real first-pass keys (listed above). Keep the Spanish (`es`) structure but note the catalog starts English-only until someone actually populates `es` translations for these new keys — don't claim Spanish is done. Update the "currently localized system strings" list to `NSLocationWhenInUseUsageDescription`.

---

## Sequencing (compiles at every checkpoint)

1. Docs rewrite (`ARCHITECTURE.md`, `CLAUDE.md`, `LOCALIZATION.md`) — zero compile risk.
2. Strip template: delete `Item.swift`/`ContentView.swift`; temporarily point `GoFlyAKiteApp.swift` at a bare `Text` with an empty `Schema([])`. ✅ builds, blank screen.
3. Add `EventKind.swift`, `WeatherWatch.swift`. ✅ builds standalone.
4. Add `ModelContainers.swift` + `Sample Data/SampleWeatherWatches.swift`; wire `GoFlyAKiteApp.swift` to `ModelContainers.persistentContainer()` with `[WeatherWatch.self]`. ✅ builds, persists empty table.
5. Add the three service protocols + `WeatherSnapshot.swift` (no conformers yet — compiles fine).
6. Add the three real implementations. ✅ builds (WeatherKit import compiles without the capability; only runtime calls need it).
7. Add `Common/Environment.swift` + `InjectLiveServicesModifier.swift`; wire into `GoFlyAKiteApp.swift`.
8. Add the three mocks + `InjectMockServicesModifier.swift` (`#if DEBUG`).
9. Add `WeatherWatchStore.swift`, `WeatherAlertEvaluator.swift`, and `WeatherAlertEvaluatorTests.swift` as the first real test (no mocks needed). ✅ `xcodebuild test` passes one test.
10. Add `WatchListViewModel.swift`, `WatchListView.swift`, `Components/WatchRow.swift`; swap the placeholder `Text` for `WatchListView()`. ✅ run in Simulator, empty list + inert "+" button.
11. Add `AddWatchViewModel.swift`, `AddWatchForm.swift`; wire the "+" sheet. ✅ full create→persist→list-updates flow works end to end.
12. Add `GoFlyAKiteError.swift`, `String+Localized.swift`, the `Localizable.xcstrings` catalog (via Xcode UI) with seed keys; swap literal strings in the two views for `.localized`.
13. (Optional) `Preferences/AppStorageKeys.swift` with one real key.
14. Remaining tests: `WeatherWatchTests.swift` (via `inMemorySampleContainer()`), `WatchListViewModelTests.swift`, `AddWatchViewModelTests.swift` (mocks injected, assert state transitions). Delete placeholder `GoFlyAKiteTests.swift`.
15. `Info.plist`/entitlements cleanup (location usage string, drop `UIBackgroundModes`, reset entitlements). Separately in Xcode: narrow Supported Destinations to iPhone/iPad; enable WeatherKit capability when ready to test live.

---

## Verification

Confirmed: Xcode 26.6, scheme `GoFlyAKite` exists, iOS Simulators available.

**After every checkpoint above — compile check:**
```bash
xcodebuild build \
  -project /Users/patmcg/Code/go-fly-a-kite/GoFlyAKite/GoFlyAKite.xcodeproj \
  -scheme GoFlyAKite \
  -destination 'generic/platform=iOS Simulator'
```

**After steps 9 and 14 — test check:**
```bash
xcodebuild test \
  -project /Users/patmcg/Code/go-fly-a-kite/GoFlyAKite/GoFlyAKite.xcodeproj \
  -scheme GoFlyAKite \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

**After step 11 — manual pass:** launch in Simulator (`-destination 'platform=iOS Simulator,name=iPhone 16'` + `xcodebuild ... build-for-testing`/normal run, or open in Xcode), add a watch via "use current location," confirm it appears in the list.

**Honest limitations:** no useful standalone per-file syntax check exists here — every file depends on cross-file types and framework imports, so `xcodebuild build` is the right (and only reliable) granularity. `#Preview` blocks are only checked by compiling, not rendering (Xcode GUI only). The real `WeatherKitWeatherService`/`CoreLocationService` can't be exercised in headless tests (need entitlement/network/auth or an interactive permission prompt) — ViewModel tests must use the mocks; only manual Simulator runs exercise the real services.
