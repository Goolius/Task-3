import Foundation
import Combine

@MainActor
final class RepairListViewModel: RepairViewModelBase {
    @Published private(set) var issues: [RepairIssue] = []
    @Published var showResolved = false

    private let useCase: ListRepairIssuesUseCase

    init(useCase: ListRepairIssuesUseCase) {
        self.useCase = useCase
    }

    var visibleIssues: [RepairIssue] {
        showResolved ? issues : issues.filter { $0.status != .resolved }
    }

    func load() {
        do {
            issues = try useCase.execute()
        } catch {
            capture(error)
        }
    }
}
