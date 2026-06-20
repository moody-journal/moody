import SwiftUI

// MARK: - Pulse ring state

struct PulseRing: Identifiable {
    let id = UUID()
    let birthTime: Double
}

// MARK: - MoodSliderView

struct MoodSliderView: View {
    @Binding var mood: Mood

    @Environment(\.colorScheme) private var colorScheme

    @State private var sliderValue: Double = 0.5
    @State private var animatedValue: Double = 0.5
    @State private var canvasValue: Double = 0.5
    @State private var time: Double = 0
    @State private var animTimer: Timer?

    @State private var pulseRings: [PulseRing] = []
    private let pulseDuration: Double = 1.6
    private let pulseInterval: Double = 1.0

    private static let moodOrder: [Mood] = [.terrible, .bad, .okay, .good, .great]

    private func sliderPos(for mood: Mood) -> Double {
        let idx = Self.moodOrder.firstIndex(of: mood) ?? 2
        return Double(idx) / Double(Self.moodOrder.count - 1)
    }

    private func mood(for sliderPos: Double) -> Mood {
        let idx = Int((sliderPos * Double(Self.moodOrder.count - 1)).rounded())
        return Self.moodOrder[max(0, min(Self.moodOrder.count - 1, idx))]
    }

    private var backgroundOpacity: Double {
        colorScheme == .light ? 0.95 : 0.85
    }

    var body: some View {
        VStack(spacing: 18) {
            MoodCanvas(canvasValue: canvasValue, time: time, pulseRings: pulseRings)
                .frame(height: 240)

            Text(MoodSliderConfig.label(for: animatedValue))
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .animation(.none, value: animatedValue)

            VStack(spacing: 6) {
                Slider(value: $sliderValue, in: 0...1)
                    .tint(colorScheme == .light ? .white.opacity(0.8) : .white.opacity(0.5))
                    .onChange(of: sliderValue) { _, new in
                        mood = mood(for: new)
                    }

                HStack {
                    Text("VERY UNPLEASANT")
                    Spacer()
                    Text("VERY PLEASANT")
                }
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .kerning(0.5)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(MoodSliderConfig.bgColor(for: animatedValue, colorScheme: colorScheme)).opacity(backgroundOpacity))
                .animation(.easeInOut(duration: 0.6), value: animatedValue)
        )
        .onAppear {
            sliderValue   = sliderPos(for: mood)
            animatedValue = sliderValue
            canvasValue   = sliderValue
            startAnimation()
        }
        .onChange(of: sliderValue) { _, new in
            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.75)) {
                animatedValue = new
            }
        }
        .onDisappear { animTimer?.invalidate() }
    }

    private func startAnimation() {
        pulseRings.append(PulseRing(birthTime: 0))

        animTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [self] _ in
            time += 1.0 / 60.0

            canvasValue += (animatedValue - canvasValue) * 0.08

            if let lastBirth = pulseRings.last?.birthTime,
               time - lastBirth >= pulseInterval {
                pulseRings.append(PulseRing(birthTime: time))
            }

            pulseRings.removeAll { time - $0.birthTime > pulseDuration }
        }
        RunLoop.main.add(animTimer!, forMode: .common)
    }
}

// MARK: - Canvas renderer

private struct MoodCanvas: View {
    let canvasValue: Double
    let time: Double
    let pulseRings: [PulseRing]

    private let pulseMaxExpand: Double = 30
    private let pulseMaxLineWidth: Double = 2.8
    private let pulseDuration: Double = 1.6

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            var cfg = MoodSliderConfig.interpolated(at: canvasValue, time: time)

            let breathe = 1.0 + 0.045 * sin(time * 0.5 * .pi * 2 / 4.0)
            cfg.baseRadius *= breathe

            let glowR = cfg.outerRadius * 1.35
            var glow = context
            glow.addFilter(.blur(radius: glowR * 0.45))
            let glowPath = Path(ellipseIn: CGRect(
                x: cx - glowR, y: cy - glowR,
                width: glowR * 2, height: glowR * 2))
            glow.fill(glowPath, with: .color(cfg.glowColor.opacity(0.25)))

