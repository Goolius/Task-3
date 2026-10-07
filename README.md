# RentRepair Log

RentRepair Log is an iOS SwiftUI application for a NSW private renter who needs to keep a clear repair-request timeline when a landlord or property manager is slow to respond. The app records the rental property, repair issues, evidence, and follow-up dates, then surfaces urgent follow-ups through a widget and captures evidence from other apps through a Share Extension.

## Problem

NSW Government renter guidance explains repair processes, urgent repairs, and dispute pathways, including the need to keep written records and evidence when trying to resolve tenancy disputes:

- [Getting repairs done on a rental property](https://www.nsw.gov.au/housing-and-construction/renting-a-place-to-live/getting-repairs-done)
- [Resolving residential tenancy disputes](https://www.nsw.gov.au/housing-and-construction/renting-a-place-to-live/resolving-residential-tenancy-disputes)
- [Urgent repairs in residential rental properties](https://www.nsw.gov.au/housing-and-construction/rules/urgent-repairs-residential-rental-properties)

The stakeholder is a renter, not a property manager. The app is designed around the renter's workflow: report the defect, attach evidence, follow up on time, and keep a coherent timeline.

## Features

- Dashboard with open repair count, urgent follow-up count, and shared evidence inbox count
- Repair list with unresolved/resolved filtering
- New repair form with category, urgency, first-reported date, and description
- Repair detail timeline with evidence, follow-ups, and resolution action
- Evidence inbox for items captured from the system Share sheet
- Property settings for address and landlord/agent contact details

## Architecture

The app follows the required layered structure:

SwiftUI Views -> ViewModels -> Use Cases -> RepairRepository protocol -> CoreDataRepairRepository -> Core Data

Views and ViewModels do not call Core Data directly. ViewModels receive use cases from `AppDependencies`, and all persistence operations pass through the `RepairRepository` protocol.

## Domain Model

| Domain type | Purpose |
|---|---|
| `RentalProperty` | The rented home and landlord/agent contact details |
| `RepairIssue` | A repair request, urgency, status, first report date, and follow-up target |
| `EvidenceItem` | A photo, message, email, document, note, or link attached to a repair |
| `FollowUpNote` | A scheduled follow-up action for an unresolved repair |

## Persistence Choice

The project uses Core Data because the repair timeline is private, personal, and needs to work offline. The Core Data model is created programmatically in `RentRepairPersistenceController` and contains related records:

- `RentalPropertyRecord` has many `RepairIssueRecord` items
- `RepairIssueRecord` has many `EvidenceItemRecord` items
- `RepairIssueRecord` has many `FollowUpRecord` items

The meaningful predicate query is implemented by `CoreDataRepairRepository.fetchUrgentIssuesNeedingFollowUp(on:)`, which fetches urgent unresolved repairs whose target follow-up date is due.

## Use Cases

- `SaveRentalPropertyUseCase`
- `ReviewRentalPropertyUseCase`
- `ReportRepairIssueUseCase`
- `AddEvidenceToRepairUseCase`
- `ScheduleRepairFollowUpUseCase`
- `ResolveRepairIssueUseCase`
- `ReviewRepairDashboardUseCase`
- `ListRepairIssuesUseCase`
- `ReviewRepairIssueUseCase`
- `ImportSharedEvidenceUseCase`

Each major write use case enforces domain rules and returns renter-readable errors.

## iOS System Extensions

### WidgetKit Widget

Target: `RentRepairWidget`

The widget reads `repair-summary.json` from the App Group and shows the next repair follow-up, open repair count, and urgent follow-up count. It supports `systemSmall` and `systemMedium`. The main app writes the snapshot and calls `WidgetCenter.reloadAllTimelines()` after relevant changes.

### Share Extension

Target: `RentRepairShareExtension`

The Share Extension accepts text, URLs, images, PDFs, and files from other apps. It writes evidence inbox items to `evidence-inbox.json` in the App Group, then dismisses via `completeRequest(returningItems:)`. The main app imports these inbox items and attaches them to an open repair.

## App Group

Identifier: `group.com.example.rentrepairlog`

Shared files:

- `repair-summary.json`
- `evidence-inbox.json`

App Group entitlement files are included for the app, widget, and share extension. A real Apple Developer Team may need to enable the matching App Group before running on device.

## Project Structure

- `Task 3/Domain`: semantic domain models and repository protocol
- `Task 3/UseCases`: business operations and domain errors
- `Task 3/Persistence`: Core Data persistence and repository implementation
- `Task 3/ViewModels`: MVVM presentation logic
- `Task 3/Views`: SwiftUI screens
- `Task 3/AppGroup`: shared snapshot and inbox stores
- `RentRepairWidget`: WidgetKit extension
- `RentRepairShareExtension`: Share Extension
- `RentRepairLogTests`: XCTest unit tests with a mock repository
- `Assessment`: requirements matrix and canonical project specification
- `output/pdf`: required assessment PDF

## Setup

1. Open `Task 3.xcodeproj` in Xcode.
2. Select the `Task 3` scheme.
3. If running on a physical device, set a valid development team and enable the App Group `group.com.example.rentrepairlog` for the app and both extensions.
4. Build and run on an iOS simulator.

## Running Tests

From Terminal:

```bash
xcodebuild -project "Task 3.xcodeproj" -scheme "Task 3" -destination "platform=iOS Simulator,name=iPhone 17" CODE_SIGNING_ALLOWED=NO test
```

Verified passing locally: 6 tests in `RentRepairUseCaseTests`.

## Known Limitations

- App Group behavior is implemented and builds, but must be verified interactively in Simulator or on device after signing is configured.
- The Share Extension stores metadata and text notes for shared files; it does not copy binary file contents into the App Group.
- The project uses example bundle identifiers suitable for assessment code review, not App Store distribution.

## External Resources / Attribution

No third-party Swift packages are used. The implementation uses Apple frameworks: SwiftUI, Core Data, WidgetKit, UIKit, UniformTypeIdentifiers, and XCTest. Real-world problem evidence is cited from NSW Government renter guidance listed above.

## AI Assistance

AI assistance was used to design and implement this assessment project. The Required Document includes an explicit AI-use reflection.

