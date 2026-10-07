import CoreData
import Foundation

@MainActor
final class RentRepairPersistenceController {
    static let shared = RentRepairPersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "RentRepairLog", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let property = NSEntityDescription()
        property.name = "RentalPropertyRecord"
        property.managedObjectClassName = "NSManagedObject"

        let issue = NSEntityDescription()
        issue.name = "RepairIssueRecord"
        issue.managedObjectClassName = "NSManagedObject"

        let evidence = NSEntityDescription()
        evidence.name = "EvidenceItemRecord"
        evidence.managedObjectClassName = "NSManagedObject"

        let followUp = NSEntityDescription()
        followUp.name = "FollowUpRecord"
        followUp.managedObjectClassName = "NSManagedObject"

        property.properties = [
            uuidAttribute("id"),
            stringAttribute("nickname", optional: true),
            stringAttribute("addressLine"),
            stringAttribute("landlordOrAgentName"),
            stringAttribute("preferredContact", optional: true),
            dateAttribute("createdAt")
        ]

        issue.properties = [
            uuidAttribute("id"),
            stringAttribute("title"),
            stringAttribute("categoryRaw"),
            stringAttribute("urgencyRaw"),
            stringAttribute("statusRaw"),
            stringAttribute("details"),
            dateAttribute("dateFirstReported"),
            dateAttribute("targetFollowUpDate"),
            dateAttribute("resolvedAt", optional: true),
            dateAttribute("createdAt")
        ]

        evidence.properties = [
            uuidAttribute("id"),
            stringAttribute("title"),
            stringAttribute("kindRaw"),
            dateAttribute("capturedAt"),
            stringAttribute("note"),
            stringAttribute("sourceApp"),
            stringAttribute("fileName", optional: true)
        ]

        followUp.properties = [
            uuidAttribute("id"),
            dateAttribute("dueDate"),
            stringAttribute("note"),
            dateAttribute("completedAt", optional: true),
            dateAttribute("createdAt")
        ]

        let propertyIssues = relationship("issues", destination: issue, min: 0, max: 0, deleteRule: .cascadeDeleteRule)
        let issueProperty = relationship("property", destination: property, min: 1, max: 1, deleteRule: .nullifyDeleteRule)
        propertyIssues.inverseRelationship = issueProperty
        issueProperty.inverseRelationship = propertyIssues

        let issueEvidence = relationship("evidence", destination: evidence, min: 0, max: 0, deleteRule: .cascadeDeleteRule)
        let evidenceIssue = relationship("issue", destination: issue, min: 1, max: 1, deleteRule: .nullifyDeleteRule)
        issueEvidence.inverseRelationship = evidenceIssue
        evidenceIssue.inverseRelationship = issueEvidence

        let issueFollowUps = relationship("followUps", destination: followUp, min: 0, max: 0, deleteRule: .cascadeDeleteRule)
        let followUpIssue = relationship("issue", destination: issue, min: 1, max: 1, deleteRule: .nullifyDeleteRule)
        issueFollowUps.inverseRelationship = followUpIssue
        followUpIssue.inverseRelationship = issueFollowUps

        property.properties.append(propertyIssues)
        issue.properties.append(contentsOf: [issueProperty, issueEvidence, issueFollowUps])
        evidence.properties.append(evidenceIssue)
        followUp.properties.append(followUpIssue)

        model.entities = [property, issue, evidence, followUp]
        return model
    }

    private static func uuidAttribute(_ name: String) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .UUIDAttributeType
        attribute.isOptional = false
        return attribute
    }

    private static func stringAttribute(_ name: String, optional: Bool = false) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = optional
        return attribute
    }

    private static func dateAttribute(_ name: String, optional: Bool = false) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .dateAttributeType
        attribute.isOptional = optional
        return attribute
    }

    private static func relationship(
        _ name: String,
        destination: NSEntityDescription,
        min: Int,
        max: Int,
        deleteRule: NSDeleteRule
    ) -> NSRelationshipDescription {
        let relationship = NSRelationshipDescription()
        relationship.name = name
        relationship.destinationEntity = destination
        relationship.minCount = min
        relationship.maxCount = max
        relationship.deleteRule = deleteRule
        relationship.isOptional = min == 0
        return relationship
    }
}

