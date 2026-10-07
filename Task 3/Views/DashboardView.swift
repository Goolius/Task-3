import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    private let dependencies: AppDependencies
    @State private var showingNewRepair = false

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(
                useCase: dependencies.reviewDashboard,
                refreshWidget: dependencies.refreshSharedSnapshot
            )
        )
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.summary.property?.nickname.isEmpty == false ? viewModel.summary.property?.nickname ?? "Rental property" : "Rental property")
                        .font(.title2.bold())
                    Text(viewModel.summary.property?.addressLine ?? "Add your rental property before reporting repairs.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        metric("Open repairs", value: viewModel.summary.openCount, tint: .blue)
                        metric("Need follow-up", value: viewModel.summary.urgentCount, tint: .red)
                        metric("Inbox", value: viewModel.summary.evidenceInboxCount, tint: .purple)
                    }
                }
                .padding(.vertical, 6)
            }

            Section("Urgent follow-ups") {
                if viewModel.summary.urgentFollowUps.isEmpty {
                    ContentUnavailableView(
                        "No urgent follow-ups",
                        systemImage: "checkmark.seal",
                        description: Text("Urgent repairs due today will appear here.")
                    )
                } else {
                    ForEach(viewModel.summary.urgentFollowUps) { issue in
                        NavigationLink {
                            RepairDetailView(issueID: issue.id, dependencies: dependencies)
                        } label: {
                            RepairIssueRow(issue: issue)
                        }
                    }
                }
            }

            Section("Next steps") {
                Button {
                    showingNewRepair = true
                } label: {
                    Label("Report a repair issue", systemImage: "plus.circle.fill")
                }

                NavigationLink {
                    EvidenceInboxView(dependencies: dependencies)
                } label: {
                    Label("Review shared evidence", systemImage: "tray.and.arrow.down")
                }
            }
        }
        .navigationTitle("RentRepair Log")
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

    private func metric(_ title: String, value: Int, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)")
                .font(.title.bold())
                .foregroundStyle(tint)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

