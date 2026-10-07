# RentRepair Log Requirements Matrix

| Requirement | Rubric Category | Planned Implementation | Evidence Files | Status | Reviewer Score |
|---|---|---|---|---|---|
| Real-world problem and precise stakeholder | Problem Justification | NSW renter records unresolved repair requests and evidence for follow-up with landlord/agent | README.md, Required Document | Planned | Pending |
| Credible evidence source | Problem Justification | NSW Government repair guidance and AIFS/Fair Trading-style citation in written report | Required Document, README.md | Planned | Pending |
| SwiftUI app | SwiftUI UI | RentRepair Log app built with SwiftUI | Task 3/Views, Task 3/Task_3App.swift | Planned | Pending |
| Minimum five functional screens | SwiftUI UI | Dashboard, Repairs, Repair Detail, New Repair, Evidence Inbox, Property Settings | Task 3/Views | Planned | Pending |
| MVVM | Domain Architecture | Views bind to ViewModels; ViewModels call Use Cases only | Task 3/ViewModels | Planned | Pending |
| Semantic domain models | Domain Architecture | RentalProperty, RepairIssue, EvidenceItem, FollowUpNote | Task 3/Domain | Planned | Pending |
| Minimum three Use Cases | Domain Architecture | ReportRepairIssue, AddEvidenceToRepair, ScheduleRepairFollowUp, ResolveRepairIssue, ImportSharedEvidence | Task 3/UseCases | Planned | Pending |
| Use Case business rules | Domain Architecture | Validate repair issue details, evidence, dates, and status transitions | Task 3/UseCases, tests | Planned | Pending |
| Typed domain errors and human-readable messages | Domain Architecture | Nested error enums expose recovery guidance for UI alerts | Task 3/UseCases | Planned | Pending |
| Core Data or CloudKit persistence | Database | Core Data local store for private evidence log | Task 3/Persistence | Planned | Pending |
| At least two related entities | Database | RentalPropertyRecord -> RepairIssueRecord -> EvidenceItemRecord / FollowUpRecord | Task 3/Persistence | Planned | Pending |
| Meaningful predicate/query | Database | Fetch unresolved urgent repairs needing follow-up by reference date | CoreDataRepairRepository | Planned | Pending |
| Repository protocol | Database | RepairRepository protocol with Core Data and mock implementations | Task 3/Domain, tests | Planned | Pending |
| No View/ViewModel direct persistence | Domain Architecture | Dependencies injected through AppDependencies and Use Cases | ViewModels, UseCases | Planned | Pending |
| Two iOS system extensions | System Extensions | WidgetKit widget and Share Extension | RentRepairWidget, RentRepairShareExtension | Planned | Pending |
| Widget reads App Group data | System Extensions | Widget reads shared summary JSON | Shared/SharedRepairSnapshotStore.swift | Planned | Pending |
| Widget supports two families | System Extensions | systemSmall and systemMedium | RentRepairWidget/RentRepairWidget.swift | Planned | Pending |
| Main app refreshes widget after relevant changes | System Extensions | WidgetCenter.reloadAllTimelines after data mutation | AppDependencies / ViewModels | Planned | Pending |
| Share Extension appears for relevant content | System Extensions | Supports text, URLs, images, PDFs; writes inbox JSON to App Group | RentRepairShareExtension | Planned | Pending |
| Share Extension dismisses correctly | System Extensions | Completes request after import attempt | ShareViewController.swift | Planned | Pending |
| Minimum five unit tests | Code Quality / Testing | XCTest tests use MockRepairRepository | PantryLinkTests / RentRepairLogTests | Planned | Pending |
| README complete | Code Quality / Git | Overview, problem, stakeholder, architecture, extensions, database, setup, tests, AI declaration | README.md | Planned | Pending |
| Required PDF with four sections | Deliverables / Reflection | Problem, design, architecture diagram, 700-900 word reflection | Docs/RentRepairLog_RequiredDocument.pdf | Planned | Pending |
| Professional Git history | Code Quality / Git | Conventional commits on feature branch, merge to main before final | git log | In progress | Pending |
| Final GitHub remote sync | Code Quality / Git | Push main once origin is known/authenticated | git remote, git status | Blocked until remote configured | Pending |

