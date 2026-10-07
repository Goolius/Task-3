import CoreData
import Foundation

@MainActor
final class CoreDataRepairRepository: RepairRepository {
    private let context: NSManagedObjectContext

    static func live() -> CoreDataRepairRepository {
        CoreDataRepairRepository(context: RentRepairPersistenceController.shared.container.viewContext)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchProperty() throws -> RentalProperty? {
        try fetchPropertyRecord().map(mapProperty)
    }

    func saveProperty(_ property: RentalProperty) throws {
        let record = try fetchPropertyRecord(id: property.id) ?? NSManagedObject(entity: entity("RentalPropertyRecord"), insertInto: context)
        record.setValue(property.id, forKey: "id")
        record.setValue(property.nickname, forKey: "nickname")
        record.setValue(property.addressLine, forKey: "addressLine")
        record.setValue(property.landlordOrAgentName, forKey: "landlordOrAgentName")
        record.setValue(property.preferredContact, forKey: "preferredContact")
        record.setValue(property.createdAt, forKey: "createdAt")
        try saveContext()
    }

    func fetchIssues() throws -> [RepairIssue] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "RepairIssueRecord")
        request.sortDescriptors = [
            NSSortDescriptor(key: "statusRaw", ascending: true),
            NSSortDescriptor(key: "targetFollowUpDate", ascending: true)
        ]
        return try context.fetch(request).map(mapIssue)
    }

    func fetchIssue(id: UUID) throws -> RepairIssue? {
        try fetchIssueRecord(id: id).map(mapIssue)
    }

    func fetchUrgentIssuesNeedingFollowUp(on referenceDate: Date) throws -> [RepairIssue] {
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: referenceDate) ?? referenceDate
        let request = NSFetchRequest<NSManagedObject>(entityName: "RepairIssueRecord")
        request.predicate = NSPredicate(
            format: "urgencyRaw == %@ AND statusRaw != %@ AND targetFollowUpDate <= %@",
            RepairUrgency.urgent.rawValue,
            RepairStatus.resolved.rawValue,
            endOfDay as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "targetFollowUpDate", ascending: true)]
        return try context.fetch(request).map(mapIssue)
    }

    func saveIssue(_ issue: RepairIssue) throws {
        guard let propertyRecord = try fetchPropertyRecord(id: issue.propertyID) else {
            throw RepairRepositoryError.propertyNotFound
        }

        let record = try fetchIssueRecord(id: issue.id) ?? NSManagedObject(entity: entity("RepairIssueRecord"), insertInto: context)
        record.setValue(issue.id, forKey: "id")
        record.setValue(issue.title, forKey: "title")
        record.setValue(issue.category.rawValue, forKey: "categoryRaw")
        record.setValue(issue.urgency.rawValue, forKey: "urgencyRaw")
        record.setValue(issue.status.rawValue, forKey: "statusRaw")
        record.setValue(issue.details, forKey: "details")
        record.setValue(issue.dateFirstReported, forKey: "dateFirstReported")
        record.setValue(issue.targetFollowUpDate, forKey: "targetFollowUpDate")
        record.setValue(issue.resolvedAt, forKey: "resolvedAt")
        record.setValue(issue.createdAt, forKey: "createdAt")
        record.setValue(propertyRecord, forKey: "property")
        try saveContext()
    }

    func deleteIssue(id: UUID) throws {
        guard let record = try fetchIssueRecord(id: id) else { return }
        context.delete(record)
        try saveContext()
    }

    func fetchEvidence(for repairIssueID: UUID) throws -> [EvidenceItem] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "EvidenceItemRecord")
        request.predicate = NSPredicate(format: "issue.id == %@", repairIssueID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "capturedAt", ascending: false)]
        return try context.fetch(request).map(mapEvidence)
    }

    func saveEvidence(_ evidence: EvidenceItem) throws {
        guard let issueRecord = try fetchIssueRecord(id: evidence.repairIssueID) else {
            throw RepairRepositoryError.repairNotFound
        }

        let record = try fetchEvidenceRecord(id: evidence.id) ?? NSManagedObject(entity: entity("EvidenceItemRecord"), insertInto: context)
        record.setValue(evidence.id, forKey: "id")
        record.setValue(evidence.title, forKey: "title")
        record.setValue(evidence.kind.rawValue, forKey: "kindRaw")
        record.setValue(evidence.capturedAt, forKey: "capturedAt")
        record.setValue(evidence.note, forKey: "note")
        record.setValue(evidence.sourceApp, forKey: "sourceApp")
        record.setValue(evidence.fileName, forKey: "fileName")
        record.setValue(issueRecord, forKey: "issue")
        try saveContext()
    }

    func fetchFollowUps(for repairIssueID: UUID) throws -> [FollowUpNote] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "FollowUpRecord")
        request.predicate = NSPredicate(format: "issue.id == %@", repairIssueID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        return try context.fetch(request).map(mapFollowUp)
    }

    func saveFollowUp(_ followUp: FollowUpNote) throws {
        guard let issueRecord = try fetchIssueRecord(id: followUp.repairIssueID) else {
            throw RepairRepositoryError.repairNotFound
        }

        let record = try fetchFollowUpRecord(id: followUp.id) ?? NSManagedObject(entity: entity("FollowUpRecord"), insertInto: context)
        record.setValue(followUp.id, forKey: "id")
        record.setValue(followUp.dueDate, forKey: "dueDate")
        record.setValue(followUp.note, forKey: "note")
        record.setValue(followUp.completedAt, forKey: "completedAt")
        record.setValue(followUp.createdAt, forKey: "createdAt")
        record.setValue(issueRecord, forKey: "issue")
        try saveContext()
    }

    private func fetchPropertyRecord() throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "RentalPropertyRecord")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return try context.fetch(request).first
    }

    private func fetchPropertyRecord(id: UUID) throws -> NSManagedObject? {
        try fetchRecord(entityName: "RentalPropertyRecord", id: id)
    }

    private func fetchIssueRecord(id: UUID) throws -> NSManagedObject? {
        try fetchRecord(entityName: "RepairIssueRecord", id: id)
    }

    private func fetchEvidenceRecord(id: UUID) throws -> NSManagedObject? {
        try fetchRecord(entityName: "EvidenceItemRecord", id: id)
    }

    private func fetchFollowUpRecord(id: UUID) throws -> NSManagedObject? {
        try fetchRecord(entityName: "FollowUpRecord", id: id)
    }

    private func fetchRecord(entityName: String, id: UUID) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private func entity(_ name: String) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: name, in: context)!
    }

    private func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            throw RepairRepositoryError.persistenceUnavailable(error.localizedDescription)
        }
    }

    private func mapProperty(_ record: NSManagedObject) -> RentalProperty {
        RentalProperty(
            id: value(record, "id", default: UUID()),
            nickname: value(record, "nickname", default: ""),
            addressLine: value(record, "addressLine", default: ""),
            landlordOrAgentName: value(record, "landlordOrAgentName", default: ""),
            preferredContact: value(record, "preferredContact", default: ""),
            createdAt: value(record, "createdAt", default: Date())
        )
    }

    private func mapIssue(_ record: NSManagedObject) -> RepairIssue {
        let property = record.value(forKey: "property") as? NSManagedObject
        let categoryRaw: String = value(record, "categoryRaw", default: RepairCategory.other.rawValue)
        let urgencyRaw: String = value(record, "urgencyRaw", default: RepairUrgency.routine.rawValue)
        let statusRaw: String = value(record, "statusRaw", default: RepairStatus.open.rawValue)

        return RepairIssue(
            id: value(record, "id", default: UUID()),
            propertyID: value(property, "id", default: UUID()),
            title: value(record, "title", default: ""),
            category: RepairCategory(rawValue: categoryRaw) ?? .other,
            urgency: RepairUrgency(rawValue: urgencyRaw) ?? .routine,
            status: RepairStatus(rawValue: statusRaw) ?? .open,
            details: value(record, "details", default: ""),
            dateFirstReported: value(record, "dateFirstReported", default: Date()),
            targetFollowUpDate: value(record, "targetFollowUpDate", default: Date()),
            resolvedAt: record.value(forKey: "resolvedAt") as? Date,
            createdAt: value(record, "createdAt", default: Date())
        )
    }

    private func mapEvidence(_ record: NSManagedObject) -> EvidenceItem {
        let issue = record.value(forKey: "issue") as? NSManagedObject
        let kindRaw: String = value(record, "kindRaw", default: EvidenceKind.note.rawValue)

        return EvidenceItem(
            id: value(record, "id", default: UUID()),
            repairIssueID: value(issue, "id", default: UUID()),
            title: value(record, "title", default: ""),
            kind: EvidenceKind(rawValue: kindRaw) ?? .note,
            capturedAt: value(record, "capturedAt", default: Date()),
            note: value(record, "note", default: ""),
            sourceApp: value(record, "sourceApp", default: ""),
            fileName: value(record, "fileName", default: nil)
        )
    }

    private func mapFollowUp(_ record: NSManagedObject) -> FollowUpNote {
        let issue = record.value(forKey: "issue") as? NSManagedObject
        return FollowUpNote(
            id: value(record, "id", default: UUID()),
            repairIssueID: value(issue, "id", default: UUID()),
            dueDate: value(record, "dueDate", default: Date()),
            note: value(record, "note", default: ""),
            completedAt: record.value(forKey: "completedAt") as? Date,
            createdAt: value(record, "createdAt", default: Date())
        )
    }

    private func value<T>(_ record: NSManagedObject?, _ key: String, default defaultValue: T) -> T {
        record?.value(forKey: key) as? T ?? defaultValue
    }
}
