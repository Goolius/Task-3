# Canonical Project Specification: RentRepair Log

## App Identity
- App name: RentRepair Log
- Xcode project: Task 3
- Primary stakeholder: NSW private renter managing a repair request with a landlord or property manager.
- Problem: Renters are advised to request repairs in writing and keep evidence, but repair details, photos, messages, and follow-up dates are often scattered across apps. That makes it harder to show a clear timeline when a repair is ignored or delayed.

## Approved Workflow
1. Renter records their rental property and landlord/agent contact.
2. Renter reports a repair issue with category, urgency, description, and date first reported.
3. The app calculates a follow-up target and stores the repair.
4. Renter attaches evidence such as photos, messages, or copied referral text.
5. Dashboard highlights urgent or overdue follow-ups.
6. Widget surfaces the next follow-up without opening the app.
7. Share Extension saves relevant text/files from other apps into an evidence inbox.
8. Renter reviews inbox items and attaches them to the right repair.

## Screens
- Dashboard
- Repairs
- Repair Detail
- New Repair
- Evidence Inbox
- Property Settings

## Domain Terminology
- RentalProperty
- RepairIssue
- EvidenceItem
- FollowUpNote
- Repair urgency: routine, urgent
- Repair status: open, followUpNeeded, resolved

## Repository
- Protocol: RepairRepository
- Core Data implementation: CoreDataRepairRepository
- Mock implementation: MockRepairRepository
- Meaningful query: fetch urgent unresolved repairs whose target follow-up date is on or before the selected date.

## Use Cases
- ReportRepairIssueUseCase
- AddEvidenceToRepairUseCase
- ScheduleRepairFollowUpUseCase
- ResolveRepairIssueUseCase
- ImportSharedEvidenceUseCase

## Persistence
- Database choice: Core Data
- Entity: RentalPropertyRecord
- Entity: RepairIssueRecord
- Entity: EvidenceItemRecord
- Entity: FollowUpRecord
- Relationship: RentalPropertyRecord has many RepairIssueRecord records.
- Relationship: RepairIssueRecord has many EvidenceItemRecord and FollowUpRecord records.

## Extensions
- Widget: RentRepairWidget
  - Families: systemSmall, systemMedium
  - Data source: App Group JSON snapshot from main app
  - Purpose: show the next repair follow-up and overdue count.
- Share Extension: RentRepairShareExtension
  - Supported content: text, URLs, images, PDFs, generic files.
  - Data path: writes inbox items to App Group JSON for the main app to import.
  - Purpose: capture repair evidence from Messages, Mail, Photos, Files, or Safari.

## App Group
- Identifier: group.com.example.rentrepairlog
- Shared files:
  - repair-summary.json
  - evidence-inbox.json

## External Sources
- NSW Government Renting: Getting repairs done.
- NSW Fair Trading / Tenants guidance may be cited if needed.

## Change Control
Any change to app name, stakeholder, domain model, persistence choice, extension behavior, App Group identifier, or use case names must update this specification, implementation, tests, README, and Required Document together.

