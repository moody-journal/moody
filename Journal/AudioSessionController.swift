import AVFoundation

/// Serializes session changes off the UI actor. Playback/recording objects remain UI-owned.
actor AudioSessionController {
    static let shared = AudioSessionController()
    private var pending: Task<Void, Error>?

    func activate(category: AVAudioSession.Category, mode: AVAudioSession.Mode = .default,
                  options: AVAudioSession.CategoryOptions = []) async throws {
        let previous = pending
        let operation = Task {
            _ = try? await previous?.value
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(category, mode: mode, options: options)
            guard try await session.activate(options: []) else { throw AudioSessionError.activationFailed }
        }
        pending = operation
        try await operation.value
    }

    func deactivate() async throws {
        let previous = pending
        let operation = Task {
            _ = try? await previous?.value
            _ = try await AVAudioSession.sharedInstance().deactivate(options: .notifyOthersOnDeactivation)
        }
        pending = operation
        try await operation.value
    }
}

private enum AudioSessionError: Error { case activationFailed }
