import Foundation
import Combine

@MainActor
final class DashboardViewModel: RepairViewModelBase {
    @Published private(set) var summary = RepairDashboardSummary(
        property: nil,
        openIssues: [],
        urgentFollowUps: [],
        evidenceInboxCount: 0
    )

    private let useCase: ReviewRepairDashboardUseCase
    private let refreshWidget: () -> Void

    init(useCase: ReviewRepairDashboardUseCase, refreshWidget: @escaping () -> Void) {
        self.useCase = useCase
        self.refreshWidget = refreshWidget
    }

    func load() {
        do {
            summary = try useCase.execute()
            refreshWidget()
        } catch {
            capture(error)
        }
    }
}
