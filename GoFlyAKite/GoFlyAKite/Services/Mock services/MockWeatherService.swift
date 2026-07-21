import CoreLocation
import Foundation

#if DEBUG
final class MockWeatherService: WeatherService {
    var snapshotToReturn = WeatherSnapshot(windSpeedMPH: 12, precipitationChance: 0.1, lowTemperatureF: 55)
    var errorToThrow: Error?

    func snapshot(at coordinate: CLLocationCoordinate2D) async throws -> WeatherSnapshot {
        if let errorToThrow {
            throw errorToThrow
        }
        return snapshotToReturn
    }
}
#endif // DEBUG
