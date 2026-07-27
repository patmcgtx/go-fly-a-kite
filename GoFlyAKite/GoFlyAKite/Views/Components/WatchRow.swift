import SwiftUI

struct WatchRow: View {
    let watch: WeatherWatch
    let weatherState: WeatherLoadState

    var body: some View {
        HStack {
            Image(systemName: watch.kind.symbolName)
                .foregroundStyle(watch.wasTriggeredOnLastCheck ? .orange : .primary)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(watch.label)
                    if watch.wasTriggeredOnLastCheck {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                Text(watch.conditionDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                statusText
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let lastNotified = watch.lastNotifiedDate {
                    Text("Last notified: \(lastNotified, style: .relative) ago")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            if watch.wasTriggeredOnLastCheck {
                VStack(spacing: 4) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(.orange)
                    Text("Active")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    @ViewBuilder
    private var statusText: some View {
        switch weatherState {
        case .idle:
            EmptyView()
        case .loading:
            Text("loading".localized)
        case .loaded(_, let triggered):
            if triggered {
                Text("conditions-met".localized)
                    .foregroundStyle(.orange)
                    .fontWeight(.medium)
            } else {
                Text("no-alert".localized)
            }
        case .failed:
            Text("weather-fetch-failed".localized)
        }
    }
}

#Preview("Normal - Not Triggered") {
    List {
        WatchRow(
            watch: WeatherWatch(
                kind: .temperature,
                label: "Home",
                latitude: 37.7749,
                longitude: -122.4194,
                comparison: .below,
                thresholdValue: 32
            ),
            weatherState: .loaded(
                WeatherSnapshot(
                    windSpeedMPH: 5,
                    maxWindSpeedMPH: 8,
                    precipitationChance: 0.1,
                    lowTemperatureF: 40,
                    highTemperatureF: 55,
                    currentTemperatureF: 48,
                    rainAccumulationInches: 0.0
                ),
                triggered: false
            )
        )
    }
}

#Preview("Triggered - Just Notified") {
    let watch = WeatherWatch(
        kind: .temperature,
        label: "Home",
        latitude: 37.7749,
        longitude: -122.4194,
        comparison: .below,
        thresholdValue: 32
    )
    watch.wasTriggeredOnLastCheck = true
    watch.lastNotifiedDate = Date()
    
    return List {
        WatchRow(
            watch: watch,
            weatherState: .loaded(
                WeatherSnapshot(
                    windSpeedMPH: 5,
                    maxWindSpeedMPH: 8,
                    precipitationChance: 0.1,
                    lowTemperatureF: 28,
                    highTemperatureF: 35,
                    currentTemperatureF: 30,
                    rainAccumulationInches: 0.0
                ),
                triggered: true
            )
        )
    }
}

#Preview("Triggered - 2 Hours Ago") {
    let watch = WeatherWatch(
        kind: .temperature,
        label: "Home",
        latitude: 37.7749,
        longitude: -122.4194,
        comparison: .below,
        thresholdValue: 32
    )
    watch.wasTriggeredOnLastCheck = true
    watch.lastNotifiedDate = Date().addingTimeInterval(-2 * 60 * 60) // 2 hours ago
    
    return List {
        WatchRow(
            watch: watch,
            weatherState: .loaded(
                WeatherSnapshot(
                    windSpeedMPH: 5,
                    maxWindSpeedMPH: 8,
                    precipitationChance: 0.1,
                    lowTemperatureF: 28,
                    highTemperatureF: 35,
                    currentTemperatureF: 30,
                    rainAccumulationInches: 0.0
                ),
                triggered: true
            )
        )
    }
}

#Preview("Wind - Triggered") {
    let watch = WeatherWatch(
        kind: .windSpeed,
        label: "Park",
        latitude: 37.7749,
        longitude: -122.4194,
        comparison: .above,
        thresholdValue: 15
    )
    watch.wasTriggeredOnLastCheck = true
    watch.lastNotifiedDate = Date().addingTimeInterval(-30 * 60) // 30 minutes ago
    
    return List {
        WatchRow(
            watch: watch,
            weatherState: .loaded(
                WeatherSnapshot(
                    windSpeedMPH: 18,
                    maxWindSpeedMPH: 22,
                    precipitationChance: 0.1,
                    lowTemperatureF: 60,
                    highTemperatureF: 70,
                    currentTemperatureF: 65,
                    rainAccumulationInches: 0.0
                ),
                triggered: true
            )
        )
    }
}

#Preview("Rain - Triggered") {
    let watch = WeatherWatch(
        kind: .rain,
        label: "Work",
        latitude: 37.7749,
        longitude: -122.4194,
        comparison: .above,
        thresholdValue: 0.5
    )
    watch.wasTriggeredOnLastCheck = true
    watch.lastNotifiedDate = Date().addingTimeInterval(-4 * 60 * 60) // 4 hours ago
    
    return List {
        WatchRow(
            watch: watch,
            weatherState: .loaded(
                WeatherSnapshot(
                    windSpeedMPH: 8,
                    maxWindSpeedMPH: 12,
                    precipitationChance: 0.8,
                    lowTemperatureF: 55,
                    highTemperatureF: 62,
                    currentTemperatureF: 58,
                    rainAccumulationInches: 0.75
                ),
                triggered: true
            )
        )
    }
}

#Preview("Loading State") {
    List {
        WatchRow(
            watch: WeatherWatch(
                kind: .temperature,
                label: "Home",
                latitude: 37.7749,
                longitude: -122.4194,
                comparison: .below,
                thresholdValue: 32
            ),
            weatherState: .loading
        )
    }
}

