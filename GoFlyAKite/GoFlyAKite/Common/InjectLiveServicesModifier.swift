import SwiftUI

struct InjectLiveServicesModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.weatherService, WeatherKitWeatherService())
            .environment(\.locationService, CoreLocationService())
            .environment(\.notificationService, UserNotificationService())
    }
}
