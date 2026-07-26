import Foundation
import SwiftData

enum WeatherLoadState {
    case idle
    case loading
    case loaded(WeatherSnapshot, triggered: Bool)
    case failed(GoFlyAKiteError)
}

@Observable
@MainActor
final class WatchListViewModel {
    var isShowingAddWatchSheet = false
    private var weatherStateByWatchID: [PersistentIdentifier: WeatherLoadState] = [:]

    func weatherState(for watch: WeatherWatch) -> WeatherLoadState {
        weatherStateByWatchID[watch.persistentModelID] ?? .idle
    }

    func refreshWeather(for watch: WeatherWatch, using weatherService: WeatherService) async {
        weatherStateByWatchID[watch.persistentModelID] = .loading
        do {
            let snapshot = try await weatherService.snapshot(at: watch.coordinate)
            let triggered = WeatherAlertEvaluator.isTriggered(watch: watch, snapshot: snapshot)
            weatherStateByWatchID[watch.persistentModelID] = .loaded(snapshot, triggered: triggered)
        } catch {
            weatherStateByWatchID[watch.persistentModelID] = .failed(.weatherFetchFailed)
        }
    }
}
