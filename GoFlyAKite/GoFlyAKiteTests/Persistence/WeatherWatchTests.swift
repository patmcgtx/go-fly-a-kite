import CoreLocation
import Foundation
import SwiftData
import Testing
@testable import GoFlyAKite

@MainActor
@Suite("WeatherWatch")
struct WeatherWatchTests {

    @Test("Inserted watch is fetchable via the model context")
    func insertAndFetch() throws {
        let container = try ModelContainers.inMemorySampleContainer()
        let context = container.mainContext

        let watch = WeatherWatch(kind: .kite, label: "Test Field", latitude: 1.0, longitude: 2.0)
        context.insert(watch)

        let fetched = try context.fetch(FetchDescriptor<WeatherWatch>(predicate: #Predicate { $0.label == "Test Field" }))
        #expect(fetched.count == 1)
        #expect(fetched.first?.kind == .kite)
        #expect(fetched.first?.coordinate.latitude == 1.0)
        #expect(fetched.first?.coordinate.longitude == 2.0)
    }

    @Test("Sample container seeds one watch per kind")
    func sampleSeeding() throws {
        let container = try ModelContainers.inMemorySampleContainer()
        let watches = try container.mainContext.fetch(FetchDescriptor<WeatherWatch>())
        #expect(Set(watches.map(\.kind)) == Set(EventKind.allCases))
    }
}
