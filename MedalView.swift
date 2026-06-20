import SwiftUI
import SceneKit
import AVFoundation

// MARK: - Medal Shape

enum MedalShape: CaseIterable {
    case star, circle, hexagon, heart, shield

    static func random() -> MedalShape {
        MedalShape.allCases.randomElement()!
    }

    static func deterministic(for type: AwardType) -> MedalShape {
        switch type {
        case .connectedWithSomeone: return .heart
        case .helpedOthers:         return .star
        case .madeAmends:           return .heart

        case .prioritisedSleep:     return .circle
        case .movedYourBody:        return .hexagon
        case .ateWell:              return .circle
        case .practicedMindfulness: return .circle

        case .learnedSomethingNew:     return .star
        case .steppedOutsideComfort:   return .shield
        case .askedForHelp:            return .heart

        case .keptGoing:           return .shield
        case .handledDifficulty:   return .shield
        case .setABoundary:        return .hexagon

        case .finishedSomething:      return .star
        case .beganSomething:         return .hexagon
        case .showedUpForYourself:    return .star
        case .reachedOutFirst:        return .circle
        case .restedWithoutGuilt:     return .heart
        case .spentTimeInNature:      return .hexagon
        case .disconnectedFromScreens: return .circle
        case .satWithUncertainty:     return .star
        case .createdSomething:       return .star
        case .saidNo:                 return .star
        case .celebratedAWin:         return .star
        case .forgivingYourself:      return .star
        case .criedItOut:             return .star
        case .blewUpMicrowave:        return .star
        case .sangInTheShower:        return .circle
        case .heroicNapper:           return .circle
        case .doomScrolled:           return .hexagon
        case .lostASock:              return .heart
        case .breakfastPizza:         return .star
        case .autocorrectDisaster:    return .shield
        case .rememberedADream:       return .star
        case .guessedTimeCorrectly:   return .star
        case .droppedPhoneOnFace:     return .shield
        }
    }

    func bezierPath() -> UIBezierPath {
        switch self {
        case .star:    return starPath(points: 5, outerR: 0.72, innerR: 0.30)
        case .circle:  return UIBezierPath(ovalIn: CGRect(x: -0.72, y: -0.72, width: 1.44, height: 1.44))
        case .hexagon: return polygonPath(sides: 6, radius: 0.74)
        case .heart:   return heartPath(size: 1.44)
        case .shield:  return shieldPath(size: 1.44)
        }
    }

    private func starPath(points: Int, outerR: CGFloat, innerR: CGFloat) -> UIBezierPath {
        let path  = UIBezierPath()
        let total = points * 2
        for i in 0..<total {
            let r     = i.isMultiple(of: 2) ? outerR : innerR
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let pt    = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.close()
        return path
    }

    private func polygonPath(sides: Int, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        for i in 0..<sides {
            let angle = CGFloat(i) * 2 * .pi / CGFloat(sides) - .pi / 2
            let pt    = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.close()
        return path
    }

    private func heartPath(size: CGFloat) -> UIBezierPath {
        let s    = size / 2
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -s * 0.70))
        path.addCurve(to: CGPoint(x: -s,      y: -s * 0.20),
                      controlPoint1: CGPoint(x: -s * 0.10, y: -s * 1.15),
                      controlPoint2: CGPoint(x: -s,        y: -s * 0.70))
        path.addCurve(to: CGPoint(x:  0,      y:  s * 0.85),
                      controlPoint1: CGPoint(x: -s,        y:  s * 0.30),
                      controlPoint2: CGPoint(x: -s * 0.30, y:  s * 0.65))
        path.addCurve(to: CGPoint(x:  s,      y: -s * 0.20),
                      controlPoint1: CGPoint(x:  s * 0.30, y:  s * 0.65),
                      controlPoint2: CGPoint(x:  s,        y:  s * 0.30))
        path.addCurve(to: CGPoint(x:  0,      y: -s * 0.70),
                      controlPoint1: CGPoint(x:  s,        y: -s * 0.70),
                      controlPoint2: CGPoint(x:  s * 0.10, y: -s * 1.15))
        path.close()
        return path
    }

    private func shieldPath(size: CGFloat) -> UIBezierPath {
        let s    = size / 2
        let path = UIBezierPath()
        path.move(to:    CGPoint(x:  0,  y:  s * 1.05))
        path.addLine(to: CGPoint(x: -s,  y:  s * 0.15))
        path.addCurve(to: CGPoint(x: -s, y: -s * 0.85),
                      controlPoint1: CGPoint(x: -s * 1.05, y: -s * 0.10),
                      controlPoint2: CGPoint(x: -s * 1.05, y: -s * 0.75))
        path.addLine(to: CGPoint(x:  0,  y: -s))
        path.addLine(to: CGPoint(x:  s,  y: -s * 0.85))
        path.addCurve(to: CGPoint(x:  s, y:  s * 0.15),
                      controlPoint1: CGPoint(x:  s * 1.05, y: -s * 0.75),
                      controlPoint2: CGPoint(x:  s * 1.05, y: -s * 0.10))
        path.close()
        return path
    }
}

// MARK: - Medal Presentation (Premium)

struct MedalPresentationView: View {
    let award: Award
    var onDismiss: (() -> Void)? = nil

    @State private var bgOpacity:      Double  = 0
    @State private var vignetteScale:  CGFloat = 1.4

    @State private var haloOpacity:    Double  = 0
    @State private var haloPulse:      CGFloat = 1.0
    @State private var haloRotation:   Double  = 0

    @State private var medalOpacity:   Double  = 0
    @State private var medalScale:     CGFloat = 0.60
    @State private var medalElevation: CGFloat = 0

    @State private var dustOpacity:    Double  = 0
    @State private var dustTick:       Int     = 0
    @State private var dustTimer:      Timer?  = nil

    @State private var labelOpacity:   Double  = 0

    @State private var tapCueOpacity:  Double  = 0

    @State private var sceneReady:    Bool      = false
    @State private var medalShape:    MedalShape = .circle

    @State private var hasStarted:    Bool              = false
    @State private var dismissTask:   Task<Void, Never>? = nil

    private let autoDismissDelay: TimeInterval = 9

