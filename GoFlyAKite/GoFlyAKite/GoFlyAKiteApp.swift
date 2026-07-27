//
//  GoFlyAKiteApp.swift
//  GoFlyAKite
//
//  Created by Patrick McGonigle on 7/20/26.
//

import SwiftUI
import SwiftData

@main
struct GoFlyAKiteApp: App {
    init() {
        // Register background task handler
        BackgroundWeatherChecker.register()
    }
    
    var body: some Scene {
        WindowGroup {
            WatchListView()
                .modifier(InjectLiveServicesModifier())
                .onAppear {
                    // Request notification permission on first launch
                    Task {
                        let notificationService = UserNotificationService()
                        _ = try? await notificationService.requestAuthorization()
                    }
                    
                    // Schedule initial background refresh
                    BackgroundWeatherChecker.scheduleNextRefresh()
                }
        }
        .modelContainer(try! ModelContainers.persistentContainer())
    }
}
