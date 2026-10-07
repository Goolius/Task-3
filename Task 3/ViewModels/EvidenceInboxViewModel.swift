import Foundation
import Combine

@MainActor
final class EvidenceInboxViewModel: RepairViewModelBase {
    @Published private(set) var inboxItems: [SharedEvidenceInboxItem] = []
    @Published private(set) var repairs: [RepairIssue] = []
    @Published var selectedRepairID: UUID?

    private let importUseCase: ImportSharedEvidenceUseCase
    private let listRepairsUseCase: ListRepairIssuesUseCase
    private let refreshWidget: () -> Void

    init(
        importUseCase: ImportSharedEvidenceUseCase,
        listRepairsUseCase: ListRepairIssuesUseCase,
        refreshWidget: @escaping () -> Void
    ) {
        self.importUseCase = importUseCase
        self.listRepairsUseCase = listRepairsUseCase
        self.refreshWidget = refreshWidget
    }

    func load() {
        do {
            inboxItems = importUseCase.pendingItems()
            repairs = try listRepairsUseCase.execute().filter { $0.status != .resolved }
            selectedRepairID = selectedRepairID ?? repairs.first?.id
        } catch {
            capture(error)
        }
    }

    func attach(_ item: SharedEvidenceInboxItem) {
        guard let selectedRepairID else {
            alertMessage = "Create or choose an open repair before attaching shared evidence."
            return
        }

        do {
            _ = try importUseCase.execute(inboxItemID: item.id, repairIssueID: selectedRepairID)
            load()
            refreshWidget()
        } catch {
            capture(error)
        }
    }
}
