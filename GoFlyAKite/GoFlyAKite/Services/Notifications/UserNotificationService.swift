import Foundation
import SwiftData
import UserNotifications

struct UserNotificationService: NotificationService {
    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    func scheduleReminder(for watch: WeatherWatch) async throws {
        let content = UNMutableNotificationContent()
        content.title = watch.label
        content.body = watch.kind.titleKey

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: watch.persistentModelID.hashValue.description, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for watch: WeatherWatch) async {
        let identifier = watch.persistentModelID.hashValue.description
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