    private var ambientHue: Double {
        switch award.type {
        case .connectedWithSomeone, .helpedOthers, .madeAmends:
            return 0.13
        case .prioritisedSleep, .movedYourBody, .ateWell, .practicedMindfulness:
            return 0.55
        case .learnedSomethingNew, .steppedOutsideComfort, .askedForHelp:
            return 0.60
        case .keptGoing, .handledDifficulty, .setABoundary:
            return 0.72
        case .finishedSomething, .beganSomething, .showedUpForYourself:
            return 0.08
        case .reachedOutFirst:      return 0.20
        case .restedWithoutGuilt:   return 0.9
        case .spentTimeInNature:    return 0.28
        case .disconnectedFromScreens: return 0.45
        case .satWithUncertainty:   return 0.33
        case .createdSomething:     return 0.85
        case .saidNo:               return 0.88
        case .celebratedAWin:       return 0.18
        case .forgivingYourself:    return 0.92
        case .criedItOut:           return 0.03
        case .blewUpMicrowave:      return 0.05
        case .sangInTheShower:      return 0.55
        case .heroicNapper:         return 0.70
        case .doomScrolled:         return 0.75
        case .lostASock:            return 0.10
        case .breakfastPizza:       return 0.07
        case .autocorrectDisaster:  return 0.88
        case .rememberedADream:     return 0.72
        case .guessedTimeCorrectly: return 0.45
        case .droppedPhoneOnFace:   return 0.03
        }
    }

    var body: some View {
        ZStack {

            Color(red: 0.01, green: 0.01, blue: 0.04)
                .opacity(bgOpacity)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            RadialGradient(
                colors: [.clear, Color.black.opacity(0.70)],
                center: .center,
                startRadius: 140,
                endRadius: 420
            )
            .opacity(bgOpacity * 0.85)
            .scaleEffect(vignetteScale)
            .ignoresSafeArea()
            .allowsHitTesting(false)

            if dustOpacity > 0 {
                GoldDustView(tick: dustTick, hue: ambientHue)
                    .opacity(dustOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hue: ambientHue, saturation: 0.75,
                                          brightness: 0.65, opacity: 0.28),
                                    Color(hue: ambientHue, saturation: 0.60,
                                          brightness: 0.40, opacity: 0.0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 220
                            )
                        )
                        .frame(width: 440, height: 440)
                        .scaleEffect(haloPulse)
                        .opacity(haloOpacity)
                        .blendMode(.screen)
                        .rotationEffect(.degrees(haloRotation))
                        .allowsHitTesting(false)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hue: ambientHue, saturation: 0.50,
                                          brightness: 0.90, opacity: 0.22),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                        .opacity(haloOpacity)
                        .blendMode(.screen)
                        .allowsHitTesting(false)

                    Medal3DSceneView(
                        awardType: award.type,
                        medalShape: medalShape,
                        triggerSpinIn: sceneReady
                    )
                    .id(award.id)
                    .frame(width: 240, height: 240)
                    .scaleEffect(medalScale)
                    .offset(y: medalElevation)
                    .opacity(medalOpacity)
                }

                HStack(spacing: 6) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 13))
                    Text("Tap anywhere to continue")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.medium)
                }
                .foregroundStyle(.white.opacity(0.28))
                .padding(.top, 28)
                .opacity(tapCueOpacity)

                PremiumLabelCard(award: award)
                    .padding(.top, 48)
                    .padding(.horizontal, 32)
                    .opacity(labelOpacity)

                Spacer().frame(height: 128)
            }
        }
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            runEntrance()
        }
        .onDisappear {
            stopDustTimer()
        }
    }

    // MARK: - Entrance sequence

    private func runEntrance() {
        medalShape = MedalShape.deterministic(for: award.type)
        MedalSoundPlayer.shared.playChime()

        withAnimation(.easeIn(duration: 0.6)) {
            bgOpacity     = 1
            vignetteScale = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            sceneReady = true
        }

        withAnimation(.easeIn(duration: 0.35).delay(0.30)) {
            medalOpacity = 1
        }
        withAnimation(
            .spring(response: 0.80, dampingFraction: 0.62).delay(0.30)
        ) {
            medalScale = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.70) {
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred(intensity: 0.85)
        }

        withAnimation(.easeOut(duration: 1.1).delay(0.80)) {
            haloOpacity = 1
        }
        withAnimation(
            .easeInOut(duration: 3.2)
            .repeatForever(autoreverses: true)
            .delay(1.2)
        ) {
            haloPulse = 1.12
        }
        withAnimation(
            .linear(duration: 28)
            .repeatForever(autoreverses: false)
            .delay(0.8)
        ) {
            haloRotation = 360
        }

        withAnimation(
            .easeInOut(duration: 2.8)
            .repeatForever(autoreverses: true)
            .delay(0.90)
        ) {
            medalElevation = -10
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) { dustOpacity = 1 }
            startDustTimer()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            withAnimation(.easeIn(duration: 2.0)) { dustOpacity = 0.18 }
        }

        withAnimation(.easeOut(duration: 0.9).delay(1.10)) {
            labelOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred(intensity: 0.5)
        }

        withAnimation(.easeIn(duration: 1.2).delay(4.0)) {
            tapCueOpacity = 1
        }

        dismissTask = Task {
            try? await Task.sleep(for: .seconds(autoDismissDelay))
            guard !Task.isCancelled else { return }
            await MainActor.run { dismiss() }
        }
    }

    // MARK: - Gold dust timer

    private func startDustTimer() {
        dustTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0,
                                         repeats: true) { _ in
            dustTick += 1
        }
    }

    private func stopDustTimer() {
        dustTimer?.invalidate()
        dustTimer = nil
    }

    // MARK: - Dismiss

    private func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        stopDustTimer()

        withAnimation(.easeInOut(duration: 0.45)) {
            bgOpacity     = 0
            labelOpacity  = 0
            haloOpacity   = 0
            tapCueOpacity = 0
        }
        withAnimation(.easeIn(duration: 0.30)) {
            medalOpacity = 0
            medalScale   = 1.08
        }
        withAnimation(.easeIn(duration: 0.60)) {
            dustOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
            onDismiss?()
        }
    }
}

