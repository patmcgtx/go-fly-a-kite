import Foundation

protocol NotificationService {
    func requestAuthorization() async throws -> Bool
    func scheduleReminder(for watch: WeatherWatch) async throws
    func cancelReminder(for watch: WeatherWatch) async
    func sendAlert(for watch: WeatherWatch, currentValue: Double) async throws
}
