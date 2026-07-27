import BackgroundTasks
import Foundation
import SwiftData

@MainActor
final class BackgroundWeatherChecker {
    static let taskIdentifier = "com.goFlyAKite.weatherCheck"
    
    private let modelContext: ModelContext
    private let weatherService: WeatherService
    private let notificationService: NotificationService
    
    init(modelContext: ModelContext, weatherService: WeatherService, notificationService: NotificationService) {
        self.modelContext = modelContext
        self.weatherService = weatherService
        self.notificationService = notificationService
    }
    
    /// Register the background task handler with the system
    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let task = task as? BGAppRefreshTask else { return }
            Task {
                await handleBackgroundTask(task)
            }
        }
    }
    
    /// Schedule the next background refresh
    static func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        // Check weather every 15 minutes (minimum allowed is 15 minutes)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background weather check scheduled")
        } catch {
            print("❌ Failed to schedule background task: \(error.localizedDescription)")
        }
    }
    
    /// Handle the background task
    private static func handleBackgroundTask(_ task: BGAppRefreshTask) async {
        // Schedule the next refresh immediately
        scheduleNextRefresh()
        
        // Set up task expiration handler
        task.expirationHandler = {
            print("⏰ Background task expired")
        }
        
        do {
            // Create services for background execution
            let container = try ModelContainers.persistentContainer()
            let weatherService = WeatherKitWeatherService()
            let notificationService = UserNotificationService()
            
            let checker = BackgroundWeatherChecker(
                modelContext: container.mainContext,
                weatherService: weatherService,
                notificationService: notificationService
            )
            
            await checker.checkAllWatches()
            task.setTaskCompleted(success: true)
            print("✅ Background weather check completed")
        } catch {
            print("❌ Background weather check failed: \(error.localizedDescription)")
            task.setTaskCompleted(success: false)
        }
    }
    
    /// Check weather for all watches and send notifications if conditions are met
    func checkAllWatches() async {
        // Fetch all enabled watches
        let descriptor = FetchDescriptor<WeatherWatch>(
            predicate: #Predicate { $0.isEnabled }
        )
        
        guard let watches = try? modelContext.fetch(descriptor) else {
            print("❌ Failed to fetch watches")
            return
        }
        
        print("🔍 Checking \(watches.count) watches...")
        
        for watch in watches {
            await checkWatch(watch)
        }
    }
    
    /// Check a single watch and send notification if triggered
    private func checkWatch(_ watch: WeatherWatch) async {
        do {
            let snapshot = try await weatherService.snapshot(at: watch.coordinate)
            let isTriggered = WeatherAlertEvaluator.isTriggered(watch: watch, snapshot: snapshot)
            
            // State change detection: only notify on false→true transition
            let shouldNotify = isTriggered && !watch.wasTriggeredOnLastCheck
            
            if shouldNotify {
                print("🚨 Alert triggered for: \(watch.label) (state changed to triggered)")
                try await sendNotification(for: watch, snapshot: snapshot)
                watch.lastNotifiedDate = Date()
            } else if isTriggered {
                print("⚠️ Alert still triggered for: \(watch.label) (no new notification)")
            } else {
                print("✓ No alert for: \(watch.label)")
            }
            
            // Update state for next check
            watch.wasTriggeredOnLastCheck = isTriggered
            
            // Save the updated watch state
            try? modelContext.save()
            
        } catch {
            print("❌ Failed to check weather for \(watch.label): \(error.localizedDescription)")
        }
    }
    
    /// Send a notification for a triggered watch
    private func sendNotification(for watch: WeatherWatch, snapshot: WeatherSnapshot) async throws {
        // Check if we have notification permission
        let hasPermission = try await notificationService.requestAuthorization()
        guard hasPermission else {
            print("⚠️ No notification permission")
            return
        }
        
        // Get the current value for the watch's kind
        let currentValue: Double
        switch watch.kind {
        case .temperature:
            currentValue = snapshot.currentTemperatureF
        case .windSpeed:
            currentValue = snapshot.windSpeedMPH
        case .rain:
            currentValue = snapshot.rainAccumulationInches
        }
        
        // Send notification with current conditions
        try await notificationService.sendAlert(
            for: watch,
            currentValue: currentValue
        )
    }
}
