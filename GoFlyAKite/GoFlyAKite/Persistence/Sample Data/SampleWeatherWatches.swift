import Foundation
import SwiftData

#if DEBUG
enum SampleWeatherWatches {
    @MainActor
    static func seed(into context: ModelContext) {
        let watches = [
            WeatherWatch(kind: .temperature, label: "Backyard", latitude: 37.7749, longitude: -122.4194),
            WeatherWatch(kind: .windSpeed, label: "Garage spigot", latitude: 37.7749, longitude: -122.4194),
            WeatherWatch(kind: .rain, label: "Bus stop", latitude: 37.7749, longitude: -122.4194),
        ]
        for watch in watches {
            context.insert(watch)
        }
    }
}
#endif // DEBUG
