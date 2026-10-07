import SwiftUI

struct NewRepairView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NewRepairViewModel

    init(dependencies: AppDependencies) {
        _viewModel = StateObject(
            wrappedValue: NewRepairViewModel(
                useCase: dependencies.reportRepair,
                refreshWidget: dependencies.refreshSharedSnapshot
            )
        )
    }

    var body: some View {
        Form {
            Section("Repair issue") {
                TextField("Short title", text: $viewModel.title)
                Picker("Category", selection: $viewModel.category) {
                    ForEach(RepairCategory.allCases) { category in
                        Text(category.label).tag(category)
                    }
                }
                Picker("Urgency", selection: $viewModel.urgency) {
                    ForEach(RepairUrgency.allCases) { urgency in
                        Text(urgency.label).tag(urgency)
                    }
                }
                DatePicker("First reported", selection: $viewModel.dateFirstReported, in: ...Date(), displayedComponents: .date)
            }

            Section("What happened") {
                TextEditor(text: $viewModel.details)
                    .frame(minHeight: 140)
                    .overlay(alignment: .topLeading) {
                        if viewModel.details.isEmpty {
                            Text("Describe the defect, impact, and how you contacted the landlord or agent.")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                    }
            }
        }
        .navigationTitle("New Repair")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if viewModel.save() {
                        dismiss()
                    }
                }
            }
        }
        .repairAlert(message: $viewModel.alertMessage)
    }
}