// MARK: - Premium Label Card

private struct PremiumLabelCard: View {
    let award: Award

    var body: some View {
        VStack(spacing: 0) {

            Text(award.type.medal + "  Award Earned")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.88, blue: 0.45),
                            Color(red: 1.0, green: 0.65, blue: 0.15)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .textCase(.uppercase)
                .tracking(2.0)
                .padding(.bottom, 14)

            Text(award.displayTitle)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 28)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color(white: 0.06).opacity(0.92))

                VStack {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.10),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 60)
                    Spacer()
                }

                RoundedRectangle(cornerRadius: 26)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.22),
                                Color.white.opacity(0.04),
                                Color.white.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
        }
        .shadow(color: .black.opacity(0.55), radius: 32, x: 0, y: 16)
    }
}

// MARK: - Gold Dust

struct GoldDustView: View {
    let tick: Int
    let hue:  Double

    private static let particles: [DustParticle] = makeDust(count: 55)

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let t = CGFloat(tick)
                for p in Self.particles {
                    let x = (p.x * size.width
                             + sin(t * p.sineFreq + p.sinePhase) * p.sineAmp
                             + p.xDrift * t * 0.3)
                    let wrappedX = ((x.truncatingRemainder(dividingBy: size.width))
                                   + size.width)
                                  .truncatingRemainder(dividingBy: size.width)

                    let rawY  = p.y * size.height - p.ySpeed * t
                    let loopY = rawY < -20
                               ? size.height + (rawY.truncatingRemainder(dividingBy: size.height + 20))
                               : rawY

                    let progress = 1.0 - (loopY / size.height)
                    let alpha    = Double(max(0, min(1, p.opacity * (1.0 - progress * 0.7))))

                    var ctx2 = ctx
                    ctx2.opacity = alpha
                    ctx2.translateBy(x: wrappedX, y: loopY)

                    let r    = p.size / 2
                    let rect = CGRect(x: -r, y: -r, width: p.size, height: p.size)
                    ctx2.fill(Path(ellipseIn: rect), with: .color(p.color))
                }
            }
        }
        .ignoresSafeArea()
    }

    private static func makeDust(count: Int) -> [DustParticle] {
        var rng = SystemRandomNumberGenerator()
        let palette: [(h: Double, s: Double, b: Double)] = [
            (0.11, 0.85, 1.00),
            (0.10, 0.60, 1.00),
            (0.08, 0.90, 0.95),
            (0.12, 0.40, 1.00),
            (0.00, 0.00, 1.00),
        ]
        return (0..<count).map { i in
            let c = palette[i % palette.count]
            return DustParticle(
                x:         CGFloat.random(in: 0...1,       using: &rng),
                y:         CGFloat.random(in: 0.2...1.1,   using: &rng),
                size:       CGFloat.random(in: 1.5...4.5,  using: &rng),
                ySpeed:     CGFloat.random(in: 0.4...1.0,  using: &rng),
                xDrift:     CGFloat.random(in: -0.3...0.3, using: &rng),
                opacity:    Double.random(in: 0.35...0.90, using: &rng),
                sineAmp:    CGFloat.random(in: 6...22,     using: &rng),
                sineFreq:   CGFloat.random(in: 0.02...0.06,using: &rng),
                sinePhase:  CGFloat.random(in: 0...(.pi * 2), using: &rng),
                color:      Color(hue: c.h, saturation: c.s,
                                  brightness: c.b, opacity: 1.0)
            )
        }
    }
}

private struct DustParticle {
    let x, y, size, ySpeed, xDrift: CGFloat
    let opacity:                     Double
    let sineAmp, sineFreq, sinePhase: CGFloat
    let color:                       Color
}

// MARK: - Light Rays

struct LightRaysView: View {
    private let rayCount = 18

    var body: some View {
        Canvas { context, size in
            let center    = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius    = max(size.width, size.height) * 0.8
            for i in 0..<rayCount {
                let angle     = (Double(i) / Double(rayCount)) * 2 * .pi
                let halfWidth = .pi / Double(rayCount) * 0.52
                var path = Path()
                path.move(to: center)
                path.addArc(center: center, radius: radius,
                            startAngle: .radians(angle - halfWidth),
                            endAngle:   .radians(angle + halfWidth),
                            clockwise: false)
                path.closeSubpath()
                let alpha = i.isMultiple(of: 2) ? 0.12 : 0.05
                context.fill(path, with: .color(
                    Color(red: 1, green: 0.88, blue: 0.3).opacity(alpha)
                ))
            }
        }
        .frame(width: 560, height: 560)
        .mask(
            RadialGradient(
                colors: [.white, .white.opacity(0.4), .clear],
                center: .center, startRadius: 50, endRadius: 280
            )
        )
    }
}

// MARK: - Gold Sparkle Rings

struct SparkleRingView: View {
    let count:    Int
    let radius:   CGFloat
    let iconSize: CGFloat
    let delay:    Double

    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle     = Double(i) / Double(count) * .pi * 2
                let itemDelay = delay + Double(i) / Double(count) * 0.45
                SingleSparkle(iconSize: iconSize)
                    .offset(x: cos(angle) * radius, y: sin(angle) * radius)
                    .rotationEffect(.degrees(angle * 180 / .pi))
                    .scaleEffect(animate ? 1 : 0.05)
                    .opacity(animate ? 1 : 0)
                    .animation(
                        .spring(response: 0.38, dampingFraction: 0.48).delay(itemDelay),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

struct SingleSparkle: View {
    let iconSize: CGFloat
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: iconSize, weight: .regular))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.55),
                        Color(red: 1.0, green: 0.72, blue: 0.10),
                        Color(red: 1.0, green: 0.50, blue: 0.05)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .shadow(color: Color(red: 1, green: 0.8, blue: 0.2).opacity(0.9), radius: 6)
    }
}

// MARK: - 3D Medal (SceneKit)

struct Medal3DSceneView: UIViewRepresentable {
    let awardType:     AwardType
    let medalShape:    MedalShape
    let triggerSpinIn: Bool

