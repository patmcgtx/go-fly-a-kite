import Foundation
import SwiftData
import UserNotifications

struct UserNotificationService: NotificationService {
    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleReminder(for watch: WeatherWatch) async throws {
        let content = UNMutableNotificationContent()
        content.title = watch.label
        content.body = watch.conditionDescription

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: watch.id.uuidString, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for watch: WeatherWatch) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [watch.id.uuidString])
    }
    
    func sendAlert(for watch: WeatherWatch, currentValue: Double) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Weather Alert: \(watch.label)"
        content.body = "\(watch.kind.titleKey) is \(Int(currentValue))\(watch.kind.unit) - \(watch.conditionDescription)"
        content.sound = .default
        content.badge = 1
        
        // Use a unique identifier based on watch ID and timestamp to allow multiple alerts
        let identifier = "\(watch.id.uuidString)-\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        try await UNUserNotificationCenter.current().add(request)
    }
}

