import SwiftUI

struct WatchRow: View {
    let watch: WeatherWatch
    let weatherState: WeatherLoadState

    var body: some View {
        HStack {
            Image(systemName: watch.kind.symbolName)
            VStack(alignment: .leading) {
                Text(watch.label)
                statusText
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var statusText: some View {
        switch weatherState {
        case .idle:
            Text("watch-list-title".localized)
        case .loading:
            Text("Loading…")
        case .loaded(_, let triggered):
            Text(triggered ? "Conditions met" : "No alert")
        case .failed:
            Text("weather-fetch-failed".localized)
        }
    }
}