    func makeUIView(context: Context) -> SCNView {
        let v                      = SCNView()
        v.backgroundColor          = .clear
        v.allowsCameraControl      = false
        v.antialiasingMode         = .multisampling4X
        v.preferredFramesPerSecond = 60
        v.scene                    = buildScene(coordinator: context.coordinator)
        return v
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard triggerSpinIn, !context.coordinator.didAnimate else { return }
        context.coordinator.didAnimate = true
        context.coordinator.medalNode?.removeAllAnimations()
        context.coordinator.runSpinIn()
    }

    private func usdzName(for type: AwardType) -> String? {
        switch type {
        case .beganSomething:          return "New Beginnings Badge"
        case .handledDifficulty:       return "Overcoming Difficulty Badge"
        case .practicedMindfulness:    return "Mindfulness Badge"
        case .prioritisedSleep:        return "Rest Well Badge"
        case .madeAmends:              return "Made Amends Badge"
        case .connectedWithSomeone:    return "Made Connections Badge"
        case .askedForHelp:            return "Reached Out Badge"
        case .finishedSomething:       return "Finished Tasks Badge"
        case .celebratedAWin:          return "Goal Achieved Badge"
        case .steppedOutsideComfort:   return "Comfort Zone Badge"
        case .movedYourBody:           return "Stayed Active Badge"
        case .createdSomething:        return "Created Something Badge"
        case .helpedOthers:            return "Helped Others Badge"
        case .ateWell:                 return "Nourished Yourself Badge"
        case .reachedOutFirst:         return "Reached Out First Badge"
        case .learnedSomethingNew:     return "Fed Curiosity Badge"
        case .spentTimeInNature:       return "Touched Grass Badge"
        case .disconnectedFromScreens: return "Disconnected From Screens Badge"
        case .satWithUncertainty:      return "Sat With Uncertainty Badge"
        case .restedWithoutGuilt:      return "Slept Without Guilt Badge"
        case .keptGoing:               return "Kept Going Badge"
        case .saidNo:                  return "Said No Badge"
        case .setABoundary:            return "Set Boundaries Badge"
        case .showedUpForYourself:     return "Showed Up For Yourself Badge"
        case .criedItOut:              return "Cried It Out Badge"
        case .sangInTheShower:         return "Sang In The Shower Badge"
        case .forgivingYourself:       return "Forgave Yourself Badge"
        case .blewUpMicrowave:         return "Blew Up A Microwave Badge"
        case .heroicNapper:            return "Heroic Napper Badge"
        case .doomScrolled:            return "Doomscrolled Badge"
        case .lostASock:               return "Lost A Sock Badge"
        case .breakfastPizza:          return "Breakfast Pizza Badge"
        case .autocorrectDisaster:     return "Autocorrect Disaster Badge"
        case .rememberedADream:        return "Remembered A Dream Badge"
        case .guessedTimeCorrectly:    return "Guessed The Time Correctly Badge"
        case .droppedPhoneOnFace:      return "Dropped Phone On Face Badge"
        default:                       return nil
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    // MARK: Coordinator

    final class Coordinator: NSObject {
        var medalNode:  SCNNode?
        var didAnimate: Bool = false
        var restingAngles: SCNVector3 = .init(0, 0, 0)

        func runSpinIn() {
            guard let node = medalNode else { return }

            let rx = restingAngles.x

            let fastSpin            = CABasicAnimation(keyPath: "eulerAngles.y")
            fastSpin.fromValue      = (-Float.pi * 6) as NSNumber
            fastSpin.toValue        = (0.0) as NSNumber
            fastSpin.duration       = 1.05
            fastSpin.timingFunction = CAMediaTimingFunction(name: .easeOut)
            fastSpin.fillMode       = .forwards
            fastSpin.isRemovedOnCompletion = false
            node.addAnimation(fastSpin, forKey: "spinIn")

            let after = CACurrentMediaTime() + 1.05

            let idle            = CABasicAnimation(keyPath: "eulerAngles.y")
            idle.byValue        = (Float.pi * 2) as NSNumber
            idle.duration       = 4.5
            idle.timingFunction = CAMediaTimingFunction(name: .linear)
            idle.repeatCount    = .infinity
            idle.beginTime      = after
            node.addAnimation(idle, forKey: "idleSpin")

            let wobble            = CABasicAnimation(keyPath: "eulerAngles.x")
            wobble.fromValue      = (rx - 0.12) as NSNumber
            wobble.toValue        = (rx + 0.12) as NSNumber
            wobble.duration       = 2.2
            wobble.autoreverses   = true
            wobble.repeatCount    = .infinity
            wobble.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            wobble.beginTime      = after
            node.addAnimation(wobble, forKey: "wobble")
        }
    }

    // MARK: Scene

    private func buildScene(coordinator: Coordinator) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let uiPath = medalShape.bezierPath()
        let geo    = SCNShape(path: uiPath, extrusionDepth: 0.10)
        geo.chamferRadius = 0.03
        geo.chamferMode   = .both

        let h = baseHue(for: awardType)

        let faceMat = SCNMaterial()
        faceMat.lightingModel      = .physicallyBased
        faceMat.diffuse.contents   = medalGradientImage(for: awardType)
        faceMat.roughness.contents = 0.08
        faceMat.metalness.contents = 1.0
        faceMat.specular.contents  = UIColor.white
        faceMat.shininess          = 1.0

        let edgeMat = SCNMaterial()
        edgeMat.lightingModel      = .physicallyBased
        edgeMat.diffuse.contents   = UIColor(hue: h, saturation: 0.65, brightness: 0.72, alpha: 1)
        edgeMat.roughness.contents = 0.12
        edgeMat.metalness.contents = 1.0

        geo.materials = [faceMat, faceMat, edgeMat, edgeMat, edgeMat]

        let medalNode: SCNNode

        if let name = usdzName(for: awardType),
           let url = Bundle.main.url(forResource: name, withExtension: "usdz"),
           let usdzScene = try? SCNScene(url: url, options: nil) {

            let container = SCNNode()
            for child in usdzScene.rootNode.childNodes {
                container.addChildNode(child)
            }
            medalNode = container
            medalNode.scale = SCNVector3(0.36, 0.36, 0.36)
            medalNode.eulerAngles.x = -(.pi / 2)

        } else {
            let uiPath = medalShape.bezierPath()
            let geo    = SCNShape(path: uiPath, extrusionDepth: 0.10)
            geo.chamferRadius = 0.03
            geo.chamferMode   = .both

            let h = baseHue(for: awardType)

            let faceMat = SCNMaterial()
            faceMat.lightingModel      = .physicallyBased
            faceMat.diffuse.contents   = medalGradientImage(for: awardType)
            faceMat.roughness.contents = 0.08
            faceMat.metalness.contents = 1.0
            faceMat.specular.contents  = UIColor.white
            faceMat.shininess          = 1.0

            let edgeMat = SCNMaterial()
            edgeMat.lightingModel      = .physicallyBased
            edgeMat.diffuse.contents   = UIColor(hue: h, saturation: 0.65, brightness: 0.72, alpha: 1)
            edgeMat.roughness.contents = 0.12
            edgeMat.metalness.contents = 1.0

            geo.materials = [faceMat, faceMat, edgeMat, edgeMat, edgeMat]

            let shapeNode = SCNNode(geometry: geo)
            shapeNode.eulerAngles.z = .pi

            let ep = SCNPlane(width: 0.80, height: 0.80)
            let em = SCNMaterial()
            em.diffuse.contents = emojiImage(awardType.medal)
            em.isDoubleSided    = false
            em.lightingModel    = .constant
            ep.materials        = [em]
            let en = SCNNode(geometry: ep)
            en.position      = SCNVector3(0, 0, 0.07)
            en.eulerAngles.z = .pi
            en.scale         = SCNVector3(0.75, 0.75, 1)
            shapeNode.addChildNode(en)

            medalNode = shapeNode
        }

        coordinator.restingAngles = medalNode.eulerAngles
        coordinator.medalNode = medalNode
        scene.rootNode.addChildNode(medalNode)

        addLight(scene, .directional,
                 UIColor(hue: 0.10, saturation: 0.35, brightness: 1.0, alpha: 1),
                 4800, SCNVector3(3, 4, 5))
        addLight(scene, .directional,
                 UIColor(hue: 0.60, saturation: 0.6, brightness: 0.9, alpha: 1),
                 900,  SCNVector3(-2, -1, -4))
        addLight(scene, .omni,
                 UIColor(white: 0.55, alpha: 1),
                 700,  SCNVector3(-3, -2, 2))
        addLight(scene, .ambient,
                 UIColor(hue: 0.11, saturation: 0.2, brightness: 0.6, alpha: 1),
                 480,  SCNVector3(0, 0, 0))

        let cam = SCNCamera()
        cam.fieldOfView    = 38
        cam.wantsHDR       = true
        cam.bloomIntensity = 0.5
        cam.bloomThreshold = 0.55
        let cn = SCNNode()
        cn.camera   = cam
        cn.position = SCNVector3(0, 0, 2.9)
        scene.lightingEnvironment.contents = UIColor(white: 1.0, alpha: 1)
        scene.lightingEnvironment.intensity = 3.0
        scene.rootNode.addChildNode(cn)
        
        return scene
    }

    @discardableResult
    private func addLight(_ scene: SCNScene, _ type: SCNLight.LightType,
                           _ color: UIColor, _ intensity: CGFloat,
                           _ pos: SCNVector3) -> SCNNode {
        let l = SCNLight(); l.type = type; l.color = color; l.intensity = intensity
        let n = SCNNode(); n.light = l; n.position = pos
        if type == .directional { n.look(at: .init(0,0,0)) }
        scene.rootNode.addChildNode(n)
        return n
    }

    private func medalGradientImage(for type: AwardType) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)

