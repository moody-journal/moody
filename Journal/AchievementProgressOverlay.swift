import SwiftUI

struct AnalysisActivityPreferenceKey: PreferenceKey {
    static var defaultValue: Bool { false }
    static func reduce(value: inout Bool, nextValue: () -> Bool) { value = value || nextValue() }
}

/// Native progress and Liquid Glass, centered above the tab layout.
struct AchievementProgressOverlay: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.16).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.primary)
                    .accessibilityLabel("Analyzing entry")
                VStack(spacing: 6) {
                    Text("Analyzing entry")
                        .font(.headline)
                    Text("Your entry is saved. Finding your achievements…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button("Keep journaling", action: onContinue)
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.glass)
            }
            .padding(24)
            .frame(maxWidth: 320)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityAddTraits(.isModal)
    }
}
