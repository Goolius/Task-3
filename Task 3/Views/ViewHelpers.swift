import SwiftUI

struct StatusBadge: View {
    let text: String
    let systemImage: String
    var color: Color

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.16), in: Capsule())
            .foregroundStyle(color)
    }
}

struct RepairIssueRow: View {
    let issue: RepairIssue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(issue.title)
                    .font(.headline)
                Spacer()
                Text(issue.targetFollowUpDate.repairShortDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(issue.details)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                StatusBadge(
                    text: issue.urgency.label,
                    systemImage: issue.urgency == .urgent ? "exclamationmark.triangle.fill" : "wrench.and.screwdriver",
                    color: issue.urgency == .urgent ? .red : .blue
                )
                StatusBadge(text: issue.status.label, systemImage: "clock", color: issue.status == .resolved ? .green : .orange)
            }
        }
        .padding(.vertical, 4)
    }
}

extension View {
    func repairAlert(message: Binding<String?>) -> some View {
        alert(
            "RentRepair Log",
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { if !$0 { message.wrappedValue = nil } }
            )
        ) {
            Button("OK", role: .cancel) { message.wrappedValue = nil }
        } message: {
            Text(message.wrappedValue ?? "")
        }
    }
}

