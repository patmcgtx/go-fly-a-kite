import Foundation

enum GoFlyAKiteError: LocalizedError {
    case locationPermissionDenied
    case locationUnavailable
    case weatherFetchFailed
    case notificationPermissionDenied
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .locationPermissionDenied: return "location-permission-denied".localized
        case .locationUnavailable: return "Location unavailable".localized
        case .weatherFetchFailed: return "weather-fetch-failed".localized
        case .notificationPermissionDenied: return "Notification permission denied".localized
        case .saveFailed: return "Failed to save".localized
        }
    }
}