            let layerCount = 3
            for li in stride(from: layerCount - 1, through: 0, by: -1) {
                let r      = cfg.baseRadius + cfg.layerGap * Double(li)
                let alpha  = [1.0, 0.5, 0.28][li]
                let speed  = cfg.layerSpeeds[li]
                let rotOff = cfg.rotation + time * speed
                let color  = cfg.layerColors[min(li, cfg.layerColors.count - 1)]

                let path = organicPath(
                    cx: cx, cy: cy,
                    radius: r,
                    cfg: cfg,
                    rotation: rotOff,
                    time: time,
                    layerIndex: li
                )

                context.fill(path, with: .color(color.opacity(alpha)))

                var stroke = context
                stroke.opacity = alpha * 0.6
                stroke.stroke(path, with: .color(.white.opacity(0.55)), lineWidth: 1.2)
            }

            let outerLayerIndex = layerCount - 1
            let outerRadius     = cfg.baseRadius + cfg.layerGap * Double(outerLayerIndex)
            let outerRotation   = cfg.rotation + time * cfg.layerSpeeds[outerLayerIndex]

            for ring in pulseRings {
                let age      = time - ring.birthTime
                let progress = max(0, min(1, age / pulseDuration))

                let eased    = 1 - pow(1 - progress, 2)

                let extraR   = pulseMaxExpand * eased

                let opacity  = (1 - progress) * 0.2
                let lineW    = pulseMaxLineWidth * (1 - progress * 0.7)

                let ringPath = organicPath(
                    cx: cx, cy: cy,
                    radius: outerRadius + extraR,
                    cfg: cfg,
                    rotation: outerRotation,
                    time: time,
                    layerIndex: outerLayerIndex
                )

                let ringColor = cfg.layerColors[min(outerLayerIndex, cfg.layerColors.count - 1)]

                var ringCtx = context
                ringCtx.stroke(
                    ringPath,
                    with: .color(ringColor.opacity(opacity)),
                    lineWidth: lineW
                )

                let ghostPath = organicPath(
                    cx: cx, cy: cy,
                    radius: outerRadius + extraR + lineW * 0.8,
                    cfg: cfg,
                    rotation: outerRotation,
                    time: time,
                    layerIndex: outerLayerIndex
                )
                var ghostCtx = context
                ghostCtx.addFilter(.blur(radius: lineW * 1.2))
                ghostCtx.stroke(
                    ghostPath,
                    with: .color(.white.opacity(opacity * 0.35)),
                    lineWidth: lineW * 0.6
                )
            }

            let innerR    = cfg.baseRadius * 0.35
            let innerPath = Path(ellipseIn: CGRect(
                x: cx - innerR, y: cy - innerR,
                width: innerR * 2, height: innerR * 2))
            context.fill(innerPath, with: .color(cfg.layerColors[0].opacity(0.55)))

            let dotR    = 4.0
            let dotPath = Path(ellipseIn: CGRect(
                x: cx - dotR, y: cy - dotR,
                width: dotR * 2, height: dotR * 2))
            context.fill(dotPath, with: .color(.white.opacity(0.65)))
        }
    }

    private func organicPath(
        cx: Double, cy: Double,
        radius: Double,
        cfg: MoodSliderConfig,
        rotation: Double,
        time: Double,
        layerIndex: Int
    ) -> Path {
        let steps = 300
        var points: [CGPoint] = []
        for i in 0...steps {
            let angle = (Double(i) / Double(steps)) * .pi * 2 + rotation
            let r = blendedRadius(
                base: radius,
                cfg: cfg,
                angle: angle,
                time: time,
                layer: layerIndex
            )
            points.append(CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r))
        }
        var path = Path()
        path.move(to: points[0])
        for i in 1..<points.count {
            let prev = points[i - 1], curr = points[i]
            let mid  = CGPoint(x: (prev.x + curr.x) / 2, y: (prev.y + curr.y) / 2)
            path.addQuadCurve(to: mid, control: prev)
        }
        path.closeSubpath()
        return path
    }

    private func blendedRadius(
        base: Double,
        cfg: MoodSliderConfig,
        angle: Double,
        time: Double,
        layer: Int
    ) -> Double {
        let rA = shapeRadius(base: base, petals: cfg.petalsA, shape: cfg.shapeA,
                             angle: angle, time: time, layer: layer)
        let rB = shapeRadius(base: base, petals: cfg.petalsB, shape: cfg.shapeB,
                             angle: angle, time: time, layer: layer)
        return rA + (rB - rA) * cfg.shapeFrac
    }

    private func shapeRadius(
        base: Double, petals: Double, shape: MoodShapeKind,
        angle: Double, time: Double, layer: Int
    ) -> Double {
        switch shape {
        case .circle:
            return base
        case .flower:
            return base * (1.0 + 0.22 * cos(petals * angle + time * 0.3))
        case .wavy:
            return base * (1.0 + 0.18 * cos(petals * angle + time * 0.4)
                               + 0.06 * cos(petals * 2 * angle - time * 0.2))
        case .pointed:
            return base * (1.0 + 0.28 * cos(petals * angle + time * 0.25)
                               + 0.05 * cos(petals * 2 * angle + time * 0.1))
        case .star:
            return base * (1.0 + 0.30 * cos(petals * (angle - .pi / 2) + time * 0.2))
        case .pentagon:
            return base * (1.0 + 0.14 * cos(petals * (angle - .pi / 2) + time * 0.3))
        }
    }
}

