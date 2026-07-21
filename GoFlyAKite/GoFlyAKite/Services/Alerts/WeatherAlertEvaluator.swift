import Foundation

enum WeatherAlertEvaluator {
    static func isTriggered(kind: EventKind, snapshot: WeatherSnapshot) -> Bool {
        switch kind {
        case .kite:
            return snapshot.windSpeedMPH >= 15
        case .faucet:
            return snapshot.lowTemperatureF <= 34
        case .umbrella:
            return snapshot.precipitationChance >= 0.5
        }
    }
}
