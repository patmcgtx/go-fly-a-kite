import Foundation
import SwiftData

#if DEBUG
enum SampleWeatherWatches {
    @MainActor
    static func seed(into context: ModelContext) {
        let watches = [
            WeatherWatch(kind: .kite, label: "Backyard", latitude: 37.7749, longitude: -122.4194),
            WeatherWatch(kind: .faucet, label: "Garage spigot", latitude: 37.7749, longitude: -122.4194),
            WeatherWatch(kind: .umbrella, label: "Bus stop", latitude: 37.7749, longitude: -122.4194),
        ]
        for watch in watches {
            context.insert(watch)
        }
    }
}
#endif // DEBUG
