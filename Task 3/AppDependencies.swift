import Foundation
import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
final class AppDependencies: ObservableObject {
    let repository: RepairRepository
    let inboxStore: SharedEvidenceInboxStore
    let snapshotStore: RepairWidgetSnapshotStore

    let saveProperty: SaveRentalPropertyUseCase
    let reviewProperty: ReviewRentalPropertyUseCase
    let reportRepair: ReportRepairIssueUseCase
    let addEvidence: AddEvidenceToRepairUseCase
    let scheduleFollowUp: ScheduleRepairFollowUpUseCase
    let resolveRepair: ResolveRepairIssueUseCase
    let reviewDashboard: ReviewRepairDashboardUseCase
    let listRepairs: ListRepairIssuesUseCase
    let reviewRepair: ReviewRepairIssueUseCase
    let importEvidence: ImportSharedEvidenceUseCase

    static func live() -> AppDependencies {
        AppDependencies(
            repository: CoreDataRepairRepository.live(),
            inboxStore: SharedEvidenceInboxStore(),
            snapshotStore: RepairWidgetSnapshotStore()
        )
    }

    init(
        repository: RepairRepository,
        inboxStore: SharedEvidenceInboxStore,
        snapshotStore: RepairWidgetSnapshotStore
    ) {
        self.repository = repository
        self.inboxStore = inboxStore
        self.snapshotStore = snapshotStore

        self.saveProperty = SaveRentalPropertyUseCase(repository: repository)
        self.reviewProperty = ReviewRentalPropertyUseCase(repository: repository)
        self.reportRepair = ReportRepairIssueUseCase(repository: repository)
        self.addEvidence = AddEvidenceToRepairUseCase(repository: repository)
        self.scheduleFollowUp = ScheduleRepairFollowUpUseCase(repository: repository)
        self.resolveRepair = ResolveRepairIssueUseCase(repository: repository)
        self.reviewDashboard = ReviewRepairDashboardUseCase(repository: repository, inboxStore: inboxStore)
        self.listRepairs = ListRepairIssuesUseCase(repository: repository)
        self.reviewRepair = ReviewRepairIssueUseCase(repository: repository)
        self.importEvidence = ImportSharedEvidenceUseCase(
            repository: repository,
            inboxStore: inboxStore,
            addEvidence: self.addEvidence
        )
    }

    func refreshSharedSnapshot() {
        let summary = try? reviewDashboard.execute()
        let nextIssue = summary?.openIssues
            .filter { $0.status != .resolved }
            .sorted { $0.targetFollowUpDate < $1.targetFollowUpDate }
            .first

        snapshotStore.save(
            SharedRepairSnapshot(
                generatedAt: Date(),
                nextRepairTitle: nextIssue?.title ?? "No open repairs",
                nextFollowUpDate: nextIssue?.targetFollowUpDate,
                openRepairCount: summary?.openCount ?? 0,
                urgentFollowUpCount: summary?.urgentCount ?? 0
            )
        )

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
