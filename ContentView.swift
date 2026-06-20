import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            JournalTab()
                .tabItem {
                    Label("Journal", systemImage: "book.closed")
                }

            MoodTab()
                .tabItem {
                    Label("Mood", systemImage: "chart.line.uptrend.xyaxis")
                }

            AwardsTab()
                .tabItem {
                    Label("Awards", systemImage: "medal")
                }
        }
        .tint(.indigo)
    }
}
