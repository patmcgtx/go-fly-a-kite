import Foundation

enum WeatherAlertEvaluator {
    static func isTriggered(watch: WeatherWatch, snapshot: WeatherSnapshot) -> Bool {
        let value: Double
        
        switch watch.kind {
        case .temperature:
            value = snapshot.currentTemperatureF
        case .windSpeed:
            value = snapshot.windSpeedMPH
        case .rain:
            value = snapshot.rainAccumulationInches
        }
        
        switch watch.comparison {
        case .above:
            return value >= watch.thresholdValue
        case .below:
            return value <= watch.thresholdValue
        }
    }
}