            let rect = CGRect(origin: .zero, size: size)
            let h = baseHue(for: type)

            UIColor(hue: h, saturation: 0.78, brightness: 0.68, alpha: 1).setFill()
            context.fill(rect)

            let colors = [
                UIColor(hue: h, saturation: 0.10, brightness: 1.00, alpha: 1).cgColor,
                UIColor(hue: h, saturation: 0.78, brightness: 0.68, alpha: 1).cgColor
            ] as CFArray
            let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1.0])!

            context.drawRadialGradient(
                grad,
                startCenter: CGPoint(x: size.width * 0.3, y: size.height * 0.3), startRadius: 0,
                endCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.5), endRadius: size.width * 0.6,
                options: .drawsAfterEndLocation
            )
        }
    }

    private func baseHue(for type: AwardType) -> CGFloat {
        switch type {
        case .connectedWithSomeone:    return 0.95
        case .helpedOthers:            return 0.13
        case .madeAmends:              return 0.85
        case .prioritisedSleep:        return 0.60
        case .movedYourBody:           return 0.35
        case .ateWell:                 return 0.25
        case .practicedMindfulness:    return 0.55
        case .learnedSomethingNew:     return 0.13
        case .steppedOutsideComfort:   return 0.07
        case .askedForHelp:            return 0.80
        case .keptGoing:               return 0.05
        case .handledDifficulty:       return 0.03
        case .setABoundary:            return 0.70
        case .finishedSomething:       return 0.11
        case .beganSomething:          return 0.45
        case .showedUpForYourself:     return 0.75
        case .reachedOutFirst:         return 0.90
        case .restedWithoutGuilt:      return 0.20
        case .spentTimeInNature:       return 0.50
        case .disconnectedFromScreens: return 0.65
        case .satWithUncertainty:      return 0.40
        case .createdSomething:        return 0.30
        case .saidNo:                  return 0.28
        case .celebratedAWin:          return 0.15
        case .forgivingYourself:       return 0.02
        case .criedItOut:              return 0.01
        case .blewUpMicrowave:         return 0.05
        case .sangInTheShower:         return 0.55
        case .heroicNapper:            return 0.70
        case .doomScrolled:            return 0.75
        case .lostASock:               return 0.10
        case .breakfastPizza:          return 0.07
        case .autocorrectDisaster:     return 0.88
        case .rememberedADream:        return 0.72
        case .guessedTimeCorrectly:    return 0.45
        case .droppedPhoneOnFace:      return 0.03
        }
    }

    private func emojiImage(_ emoji: String) -> UIImage {
        let size = CGSize(width: 300, height: 300)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 190)]
            let s = NSAttributedString(string: emoji, attributes: attrs)
            let sz = s.size()
            s.draw(at: CGPoint(x: (size.width-sz.width)/2, y: (size.height-sz.height)/2))
        }
    }
}

