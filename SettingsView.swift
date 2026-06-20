import SwiftUI
import UserNotifications
import SwiftData

// MARK: - Settings View

struct SettingsView: View {

    // MARK: – Persisted Preferences
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @AppStorage("settings_darkMode")           private var darkModeEnabled       = true
    @AppStorage("settings_haptics")            private var hapticsEnabled        = true
    @AppStorage("settings_streakReminder")     private var streakReminderEnabled = false
    @AppStorage("settings_reminderHour")       private var reminderHour          = 21
    @AppStorage("settings_weatherUnit")        private var usesCelsius           = true
    @AppStorage("settings_autoWeather")        private var autoFetchWeather      = true
    @AppStorage("settings_autoMusic")          private var autoFetchMusic        = false
    @AppStorage("settings_aiAnalysis")         private var aiAnalysisEnabled     = true
    @AppStorage("settings_showMoodOnRow")      private var showMoodOnRow         = true
    @AppStorage("settings_compactRows")        private var compactRows           = false
    
    @State private var isExporting = false
    @State private var showClearDataConfirm    = false
    @State private var showClearAwardsConfirm  = false
    @State private var showAbout               = false
    @State private var showNotificationDeniedAlert = false
    @State private var reminderTime = Calendar.current.date(
        bySettingHour: 21, minute: 0, second: 0, of: Date()
    ) ?? Date()
    @State private var exportFile: ExportFile? = nil
    
