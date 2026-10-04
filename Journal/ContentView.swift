import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isAnalysing = false
    @State private var progressDismissed = false

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
        .onPreferenceChange(AnalysisActivityPreferenceKey.self) { active in
            isAnalysing = active
            if !active { progressDismissed = false }
        }
        .overlay {
            if isAnalysing && !progressDismissed {
                AchievementProgressOverlay { progressDismissed = true }
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(1000)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isAnalysing && !progressDismissed)
    }
}
