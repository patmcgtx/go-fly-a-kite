import Foundation

#if DEBUG
final class MockNotificationService: NotificationService {
    var authorizationResult = true
    private(set) var scheduledWatches: [WeatherWatch] = []
    private(set) var canceledWatches: [WeatherWatch] = []
    private(set) var sentAlerts: [(watch: WeatherWatch, value: Double)] = []

    func requestAuthorization() async throws -> Bool {
        authorizationResult
    }

    func scheduleReminder(for watch: WeatherWatch) async throws {
        scheduledWatches.append(watch)
    }

    func cancelReminder(for watch: WeatherWatch) async {
        canceledWatches.append(watch)
    }
    
    func sendAlert(for watch: WeatherWatch, currentValue: Double) async throws {
        sentAlerts.append((watch, currentValue))
    }
}
#endif // DEBUG
