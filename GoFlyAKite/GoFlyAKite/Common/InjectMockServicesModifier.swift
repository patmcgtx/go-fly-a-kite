import SwiftUI

#if DEBUG
struct InjectMockServicesModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.weatherService, MockWeatherService())
            .environment(\.locationService, MockLocationService())
            .environment(\.notificationService, MockNotificationService())
    }
}
#endif // DEBUG
