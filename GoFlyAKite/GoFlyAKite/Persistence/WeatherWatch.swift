import CoreLocation
import Foundation
import SwiftData

enum ThresholdComparison: String, Codable, CaseIterable {
    case above
    case below
    
    var displayName: String {
        switch self {
        case .above: return "Above"
        case .below: return "Below"
        }
    }
}

@Model
final class WeatherWatch {
    var id: UUID = UUID()
    var kind: EventKind = EventKind.temperature
    var label: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var isEnabled: Bool = true
    var createdAt: Date = Date.now
    
    // Threshold configuration
    var comparison = ThresholdComparison.above
    var thresholdValue: Double = 0.0

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var conditionDescription: String {
        "\(kind.titleKey) \(comparison.displayName.lowercased()) \(Int(thresholdValue))\(kind.unit)"
    }

    init(kind: EventKind, label: String, latitude: Double, longitude: Double, comparison: ThresholdComparison = .above, thresholdValue: Double = 0.0) {
        self.kind = kind
        self.label = label
        self.latitude = latitude
        self.longitude = longitude
        self.comparison = comparison
        self.thresholdValue = thresholdValue
    }
}