    var body: some View {
        ZStack {
            JournalGradientBackground()

            ScrollView {
                VStack(spacing: 28) {

                    // MARK: Appearance
                    SettingsSection(title: "Appearance", icon: "paintbrush.fill", iconColor: .indigo) {
                        SettingsToggleRow(
                            icon: "moon.fill",
                            iconColor: .indigo,
                            title: "Dark Mode",
                            subtitle: "Force the app into dark theme",
                            isOn: $darkModeEnabled
                        )
                        SettingsDivider()
                        SettingsToggleRow(
                            icon: "rectangle.compress.vertical",
                            iconColor: .purple,
                            title: "Compact Rows",
                            subtitle: "Smaller entry cards in the list",
                            isOn: $compactRows
                        )
                        SettingsDivider()
                        SettingsToggleRow(
                            icon: "face.smiling",
                            iconColor: .yellow,
                            title: "Show Mood Label",
                            subtitle: "Display mood name on entry rows",
                            isOn: $showMoodOnRow
                        )
                    }

                    // MARK: Notifications
                    SettingsSection(title: "Notifications", icon: "bell.fill", iconColor: .orange) {
                        SettingsToggleRow(
                            icon: "flame.fill",
                            iconColor: .orange,
                            title: "Streak Reminder",
                            subtitle: "Daily nudge to keep your streak alive",
                            isOn: $streakReminderEnabled
                        )
                        if streakReminderEnabled {
                            SettingsDivider()
                            HStack(spacing: 14) {
                                SettingsIcon(symbol: "clock.fill", color: .orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Reminder Time")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.primary)
                                    Text("When to send the daily reminder")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.tertiary)
                                }
                                Spacer()
                                DatePicker(
                                    "",
                                    selection: $reminderTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .tint(.orange)
                            }
                            .padding(14)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: streakReminderEnabled)

                    // MARK: AI & Analysis
                    SettingsSection(title: "AI & Analysis", icon: "cpu.fill", iconColor: .violet) {
                        SettingsToggleRow(
                            icon: "sparkles",
                            iconColor: .violet,
                            title: "AI Analysis",
                            subtitle: "Detect achievements and generate encouragement",
                            isOn: $aiAnalysisEnabled
                        )
                    }

                    // MARK: Data & Privacy
                    SettingsSection(title: "Data & Privacy", icon: "lock.shield.fill", iconColor: .green) {
                        SettingsActionRow(
                            icon: "square.and.arrow.up.fill",
                            iconColor: .green,
                            title: "Export Journal",
                            subtitle: "Save all entries as a PDF"
                        ) {
                            guard !isExporting else { return }
                            isExporting = true
                            Task {
                                try? await Task.sleep(for: .milliseconds(50))
                                if let url = ExportManager.shared.exportURL(from: entries) {
                                    await MainActor.run {
                                        exportFile   = ExportFile(url: url)
                                        isExporting  = false
                                    }
                                } else {
                                    await MainActor.run { isExporting = false }
                                }
                            }
                        }
                        SettingsDivider()
                        SettingsActionRow(
                            icon: "arrow.counterclockwise",
                            iconColor: .orange,
                            title: "Reset Achievements",
                            subtitle: "Clear all earned awards and medals"
                        ) {
                            showClearAwardsConfirm = true
                        }
                        .confirmationDialog(
                            "Reset All Achievements?",
                            isPresented: $showClearAwardsConfirm,
                            titleVisibility: .visible
                        ) {
                            Button("Reset Achievements", role: .destructive) {
                                do {
                                    let awards = try context.fetch(FetchDescriptor<Award>())
                                    for award in awards {
                                        context.delete(award)
                                    }
                                    try context.save()
                                } catch {
                                    print("Failed to reset achievements:", error)
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This will remove all medals and awards from every entry. Your journal text will not be affected.")
                        }
                        SettingsDivider()
                        SettingsActionRow(
                            icon: "trash.fill",
                            iconColor: .red,
                            title: "Clear All Entries",
                            subtitle: "Permanently delete your entire journal",
                            isDestructive: true
                        ) {
                            showClearDataConfirm = true
                        }
                        .confirmationDialog(
                            "Clear All Entries?",
                            isPresented: $showClearDataConfirm,
                            titleVisibility: .visible
                        ) {
                            Button("Delete Everything", role: .destructive) {
                                do {
                                    try context.delete(model: JournalEntry.self)
                                    try context.delete(model: Award.self)
                                    try context.save()
                                } catch {
                                    print("Failed to delete entries:", error)
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This will permanently erase your entire journal. This cannot be undone.")
                        }
                    }

                    // MARK: About
                    SettingsSection(title: "About", icon: "info.circle.fill", iconColor: .secondary) {
                        SettingsActionRow(
                            icon: "heart.fill",
                            iconColor: .pink,
                            title: "Rate the App",
                            subtitle: "Leave a review on the App Store"
                        ) { }
                        SettingsDivider()
                        SettingsActionRow(
                            icon: "envelope.fill",
                            iconColor: .blue,
                            title: "Send Feedback",
                            subtitle: "Help shape the future of the app"
                        ) { }
                        SettingsDivider()
                        HStack(spacing: 14) {
                            SettingsIcon(symbol: "tag.fill", color: .secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Version")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.primary)
                                Text("App version and build number")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.tertiary)
                            }
                            Spacer()
                            Text("1.0.0 (42)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(14)
                    }
                    .onChange(of: streakReminderEnabled) { _, enabled in
                        if enabled {
                            Task {
                                let granted = await NotificationManager.shared.requestPermission()
                                if granted {
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                                    await NotificationManager.shared.scheduleStreakReminder(
                                        hour:   components.hour   ?? 21,
                                        minute: components.minute ?? 0
                                    )
                                } else {
                                    await MainActor.run {
                                        streakReminderEnabled      = false
                                        showNotificationDeniedAlert = true
                                    }
                                }
                            }
                        } else {
                            NotificationManager.shared.cancelStreakReminder()
                        }
                    }
                    .onChange(of: reminderTime) { _, newTime in
                        reminderHour = Calendar.current.component(.hour, from: newTime)
                    }
                    .onChange(of: reminderTime) { _, newTime in
                        guard streakReminderEnabled else { return }
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newTime)
                        Task {
                            await NotificationManager.shared.scheduleStreakReminder(
                                hour:   components.hour   ?? 21,
                                minute: components.minute ?? 0
                            )
                        }
                    }
                    .alert("Notifications Disabled", isPresented: $showNotificationDeniedAlert) {
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Please enable notifications in Settings to use the streak reminder.")
                    }

                    Text("Made with ♥ · All data stays on your device")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .onAppear {
                reminderTime = Calendar.current.date(
                    bySettingHour: reminderHour, minute: 0, second: 0, of: Date()
                ) ?? Date()
            }
            
            if isExporting {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)

                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.4)

                    Text("Exporting Journal…")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                        )
                )
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
            
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExporting)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $exportFile) { file in
            ShareSheet(url: file.url)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Settings Section Container

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(iconColor)
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                    .kerning(1.2)
            }
            .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            SettingsIcon(symbol: icon, color: iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(iconColor)
        }
        .padding(14)
        .contentShape(Rectangle())
        .onTapGesture { isOn.toggle() }
    }
}
// MARK: - Action Row

struct SettingsActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                SettingsIcon(symbol: icon, color: iconColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isDestructive ? .red : .primary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Icon Badge

struct SettingsIcon: View {
    let symbol: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(color.opacity(0.15))
                .frame(width: 36, height: 36)
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Divider

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .background(.white.opacity(0.07))
            .padding(.leading, 64)
    }
}

// MARK: - Violet Color Extension

extension Color {
    static let violet = Color(red: 0.6, green: 0.3, blue: 1.0)
}

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}

struct ExportFile: Identifiable {
    let id = UUID()
    let url: URL
}
