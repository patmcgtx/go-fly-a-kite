import Foundation
import SwiftData

enum ModelContainers {
    @MainActor
    static func persistentContainer() throws -> ModelContainer {
        let config = ModelConfiguration()
        return try ModelContainer(for: WeatherWatch.self, configurations: config)
    }

    @MainActor
    static func inMemorySampleContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WeatherWatch.self, configurations: config)
        #if DEBUG
        SampleWeatherWatches.seed(into: container.mainContext)
        #endif
        return container
    }
}
