import Foundation

struct WeatherSnapshot: Equatable {
    var windSpeedMPH: Double
    var maxWindSpeedMPH: Double
    var precipitationChance: Double
    var lowTemperatureF: Double
    var highTemperatureF: Double
    var currentTemperatureF: Double
    var rainAccumulationInches: Double
}
