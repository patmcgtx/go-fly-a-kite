import CoreLocation
import Foundation

protocol LocationService {
    func currentLocation() async throws -> CLLocationCoordinate2D
}
