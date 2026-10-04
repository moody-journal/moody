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
    let awards: [Award]
    var onDismiss: (() -> Void)?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedID: UUID?
    @State private var arrived = false
    @State private var showCollection = false
    @State private var started = false
    @State private var isClosing = false
    @State private var sound = MedalSoundPlayer()

    init(awards: [Award], onDismiss: (() -> Void)? = nil) {
        self.awards = awards
        self.onDismiss = onDismiss
        _selectedID = State(initialValue: awards.first?.id)
    }

    init(award: Award, onDismiss: (() -> Void)? = nil) {
        self.init(awards: [award], onDismiss: onDismiss)
    }

    private var selectedAward: Award? {
        awards.first(where: { $0.id == selectedID }) ?? awards.first
    }

    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.01, blue: 0.04).ignoresSafeArea()
            RadialGradient(colors: [.indigo.opacity(0.28), .clear], center: .center,
                           startRadius: 20, endRadius: 340)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    Text(awards.count == 1 ? "A little win, just for you" : "Your moments worth celebrating")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Button(action: finish) {
                        Image(systemName: "xmark.circle.fill").font(.title2)
                    }
                    .accessibilityLabel("Close medals")
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer(minLength: 0)
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let itemWidth = min(240.0, width * 0.64)
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 12) {
                            ForEach(awards, id: \.id) { award in
                                Medal3DSceneView(awardType: award.type,
                                    medalShape: .deterministic(for: award.type), triggerSpinIn: false)
                                    .allowsHitTesting(false)
                                    .frame(width: itemWidth, height: 270)
                                    .visualEffect { content, proxy in
                                        content.scaleEffect(MedalCarouselLayout.scale(
                                            center: proxy.frame(in: .scrollView(axis: .horizontal)).midX,
                                            viewportWidth: width))
                                    }
                                    .opacity(award.id == awards.first?.id ? (arrived ? 1 : 0) : (showCollection ? 1 : 0))
                                    .offset(y: award.id == awards.first?.id && !arrived && !reduceMotion ? geometry.size.height + 100 : 0)
                                    .id(award.id)
                                    .accessibilityLabel(award.displayTitle)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.horizontal, (width - itemWidth) / 2, for: .scrollContent)
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $selectedID)
                    .scrollDisabled(!showCollection || awards.count < 2)
                    .scrollClipDisabled()
                }
                .frame(height: 280)

                if let award = selectedAward {
                    ScrollView {
                        PremiumLabelCard(award: award)
                            .padding(.horizontal, 24)
                    }
                    .frame(maxHeight: 200)
                    .opacity(arrived ? 1 : 0)
                }
                if awards.count > 1 {
                    Text("\((awards.firstIndex(where: { $0.id == selectedID }) ?? 0) + 1) of \(awards.count) · Swipe to explore")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .opacity(showCollection ? 1 : 0)
                }
                Spacer(minLength: 0)
                Button("Keep journaling", action: finish)
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            guard !started else { return }
            started = true
            sound.prepare()
            do {
                try await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled, !isClosing else { return }
                if scenePhase == .active { sound.playChime() }
                withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.75, dampingFraction: 0.82)) {
                    arrived = true
                }
                try await Task.sleep(for: .milliseconds(reduceMotion ? 200 : 900))
                guard !Task.isCancelled, !isClosing else { return }
                withAnimation(.easeIn(duration: 0.45)) { showCollection = true }
            } catch { /* View dismissal cancels the entrance sequence. */ }
        }
        .onDisappear { sound.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { sound.stop() }
        }
    }

    private func finish() {
        guard !isClosing else { return }
        isClosing = true
        sound.stop()
        onDismiss?()
    }
}

enum MedalCarouselLayout {
    nonisolated static func scale(center: CGFloat, viewportWidth: CGFloat) -> CGFloat {
        guard viewportWidth > 0 else { return 1 }
        let distance = abs(center - viewportWidth / 2)
        return max(0.64, 1 - distance / viewportWidth * 0.7)
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

    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) {
        coordinator.medalNode?.removeAllAnimations()
        coordinator.medalNode = nil
        uiView.scene = nil
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
        case .rememberedADream:        return "Remembered A Dream"
        case .guessedTimeCorrectly:    return "Guessed The Time Correctly Badge"
        case .droppedPhoneOnFace:      return "Dropped Phone On Face Badge"
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
           let url = MedalAppearance.resourceURL(named: name),
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

        MedalAppearance.light(scene)

        let cam = SCNCamera()
        cam.fieldOfView    = 38
        cam.wantsHDR       = true
        cam.bloomIntensity = 0.12
        cam.bloomThreshold = 1.0
        let cn = SCNNode()
        cn.camera   = cam
        cn.position = SCNVector3(0, 0, 2.9)
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

@MainActor
final class MedalSoundPlayer {
    private var player: AVAudioPlayer?
    private var didPlay = false

    func prepare() {
        guard player == nil, !didPlay,
              let url = Bundle.main.url(forResource: "MedalChime", withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
            let chime = try AVAudioPlayer(contentsOf: url)
            chime.volume = 0.65
            chime.prepareToPlay()
            player = chime
        } catch { player = nil }
    }

    /// One chime belongs to one presentation, never to a scrolling medal cell.
    func playChime() {
        guard !didPlay else { return }
        didPlay = true
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            player?.play()
        } catch { player = nil }
    }

    func stop() { player?.stop(); player = nil }
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

    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) {
        coordinator.stop()
        uiView.scene = nil
    }

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

        func stop() {
            displayLink?.invalidate(); displayLink = nil
            cancelIdleTimer()
            medalNode?.removeAllAnimations()
            medalNode = nil
            scnView = nil
        }

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
        case .rememberedADream:        return "Remembered A Dream"
        case .guessedTimeCorrectly:    return "Guessed The Time Correctly Badge"
        case .droppedPhoneOnFace:      return "Dropped Phone On Face Badge"
        }
    }

    private func buildScene() -> (SCNScene, SCNNode, Float) {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let medalNode: SCNNode
        var restingX: Float = 0

        if let name = usdzName(for: awardType),
           let url  = MedalAppearance.resourceURL(named: name),
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

        MedalAppearance.light(scene)

        let cam = SCNCamera()
        cam.fieldOfView    = 32
        cam.wantsHDR       = true
        cam.bloomIntensity = 0.12
        cam.bloomThreshold = 1.0
        let cn = SCNNode(); cn.camera = cam; cn.position = SCNVector3(0, 0, 2.9)
        scene.rootNode.addChildNode(cn)

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
