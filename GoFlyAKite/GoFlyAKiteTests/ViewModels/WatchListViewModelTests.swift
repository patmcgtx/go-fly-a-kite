import Foundation
import Testing
@testable import GoFlyAKite

@MainActor
@Suite("WatchListViewModel")
struct WatchListViewModelTests {

    @Test("Loading weather for a watch reports the triggered state")
    func refreshWeatherReportsTriggered() async {
        let viewModel = WatchListViewModel()
        let watch = WeatherWatch(kind: .kite, label: "Test", latitude: 0, longitude: 0)
        let mockService = MockWeatherService()
        mockService.snapshotToReturn = WeatherSnapshot(windSpeedMPH: 25, precipitationChance: 0, lowTemperatureF: 60)

        await viewModel.refreshWeather(for: watch, using: mockService)

        guard case .loaded(let snapshot, let triggered) = viewModel.weatherState(for: watch) else {
            Issue.record("Expected .loaded state")
            return
        }
        #expect(snapshot.windSpeedMPH == 25)
        #expect(triggered == true)
    }

    @Test("A failing weather service reports the failed state")
    func refreshWeatherReportsFailure() async {
        let viewModel = WatchListViewModel()
        let watch = WeatherWatch(kind: .umbrella, label: "Test", latitude: 0, longitude: 0)
        let mockService = MockWeatherService()
        mockService.errorToThrow = GoFlyAKiteError.weatherFetchFailed

        await viewModel.refreshWeather(for: watch, using: mockService)

        guard case .failed = viewModel.weatherState(for: watch) else {
            Issue.record("Expected .failed state")
            return
        }
    }
}
