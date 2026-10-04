import SwiftUI
import UserNotifications
import SwiftData

// MARK: - Settings View

struct SettingsView: View {

    @State private var operationError: String?
    // MARK: – Persisted Preferences
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @AppStorage("settings_darkMode")           private var darkModeEnabled       = true
    @AppStorage("settings_haptics")            private var hapticsEnabled        = true
    @AppStorage("settings_streakReminder")     private var streakReminderEnabled = false
    @AppStorage("settings_reminderHour")       private var reminderHour          = 21
    @AppStorage("settings_reminderMinute") private var reminderMinute = 0
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
                                let snapshots = entries.map(ExportEntry.init)
                                if let url = await ExportManager.shared.exportURL(from: snapshots) {
                                    await MainActor.run {
                                        exportFile   = ExportFile(url: url)
                                        isExporting  = false
                                    }
                                } else {
                                    isExporting = false
                                    operationError = "The journal could not be exported. Check the available storage and try again."
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
                                    for entry in entries { entry.isAnalysed = false }
                                    for award in awards {
                                        context.delete(award)
                                    }
                                    try context.save()
                                    JournalViewModel.invalidatePendingAnalyses()
                                } catch {
                                    context.rollback()
                                    operationError = "Could not reset achievements: \(error.localizedDescription)"
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
                                    JournalViewModel.invalidatePendingAnalyses()
                                } catch {
                                    context.rollback()
                                    operationError = "Could not delete entries: \(error.localizedDescription)"
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This will permanently erase your entire journal. This cannot be undone.")
                        }
                    }

                    // MARK: About
                    SettingsSection(title: "About", icon: "info.circle.fill", iconColor: .secondary) {
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
                            Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(14)
                    }
                    .task(id: "\(streakReminderEnabled)-\(reminderHour)-\(reminderMinute)") {
                        guard streakReminderEnabled else {
                            NotificationManager.shared.cancelStreakReminder()
                            return
                        }
                        let scheduled = await NotificationManager.shared.scheduleStreakReminder(hour: reminderHour, minute: reminderMinute)
                        guard !Task.isCancelled else { return }
                        if !scheduled {
                            streakReminderEnabled = false
                            showNotificationDeniedAlert = true
                        }
                    }
                    .onChange(of: reminderTime) { _, newTime in
                        reminderHour = Calendar.current.component(.hour, from: newTime)
                        reminderMinute = Calendar.current.component(.minute, from: newTime)
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

                    Text("Made with ♥ · Journal entries and AI analysis stay on your device")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .onAppear {
                reminderTime = Calendar.current.date(
                    bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: Date()
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
        .alert("Could Not Complete Action", isPresented: Binding(get: { operationError != nil }, set: { if !$0 { operationError = nil } })) {
            Button("OK") { operationError = nil }
        } message: { Text(operationError ?? "") }
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
