import CoreLocation
import Foundation

enum LocationCaptureState {
    case notCaptured
    case capturing
    case captured(CLLocationCoordinate2D)
    case failed(GoFlyAKiteError)
}

@Observable
@MainActor
final class AddWatchViewModel {
    var kind: EventKind = .kite
    var label: String = ""
    var locationCaptureState: LocationCaptureState = .notCaptured

    func captureLocation(using locationService: LocationService) async {
        locationCaptureState = .capturing
        do {
            let coordinate = try await locationService.currentLocation()
            locationCaptureState = .captured(coordinate)
        } catch {
            locationCaptureState = .failed(.locationUnavailable)
        }
    }

    func save(using store: WeatherWatchStore) -> Bool {
        guard case .captured(let coordinate) = locationCaptureState else { return false }
        let watch = WeatherWatch(kind: kind, label: label, latitude: coordinate.latitude, longitude: coordinate.longitude)
        store.commit(watch)
        return true
    }
}