// MARK: - Sound Player

final class MedalSoundPlayer {
    static let shared = MedalSoundPlayer()
    private var engine: AVAudioEngine?
    private init() {}

    func playChime() {
        let frequencies: [Float] = [523.25, 659.25, 784.00, 987.77, 1046.50]
        let durations:   [Float] = [0.20,   0.20,   0.20,   0.20,   0.70  ]
        let delays:      [Float] = [0.00,   0.13,   0.26,   0.39,   0.52  ]
        let amplitudes:  [Float] = [0.28,   0.26,   0.24,   0.22,   0.32  ]

        DispatchQueue.global(qos: .userInitiated).async {
            let engine     = AVAudioEngine()
            let mixer      = engine.mainMixerNode
            let sampleRate = 44100.0
            let format     = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

            for idx in 0..<frequencies.count {
                let freq  = frequencies[idx]
                let dur   = durations[idx]
                let del   = delays[idx]
                let amp   = amplitudes[idx]
                let total = AVAudioFrameCount(sampleRate * Double(dur + 0.45))
                guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: total) else { continue }
                buf.frameLength = total
                let data  = buf.floatChannelData![0]
                let omega = 2 * Float.pi * freq / Float(sampleRate)
                let atk   = Int(sampleRate * 0.008)
                let rel   = Int(sampleRate * Double(dur) * 0.75)
                let n     = Int(total)
                for f in 0..<n {
                    var env: Float = 1
                    if f < atk { env = Float(f) / Float(atk) }
                    else if f > n - rel { env = max(0, Float(n-f) / Float(rel)) }
                    data[f] = amp * (
                          0.50 * sin(1 * omega * Float(f)) * env
                        + 0.25 * sin(2 * omega * Float(f)) * env * powf(env, 0.3)
                        + 0.12 * sin(4 * omega * Float(f)) * env * powf(env, 0.8)
                        + 0.06 * sin(7 * omega * Float(f)) * env * powf(env, 1.5)
                    )
                }
                let player = AVAudioPlayerNode()
                engine.attach(player)
                engine.connect(player, to: mixer, format: format)
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(del)) {
                    player.scheduleBuffer(buf, completionHandler: nil)
                    player.play()
                }
            }

            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
                try engine.start()
                self.engine = engine
            } catch { print("MedalSoundPlayer: \(error)") }

            Thread.sleep(forTimeInterval: 2.5)
        }
    }
}

// MARK: - Shelf Medal (compact, idle-spinning, draggable on Y axis)

struct ShelfMedal3DView: UIViewRepresentable {
    let awardType: AwardType
    let medalShape: MedalShape

    private var shape: MedalShape { MedalShape.deterministic(for: awardType) }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let v                      = SCNView()
        v.backgroundColor          = .clear
        v.allowsCameraControl      = false
        v.antialiasingMode         = .multisampling4X
        v.preferredFramesPerSecond = 60

        let (scene, medalNode, restingX) = buildScene()
        v.scene = scene

        let coord = context.coordinator
        coord.medalNode  = medalNode
        coord.restingX   = restingX
        coord.scnView    = v

        coord.startIdle()

