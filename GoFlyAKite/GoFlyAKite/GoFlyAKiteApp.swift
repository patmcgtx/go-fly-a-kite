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
    var body: some Scene {
        WindowGroup {
            WatchListView()
                .modifier(InjectLiveServicesModifier())
        }
        .modelContainer(try! ModelContainers.persistentContainer())
    }
}
