import SwiftUI

struct EvidenceInboxView: View {
    @StateObject private var viewModel: EvidenceInboxViewModel

    init(dependencies: AppDependencies) {
        _viewModel = StateObject(
            wrappedValue: EvidenceInboxViewModel(
                importUseCase: dependencies.importEvidence,
                listRepairsUseCase: dependencies.listRepairs,
                refreshWidget: dependencies.refreshSharedSnapshot
            )
        )
    }

    var body: some View {
        List {
            Section("Attach to repair") {
                if viewModel.repairs.isEmpty {
                    Text("Create an open repair before importing shared evidence.")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Open repair", selection: $viewModel.selectedRepairID) {
                        ForEach(viewModel.repairs) { repair in
                            Text(repair.title).tag(Optional(repair.id))
                        }
                    }
                }
            }

            Section("Shared evidence") {
                if viewModel.inboxItems.isEmpty {
                    ContentUnavailableView(
                        "Inbox empty",
                        systemImage: "tray",
                        description: Text("Use the Share sheet from Messages, Mail, Photos, Files, or Safari to send repair evidence here.")
                    )
                } else {
                    ForEach(viewModel.inboxItems) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(item.suggestedTitle)
                                    .font(.headline)
                                Spacer()
                                Text(item.kind.label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(item.note)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button {
                                viewModel.attach(item)
                            } label: {
                                Label("Attach to selected repair", systemImage: "paperclip")
                            }
                            .disabled(viewModel.repairs.isEmpty)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Evidence Inbox")
        .task {
            viewModel.load()
        }
        .refreshable {
            viewModel.load()
        }
        .repairAlert(message: $viewModel.alertMessage)
    }
}

