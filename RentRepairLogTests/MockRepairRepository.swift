import Foundation
@testable import Task_3

@MainActor
final class MockRepairRepository: RepairRepository {
    var property: RentalProperty?
    var issues: [RepairIssue] = []
    var evidence: [EvidenceItem] = []
    var followUps: [FollowUpNote] = []
    var saveIssueCallCount = 0

    func fetchProperty() throws -> RentalProperty? { property }
    func saveProperty(_ property: RentalProperty) throws { self.property = property }
    func fetchIssues() throws -> [RepairIssue] { issues.sorted { $0.targetFollowUpDate < $1.targetFollowUpDate } }
    func fetchIssue(id: UUID) throws -> RepairIssue? { issues.first { $0.id == id } }
    func fetchUrgentIssuesNeedingFollowUp(on referenceDate: Date) throws -> [RepairIssue] {
        issues
            .filter { $0.urgency == .urgent && $0.status != .resolved && $0.targetFollowUpDate <= referenceDate }
            .sorted { $0.targetFollowUpDate < $1.targetFollowUpDate }
    }
    func saveIssue(_ issue: RepairIssue) throws {
        saveIssueCallCount += 1
        issues.removeAll { $0.id == issue.id }
        issues.append(issue)
    }
    func deleteIssue(id: UUID) throws { issues.removeAll { $0.id == id } }
    func fetchEvidence(for repairIssueID: UUID) throws -> [EvidenceItem] { evidence.filter { $0.repairIssueID == repairIssueID } }
    func saveEvidence(_ evidence: EvidenceItem) throws {
        self.evidence.removeAll { $0.id == evidence.id }
        self.evidence.append(evidence)
    }
    func fetchFollowUps(for repairIssueID: UUID) throws -> [FollowUpNote] { followUps.filter { $0.repairIssueID == repairIssueID } }
    func saveFollowUp(_ followUp: FollowUpNote) throws {
        followUps.removeAll { $0.id == followUp.id }
        followUps.append(followUp)
    }
}

