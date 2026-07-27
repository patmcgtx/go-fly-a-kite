# Go Fly a Kite!

An iOS app that reminds you of weather-dependent events, such as:
* Flying a kite when the wind is (or will be) high
* Dropping the faucet when it's going to freeze
* Grabbing an umbrella when it's going to rain

## Status: vibe-coded work in progress

This is a personal project being built largely with AI assistance (Claude), one pass at a time. It's not a finished app — expect rough edges, missing features, and things that only half-work.

What exists today:
* SwiftUI + SwiftData app, iOS only (iPhone/iPad)
* Add a "watch" (kite/faucet/umbrella) tied to a location, list it, fetch current conditions via WeatherKit
* Background weather monitoring — a `BGTaskScheduler`-driven check runs roughly every 15 minutes, even when the app is closed, and sends a local notification when a watch's condition is met
* Notification deduplication — alerts only fire on a false→true transition, so an ongoing condition doesn't spam repeat notifications
* Watch list shows at-a-glance alert state (icon color, badge, "last notified" timestamp) for any watch that's currently triggered
* Protocol-based services (weather, location, notifications) with mocks for testing, following a layered architecture (see [`GoFlyAKite/docs/ARCHITECTURE.md`](GoFlyAKite/docs/ARCHITECTURE.md))
* Local-only persistence — data is on-device, not synced anywhere yet

Not yet built:
* iCloud/CloudKit sync (the data model is designed to accommodate it later, but it isn't wired up)
* Mac, iPad-optimized, watch, or TV support
* Watch detail view, filtering, and general UI polish
* Advanced notification features (quiet hours, per-watch toggles, notification history, critical alerts)
* Widgets, Live Activities, and Siri/Shortcuts integration

See [`GoFlyAKite/docs/ARCHITECTURE.md`](GoFlyAKite/docs/ARCHITECTURE.md) for the current architecture and its "Future Work" section for what's deliberately deferred.