// MARK: - Shape kinds

enum MoodShapeKind {
    case circle, flower, wavy, pointed, star, pentagon
}

// MARK: - Config & interpolation

struct MoodSliderConfig {
    var shapeA: MoodShapeKind
    var shapeB: MoodShapeKind
    var shapeFrac: Double
    var petalsA: Double
    var petalsB: Double
    var baseRadius: Double
    var layerGap: Double
    var layerColors: [Color]
    var layerSpeeds: [Double]
    var glowColor: Color
    var bgHex: String
    var rotation: Double

    var outerRadius: Double { baseRadius + layerGap * 2 }

    static let keyframes: [KeyFrame] = [
        KeyFrame(petals: 8, shape: .pointed,  baseRadius: 58, layerGap: 22,
                 layerColors: [Color(hex:"#7a5faa"), Color(hex:"#9b7fc4"), Color(hex:"#c0a8e0")],
                 layerSpeeds: [0.011, 0.007, 0.004],
                 glowColor: Color(hex:"#a07fd0"), bgHex: "#2e2540", lightBgHex: "#e8dff7", rotation: 0.3),

        KeyFrame(petals: 8, shape: .wavy,     baseRadius: 56, layerGap: 20,
                 layerColors: [Color(hex:"#4466bb"), Color(hex:"#6688cc"), Color(hex:"#88aadd")],
                 layerSpeeds: [0.009, 0.006, 0.003],
                 glowColor: Color(hex:"#6699dd"), bgHex: "#242d44", lightBgHex: "#d8e6f8", rotation: 0.1),

        KeyFrame(petals: 7, shape: .wavy,     baseRadius: 54, layerGap: 18,
                 layerColors: [Color(hex:"#5577aa"), Color(hex:"#7799bb"), Color(hex:"#99bbcc")],
                 layerSpeeds: [0.007, 0.005, 0.003],
                 glowColor: Color(hex:"#99bbdd"), bgHex: "#2a3340", lightBgHex: "#d4e4f0", rotation: 0.0),

        KeyFrame(petals: 5, shape: .circle,   baseRadius: 60, layerGap: 26,
                 layerColors: [Color(hex:"#6699aa"), Color(hex:"#88aabc"), Color(hex:"#aaccd0")],
                 layerSpeeds: [0.005, 0.003, 0.002],
                 glowColor: Color(hex:"#aaccee"), bgHex: "#2c3840", lightBgHex: "#cce8f0", rotation: 0.0),

        KeyFrame(petals: 5, shape: .pentagon, baseRadius: 52, layerGap: 20,
                 layerColors: [Color(hex:"#559933"), Color(hex:"#77bb44"), Color(hex:"#aadd66")],
                 layerSpeeds: [0.006, 0.004, 0.003],
                 glowColor: Color(hex:"#aadd66"), bgHex: "#243020", lightBgHex: "#d4f0c4", rotation: -0.31),

        KeyFrame(petals: 5, shape: .star,     baseRadius: 54, layerGap: 22,
                 layerColors: [Color(hex:"#99bb00"), Color(hex:"#bbcc22"), Color(hex:"#ddee44")],
                 layerSpeeds: [0.008, 0.005, 0.003],
                 glowColor: Color(hex:"#ddf000"), bgHex: "#2d3010", lightBgHex: "#eef5c0", rotation: -0.31),

        KeyFrame(petals: 5, shape: .flower,   baseRadius: 55, layerGap: 22,
                 layerColors: [Color(hex:"#cc5520"), Color(hex:"#e07838"), Color(hex:"#f0a060")],
                 layerSpeeds: [0.010, 0.006, 0.004],
                 glowColor: Color(hex:"#ffbb66"), bgHex: "#3c2a18", lightBgHex: "#fce0c8", rotation: 0.0),
    ]

