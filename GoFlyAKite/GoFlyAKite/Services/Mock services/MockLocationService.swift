import CoreLocation
import Foundation

#if DEBUG
final class MockLocationService: LocationService {
    var coordinateToReturn = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    var errorToThrow: Error?

    func currentLocation() async throws -> CLLocationCoordinate2D {
        if let errorToThrow {
            throw errorToThrow
        }
        return coordinateToReturn
    }
}
#endif // DEBUG
