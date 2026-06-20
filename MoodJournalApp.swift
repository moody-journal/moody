import SwiftUI
import SwiftData

@main
struct MoodJournalApp: App {
    @AppStorage("settings_darkMode") private var darkModeEnabled = true

    let container: ModelContainer = {
        let schema = Schema([JournalEntry.self, Award.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if #available(iOS 18.4, *) {
                ContentView()
                    .preferredColorScheme(darkModeEnabled ? .dark : .light)
                    .modelContainer(container)
            } else {
                UnsupportedDeviceView()
            }
        }
    }
}

// MARK: - Unsupported device fallback

struct UnsupportedDeviceView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 56))
                .foregroundStyle(.orange)
            Text("Device not supported")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Mood Journal uses on-device AI which requires iOS 18.4 or later on an iPhone 15 Pro or newer (A17 Pro chip or better).")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(40)
    }
}
