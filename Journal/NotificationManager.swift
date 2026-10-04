import UserNotifications
import SwiftUI

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private var revision = 0
    private let notificationID = "streak_reminder"

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else {
            return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional || settings.authorizationStatus == .ephemeral
        }
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    @discardableResult
    func scheduleStreakReminder(hour: Int, minute: Int) async -> Bool {
        revision += 1
        let requestRevision = revision
        guard (0...23).contains(hour), (0...59).contains(minute) else { return false }
        let granted = await requestPermission()
        guard granted, requestRevision == revision, !Task.isCancelled else { return false }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationID])

        let content = UNMutableNotificationContent()
        content.title = "Keep your streak alive 🔥"
        content.body  = "Take a moment to capture how you're feeling today."
        content.sound = .default

        var components        = DateComponents()
        components.hour       = hour
        components.minute     = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: notificationID,
            content:    content,
            trigger:    trigger
        )

        do {
            try await center.add(request)
            guard requestRevision == revision, !Task.isCancelled else {
                if !UserDefaults.standard.bool(forKey: "settings_streakReminder") {
                    center.removePendingNotificationRequests(withIdentifiers: [notificationID])
                }
                return false
            }
            return true
        } catch { return false }
    }

    func cancelStreakReminder() {
        revision += 1
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
}
