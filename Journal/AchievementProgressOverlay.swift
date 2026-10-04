import SwiftUI

struct AnalysisActivityPreferenceKey: PreferenceKey {
    static var defaultValue: Bool { false }
    static func reduce(value: inout Bool, nextValue: () -> Bool) { value = value || nextValue() }
}

/// Presented above the entire TabView so the card and scrim cannot intersect its tab bar.
struct AchievementProgressOverlay: View {
    var onContinue: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotating = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.38).ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle().fill(.indigo.opacity(0.10))
                    Circle().stroke(.indigo.opacity(0.12), lineWidth: 3)
                    Circle().trim(from: 0.05, to: 0.76)
                        .stroke(AngularGradient(colors: [.indigo.opacity(0.1), .purple, .indigo], center: .center),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(rotating ? 360 : 0))
                        .animation(reduceMotion ? nil : .linear(duration: 2.2).repeatForever(autoreverses: false), value: rotating)
                    Image(systemName: "sparkles")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(.indigo.gradient)
                }
                .frame(width: 80, height: 80)
                .accessibilityHidden(true)

                VStack(spacing: 8) {
                    Text("Finding your achievements")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                    Text("Noticing the little wins in your day.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Label("Your entry is saved", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .combine)

                Button("Keep journaling", action: onContinue)
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(.indigo)
            }
            .padding(28)
            .frame(maxWidth: 340)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.18), radius: 28, y: 12)
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { rotating = true }
        .accessibilityAddTraits(.isModal)
    }
}