        let pan = UIPanGestureRecognizer(target: coord,
                                         action: #selector(Coordinator.handlePan(_:)))
        v.addGestureRecognizer(pan)

        return v
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    // MARK: - Coordinator

    final class Coordinator: NSObject {
        weak var scnView:   SCNView?
        var medalNode:      SCNNode?
        var restingX:       Float = 0

        private var currentYAngle:   Float = 0
        private var angularVelocity: Float = 0
        private var displayLink:     CADisplayLink?
        private var idleTimer:       Timer?
        private var isIdling         = false

        private let decayFactor:  Float = 0.88
        private let sensitivity:  Float = 0.012
        private let snapThreshold: Float = 0.04

        func startIdle() {
            guard let node = medalNode, !isIdling else { return }
            isIdling = true

            let spin            = CABasicAnimation(keyPath: "eulerAngles.y")
            spin.byValue        = (Float.pi * 2) as NSNumber
            spin.duration       = 5.0
            spin.timingFunction = CAMediaTimingFunction(name: .linear)
            spin.repeatCount    = .infinity
            spin.fromValue      = node.presentation.eulerAngles.y as NSNumber
            node.addAnimation(spin, forKey: "idleSpin")

            let wobble            = CABasicAnimation(keyPath: "eulerAngles.x")
            wobble.fromValue      = (restingX - 0.10) as NSNumber
            wobble.toValue        = (restingX + 0.10) as NSNumber
            wobble.duration       = 2.4
            wobble.autoreverses   = true
            wobble.repeatCount    = .infinity
            wobble.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            node.addAnimation(wobble, forKey: "wobble")
        }

        private func stopIdle() {
            guard let node = medalNode else { return }
            isIdling = false

            let presentedY = node.presentation.eulerAngles.y
            let presentedX = node.presentation.eulerAngles.x
            node.removeAnimation(forKey: "idleSpin")
            node.removeAnimation(forKey: "wobble")
            node.eulerAngles.y = presentedY
            node.eulerAngles.x = presentedX
            currentYAngle      = presentedY
        }

        @objc func handlePan(_ gr: UIPanGestureRecognizer) {
            guard let node = medalNode else { return }

            switch gr.state {
            case .began:
                cancelIdleTimer()
                stopMomentum()
                stopIdle()

            case .changed:
                let dx = Float(gr.translation(in: gr.view).x)
                node.eulerAngles.y = currentYAngle + dx * sensitivity
                node.eulerAngles.x = restingX

                let vel         = gr.velocity(in: gr.view)
                angularVelocity = Float(vel.x) * sensitivity

            case .ended, .cancelled:
                currentYAngle = node.eulerAngles.y
                startMomentumThenSnap()

            default:
                break
            }
        }

        private func startMomentumThenSnap() {
            stopMomentum()
            let dl = CADisplayLink(target: self,
                                   selector: #selector(momentumStep(_:)))
            dl.add(to: .main, forMode: .common)
            displayLink = dl
        }

        private func stopMomentum() {
            displayLink?.invalidate()
            displayLink = nil
        }

        @objc private func momentumStep(_ dl: CADisplayLink) {
            guard let node = medalNode else { stopMomentum(); return }

            angularVelocity *= decayFactor
            currentYAngle   += angularVelocity * Float(dl.duration)
            node.eulerAngles.y = currentYAngle
            node.eulerAngles.x = restingX

            if abs(angularVelocity) < snapThreshold {
                stopMomentum()
                snapToNearestFace()
            }
        }

        private func snapToNearestFace() {
            guard let node = medalNode else { return }

            let twoPi   = Float.pi * 2
            let raw     = currentYAngle
            let norm    = ((raw.truncatingRemainder(dividingBy: twoPi)) + twoPi)
                          .truncatingRemainder(dividingBy: twoPi)

            let distToFront = min(norm, twoPi - norm)
            let distToBack  = abs(norm - Float.pi)

            let faceAngle: Float = distToFront <= distToBack ? 0 : Float.pi

            let nearestMultiple = (raw / Float.pi).rounded() * Float.pi
            let targetBase  = nearestMultiple
            let targetNorm  = ((targetBase.truncatingRemainder(dividingBy: twoPi)) + twoPi)
                              .truncatingRemainder(dividingBy: twoPi)
            let wantFront   = distToFront <= distToBack
            let landsFront  = targetNorm < 0.01 || targetNorm > twoPi - 0.01

            let targetY: Float = (wantFront == landsFront)
                                 ? targetBase
                                 : targetBase + Float.pi

            let spring                 = CASpringAnimation(keyPath: "eulerAngles.y")
            spring.fromValue           = node.presentation.eulerAngles.y as NSNumber
            spring.toValue             = targetY as NSNumber
            spring.mass                = 1.0
            spring.stiffness           = 180
            spring.damping             = 22
            spring.initialVelocity     = Double(angularVelocity)
            spring.duration            = spring.settlingDuration
            spring.fillMode            = .forwards
            spring.isRemovedOnCompletion = false
            node.addAnimation(spring, forKey: "snapFace")

            let settleDuration = spring.settlingDuration
            currentYAngle = targetY

            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred(intensity: 0.5)

            scheduleIdleTimer(after: settleDuration + 1.5)
        }

        private func scheduleIdleTimer(after delay: TimeInterval = 2.0) {
            cancelIdleTimer()
            idleTimer = Timer.scheduledTimer(withTimeInterval: delay,
                                             repeats: false) { [weak self] _ in
                guard let self, let node = self.medalNode else { return }
                node.removeAnimation(forKey: "snapFace")
                node.eulerAngles.y = self.currentYAngle
                node.eulerAngles.x = self.restingX
                self.startIdle()
            }
        }

        private func cancelIdleTimer() {
            idleTimer?.invalidate()
            idleTimer = nil
        }
    }

    // MARK: - Scene builder

    private func usdzName(for type: AwardType) -> String? {
        switch type {
        case .beganSomething:          return "New Beginnings Badge"
        case .handledDifficulty:       return "Overcoming Difficulty Badge"
        case .practicedMindfulness:    return "Mindfulness Badge"
        case .prioritisedSleep:        return "Rest Well Badge"
        case .madeAmends:              return "Made Amends Badge"
        case .connectedWithSomeone:    return "Made Connections Badge"
        case .askedForHelp:            return "Reached Out Badge"
        case .finishedSomething:       return "Finished Tasks Badge"
        case .celebratedAWin:          return "Goal Achieved Badge"
        case .steppedOutsideComfort:   return "Comfort Zone Badge"
        case .movedYourBody:           return "Stayed Active Badge"
        case .createdSomething:        return "Created Something Badge"
        case .helpedOthers:            return "Helped Others Badge"
        case .ateWell:                 return "Nourished Yourself Badge"
        case .reachedOutFirst:         return "Reached Out First Badge"
        case .learnedSomethingNew:     return "Fed Curiosity Badge"
        case .spentTimeInNature:       return "Touched Grass Badge"
        case .disconnectedFromScreens: return "Disconnected From Screens Badge"
        case .satWithUncertainty:      return "Sat With Uncertainty Badge"
        case .restedWithoutGuilt:      return "Slept Without Guilt Badge"
        case .keptGoing:               return "Kept Going Badge"
        case .saidNo:                  return "Said No Badge"
        case .setABoundary:            return "Set Boundaries Badge"
        case .showedUpForYourself:     return "Showed Up For Yourself Badge"
        case .criedItOut:              return "Cried It Out Badge"
        case .sangInTheShower:         return "Sang In The Shower Badge"
        case .forgivingYourself:       return "Forgave Yourself Badge"
        case .blewUpMicrowave:         return "Blew Up A Microwave Badge"
        case .heroicNapper:            return "Heroic Napper Badge"
        case .doomScrolled:            return "Doomscrolled Badge"
        case .lostASock:               return "Lost A Sock Badge"
        case .breakfastPizza:          return "Breakfast Pizza Badge"
        case .autocorrectDisaster:     return "Autocorrect Disaster Badge"
        case .rememberedADream:        return "Remembered A Dream Badge"
        case .guessedTimeCorrectly:    return "Guessed The Time Correctly Badge"
        case .droppedPhoneOnFace:      return "Dropped Phone On Face Badge"
        default:                       return nil
        }
    }

    private func buildScene() -> (SCNScene, SCNNode, Float) {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let medalNode: SCNNode
        var restingX: Float = 0

        if let name = usdzName(for: awardType),
           let url  = Bundle.main.url(forResource: name, withExtension: "usdz"),
           let usdzScene = try? SCNScene(url: url, options: nil) {

            let container = SCNNode()
            for child in usdzScene.rootNode.childNodes {
                container.addChildNode(child)
            }
            medalNode              = container
            medalNode.scale        = SCNVector3(0.3, 0.3, 0.3)
            medalNode.eulerAngles.x = -(.pi / 2)
            restingX               = medalNode.eulerAngles.x

        } else {
            let uiPath = shape.bezierPath()
            let geo    = SCNShape(path: uiPath, extrusionDepth: 0.10)
            geo.chamferRadius = 0.03
            geo.chamferMode   = .both

            let h = baseHue(for: awardType)

            let faceMat = SCNMaterial()
            faceMat.lightingModel      = .physicallyBased
            faceMat.diffuse.contents   = medalGradientImage(for: awardType)
            faceMat.roughness.contents = 0.08
            faceMat.metalness.contents = 1.0
            faceMat.specular.contents  = UIColor.white

            let edgeMat = SCNMaterial()
            edgeMat.lightingModel      = .physicallyBased
            edgeMat.diffuse.contents   = UIColor(hue: h, saturation: 0.65, brightness: 0.72, alpha: 1)
            edgeMat.roughness.contents = 0.12
            edgeMat.metalness.contents = 1.0

            geo.materials = [faceMat, faceMat, edgeMat, edgeMat, edgeMat]

            let shapeNode = SCNNode(geometry: geo)
            shapeNode.eulerAngles.z = .pi

            let ep = SCNPlane(width: 0.80, height: 0.80)
            let em = SCNMaterial()
            em.diffuse.contents = emojiImage(awardType.medal)
            em.isDoubleSided    = false
            em.lightingModel    = .constant
            ep.materials        = [em]
            let en = SCNNode(geometry: ep)
            en.position      = SCNVector3(0, 0, 0.07)
            en.eulerAngles.z = .pi
            en.scale         = SCNVector3(0.75, 0.75, 1)
            shapeNode.addChildNode(en)

            medalNode = shapeNode
        }

        scene.rootNode.addChildNode(medalNode)

        let key = SCNLight(); key.type = .directional
        key.color     = UIColor(hue: 0.10, saturation: 0.30, brightness: 1.0, alpha: 1)
        key.intensity = 4200
        let kn = SCNNode(); kn.light = key; kn.position = SCNVector3(3, 4, 5)
        kn.look(at: .init(0, 0, 0))
        scene.rootNode.addChildNode(kn)

        let fill = SCNLight(); fill.type = .directional
        fill.color     = UIColor(hue: 0.60, saturation: 0.5, brightness: 0.9, alpha: 1)
        fill.intensity = 700
        let fn = SCNNode(); fn.light = fill; fn.position = SCNVector3(-2, -1, -4)
        fn.look(at: .init(0, 0, 0))
        scene.rootNode.addChildNode(fn)

        let amb = SCNLight(); amb.type = .ambient
        amb.color     = UIColor(hue: 0.11, saturation: 0.2, brightness: 0.55, alpha: 1)
        amb.intensity = 420
        let an = SCNNode(); an.light = amb
        scene.rootNode.addChildNode(an)

        let cam = SCNCamera()
        cam.fieldOfView    = 32
        cam.wantsHDR       = true
        cam.bloomIntensity = 0.35
        cam.bloomThreshold = 0.4
        let cn = SCNNode(); cn.camera = cam; cn.position = SCNVector3(0, 0, 2.9)
        scene.rootNode.addChildNode(cn)
        scene.lightingEnvironment.contents = UIColor(white: 1.0, alpha: 1)
        scene.lightingEnvironment.intensity = 3.0

        return (scene, medalNode, restingX)
    }

    // MARK: - Helpers

    private func baseHue(for type: AwardType) -> CGFloat {
        switch type {
        case .connectedWithSomeone:    return 0.95
        case .helpedOthers:            return 0.13
        case .madeAmends:              return 0.85
        case .prioritisedSleep:        return 0.60
        case .movedYourBody:           return 0.35
        case .ateWell:                 return 0.25
        case .practicedMindfulness:    return 0.55
        case .learnedSomethingNew:     return 0.13
        case .steppedOutsideComfort:   return 0.07
        case .askedForHelp:            return 0.80
        case .keptGoing:               return 0.05
        case .handledDifficulty:       return 0.03
        case .setABoundary:            return 0.70
        case .finishedSomething:       return 0.11
        case .beganSomething:          return 0.45
        case .showedUpForYourself:     return 0.75
        case .reachedOutFirst:         return 0.20
        case .restedWithoutGuilt:      return 0.40
        case .spentTimeInNature:       return 0.60
        case .disconnectedFromScreens: return 0.70
        case .satWithUncertainty:      return 0.80
        case .createdSomething:        return 0.90
        case .saidNo:                  return 0.00
        case .celebratedAWin:          return 0.50
        case .forgivingYourself:       return 0.65
        case .criedItOut:              return 0.90
        case .blewUpMicrowave:         return 0.05
        case .sangInTheShower:         return 0.55
        case .heroicNapper:            return 0.70
        case .doomScrolled:            return 0.75
        case .lostASock:               return 0.10
        case .breakfastPizza:          return 0.07
        case .autocorrectDisaster:     return 0.88
        case .rememberedADream:        return 0.72
        case .guessedTimeCorrectly:    return 0.45
        case .droppedPhoneOnFace:      return 0.03
        }
    }

    private func medalGradientImage(for type: AwardType) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)

            let rect = CGRect(origin: .zero, size: size)
            let h    = baseHue(for: type)

            UIColor(hue: h, saturation: 0.78, brightness: 0.68, alpha: 1).setFill()
            context.fill(rect)

            let colors = [
                UIColor(hue: h, saturation: 0.10, brightness: 1.00, alpha: 1).cgColor,
                UIColor(hue: h, saturation: 0.78, brightness: 0.68, alpha: 1).cgColor
            ] as CFArray
            let grad = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors, locations: [0, 1.0])!

            context.drawRadialGradient(
                grad,
                startCenter: CGPoint(x: size.width * 0.3, y: size.height * 0.3),
                startRadius: 0,
                endCenter:   CGPoint(x: size.width * 0.5, y: size.height * 0.5),
                endRadius:   size.width * 0.6,
                options:     .drawsAfterEndLocation
            )
        }
    }

    private func emojiImage(_ emoji: String) -> UIImage {
        let size = CGSize(width: 300, height: 300)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 190)]
            let s  = NSAttributedString(string: emoji, attributes: attrs)
            let sz = s.size()
            s.draw(at: CGPoint(x: (size.width - sz.width) / 2,
                               y: (size.height - sz.height) / 2))
        }
    }
}
