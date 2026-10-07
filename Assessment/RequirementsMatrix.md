# RentRepair Log Requirements Matrix

| Requirement | Rubric Category | Final Implementation | Evidence Files | Status | Reviewer Score |
|---|---|---|---|---|---|
| Real-world problem and precise stakeholder | Problem Justification | NSW renter records unresolved repair requests and evidence for follow-up with landlord/agent | README.md, output/pdf/RentRepairLog_RequiredDocument.pdf | Verified | 9/10 |
| Credible evidence source | Problem Justification | NSW Government repair, urgent repair, and tenancy dispute guidance cited in README/report | README.md, output/pdf/RentRepairLog_RequiredDocument.pdf | Verified | 9/10 |
| SwiftUI app | SwiftUI UI | RentRepair Log app built with SwiftUI | Task 3/Views, Task 3/Task_3App.swift, Task 3/ContentView.swift | Verified | 9/10 |
| Minimum five functional screens | SwiftUI UI | Dashboard, Repairs, Repair Detail, New Repair, Evidence Inbox, Property Settings | Task 3/Views | Verified | 10/10 |
| MVVM | Domain Architecture | Views bind to ViewModels; ViewModels call Use Cases for workflow actions | Task 3/ViewModels, Task 3/UseCases | Verified | 9/10 |
| Semantic domain models | Domain Architecture | RentalProperty, RepairIssue, EvidenceItem, FollowUpNote | Task 3/Domain/RepairDomain.swift | Verified | 10/10 |
| Minimum three Use Cases | Domain Architecture | Save/Review property, Report, AddEvidence, ScheduleFollowUp, Resolve, Dashboard, List, Detail, ImportSharedEvidence | Task 3/UseCases/RepairUseCases.swift | Verified | 10/10 |
| Use Case business rules | Domain Architecture | Validates issue details, evidence, dates, property setup, and status transitions | Task 3/UseCases, RentRepairLogTests | Verified | 9/10 |
| Typed domain errors and human-readable messages | Domain Architecture | Nested error enums expose renter-facing recovery guidance for UI alerts | Task 3/UseCases/RepairUseCases.swift | Verified | 9/10 |
| Core Data or CloudKit persistence | Database | Core Data local store for private evidence log | Task 3/Persistence | Verified | 10/10 |
| At least two related entities | Database | RentalPropertyRecord -> RepairIssueRecord -> EvidenceItemRecord / FollowUpRecord | Task 3/Persistence/RentRepairPersistenceController.swift | Verified | 10/10 |
| Meaningful predicate/query | Database | Fetches unresolved urgent repairs needing follow-up by reference date | Task 3/Persistence/CoreDataRepairRepository.swift | Verified | 9/10 |
| Repository protocol | Database | RepairRepository protocol with Core Data, preview, and mock implementations | Task 3/Domain/RepairRepository.swift, RentRepairLogTests/MockRepairRepository.swift | Verified | 10/10 |
| No View/ViewModel direct persistence | Domain Architecture | Dependencies injected through AppDependencies and Use Cases | Task 3/AppDependencies.swift, Task 3/ViewModels, Task 3/UseCases | Verified | 9/10 |
| Two iOS system extensions | System Extensions | WidgetKit widget and Share Extension | RentRepairWidget, RentRepairShareExtension | Verified | 10/10 |
| Widget reads App Group data | System Extensions | Widget reads shared summary JSON from App Group/fallback support directory | Task 3/AppGroup/SharedRepairStores.swift, RentRepairWidget/RentRepairWidget.swift | Verified | 9/10 |
| Widget supports two families | System Extensions | systemSmall and systemMedium | RentRepairWidget/RentRepairWidget.swift | Verified | 10/10 |
| Main app refreshes widget after relevant changes | System Extensions | WidgetCenter.reloadAllTimelines after snapshot refresh | Task 3/AppDependencies.swift | Verified | 9/10 |
| Share Extension appears for relevant content | System Extensions | Supports text, URLs, images, PDFs, and general files; writes inbox metadata to App Group | RentRepairShareExtension/ShareViewController.swift, Config/RentRepairShareExtensionInfo.plist | Verified | 9/10 |
| Share Extension dismisses correctly | System Extensions | Completes request after import attempt | RentRepairShareExtension/ShareViewController.swift | Verified | 10/10 |
| Minimum five unit tests | Code Quality / Testing | Six XCTest tests use MockRepairRepository and cover business rules/predicate behavior | RentRepairLogTests/RentRepairUseCaseTests.swift | Verified | 10/10 |
| README complete | Code Quality / Git | Overview, problem, stakeholder, architecture, extensions, database, setup, tests, known limitations, AI declaration | README.md | Verified | 10/10 |
| Required PDF with four sections | Deliverables / Reflection | Problem, design, architecture diagram, and 700-900 word reflection | output/pdf/RentRepairLog_RequiredDocument.pdf, Docs/build_required_document.py | Verified | 10/10 |
| Professional Git history | Code Quality / Git | Conventional commits on feature branch; final merge to main pending final verification | git log | Local feature history complete | 9/10 |
| Final GitHub remote sync | Code Quality / Git | Push main once origin is known/authenticated | git remote, git status | Blocked: origin not configured | Blocked |