    static let labels = [
        "Very Unpleasant", "Unpleasant", "Slightly Unpleasant",
        "Neutral",
        "Slightly Pleasant", "Pleasant", "Very Pleasant"
    ]

    static func label(for t: Double) -> String {
        let idx = Int((t * Double(labels.count - 1)).rounded())
        return labels[max(0, min(labels.count - 1, idx))]
    }

    static func bgColor(for t: Double, colorScheme: ColorScheme = .dark) -> UIColor {
        let (lo, hi, frac) = keyframeNeighbours(t)
        let ef = smoothstep(frac)
        let loHex = colorScheme == .light ? keyframes[lo].lightBgHex : keyframes[lo].bgHex
        let hiHex = colorScheme == .light ? keyframes[hi].lightBgHex : keyframes[hi].bgHex
        return UIColor(Color(hex: loHex))
            .interpolated(to: UIColor(Color(hex: hiHex)), fraction: ef)
    }

    static func interpolated(at t: Double, time: Double) -> MoodSliderConfig {
        let (lo, hi, frac) = keyframeNeighbours(t)
        let ef = smoothstep(frac)

        let a = keyframes[lo]
        let b = keyframes[hi]

        func lerpD(_ x: Double, _ y: Double) -> Double { x + (y - x) * ef }
        func lerpC(_ c1: Color, _ c2: Color) -> Color {
            Color(UIColor(c1).interpolated(to: UIColor(c2), fraction: ef))
        }

        return MoodSliderConfig(
            shapeA:      a.shape,
            shapeB:      b.shape,
            shapeFrac:   ef,
            petalsA:     a.petals,
            petalsB:     b.petals,
            baseRadius:  lerpD(a.baseRadius, b.baseRadius),
            layerGap:    lerpD(a.layerGap,   b.layerGap),
            layerColors: zip(a.layerColors, b.layerColors).map { lerpC($0.0, $0.1) },
            layerSpeeds: zip(a.layerSpeeds, b.layerSpeeds).map { lerpD($0.0, $0.1) },
            glowColor:   lerpC(a.glowColor, b.glowColor),
            bgHex:       a.bgHex,
            rotation:    lerpD(a.rotation, b.rotation)
        )
    }

    private static func smoothstep(_ t: Double) -> Double {
        let t = max(0, min(1, t))
        return t * t * (3 - 2 * t)
    }

    private static func keyframeNeighbours(_ t: Double) -> (Int, Int, Double) {
        let n   = Double(keyframes.count - 1)
        let raw = t * n
        let lo  = max(0, min(keyframes.count - 2, Int(raw)))
        return (lo, lo + 1, raw - Double(lo))
    }
}

// MARK: - Keyframe value type

extension MoodSliderConfig {
    struct KeyFrame {
        var petals: Double
        var shape: MoodShapeKind
        var baseRadius: Double
        var layerGap: Double
        var layerColors: [Color]
        var layerSpeeds: [Double]
        var glowColor: Color
        var bgHex: String
        var lightBgHex: String
        var rotation: Double
    }
}

// MARK: - Colour helpers

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension UIColor {
    func interpolated(to other: UIColor, fraction: Double) -> UIColor {
        var r1: CGFloat=0, g1: CGFloat=0, b1: CGFloat=0, a1: CGFloat=0
        var r2: CGFloat=0, g2: CGFloat=0, b2: CGFloat=0, a2: CGFloat=0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let f = CGFloat(fraction)
        return UIColor(red:   r1 + (r2 - r1) * f,
                       green: g1 + (g2 - g1) * f,
                       blue:  b1 + (b2 - b1) * f,
                       alpha: a1 + (a2 - a1) * f)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var mood: Mood = .okay
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            MoodSliderView(mood: $mood)
                .padding()
            Text("Selected: \(mood.label)")
                .foregroundStyle(.white)
        }
    }
}

struct MoodIcon: View {
    let mood: Mood
    var size: CGFloat = 44
    var animated: Bool = false

    @State private var time: Double = 0
    @State private var timer: Timer?

    private var sliderPos: Double {
        switch mood {
        case .terrible: return 0.00
        case .bad:      return 0.16
        case .okay:     return 0.50
        case .good:     return 0.76
        case .great:    return 1.00
        }
    }

