import Foundation

enum EventKind: String, Codable, CaseIterable, Identifiable {
    case kite
    case faucet
    case umbrella

    var id: Self { self }

    var symbolName: String {
        switch self {
        case .kite: return "wind"
        case .faucet: return "drop.degreesign"
        case .umbrella: return "umbrella"
        }
    }

    var titleKey: String {
        switch self {
        case .kite: return "kite"
        case .faucet: return "faucet"
        case .umbrella: return "umbrella"
        }
    }
}
