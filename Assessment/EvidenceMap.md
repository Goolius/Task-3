# RentRepair Log Evidence Map

This file maps the assessment requirements to the concrete project files that demonstrate them.

## Product and Problem

| Requirement | Evidence |
|---|---|
| Real-world problem, stakeholder, and scope | `README.md`, `Assessment/CanonicalProjectSpecification.md`, `output/pdf/RentRepairLog_RequiredDocument.pdf` |
| Evidence-based justification | `README.md`, `output/pdf/RentRepairLog_RequiredDocument.pdf` |
| AI assistance declaration | `README.md`, `output/pdf/RentRepairLog_RequiredDocument.pdf` |

## Architecture

| Requirement | Evidence |
|---|---|
| MVVM structure | `Task 3/Views`, `Task 3/ViewModels`, `Task 3/UseCases` |
| Domain models | `Task 3/Domain/RepairDomain.swift` |
| Repository abstraction | `Task 3/Domain/RepairRepository.swift` |
| Use Case layer | `Task 3/UseCases/RepairUseCases.swift` |
| Dependency composition | `Task 3/AppDependencies.swift` |
| Architecture explanation and diagram | `output/pdf/RentRepairLog_RequiredDocument.pdf` |

## Persistence

| Requirement | Evidence |
|---|---|
| Core Data stack | `Task 3/Persistence/RentRepairPersistenceController.swift` |
| Related entities | `RentalPropertyRecord`, `RepairIssueRecord`, `EvidenceItemRecord`, and `FollowUpRecord` in `RentRepairPersistenceController.swift` |
| Repository implementation | `Task 3/Persistence/CoreDataRepairRepository.swift` |
| Predicate query | `fetchUrgentIssuesNeedingFollowUp(on:)` in `CoreDataRepairRepository.swift` |

## SwiftUI Experience

| Requirement | Evidence |
|---|---|
| Dashboard | `Task 3/Views/DashboardView.swift`, `Task 3/ViewModels/DashboardViewModel.swift` |
| Repair list | `Task 3/Views/RepairListView.swift`, `Task 3/ViewModels/RepairListViewModel.swift` |
| Repair detail | `Task 3/Views/RepairDetailView.swift`, `Task 3/ViewModels/RepairDetailViewModel.swift` |
| New repair workflow | `Task 3/Views/NewRepairView.swift`, `Task 3/ViewModels/NewRepairViewModel.swift` |
| Evidence inbox | `Task 3/Views/EvidenceInboxView.swift`, `Task 3/ViewModels/EvidenceInboxViewModel.swift` |
| Property settings | `Task 3/Views/PropertySettingsView.swift`, `Task 3/ViewModels/PropertySettingsViewModel.swift` |

## System Extensions

| Requirement | Evidence |
|---|---|
| Shared App Group storage | `Task 3/AppGroup/SharedRepairStores.swift`, `Task 3/RentRepairLog.entitlements`, `RentRepairWidget/RentRepairWidget.entitlements`, `RentRepairShareExtension/RentRepairShareExtension.entitlements` |
| Widget extension | `RentRepairWidget/RentRepairWidget.swift`, `Config/RentRepairWidgetInfo.plist` |
| Widget families | `.systemSmall` and `.systemMedium` support in `RentRepairWidget.swift` |
| Share extension | `RentRepairShareExtension/ShareViewController.swift`, `Config/RentRepairShareExtensionInfo.plist` |
| App refreshes widget | `refreshSharedSnapshot()` in `Task 3/AppDependencies.swift` |

## Testing and Quality

| Requirement | Evidence |
|---|---|
| Unit tests | `RentRepairLogTests/RentRepairUseCaseTests.swift` |
| Mock repository | `RentRepairLogTests/MockRepairRepository.swift` |
| Xcode test target and shared scheme | `Task 3.xcodeproj/project.pbxproj`, `Task 3.xcodeproj/xcshareddata/xcschemes/Task 3.xcscheme` |
| Excluded generated/secrets files | `.gitignore` |

## Final Delivery State

The local implementation is complete and documented. GitHub publishing remains blocked until the repository has a configured `origin` remote and valid GitHub authentication.
