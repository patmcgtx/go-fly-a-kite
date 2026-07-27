import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var showingNotificationSettings = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enable Weather Alerts", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue {
                                Task {
                                    let service = UserNotificationService()
                                    let granted = try? await service.requestAuthorization()
                                    if granted != true {
                                        showingNotificationSettings = true
                                    }
                                }
                            }
                        }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Receive alerts when weather conditions meet your watch thresholds")
                }
                
                Section {
                    LabeledContent("Check Frequency", value: "Every 15 minutes")
                    LabeledContent("Background Refresh", value: "Enabled")
                } header: {
                    Text("Background Updates")
                } footer: {
                    Text("The app checks weather conditions in the background. iOS determines the actual frequency based on battery and usage patterns.")
                }
                
                Section {
                    Button("Open Notification Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                } header: {
                    Text("System Settings")
                }
            }
            .navigationTitle("Settings")
            .alert("Notification Permission Required", isPresented: $showingNotificationSettings) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    notificationsEnabled = false
                }
            } message: {
                Text("Please enable notifications in Settings to receive weather alerts")
            }
        }
    }
}

#Preview {
    SettingsView()
}
