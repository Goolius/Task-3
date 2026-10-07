import Foundation

let rentRepairAppGroupIdentifier = "group.com.example.rentrepairlog"

struct SharedRepairSnapshot: Codable, Equatable {
    var generatedAt: Date
    var nextRepairTitle: String
    var nextFollowUpDate: Date?
    var openRepairCount: Int
    var urgentFollowUpCount: Int

    static let empty = SharedRepairSnapshot(
        generatedAt: Date(),
        nextRepairTitle: "No open repairs",
        nextFollowUpDate: nil,
        openRepairCount: 0,
        urgentFollowUpCount: 0
    )
}

struct SharedEvidenceInboxItem: Identifiable, Codable, Equatable {
    var id: UUID
    var suggestedTitle: String
    var kind: EvidenceKind
    var capturedAt: Date
    var note: String
    var sourceApp: String
    var fileName: String?
}

struct AppGroupFileStore {
    let appGroupIdentifier: String

    var directoryURL: URL {
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return groupURL
        }

        let fallback = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RentRepairLogShared", isDirectory: true)
        try? FileManager.default.createDirectory(at: fallback, withIntermediateDirectories: true)
        return fallback
    }

    func url(for fileName: String) -> URL {
        directoryURL.appendingPathComponent(fileName)
    }
}

struct RepairWidgetSnapshotStore {
    private let fileStore: AppGroupFileStore
    private let fileName = "repair-summary.json"

    init(appGroupIdentifier: String = rentRepairAppGroupIdentifier) {
        self.fileStore = AppGroupFileStore(appGroupIdentifier: appGroupIdentifier)
    }

    func save(_ snapshot: SharedRepairSnapshot) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: fileStore.url(for: fileName), options: [.atomic])
    }

    func load() -> SharedRepairSnapshot {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: fileStore.url(for: fileName)),
              let snapshot = try? decoder.decode(SharedRepairSnapshot.self, from: data) else {
            return .empty
        }
        return snapshot
    }
}

struct SharedEvidenceInboxStore {
    private let fileStore: AppGroupFileStore
    private let fileName = "evidence-inbox.json"

    init(appGroupIdentifier: String = rentRepairAppGroupIdentifier) {
        self.fileStore = AppGroupFileStore(appGroupIdentifier: appGroupIdentifier)
    }

    func loadItems() -> [SharedEvidenceInboxItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: fileStore.url(for: fileName)),
              let items = try? decoder.decode([SharedEvidenceInboxItem].self, from: data) else {
            return []
        }
        return items.sorted { $0.capturedAt > $1.capturedAt }
    }

    func saveItems(_ items: [SharedEvidenceInboxItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: fileStore.url(for: fileName), options: [.atomic])
    }

    func append(_ item: SharedEvidenceInboxItem) {
        var items = loadItems()
        items.insert(item, at: 0)
        saveItems(items)
    }

    func removeItem(id: UUID) {
        saveItems(loadItems().filter { $0.id != id })
    }
}

