import CoreLocation
import Foundation
import WeatherKit

struct WeatherKitWeatherService: WeatherService {
    func snapshot(at coordinate: CLLocationCoordinate2D) async throws -> WeatherSnapshot {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let weather = try await WeatherKit.WeatherService.shared.weather(for: location)
        return WeatherSnapshot(
            windSpeedMPH: weather.currentWeather.wind.speed.converted(to: .milesPerHour).value,
            precipitationChance: weather.hourlyForecast.first?.precipitationChance ?? 0,
            lowTemperatureF: weather.dailyForecast.first?.lowTemperature.converted(to: .fahrenheit).value ?? weather.currentWeather.temperature.converted(to: .fahrenheit).value
        )
    }
}
