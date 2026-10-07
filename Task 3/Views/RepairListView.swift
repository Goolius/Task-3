import SwiftUI

struct RepairListView: View {
    @StateObject private var viewModel: RepairListViewModel
    private let dependencies: AppDependencies
    @State private var showingNewRepair = false

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = StateObject(wrappedValue: RepairListViewModel(useCase: dependencies.listRepairs))
    }

    var body: some View {
        List {
            Section {
                Toggle("Show resolved repairs", isOn: $viewModel.showResolved)
            }

            Section("Repair timeline") {
                if viewModel.visibleIssues.isEmpty {
                    ContentUnavailableView(
                        "No repair issues yet",
                        systemImage: "wrench.and.screwdriver",
                        description: Text("Report a repair to start a written timeline.")
                    )
                } else {
                    ForEach(viewModel.visibleIssues) { issue in
                        NavigationLink {
                            RepairDetailView(issueID: issue.id, dependencies: dependencies)
                        } label: {
                            RepairIssueRow(issue: issue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Repairs")
        .toolbar {
            Button {
                showingNewRepair = true
            } label: {
                Label("New Repair", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingNewRepair, onDismiss: viewModel.load) {
            NavigationStack {
                NewRepairView(dependencies: dependencies)
            }
        }
        .task {
            viewModel.load()
        }
        .refreshable {
            viewModel.load()
        }
        .repairAlert(message: $viewModel.alertMessage)
    }
}

