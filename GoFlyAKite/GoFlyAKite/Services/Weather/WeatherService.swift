import CoreLocation
import Foundation

protocol WeatherService {
    func snapshot(at coordinate: CLLocationCoordinate2D) async throws -> WeatherSnapshot
}
