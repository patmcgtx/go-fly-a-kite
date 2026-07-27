import CoreLocation
import Foundation

#if DEBUG
final class MockWeatherService: WeatherService {
    var snapshotToReturn = WeatherSnapshot(
        windSpeedMPH: 12,
        maxWindSpeedMPH: 18,
        precipitationChance: 0.1,
        lowTemperatureF: 55,
        highTemperatureF: 75,
        currentTemperatureF: 65,
        rainAccumulationInches: 0.0
    )
    var errorToThrow: Error?

    func snapshot(at coordinate: CLLocationCoordinate2D) async throws -> WeatherSnapshot {
        if let errorToThrow {
            throw errorToThrow
        }
        return snapshotToReturn
    }
}
#endif // DEBUG
