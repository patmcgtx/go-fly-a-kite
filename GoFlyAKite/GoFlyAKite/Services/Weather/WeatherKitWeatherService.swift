import CoreLocation
import Foundation
import WeatherKit

struct WeatherKitWeatherService: WeatherService {
    func snapshot(at coordinate: CLLocationCoordinate2D) async throws -> WeatherSnapshot {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let weather = try await WeatherKit.WeatherService.shared.weather(for: location)
        
        let currentTemp = weather.currentWeather.temperature.converted(to: .fahrenheit).value
        let currentWind = weather.currentWeather.wind.speed.converted(to: .milesPerHour).value
        
        // Get next 24 hours of hourly forecast data
        let next24Hours = weather.hourlyForecast.prefix(24)
        
        // Calculate rolling 24-hour temperature range
        let temperatures = next24Hours.map { $0.temperature.converted(to: .fahrenheit).value }
        let lowTemp = temperatures.min() ?? currentTemp
        let highTemp = temperatures.max() ?? currentTemp
        
        // Calculate rolling 24-hour max wind
        let windSpeeds = next24Hours.map { $0.wind.speed.converted(to: .milesPerHour).value }
        let maxWind = windSpeeds.max() ?? currentWind
        
        // Calculate rolling 24-hour rain accumulation
        let rainAccumulation = next24Hours.reduce(0.0) { total, hour in
            total + (hour.precipitationAmount.converted(to: .inches).value)
        }
        
        return WeatherSnapshot(
            windSpeedMPH: currentWind,
            maxWindSpeedMPH: maxWind,
            precipitationChance: weather.hourlyForecast.first?.precipitationChance ?? 0,
            lowTemperatureF: lowTemp,
            highTemperatureF: highTemp,
            currentTemperatureF: currentTemp,
            rainAccumulationInches: rainAccumulation
        )
    }
}
