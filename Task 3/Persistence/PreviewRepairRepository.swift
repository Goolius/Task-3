import Foundation

@MainActor
final class PreviewRepairRepository: RepairRepository {
    private var property = RentalProperty(
        id: UUID(),
        nickname: "Unit 4",
        addressLine: "12 Sample Street, Parramatta NSW",
        landlordOrAgentName: "Harbour Property Management",
        preferredContact: "repairs@example.com",
        createdAt: Date()
    )
    private var issues: [RepairIssue] = []
    private var evidence: [EvidenceItem] = []
    private var followUps: [FollowUpNote] = []

    init() {
        let issue = RepairIssue(
            id: UUID(),
            propertyID: property.id,
            title: "Bathroom ceiling leak",
            category: .plumbing,
            urgency: .urgent,
            status: .followUpNeeded,
            details: "Water is dripping through the bathroom ceiling after heavy rain.",
            dateFirstReported: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            targetFollowUpDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            resolvedAt: nil,
            createdAt: Date()
        )
        issues = [issue]
        evidence = [
            EvidenceItem(
                id: UUID(),
                repairIssueID: issue.id,
                title: "Ceiling photo",
                kind: .photo,
                capturedAt: Date(),
                note: "Shows water stain and active drip.",
                sourceApp: "Photos",
                fileName: "ceiling.jpg"
            )
        ]
    }

    func fetchProperty() throws -> RentalProperty? { property }
    func saveProperty(_ property: RentalProperty) throws { self.property = property }
    func fetchIssues() throws -> [RepairIssue] { issues }
    func fetchIssue(id: UUID) throws -> RepairIssue? { issues.first { $0.id == id } }
    func fetchUrgentIssuesNeedingFollowUp(on referenceDate: Date) throws -> [RepairIssue] {
        issues.filter { $0.urgency == .urgent && $0.status != .resolved && $0.targetFollowUpDate <= referenceDate }
    }
    func saveIssue(_ issue: RepairIssue) throws {
        issues.removeAll { $0.id == issue.id }
        issues.append(issue)
    }
    func deleteIssue(id: UUID) throws { issues.removeAll { $0.id == id } }
    func fetchEvidence(for repairIssueID: UUID) throws -> [EvidenceItem] {
        evidence.filter { $0.repairIssueID == repairIssueID }
    }
    func saveEvidence(_ evidence: EvidenceItem) throws {
        self.evidence.removeAll { $0.id == evidence.id }
        self.evidence.append(evidence)
    }
    func fetchFollowUps(for repairIssueID: UUID) throws -> [FollowUpNote] {
        followUps.filter { $0.repairIssueID == repairIssueID }
    }
    func saveFollowUp(_ followUp: FollowUpNote) throws {
        followUps.removeAll { $0.id == followUp.id }
        followUps.append(followUp)
    }
}

