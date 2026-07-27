import SwiftData
import SwiftUI

struct WatchListView: View {
    @Query private var watches: [WeatherWatch]
    @Environment(\.weatherService) private var weatherService
    @State private var viewModel = WatchListViewModel()

    var body: some View {
        NavigationStack {
            List(watches) { watch in
                WatchRow(watch: watch, weatherState: viewModel.weatherState(for: watch))
                    .task {
                        guard let weatherService else {
                            assertionFailure("weatherService was not injected into the environment")
                            return
                        }
                        await viewModel.refreshWeather(for: watch, using: weatherService)
                    }
            }
            .navigationTitle("watch-list-title".localized)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.isShowingAddWatchSheet = true }) {
                        Label("add-watch".localized, systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddWatchSheet) {
                AddWatchForm()
            }
        }
    }
}

#Preview("Real") {
    WatchListView()
        .modifier(InjectLiveServicesModifier())
        .modelContainer(try! ModelContainers.inMemorySampleContainer())
}

#Preview("Mock") {
    WatchListView()
        .modifier(InjectMockServicesModifier())
        .modelContainer(try! ModelContainers.inMemorySampleContainer())
}
