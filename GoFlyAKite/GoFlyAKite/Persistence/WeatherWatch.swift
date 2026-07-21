import CoreLocation
import Foundation
import SwiftData

@Model
final class WeatherWatch {
    var id: UUID = UUID()
    var kind: EventKind = EventKind.kite
    var label: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var isEnabled: Bool = true
    var createdAt: Date = Date.now

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(kind: EventKind, label: String, latitude: Double, longitude: Double) {
        self.kind = kind
        self.label = label
        self.latitude = latitude
        self.longitude = longitude
    }
}
