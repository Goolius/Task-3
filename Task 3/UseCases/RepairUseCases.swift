import Foundation

@MainActor
struct SaveRentalPropertyUseCase {
    enum Failure: Error, LocalizedError, Equatable {
        case missingAddress
        case missingAgent
        case repository(String)

        var errorDescription: String? {
            switch self {
            case .missingAddress:
                "Enter the rental property address so repair evidence is tied to the right home."
            case .missingAgent:
                "Enter the landlord or agent name so follow-ups are addressed clearly."
            case .repository(let message):
                message
            }
        }
    }

    let repository: RepairRepository

    func execute(_ property: RentalProperty) throws {
        let address = property.addressLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let agent = property.landlordOrAgentName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty else { throw Failure.missingAddress }
        guard !agent.isEmpty else { throw Failure.missingAgent }

        do {
            var cleanProperty = property
            cleanProperty.nickname = property.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
            cleanProperty.addressLine = address
            cleanProperty.landlordOrAgentName = agent
            cleanProperty.preferredContact = property.preferredContact.trimmingCharacters(in: .whitespacesAndNewlines)
            try repository.saveProperty(cleanProperty)
        } catch {
            throw Failure.repository(error.localizedDescription)
        }
    }
}

@MainActor
struct ReviewRentalPropertyUseCase {
    enum Failure: Error, LocalizedError, Equatable {
        case repository(String)

        var errorDescription: String? {
            switch self {
            case .repository(let message):
                message
            }
        }
    }

    let repository: RepairRepository

    func execute() throws -> RentalProperty? {
        do {
            return try repository.fetchProperty()
        } catch {
            throw Failure.repository(error.localizedDescription)
        }
    }
}

@MainActor
struct ReportRepairIssueUseCase {
    enum Failure: Error, LocalizedError, Equatable {
        case missingProperty
        case titleTooShort
        case detailsTooShort
        case futureReportDate
        case repository(String)

        var errorDescription: String? {
            switch self {
            case .missingProperty:
                "Add your rental property before reporting a repair issue."
            case .titleTooShort:
                "Give the repair a clear title so it can be recognised later."
            case .detailsTooShort:
                "Add enough detail to explain what is broken and how it affects the home."
            case .futureReportDate:
                "The first report date cannot be in the future. Choose the date you first told the landlord or agent."
            case .repository(let message):
                message
            }
        }
    }

    let repository: RepairRepository
    var calendar: Calendar = .current

    func execute(
        title: String,
        category: RepairCategory,
        urgency: RepairUrgency,
        details: String,
        dateFirstReported: Date
    ) throws -> RepairIssue {
        guard let property = try repository.fetchProperty() else { throw Failure.missingProperty }

        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanTitle.count >= 4 else { throw Failure.titleTooShort }
        guard cleanDetails.count >= 12 else { throw Failure.detailsTooShort }
        guard dateFirstReported <= Date() else { throw Failure.futureReportDate }

        let targetDate = calendar.date(
            byAdding: .day,
            value: urgency.recommendedFollowUpDays,
            to: dateFirstReported
        ) ?? dateFirstReported

        let issue = RepairIssue(
            id: UUID(),
            propertyID: property.id,
            title: cleanTitle,
            category: category,
            urgency: urgency,
            status: .open,
            details: cleanDetails,
            dateFirstReported: dateFirstReported,
            targetFollowUpDate: targetDate,
            resolvedAt: nil,
            createdAt: Date()
        )

        do {
            try repository.saveIssue(issue)
            return issue
        } catch {
            throw Failure.repository(error.localizedDescription)
        }
    }
}

@MainActor
struct AddEvidenceToRepairUseCase {
    enum Failure: Error, LocalizedError, Equatable {
        case repairMissing
        case repairAlreadyResolved
        case titleMissing
        case noteMissing
        case repository(String)

