import CoreLocation
import Foundation
import SwiftData
import Testing
@testable import GoFlyAKite

@MainActor
@Suite("AddWatchViewModel")
struct AddWatchViewModelTests {

    @Test("Capturing location transitions to captured with the mock's coordinate")
    func captureLocationSucceeds() async {
        let viewModel = AddWatchViewModel()
        let mockService = MockLocationService()
        mockService.coordinateToReturn = CLLocationCoordinate2D(latitude: 10, longitude: 20)

        await viewModel.captureLocation(using: mockService)

        guard case .captured(let coordinate) = viewModel.locationCaptureState else {
            Issue.record("Expected .captured state")
            return
        }
        #expect(coordinate.latitude == 10)
        #expect(coordinate.longitude == 20)
    }

    @Test("A failing location service transitions to failed")
    func captureLocationFails() async {
        let viewModel = AddWatchViewModel()
        let mockService = MockLocationService()
        mockService.errorToThrow = GoFlyAKiteError.locationUnavailable

        await viewModel.captureLocation(using: mockService)

        guard case .failed = viewModel.locationCaptureState else {
            Issue.record("Expected .failed state")
            return
        }
    }

    @Test("Save inserts a watch once a location has been captured")
    func saveInsertsWatch() async throws {
        let viewModel = AddWatchViewModel()
        viewModel.kind = .faucet
        viewModel.label = "Garage"
        let mockService = MockLocationService()
        await viewModel.captureLocation(using: mockService)

        let container = try ModelContainers.inMemorySampleContainer()
        let context = container.mainContext
        let store = WeatherWatchStore(context: context)
        let saved = viewModel.save(using: store)

        #expect(saved == true)
        let fetched = try context.fetch(FetchDescriptor<WeatherWatch>(predicate: #Predicate { $0.label == "Garage" }))
        #expect(fetched.count == 1)
    }

    @Test("Save fails when no location has been captured")
    func saveFailsWithoutLocation() throws {
        let viewModel = AddWatchViewModel()
        let container = try ModelContainers.inMemorySampleContainer()
        let store = WeatherWatchStore(context: container.mainContext)

        #expect(viewModel.save(using: store) == false)
    }
}