#Preview("Failed State") {
    List {
        WatchRow(
            watch: WeatherWatch(
                kind: .temperature,
                label: "Home",
                latitude: 37.7749,
                longitude: -122.4194,
                comparison: .below,
                thresholdValue: 32
            ),
            weatherState: .failed(.weatherFetchFailed)
        )
    }
}

#Preview("Idle State") {
    List {
        WatchRow(
            watch: WeatherWatch(
                kind: .temperature,
                label: "Home",
                latitude: 37.7749,
                longitude: -122.4194,
                comparison: .below,
                thresholdValue: 32
            ),
            weatherState: .idle
        )
    }
}

#Preview("Multiple Watches") {
    let freezeWatch = WeatherWatch(
        kind: .temperature,
        label: "Home",
        latitude: 37.7749,
        longitude: -122.4194,
        comparison: .below,
        thresholdValue: 32
    )
    freezeWatch.wasTriggeredOnLastCheck = true
    freezeWatch.lastNotifiedDate = Date().addingTimeInterval(-30 * 60)
    
    let windWatch = WeatherWatch(
        kind: .windSpeed,
        label: "Park",
        latitude: 37.7749,
        longitude: -122.4194,
        comparison: .above,
        thresholdValue: 15
    )
    
    let rainWatch = WeatherWatch(
        kind: .rain,
        label: "Work",
        latitude: 37.7749,
        longitude: -122.4194,
        comparison: .above,
        thresholdValue: 0.5
    )
    rainWatch.wasTriggeredOnLastCheck = true
    rainWatch.lastNotifiedDate = Date().addingTimeInterval(-2 * 60 * 60)
    
    return List {
        WatchRow(
            watch: freezeWatch,
            weatherState: .loaded(
                WeatherSnapshot(
                    windSpeedMPH: 5,
                    maxWindSpeedMPH: 8,
                    precipitationChance: 0.1,
                    lowTemperatureF: 28,
                    highTemperatureF: 35,
                    currentTemperatureF: 30,
                    rainAccumulationInches: 0.0
                ),
                triggered: true
            )
        )
        
        WatchRow(
            watch: windWatch,
            weatherState: .loaded(
                WeatherSnapshot(
                    windSpeedMPH: 8,
                    maxWindSpeedMPH: 12,
                    precipitationChance: 0.1,
                    lowTemperatureF: 60,
                    highTemperatureF: 70,
                    currentTemperatureF: 65,
                    rainAccumulationInches: 0.0
                ),
                triggered: false
            )
        )
        
        WatchRow(
            watch: rainWatch,
            weatherState: .loaded(
                WeatherSnapshot(
                    windSpeedMPH: 8,
                    maxWindSpeedMPH: 12,
                    precipitationChance: 0.8,
                    lowTemperatureF: 55,
                    highTemperatureF: 62,
                    currentTemperatureF: 58,
                    rainAccumulationInches: 0.75
                ),
                triggered: true
            )
        )
    }
}
