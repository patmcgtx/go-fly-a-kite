import CoreLocation
import Foundation
import WeatherKit

struct WeatherKitWeatherService: WeatherService {
    func snapshot(at coordinate: CLLocationCoordinate2D) async throws -> WeatherSnapshot {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let weather = try await WeatherKit.WeatherService.shared.weather(for: location)
        
        let currentTemp = weather.currentWeather.temperature.converted(to: .fahrenheit).value
        let dailyForecast = weather.dailyForecast.first
        
        return WeatherSnapshot(
            windSpeedMPH: weather.currentWeather.wind.speed.converted(to: .milesPerHour).value,
            precipitationChance: weather.hourlyForecast.first?.precipitationChance ?? 0,
            lowTemperatureF: dailyForecast?.lowTemperature.converted(to: .fahrenheit).value ?? currentTemp,
            highTemperatureF: dailyForecast?.highTemperature.converted(to: .fahrenheit).value ?? currentTemp,
            currentTemperatureF: currentTemp,
            rainAccumulationInches: dailyForecast?.precipitationAmount.converted(to: .inches).value ?? 0
        )
    }
}
