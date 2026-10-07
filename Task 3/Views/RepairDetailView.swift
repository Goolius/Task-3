import SwiftUI

struct RepairDetailView: View {
    @StateObject private var viewModel: RepairDetailViewModel

    init(issueID: UUID, dependencies: AppDependencies) {
        _viewModel = StateObject(
            wrappedValue: RepairDetailViewModel(
                issueID: issueID,
                reviewUseCase: dependencies.reviewRepair,
                addEvidenceUseCase: dependencies.addEvidence,
                scheduleFollowUpUseCase: dependencies.scheduleFollowUp,
                resolveUseCase: dependencies.resolveRepair,
                refreshWidget: dependencies.refreshSharedSnapshot
            )
        )
    }

    var body: some View {
        List {
            if let details = viewModel.details {
                Section("Repair") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(details.issue.title)
                            .font(.title3.bold())
                        Text(details.issue.details)
                            .foregroundStyle(.secondary)
                        HStack {
                            StatusBadge(text: details.issue.urgency.label, systemImage: "exclamationmark.triangle", color: details.issue.urgency == .urgent ? .red : .blue)
                            StatusBadge(text: details.issue.status.label, systemImage: "clock", color: details.issue.status == .resolved ? .green : .orange)
                        }
                        Text("First reported \(details.issue.dateFirstReported.repairShortDate)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Follow up by \(details.issue.targetFollowUpDate.repairShortDate)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Evidence timeline") {
                    if details.evidence.isEmpty {
                        ContentUnavailableView("No evidence yet", systemImage: "photo.badge.plus", description: Text("Attach photos, messages, emails, or notes before resolving the repair."))
                    } else {
                        ForEach(details.evidence) { evidence in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(evidence.title).font(.headline)
                                Text("\(evidence.kind.label) from \(evidence.sourceApp)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(evidence.note)
                                    .font(.subheadline)
                            }
                        }
                    }
                }

                Section("Add evidence") {
                    TextField("Evidence title", text: $viewModel.evidenceTitle)
                    Picker("Kind", selection: $viewModel.evidenceKind) {
                        ForEach(EvidenceKind.allCases) { kind in
                            Text(kind.label).tag(kind)
                        }
                    }
                    TextField("What does this show?", text: $viewModel.evidenceNote, axis: .vertical)
                        .lineLimit(2...4)
                    Button {
                        viewModel.addEvidence()
                    } label: {
                        Label("Attach evidence", systemImage: "paperclip")
                    }
                }

                Section("Follow-ups") {
                    if details.followUps.isEmpty {
                        Text("No follow-ups scheduled.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(details.followUps) { followUp in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(followUp.dueDate.repairShortDate)
                                    .font(.headline)
                                Text(followUp.note)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    DatePicker("Follow-up date", selection: $viewModel.followUpDate, displayedComponents: .date)
                    TextField("Follow-up note", text: $viewModel.followUpNote, axis: .vertical)
                    Button {
                        viewModel.scheduleFollowUp()
                    } label: {
                        Label("Schedule follow-up", systemImage: "calendar.badge.clock")
                    }
                }

                Section {
                    Button(role: .none) {
                        viewModel.resolve()
                    } label: {
                        Label("Mark repair resolved", systemImage: "checkmark.circle")
                    }
                    .disabled(details.issue.status == .resolved)
                }
            } else {
                ContentUnavailableView("Repair unavailable", systemImage: "questionmark.folder", description: Text("Return to the repair list and try again."))
            }
        }
        .navigationTitle("Repair Detail")
        .task {
            viewModel.load()
        }
        .repairAlert(message: $viewModel.alertMessage)
    }
}

