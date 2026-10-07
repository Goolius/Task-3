import SwiftUI
import WidgetKit

private let appGroupIdentifier = "group.com.example.rentrepairlog"

struct WidgetRepairSnapshot: Codable, Equatable {
    var generatedAt: Date
    var nextRepairTitle: String
    var nextFollowUpDate: Date?
    var openRepairCount: Int
    var urgentFollowUpCount: Int

    static let empty = WidgetRepairSnapshot(
        generatedAt: Date(),
        nextRepairTitle: "No open repairs",
        nextFollowUpDate: nil,
        openRepairCount: 0,
        urgentFollowUpCount: 0
    )
}

struct WidgetRepairSnapshotStore {
    func load() -> WidgetRepairSnapshot {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("RentRepairLogShared", isDirectory: true)
        let url = directory.appendingPathComponent("repair-summary.json")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let data = try? Data(contentsOf: url),
              let snapshot = try? decoder.decode(WidgetRepairSnapshot.self, from: data) else {
            return .empty
        }
        return snapshot
    }
}

struct RentRepairEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetRepairSnapshot
}

struct RentRepairTimelineProvider: TimelineProvider {
    private let store = WidgetRepairSnapshotStore()

    func placeholder(in context: Context) -> RentRepairEntry {
        RentRepairEntry(date: Date(), snapshot: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (RentRepairEntry) -> Void) {
        completion(RentRepairEntry(date: Date(), snapshot: store.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RentRepairEntry>) -> Void) {
        let entry = RentRepairEntry(date: Date(), snapshot: store.load())
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1_800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct RentRepairWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: RentRepairEntry

    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemSmall ? 8 : 12) {
            Label("RentRepair", systemImage: "wrench.and.screwdriver")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.teal)

            Text(entry.snapshot.nextRepairTitle)
                .font(family == .systemSmall ? .headline : .title3.bold())
                .lineLimit(family == .systemSmall ? 2 : 1)

            if let followUp = entry.snapshot.nextFollowUpDate {
                Text("Follow up \(followUp.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Your repair timeline is clear.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if family != .systemSmall {
                HStack {
                    widgetMetric("Open", entry.snapshot.openRepairCount, .blue)
                    widgetMetric("Urgent", entry.snapshot.urgentFollowUpCount, .red)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(.background, for: .widget)
    }

    private func widgetMetric(_ label: String, _ value: Int, _ color: Color) -> some View {
        VStack(alignment: .leading) {
            Text("\(value)")
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RentRepairWidget: Widget {
    let kind = "RentRepairWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RentRepairTimelineProvider()) { entry in
            RentRepairWidgetView(entry: entry)
        }
        .configurationDisplayName("Repair Follow-up")
        .description("Shows the next repair follow-up and urgent repair count.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct RentRepairWidgetBundle: WidgetBundle {
    var body: some Widget {
        RentRepairWidget()
    }
}

