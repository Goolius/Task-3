import Foundation

@MainActor
protocol RepairRepository {
    func fetchProperty() throws -> RentalProperty?
    func saveProperty(_ property: RentalProperty) throws

    func fetchIssues() throws -> [RepairIssue]
    func fetchIssue(id: UUID) throws -> RepairIssue?
    func fetchUrgentIssuesNeedingFollowUp(on referenceDate: Date) throws -> [RepairIssue]
    func saveIssue(_ issue: RepairIssue) throws
    func deleteIssue(id: UUID) throws

    func fetchEvidence(for repairIssueID: UUID) throws -> [EvidenceItem]
    func saveEvidence(_ evidence: EvidenceItem) throws

    func fetchFollowUps(for repairIssueID: UUID) throws -> [FollowUpNote]
    func saveFollowUp(_ followUp: FollowUpNote) throws
}

