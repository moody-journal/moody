import UserNotifications
import SwiftUI

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let notificationID = "streak_reminder"

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else {
            return settings.authorizationStatus == .authorized
        }
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func scheduleStreakReminder(hour: Int, minute: Int) async {
        let granted = await requestPermission()
        guard granted else { return }

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

        try? await center.add(request)
    }

    func cancelStreakReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
}
