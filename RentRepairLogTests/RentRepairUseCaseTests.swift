import XCTest
@testable import Task_3

@MainActor
final class RentRepairUseCaseTests: XCTestCase {
    private var repository: MockRepairRepository!
    private var property: RentalProperty!

    override func setUp() {
        super.setUp()
        property = RentalProperty(
            id: UUID(),
            nickname: "Home",
            addressLine: "1 Repair Street, Sydney NSW",
            landlordOrAgentName: "Sample Agent",
            preferredContact: "repairs@example.com",
            createdAt: Date()
        )
        repository = MockRepairRepository()
        repository.property = property
    }

    func testReportingUrgentRepairCalculatesNextDayFollowUp() throws {
        let reported = Date(timeIntervalSince1970: 1_700_000_000)
        let useCase = ReportRepairIssueUseCase(repository: repository, calendar: Calendar(identifier: .gregorian))

        let issue = try useCase.execute(
            title: "Burst pipe",
            category: .plumbing,
            urgency: .urgent,
            details: "Water is entering the kitchen from the pipe.",
            dateFirstReported: reported
        )

        XCTAssertEqual(issue.urgency, .urgent)
        XCTAssertEqual(issue.status, .open)
        XCTAssertEqual(repository.saveIssueCallCount, 1)
        XCTAssertEqual(
            Calendar(identifier: .gregorian).dateComponents([.day], from: reported, to: issue.targetFollowUpDate).day,
            1
        )
    }

    func testReportingRepairWithoutPropertyIsRejectedInRenterLanguage() {
        repository.property = nil
        let useCase = ReportRepairIssueUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(
                title: "Leak",
                category: .plumbing,
                urgency: .urgent,
                details: "Water is leaking under the sink.",
                dateFirstReported: Date()
            )
        ) { error in
            XCTAssertEqual(error as? ReportRepairIssueUseCase.Failure, .missingProperty)
            XCTAssertTrue(error.localizedDescription.contains("rental property"))
        }
    }

    func testEvidenceCannotBeAddedToResolvedRepair() {
        let issue = makeIssue(status: .resolved)
        repository.issues = [issue]
        let useCase = AddEvidenceToRepairUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(
                repairIssueID: issue.id,
                title: "Photo",
                kind: .photo,
                note: "Shows the repair after completion.",
                sourceApp: "Photos",
                fileName: "repair.jpg"
            )
        ) { error in
            XCTAssertEqual(error as? AddEvidenceToRepairUseCase.Failure, .repairAlreadyResolved)
        }
    }

    func testFollowUpBeforeFirstReportDateIsRejected() {
        let issue = makeIssue(dateFirstReported: Date(timeIntervalSince1970: 1_700_000_000))
        repository.issues = [issue]
        let useCase = ScheduleRepairFollowUpUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(
                repairIssueID: issue.id,
                dueDate: Date(timeIntervalSince1970: 1_699_900_000),
                note: "Ask agent for repair booking."
            )
        ) { error in
            XCTAssertEqual(error as? ScheduleRepairFollowUpUseCase.Failure, .dueDateBeforeReport)
        }
    }

    func testResolvingRepairRequiresEvidenceTimeline() {
        let issue = makeIssue(status: .followUpNeeded)
        repository.issues = [issue]
        let useCase = ResolveRepairIssueUseCase(repository: repository)

        XCTAssertThrowsError(try useCase.execute(repairIssueID: issue.id)) { error in
            XCTAssertEqual(error as? ResolveRepairIssueUseCase.Failure, .noEvidence)
        }
    }

    func testDashboardQueryReturnsOnlyUrgentUnresolvedRepairsDueForFollowUp() throws {
        let overdueUrgent = makeIssue(title: "Unsafe front lock", urgency: .urgent, targetOffset: -1)
        let futureUrgent = makeIssue(title: "Stove fault", urgency: .urgent, targetOffset: 2)
        let routine = makeIssue(title: "Loose cupboard", urgency: .routine, targetOffset: -2)
        repository.issues = [futureUrgent, routine, overdueUrgent]

        let due = try repository.fetchUrgentIssuesNeedingFollowUp(on: Date())

        XCTAssertEqual(due.map(\.title), ["Unsafe front lock"])
    }

    private func makeIssue(
        title: String = "Broken window",
        urgency: RepairUrgency = .urgent,
        status: RepairStatus = .open,
        dateFirstReported: Date = Date(timeIntervalSinceNow: -86_400),
        targetOffset: Int = 1
    ) -> RepairIssue {
        RepairIssue(
            id: UUID(),
            propertyID: property.id,
            title: title,
            category: .security,
            urgency: urgency,
            status: status,
            details: "The defect affects safe use of the rental property.",
            dateFirstReported: dateFirstReported,
            targetFollowUpDate: Calendar.current.date(byAdding: .day, value: targetOffset, to: Date()) ?? Date(),
            resolvedAt: status == .resolved ? Date() : nil,
            createdAt: Date()
        )
    }
}
