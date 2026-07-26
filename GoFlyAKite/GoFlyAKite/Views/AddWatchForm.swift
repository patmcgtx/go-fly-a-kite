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
                Section("Watch Type") {
                    Picker("Condition", selection: $viewModel.kind) {
                        ForEach(EventKind.allCases) { kind in
                            Label(kind.titleKey, systemImage: kind.symbolName).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.kind) { _, newValue in
                        // Reset threshold to sensible default when kind changes
                        viewModel.thresholdValue = viewModel.defaultThresholdValue
                    }
                }
                
                Section("Threshold") {
                    Picker("When", selection: $viewModel.comparison) {
                        ForEach(ThresholdComparison.allCases, id: \.self) { comparison in
                            Text(comparison.displayName).tag(comparison)
                        }
                    }
                    .onChange(of: viewModel.comparison) { _, _ in
                        viewModel.thresholdValue = viewModel.defaultThresholdValue
                    }
                    
                    HStack {
                        Text("Value")
                        Spacer()
                        TextField("Threshold", value: $viewModel.thresholdValue, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text(viewModel.kind.unit)
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(
                        value: $viewModel.thresholdValue,
                        in: viewModel.thresholdRange,
                        step: viewModel.thresholdStep
                    ) {
                        Text("Threshold")
                    } minimumValueLabel: {
                        Text("\(Int(viewModel.thresholdRange.lowerBound))")
                            .font(.caption)
                    } maximumValueLabel: {
                        Text("\(Int(viewModel.thresholdRange.upperBound))")
                            .font(.caption)
                    }
                }
                
                Section("Details") {
                    TextField("Label", text: $viewModel.label, prompt: Text("e.g., Home, Work"))
                }
                
                Section("Location") {
                    Button("use-current-location".localized) {
                        guard let locationService else {
                            assertionFailure("locationService was not injected into the environment")
                            return
                        }
                        Task {
                            await viewModel.captureLocation(using: locationService)
                        }
                    }
                    locationStatusView
                }
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
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var canSave: Bool {
        if !viewModel.label.isEmpty, case .captured = viewModel.locationCaptureState {
            true
        } else {
            false
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
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("location-captured".localized)
            }
        case .failed:
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("location-permission-denied".localized)
            }
        }
    }
}

#Preview {
    AddWatchForm()
        .modifier(InjectMockServicesModifier())
        .modelContainer(try! ModelContainers.inMemorySampleContainer())
}
