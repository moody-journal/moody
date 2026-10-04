import UIKit

// MARK: - Haptic Manager

final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    private var hapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: "settings_haptics") as? Bool ?? true
    }

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    func selection() {
        guard hapticsEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