    var body: some View {
        Canvas { context, canvasSize in
            let scale = Double(canvasSize.width) / 240.0
            let cx = canvasSize.width / 2
            let cy = canvasSize.height / 2

            var cfg = MoodSliderConfig.interpolated(at: sliderPos, time: time)
            cfg.baseRadius *= scale
            cfg.layerGap   *= scale

            let breathe = 1.0 + 0.045 * sin(time * 0.5 * .pi * 2 / 4.0)
            cfg.baseRadius *= breathe

            let glowR = cfg.outerRadius * 1.35
            var glow = context
            glow.addFilter(.blur(radius: glowR * 0.45))
            let glowPath = Path(ellipseIn: CGRect(
                x: cx - glowR, y: cy - glowR,
                width: glowR * 2, height: glowR * 2))
            glow.fill(glowPath, with: .color(cfg.glowColor.opacity(0.25)))

            let layerCount = 2
            for li in stride(from: layerCount - 1, through: 0, by: -1) {
                let r      = cfg.baseRadius + cfg.layerGap * Double(li)
                let alpha  = [1.0, 0.5, 0.28][li]
                let speed  = cfg.layerSpeeds[li]
                let rotOff = cfg.rotation + time * speed
                let color  = cfg.layerColors[min(li, cfg.layerColors.count - 1)]

                let path = organicPath(cx: cx, cy: cy, radius: r,
                                       cfg: cfg, rotation: rotOff,
                                       time: time, layerIndex: li)

                context.fill(path, with: .color(color.opacity(alpha)))
                var stroke = context
                stroke.opacity = alpha * 0.6
                stroke.stroke(path, with: .color(.white.opacity(0.55)), lineWidth: 1.2 * scale)
            }

            let innerR    = cfg.baseRadius * 0.35
            let innerPath = Path(ellipseIn: CGRect(
                x: cx - innerR, y: cy - innerR,
                width: innerR * 2, height: innerR * 2))
            context.fill(innerPath, with: .color(cfg.layerColors[0].opacity(0.55)))

            let dotR    = 4.0 * scale
            let dotPath = Path(ellipseIn: CGRect(
                x: cx - dotR, y: cy - dotR,
                width: dotR * 2, height: dotR * 2))
            context.fill(dotPath, with: .color(.white.opacity(0.65)))
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .onAppear {
            guard animated else { return }
            timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
                time += 1/60
            }
            RunLoop.main.add(timer!, forMode: .common)
        }
        .onDisappear { timer?.invalidate() }
    }

    private func organicPath(cx: Double, cy: Double, radius: Double,
                              cfg: MoodSliderConfig, rotation: Double,
                              time: Double, layerIndex: Int) -> Path {
        let steps = 120
        var points: [CGPoint] = []
        for i in 0...steps {
            let angle = (Double(i) / Double(steps)) * .pi * 2 + rotation
            let r = blendedRadius(base: radius, cfg: cfg, angle: angle,
                                  time: time, layer: layerIndex)
            points.append(CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r))
        }
        var path = Path()
        path.move(to: points[0])
        for i in 1..<points.count {
            let prev = points[i - 1], curr = points[i]
            let mid  = CGPoint(x: (prev.x + curr.x) / 2, y: (prev.y + curr.y) / 2)
            path.addQuadCurve(to: mid, control: prev)
        }
        path.closeSubpath()
        return path
    }

    private func blendedRadius(base: Double, cfg: MoodSliderConfig,
                                angle: Double, time: Double, layer: Int) -> Double {
        let rA = shapeRadius(base: base, petals: cfg.petalsA, shape: cfg.shapeA,
                             angle: angle, time: time, layer: layer)
        let rB = shapeRadius(base: base, petals: cfg.petalsB, shape: cfg.shapeB,
                             angle: angle, time: time, layer: layer)
        return rA + (rB - rA) * cfg.shapeFrac
    }

    private func shapeRadius(base: Double, petals: Double, shape: MoodShapeKind,
                              angle: Double, time: Double, layer: Int) -> Double {
        switch shape {
        case .circle:
            return base
        case .flower:
            return base * (1.0 + 0.22 * cos(petals * angle + time * 0.3))
        case .wavy:
            return base * (1.0 + 0.18 * cos(petals * angle + time * 0.4)
                               + 0.06 * cos(petals * 2 * angle - time * 0.2))
        case .pointed:
            return base * (1.0 + 0.28 * cos(petals * angle + time * 0.25)
                               + 0.05 * cos(petals * 2 * angle + time * 0.1))
        case .star:
            return base * (1.0 + 0.30 * cos(petals * (angle - .pi / 2) + time * 0.2))
        case .pentagon:
            return base * (1.0 + 0.14 * cos(petals * (angle - .pi / 2) + time * 0.3))
        }
    }
}