        var errorDescription: String? {
            switch self {
            case .repairMissing:
                "Choose an existing repair before attaching evidence."
            case .repairAlreadyResolved:
                "This repair is already resolved. Reopen or create a new issue before adding more evidence."
            case .titleMissing:
                "Name the evidence so it is useful in a repair timeline."
            case .noteMissing:
                "Add a short note explaining what this evidence shows."
            case .repository(let message):
                message
            }
        }
    }

    let repository: RepairRepository

    func execute(
        repairIssueID: UUID,
        title: String,
        kind: EvidenceKind,
        note: String,
        sourceApp: String,
        fileName: String?
    ) throws -> EvidenceItem {
        guard let issue = try repository.fetchIssue(id: repairIssueID) else { throw Failure.repairMissing }
        guard issue.status != .resolved else { throw Failure.repairAlreadyResolved }

        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { throw Failure.titleMissing }
        guard !cleanNote.isEmpty else { throw Failure.noteMissing }

        let evidence = EvidenceItem(
            id: UUID(),
            repairIssueID: repairIssueID,
            title: cleanTitle,
            kind: kind,
            capturedAt: Date(),
            note: cleanNote,
            sourceApp: sourceApp.trimmingCharacters(in: .whitespacesAndNewlines),
            fileName: fileName
        )

        do {
            try repository.saveEvidence(evidence)
            return evidence
        } catch {
            throw Failure.repository(error.localizedDescription)
        }
    }
}

@MainActor
struct ScheduleRepairFollowUpUseCase {
    enum Failure: Error, LocalizedError, Equatable {
        case repairMissing
        case repairAlreadyResolved
        case dueDateBeforeReport
        case noteMissing
        case repository(String)

        var errorDescription: String? {
            switch self {
            case .repairMissing:
                "Choose a repair before scheduling a follow-up."
            case .repairAlreadyResolved:
                "This repair is resolved, so it no longer needs a follow-up."
            case .dueDateBeforeReport:
                "The follow-up date must be after the first report date."
            case .noteMissing:
                "Write what you plan to ask or confirm in this follow-up."
            case .repository(let message):
                message
            }
        }
    }

    let repository: RepairRepository

    func execute(repairIssueID: UUID, dueDate: Date, note: String) throws -> FollowUpNote {
        guard var issue = try repository.fetchIssue(id: repairIssueID) else { throw Failure.repairMissing }
        guard issue.status != .resolved else { throw Failure.repairAlreadyResolved }
        guard dueDate >= issue.dateFirstReported else { throw Failure.dueDateBeforeReport }

        let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanNote.isEmpty else { throw Failure.noteMissing }

        let followUp = FollowUpNote(
            id: UUID(),
            repairIssueID: repairIssueID,
            dueDate: dueDate,
            note: cleanNote,
            completedAt: nil,
            createdAt: Date()
        )

        do {
            issue.status = .followUpNeeded
            issue.targetFollowUpDate = dueDate
            try repository.saveIssue(issue)
            try repository.saveFollowUp(followUp)
            return followUp
        } catch {
            throw Failure.repository(error.localizedDescription)
        }
    }
}

@MainActor
struct ResolveRepairIssueUseCase {
    enum Failure: Error, LocalizedError, Equatable {
        case repairMissing
        case noEvidence
        case repository(String)

        var errorDescription: String? {
            switch self {
            case .repairMissing:
                "Choose an existing repair before marking it resolved."
            case .noEvidence:
                "Attach at least one evidence item before resolving the repair, so the timeline remains complete."
            case .repository(let message):
                message
            }
        }
    }

    let repository: RepairRepository

    func execute(repairIssueID: UUID) throws -> RepairIssue {
        guard var issue = try repository.fetchIssue(id: repairIssueID) else { throw Failure.repairMissing }
        let evidence = try repository.fetchEvidence(for: repairIssueID)
        guard !evidence.isEmpty else { throw Failure.noEvidence }

        do {
            issue.status = .resolved
            issue.resolvedAt = Date()
            try repository.saveIssue(issue)
            return issue
        } catch {
            throw Failure.repository(error.localizedDescription)
        }
    }
}

