import CoreLocation
import Foundation

enum LocationCaptureState: Equatable {
    case notCaptured
    case capturing
    case captured(CLLocationCoordinate2D)
    case failed(GoFlyAKiteError)
    
    static func == (lhs: LocationCaptureState, rhs: LocationCaptureState) -> Bool {
        switch (lhs, rhs) {
        case (.notCaptured, .notCaptured):
            return true
        case (.capturing, .capturing):
            return true
        case (.captured(let lhsCoord), .captured(let rhsCoord)):
            return lhsCoord.latitude == rhsCoord.latitude && 
                   lhsCoord.longitude == rhsCoord.longitude
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

@Observable
@MainActor
final class AddWatchViewModel {
    var kind: EventKind = .temperature
    var label: String = ""
    var comparison: ThresholdComparison = .above
    var thresholdValue: Double = 70.0
    var locationCaptureState: LocationCaptureState = .notCaptured
    
    var defaultThresholdValue: Double {
        switch kind {
        case .temperature:
            return comparison == .above ? 85.0 : 32.0
        case .windSpeed:
            return comparison == .above ? 15.0 : 5.0
        case .rain:
            return comparison == .above ? 0.5 : 0.1
        }
    }
    
    var thresholdStep: Double {
        switch kind {
        case .temperature: return 1.0
        case .windSpeed: return 1.0
        case .rain: return 0.1
        }
    }
    
    var thresholdRange: ClosedRange<Double> {
        switch kind {
        case .temperature: return -20.0...120.0
        case .windSpeed: return 0.0...100.0
        case .rain: return 0.0...10.0
        }
    }

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
        let watch = WeatherWatch(
            kind: kind,
            label: label,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            comparison: comparison,
            thresholdValue: thresholdValue
        )
        store.commit(watch)
        return true
    }
}
