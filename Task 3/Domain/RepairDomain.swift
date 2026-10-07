import Foundation

struct RentalProperty: Identifiable, Equatable {
    var id: UUID
    var nickname: String
    var addressLine: String
    var landlordOrAgentName: String
    var preferredContact: String
    var createdAt: Date

    static let blank = RentalProperty(
        id: UUID(),
        nickname: "",
        addressLine: "",
        landlordOrAgentName: "",
        preferredContact: "",
        createdAt: Date()
    )
}

struct RepairIssue: Identifiable, Equatable {
    var id: UUID
    var propertyID: UUID
    var title: String
    var category: RepairCategory
    var urgency: RepairUrgency
    var status: RepairStatus
    var details: String
    var dateFirstReported: Date
    var targetFollowUpDate: Date
    var resolvedAt: Date?
    var createdAt: Date

    var needsFollowUp: Bool {
        status != .resolved && targetFollowUpDate <= Date()
    }
}

struct EvidenceItem: Identifiable, Equatable, Codable {
    var id: UUID
    var repairIssueID: UUID
    var title: String
    var kind: EvidenceKind
    var capturedAt: Date
    var note: String
    var sourceApp: String
    var fileName: String?
}

struct FollowUpNote: Identifiable, Equatable {
    var id: UUID
    var repairIssueID: UUID
    var dueDate: Date
    var note: String
    var completedAt: Date?
    var createdAt: Date
}

struct RepairIssueDetails: Equatable {
    var issue: RepairIssue
    var evidence: [EvidenceItem]
    var followUps: [FollowUpNote]
}

struct RepairDashboardSummary: Equatable {
    var property: RentalProperty?
    var openIssues: [RepairIssue]
    var urgentFollowUps: [RepairIssue]
    var evidenceInboxCount: Int

    var openCount: Int { openIssues.count }
    var urgentCount: Int { urgentFollowUps.count }
}

enum RepairCategory: String, CaseIterable, Identifiable, Codable {
    case plumbing
    case electrical
    case heatingCooling
    case security
    case mouldOrDamp
    case appliance
    case structural
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .plumbing: "Plumbing"
        case .electrical: "Electrical"
        case .heatingCooling: "Heating or cooling"
        case .security: "Security"
        case .mouldOrDamp: "Mould or damp"
        case .appliance: "Appliance"
        case .structural: "Structural"
        case .other: "Other"
        }
    }
}

enum RepairUrgency: String, CaseIterable, Identifiable, Codable {
    case routine
    case urgent

    var id: String { rawValue }

    var label: String {
        switch self {
        case .routine: "Routine"
        case .urgent: "Urgent"
        }
    }

    var recommendedFollowUpDays: Int {
        switch self {
        case .urgent: 1
        case .routine: 7
        }
    }
}

enum RepairStatus: String, CaseIterable, Identifiable, Codable {
    case open
    case followUpNeeded
    case resolved

    var id: String { rawValue }

    var label: String {
        switch self {
        case .open: "Open"
        case .followUpNeeded: "Follow-up needed"
        case .resolved: "Resolved"
        }
    }
}

enum EvidenceKind: String, CaseIterable, Identifiable, Codable {
    case photo
    case message
    case email
    case document
    case note
    case link

    var id: String { rawValue }

    var label: String {
        switch self {
        case .photo: "Photo"
        case .message: "Message"
        case .email: "Email"
        case .document: "Document"
        case .note: "Note"
        case .link: "Link"
        }
    }
}

enum RepairRepositoryError: Error, LocalizedError, Equatable {
    case propertyNotFound
    case repairNotFound
    case evidenceNotFound
    case persistenceUnavailable(String)

    var errorDescription: String? {
        switch self {
        case .propertyNotFound:
            "Add your rental property before recording repair issues."
        case .repairNotFound:
            "That repair issue could not be found. Refresh the repair list and try again."
        case .evidenceNotFound:
            "That evidence item could not be found. Import or add it again."
        case .persistenceUnavailable(let reason):
            "RentRepair Log could not save your repair record: \(reason)"
        }
    }
}

