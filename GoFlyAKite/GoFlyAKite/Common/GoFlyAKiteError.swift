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
        case .locationUnavailable: return "location-unavailable".localized
        case .weatherFetchFailed: return "weather-fetch-failed".localized
        case .notificationPermissionDenied: return "notification-permission-denied".localized
        case .saveFailed: return "save-failed".localized
        }
    }
}
