import SwiftUI

struct ContentView: View {
    @StateObject private var dependencies: AppDependencies

    @MainActor
    init(dependencies: AppDependencies? = nil) {
        _dependencies = StateObject(wrappedValue: dependencies ?? AppDependencies.live())
    }

    var body: some View {
        TabView {
            NavigationStack {
                DashboardView(dependencies: dependencies)
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }

            NavigationStack {
                RepairListView(dependencies: dependencies)
            }
            .tabItem {
                Label("Repairs", systemImage: "wrench.and.screwdriver")
            }

            NavigationStack {
                EvidenceInboxView(dependencies: dependencies)
            }
            .tabItem {
                Label("Inbox", systemImage: "tray.and.arrow.down")
            }

            NavigationStack {
                PropertySettingsView(dependencies: dependencies)
            }
            .tabItem {
                Label("Property", systemImage: "building.2")
            }
        }
        .tint(.teal)
        .onAppear {
            dependencies.refreshSharedSnapshot()
        }
    }
}

#Preview {
    ContentView(
        dependencies: AppDependencies(
            repository: PreviewRepairRepository(),
            inboxStore: SharedEvidenceInboxStore(),
            snapshotStore: RepairWidgetSnapshotStore()
        )
    )
}
