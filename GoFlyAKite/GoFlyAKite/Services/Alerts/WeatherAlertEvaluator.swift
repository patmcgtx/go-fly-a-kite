import Foundation

enum WeatherAlertEvaluator {
    static func isTriggered(watch: WeatherWatch, snapshot: WeatherSnapshot) -> Bool {
        let value: Double
        
        switch watch.kind {
        case .temperature:
            // Use forecast temps based on comparison direction
            switch watch.comparison {
            case .above:
                value = snapshot.highTemperatureF // Will it get hot today?
            case .below:
                value = snapshot.lowTemperatureF // Will it get cold/freeze today?
            }
        case .windSpeed:
            // Use max wind forecast for "above", current for "below"
            switch watch.comparison {
            case .above:
                value = snapshot.maxWindSpeedMPH // Will it get windy today?
            case .below:
                value = snapshot.windSpeedMPH // Is wind currently calm?
            }
        case .rain:
            // Use today's rain accumulation forecast
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
