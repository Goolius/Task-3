import Foundation
import Combine

@MainActor
final class NewRepairViewModel: RepairViewModelBase {
    @Published var title = ""
    @Published var category: RepairCategory = .plumbing
    @Published var urgency: RepairUrgency = .routine
    @Published var details = ""
    @Published var dateFirstReported = Date()
    @Published private(set) var savedIssue: RepairIssue?

    private let useCase: ReportRepairIssueUseCase
    private let refreshWidget: () -> Void

    init(useCase: ReportRepairIssueUseCase, refreshWidget: @escaping () -> Void) {
        self.useCase = useCase
        self.refreshWidget = refreshWidget
    }

    func save() -> Bool {
        do {
            savedIssue = try useCase.execute(
                title: title,
                category: category,
                urgency: urgency,
                details: details,
                dateFirstReported: dateFirstReported
            )
            refreshWidget()
            return true
        } catch {
            capture(error)
            return false
        }
    }
}
