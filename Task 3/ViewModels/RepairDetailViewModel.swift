import Foundation
import Combine

@MainActor
final class RepairDetailViewModel: RepairViewModelBase {
    @Published private(set) var details: RepairIssueDetails?
    @Published var evidenceTitle = ""
    @Published var evidenceNote = ""
    @Published var evidenceKind: EvidenceKind = .note
    @Published var followUpNote = ""
    @Published var followUpDate = Date()

    private let issueID: UUID
    private let reviewUseCase: ReviewRepairIssueUseCase
    private let addEvidenceUseCase: AddEvidenceToRepairUseCase
    private let scheduleFollowUpUseCase: ScheduleRepairFollowUpUseCase
    private let resolveUseCase: ResolveRepairIssueUseCase
    private let refreshWidget: () -> Void

    init(
        issueID: UUID,
        reviewUseCase: ReviewRepairIssueUseCase,
        addEvidenceUseCase: AddEvidenceToRepairUseCase,
        scheduleFollowUpUseCase: ScheduleRepairFollowUpUseCase,
        resolveUseCase: ResolveRepairIssueUseCase,
        refreshWidget: @escaping () -> Void
    ) {
        self.issueID = issueID
        self.reviewUseCase = reviewUseCase
        self.addEvidenceUseCase = addEvidenceUseCase
        self.scheduleFollowUpUseCase = scheduleFollowUpUseCase
        self.resolveUseCase = resolveUseCase
        self.refreshWidget = refreshWidget
    }

    func load() {
        do {
            details = try reviewUseCase.execute(repairIssueID: issueID)
        } catch {
            capture(error)
        }
    }

    func addEvidence() {
        do {
            _ = try addEvidenceUseCase.execute(
                repairIssueID: issueID,
                title: evidenceTitle,
                kind: evidenceKind,
                note: evidenceNote,
                sourceApp: "RentRepair Log",
                fileName: nil
            )
            evidenceTitle = ""
            evidenceNote = ""
            load()
            refreshWidget()
        } catch {
            capture(error)
        }
    }

    func scheduleFollowUp() {
        do {
            _ = try scheduleFollowUpUseCase.execute(
                repairIssueID: issueID,
                dueDate: followUpDate,
                note: followUpNote
            )
            followUpNote = ""
            load()
            refreshWidget()
        } catch {
            capture(error)
        }
    }

    func resolve() {
        do {
            _ = try resolveUseCase.execute(repairIssueID: issueID)
            load()
            refreshWidget()
        } catch {
            capture(error)
        }
    }
}
