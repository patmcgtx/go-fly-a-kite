import Foundation
import SwiftData

@MainActor
struct WeatherWatchStore {
    let context: ModelContext

    func commit(_ watch: WeatherWatch) {
        context.insert(watch)
        try? context.save()
    }

    func delete(_ watch: WeatherWatch) {
        context.delete(watch)
        try? context.save()
    }
}
