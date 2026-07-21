import Foundation
import SwiftData

@MainActor
struct WeatherWatchStore {
    let context: ModelContext

    func commit(_ watch: WeatherWatch) {
        context.insert(watch)
    }

    func delete(_ watch: WeatherWatch) {
        context.delete(watch)
    }
}
