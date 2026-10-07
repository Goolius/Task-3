import UIKit
import UniformTypeIdentifiers

private let appGroupIdentifier = "group.com.example.rentrepairlog"

private struct SharedEvidenceInboxItem: Codable {
    var id: UUID
    var suggestedTitle: String
    var kind: String
    var capturedAt: Date
    var note: String
    var sourceApp: String
    var fileName: String?
}

private struct SharedEvidenceInboxStore {
    private var inboxURL: URL {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("RentRepairLogShared", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("evidence-inbox.json")
    }

    func loadItems() -> [SharedEvidenceInboxItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: inboxURL),
              let items = try? decoder.decode([SharedEvidenceInboxItem].self, from: data) else {
            return []
        }
        return items
    }

    func append(_ item: SharedEvidenceInboxItem) {
        var items = loadItems()
        items.insert(item, at: 0)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: inboxURL, options: [.atomic])
    }
}

final class ShareViewController: UIViewController {
    private let store = SharedEvidenceInboxStore()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        importSharedEvidence()
    }

    private func importSharedEvidence() {
        let providers = extensionContext?.inputItems
            .compactMap { $0 as? NSExtensionItem }
            .flatMap { $0.attachments ?? [] } ?? []

        guard !providers.isEmpty else {
            complete()
            return
        }

        let group = DispatchGroup()
        var importedAtLeastOne = false

        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, _ in
                    self.saveTextEvidence(item)
                    importedAtLeastOne = true
                    group.leave()
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.url.identifier) { item, _ in
                    self.saveURLEvidence(item)
                    importedAtLeastOne = true
                    group.leave()
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                group.enter()
                saveFileEvidence(from: provider, type: UTType.image, kind: "photo", title: "Shared repair photo") {
                    importedAtLeastOne = true
                    group.leave()
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                group.enter()
                saveFileEvidence(from: provider, type: UTType.pdf, kind: "document", title: "Shared repair document") {
                    importedAtLeastOne = true
                    group.leave()
                }
            } else if let identifier = provider.registeredTypeIdentifiers.first {
                saveGenericEvidence(typeIdentifier: identifier)
                importedAtLeastOne = true
            }
        }

        group.notify(queue: .main) {
            if !importedAtLeastOne {
                self.saveGenericEvidence(typeIdentifier: "unknown")
            }
            self.complete()
        }
    }

    private func saveTextEvidence(_ item: NSSecureCoding?) {
        let text = item as? String ?? ""
        store.append(
            SharedEvidenceInboxItem(
                id: UUID(),
                suggestedTitle: "Shared repair message",
                kind: "message",
                capturedAt: Date(),
                note: text.isEmpty ? "Shared text could not be read. Open the source app and try again." : text,
                sourceApp: "Share Extension",
                fileName: nil
            )
        )
    }

    private func saveURLEvidence(_ item: NSSecureCoding?) {
        let url = item as? URL
        store.append(
            SharedEvidenceInboxItem(
                id: UUID(),
                suggestedTitle: "Shared repair link",
                kind: "link",
                capturedAt: Date(),
                note: url?.absoluteString ?? "Shared link could not be read. Open the source app and try again.",
                sourceApp: "Share Extension",
                fileName: nil
            )
        )
    }

    private func saveFileEvidence(
        from provider: NSItemProvider,
        type: UTType,
        kind: String,
        title: String,
        completion: @escaping () -> Void
    ) {
        provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { url, _ in
            self.store.append(
                SharedEvidenceInboxItem(
                    id: UUID(),
                    suggestedTitle: title,
                    kind: kind,
                    capturedAt: Date(),
                    note: "A file was shared from another app. Attach it to the matching repair and keep the original file if needed.",
                    sourceApp: "Share Extension",
                    fileName: url?.lastPathComponent
                )
            )
            completion()
        }
    }

    private func saveGenericEvidence(typeIdentifier: String) {
        store.append(
            SharedEvidenceInboxItem(
                id: UUID(),
                suggestedTitle: "Shared repair evidence",
                kind: "document",
                capturedAt: Date(),
                note: "A shared item with type \(typeIdentifier) was received. Attach it to the matching repair and add detail in the repair timeline.",
                sourceApp: "Share Extension",
                fileName: nil
            )
        )
    }

    private func complete() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
