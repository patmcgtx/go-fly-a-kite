import SwiftData
import SwiftUI

struct AddWatchForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locationService) private var locationService
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AddWatchViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Picker("add-watch".localized, selection: $viewModel.kind) {
                    ForEach(EventKind.allCases) { kind in
                        Text(kind.titleKey.localized).tag(kind)
                    }
                }
                TextField("add-watch".localized, text: $viewModel.label)
                Button("use-current-location".localized) {
                    Task {
                        await viewModel.captureLocation(using: locationService!)
                    }
                }
                locationStatusView
            }
            .navigationTitle("add-watch".localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save".localized) {
                        let store = WeatherWatchStore(context: modelContext)
                        if viewModel.save(using: store) {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var locationStatusView: some View {
        switch viewModel.locationCaptureState {
        case .notCaptured:
            EmptyView()
        case .capturing:
            ProgressView()
        case .captured:
            Text("Location captured")
        case .failed:
            Text("location-permission-denied".localized)
        }
    }
}

#Preview {
    AddWatchForm()
        .modifier(InjectMockServicesModifier())
        .modelContainer(try! ModelContainers.inMemorySampleContainer())
}