@MainActor
struct ReviewRepairDashboardUseCase {
    enum Failure: Error, LocalizedError, Equatable {
        case repository(String)

        var errorDescription: String? {
            switch self {
            case .repository(let message):
                message
            }
        }
    }

    let repository: RepairRepository
    let inboxStore: SharedEvidenceInboxStore

    func execute(referenceDate: Date = Date()) throws -> RepairDashboardSummary {
        do {
            let allIssues = try repository.fetchIssues()
            let openIssues = allIssues.filter { $0.status != .resolved }
            return RepairDashboardSummary(
                property: try repository.fetchProperty(),
                openIssues: openIssues,
                urgentFollowUps: try repository.fetchUrgentIssuesNeedingFollowUp(on: referenceDate),
                evidenceInboxCount: inboxStore.loadItems().count
            )
        } catch {
            throw Failure.repository(error.localizedDescription)
        }
    }
}

@MainActor
struct ListRepairIssuesUseCase {
    enum Failure: Error, LocalizedError, Equatable {
        case repository(String)

        var errorDescription: String? {
            switch self {
            case .repository(let message):
                message
            }
        }
    }

    let repository: RepairRepository

    func execute() throws -> [RepairIssue] {
        do {
            return try repository.fetchIssues()
        } catch {
            throw Failure.repository(error.localizedDescription)
        }
    }
}

@MainActor
struct ReviewRepairIssueUseCase {
    enum Failure: Error, LocalizedError, Equatable {
        case repairMissing
        case repository(String)

        var errorDescription: String? {
            switch self {
            case .repairMissing:
                "That repair could not be opened. Return to the repairs list and try again."
            case .repository(let message):
                message
            }
        }
    }

    let repository: RepairRepository

    func execute(repairIssueID: UUID) throws -> RepairIssueDetails {
        do {
            guard let issue = try repository.fetchIssue(id: repairIssueID) else { throw Failure.repairMissing }
            return RepairIssueDetails(
                issue: issue,
                evidence: try repository.fetchEvidence(for: repairIssueID),
                followUps: try repository.fetchFollowUps(for: repairIssueID)
            )
        } catch let failure as Failure {
            throw failure
        } catch {
            throw Failure.repository(error.localizedDescription)
        }
    }
}

@MainActor
struct ImportSharedEvidenceUseCase {
    enum Failure: Error, LocalizedError, Equatable {
        case repairMissing
        case inboxItemMissing
        case repository(String)

        var errorDescription: String? {
            switch self {
            case .repairMissing:
                "Choose the repair this shared evidence belongs to."
            case .inboxItemMissing:
                "That shared evidence item is no longer in the inbox."
            case .repository(let message):
                message
            }
        }
    }

    let repository: RepairRepository
    let inboxStore: SharedEvidenceInboxStore
    let addEvidence: AddEvidenceToRepairUseCase

    func pendingItems() -> [SharedEvidenceInboxItem] {
        inboxStore.loadItems()
    }

    func execute(inboxItemID: UUID, repairIssueID: UUID) throws -> EvidenceItem {
        guard try repository.fetchIssue(id: repairIssueID) != nil else { throw Failure.repairMissing }
        let items = inboxStore.loadItems()
        guard let item = items.first(where: { $0.id == inboxItemID }) else { throw Failure.inboxItemMissing }

        do {
            let evidence = try addEvidence.execute(
                repairIssueID: repairIssueID,
                title: item.suggestedTitle,
                kind: item.kind,
                note: item.note,
                sourceApp: item.sourceApp,
                fileName: item.fileName
            )
            inboxStore.removeItem(id: inboxItemID)
            return evidence
        } catch {
            throw Failure.repository(error.localizedDescription)
        }
    }
}
