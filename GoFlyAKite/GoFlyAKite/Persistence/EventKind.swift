import Foundation

enum EventKind: String, Codable, CaseIterable, Identifiable {
    case temperature
    case windSpeed
    case rain

    var id: Self { self }

    var symbolName: String {
        switch self {
        case .temperature: return "thermometer.medium"
        case .windSpeed: return "wind"
        case .rain: return "cloud.rain"
        }
    }

    var titleKey: String {
        switch self {
        case .temperature: return "Temperature"
        case .windSpeed: return "Wind Speed"
        case .rain: return "Rain"
        }
    }
    
    var unit: String {
        switch self {
        case .temperature: return "°F"
        case .windSpeed: return "mph"
        case .rain: return "in"
        }
    }
}
