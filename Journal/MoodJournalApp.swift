import SwiftUI
import SwiftData

@main
struct MoodJournalApp: App {
    @AppStorage("settings_darkMode") private var darkModeEnabled = true
    private let container: ModelContainer?
    private let startupError: String?

    init() {
        do {
            let schema = Schema([JournalEntry.self, Award.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
            startupError = nil
        } catch {
            container = nil
            startupError = error.localizedDescription
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let container {
                    ContentView().modelContainer(container)
                } else {
                    ContentUnavailableView {
                        Label("Couldn’t Open Journal", systemImage: "externaldrive.badge.exclamationmark")
                    } description: {
                        Text("Your saved data has not been removed. Close and reopen the app to try again.\n\n\(startupError ?? "")")
                    }
                }
            }
            .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
