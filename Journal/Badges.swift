import SwiftUI

/// Front-facing renders of the bundled USDZ medals; no 3D work is done while scrolling.
private struct MedalIcon: View {
    let assetName: String
    let size: CGFloat
    var body: some View {
        Image(assetName)
            .renderingMode(.original)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

// MARK: - New Beginnings Badge (green circle with sprout)
struct NewBeginningsBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-beganSomething", size: size) }
}

// MARK: - Mindfulness Badge (navy octagram with seed of life)
struct MindfulnessBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-practicedMindfulness", size: size) }
}

// MARK: - Overcoming Difficulty Badge (dark chevron shield)
struct OvercomingDifficultyBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-handledDifficulty", size: size) }
}

// MARK: - Rest Well Badge (blue circle with crescent moon + ZZZ)
struct RestWellBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-prioritisedSleep", size: size) }
}

// MARK: - Made Connections Badge (silver coin with interlocking rings)
struct MadeConnectionsBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-connectedWithSomeone", size: size) }
}

// MARK: - Made Amends Badge (purple globe with grid lines)
struct MadeAmendsBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-madeAmends", size: size) }
}

// MARK: - Reached Out Badge (purple dial/knob)
struct ReachedOutBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-askedForHelp", size: size) }
}
// MARK: - Finished Tasks Badge (gold coin with checkmark)
struct FinishedTasksBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-finishedSomething", size: size) }
}

// MARK: - Goal Achieved Badge (rosy gold bullseye)
struct GoalAchievedBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-celebratedAWin", size: size) }
}

struct ComfortZoneBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-steppedOutsideComfort", size: size) }
}

struct RocketFinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

// MARK: - Stayed Active Badge (green rounded square with runner)
struct StayedActiveBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-movedYourBody", size: size) }
}

// MARK: - Created Something Badge
struct CreatedSomethingBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-createdSomething", size: size) }
}
struct HelpedOthersBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-helpedOthers", size: size) }
}

struct NourishedYourselfBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-ateWell", size: size) }
}

struct ReachedOutFirstBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-reachedOutFirst", size: size) }
}

struct FedCuriosityBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-learnedSomethingNew", size: size) }
}

struct TouchedGrassBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-spentTimeInNature", size: size) }
}

struct DisconnectedFromScreensBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-disconnectedFromScreens", size: size) }
}

struct SatWithUncertaintyBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-satWithUncertainty", size: size) }
}

struct SleptWithoutGuiltBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-restedWithoutGuilt", size: size) }
}

struct KeptGoingBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-keptGoing", size: size) }
}

// MARK: - Supporting shapes

struct MountainShape: Shape {
    var peakX: CGFloat
    var peakY: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w * peakX, y: h * peakY))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
    }
}

struct SnowCapShape: Shape {
    var peakX: CGFloat
    var peakY: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let capHeight = h * 0.08
        path.move(to: CGPoint(x: w * peakX, y: h * peakY))
        path.addLine(to: CGPoint(x: w * peakX - w * 0.08, y: h * peakY + capHeight))
        path.addLine(to: CGPoint(x: w * peakX + w * 0.08, y: h * peakY + capHeight))
        path.closeSubpath()
        return path
    }
}
struct SaidNoBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-saidNo", size: size) }
}

struct SetBoundariesBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-setABoundary", size: size) }
}

// MARK: - Showed Up For Yourself
struct ShowedUpForYourselfBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-showedUpForYourself", size: size) }
}

// MARK: - Forgiving Yourself
struct ForgivingYourselfBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-forgivingYourself", size: size) }
}

// MARK: - Cried It Out
struct CriedItOutBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-criedItOut", size: size) }
}

// MARK: - Blew Up The Microwave
struct BlewUpMicrowaveBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-blewUpMicrowave", size: size) }
}

// MARK: - Sang In The Shower
struct SangInTheShowerBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-sangInTheShower", size: size) }
}

// MARK: - Heroic Napper
struct HeroicNapperBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-heroicNapper", size: size) }
}

// MARK: - Doom Scrolled
struct DoomScrolledBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-doomScrolled", size: size) }
}

// MARK: - Lost A Sock
struct LostASockBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-lostASock", size: size) }
}

// MARK: - Breakfast Pizza Badge
struct BreakfastPizzaBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-breakfastPizza", size: size) }
}

// MARK: - Autocorrect Disaster
struct AutocorrectDisasterBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-autocorrectDisaster", size: size) }
}

// MARK: - Remembered A Dream
struct RememberedADreamBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-rememberedADream", size: size) }
}

// MARK: - Guessed Time Correctly
struct GuessedTimeCorrectlyBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-guessedTimeCorrectly", size: size) }
}

// MARK: - Dropped Phone On Face
struct DroppedPhoneOnFaceBadge: View {
    var size: CGFloat = 60
    var body: some View { MedalIcon(assetName: "Medal2D-droppedPhoneOnFace", size: size) }
}

// MARK: - Supporting Shapes

struct TeardropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX, cy = rect.midY
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: cx, y: cy - h / 2))
        path.addCurve(to: CGPoint(x: cx + w / 2, y: cy + h * 0.15),
                      control1: CGPoint(x: cx + w * 0.55, y: cy - h * 0.35),
                      control2: CGPoint(x: cx + w / 2, y: cy))
        path.addQuadCurve(to: CGPoint(x: cx - w / 2, y: cy + h * 0.15),
                          control: CGPoint(x: cx, y: cy + h / 2))
        path.addCurve(to: CGPoint(x: cx, y: cy - h / 2),
                      control1: CGPoint(x: cx - w / 2, y: cy),
                      control2: CGPoint(x: cx - w * 0.55, y: cy - h * 0.35))
        path.closeSubpath()
        return path
    }
}

struct HalfCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.minY),
                    radius: rect.width / 2,
                    startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct SockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let ox = rect.minX, oy = rect.minY
        path.move(to: CGPoint(x: ox + w * 0.25, y: oy))
        path.addLine(to: CGPoint(x: ox + w * 0.75, y: oy))
        path.addLine(to: CGPoint(x: ox + w * 0.75, y: oy + h * 0.65))
        path.addCurve(to: CGPoint(x: ox + w, y: oy + h * 0.85),
                      control1: CGPoint(x: ox + w * 0.75, y: oy + h * 0.78),
                      control2: CGPoint(x: ox + w, y: oy + h * 0.78))
        path.addLine(to: CGPoint(x: ox + w, y: oy + h))
        path.addLine(to: CGPoint(x: ox + w * 0.40, y: oy + h))
        path.addCurve(to: CGPoint(x: ox + w * 0.25, y: oy + h * 0.65),
                      control1: CGPoint(x: ox + w * 0.25, y: oy + h * 0.90),
                      control2: CGPoint(x: ox + w * 0.25, y: oy + h * 0.78))
        path.addLine(to: CGPoint(x: ox + w * 0.25, y: oy))
        path.closeSubpath()
        return path
    }
}

struct PizzaSliceShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX, cy = rect.maxY
        let r = rect.height
        path.move(to: CGPoint(x: cx, y: cy - r))
        path.addArc(center: CGPoint(x: cx, y: cy),
                    radius: r,
                    startAngle: .degrees(-105), endAngle: .degrees(-75), clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct TrapezoidShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let ox = rect.minX, oy = rect.minY
        path.move(to: CGPoint(x: ox + w * 0.15, y: oy))
        path.addLine(to: CGPoint(x: ox + w * 0.85, y: oy))
        path.addLine(to: CGPoint(x: ox + w, y: oy + h))
        path.addLine(to: CGPoint(x: ox, y: oy + h))
        path.closeSubpath()
        return path
    }
}

struct MeltingBlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX, cy = rect.midY
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: cx - w * 0.35, y: cy - h * 0.20))
        path.addCurve(to: CGPoint(x: cx + w * 0.35, y: cy - h * 0.15),
                      control1: CGPoint(x: cx - w * 0.10, y: cy - h * 0.50),
                      control2: CGPoint(x: cx + w * 0.10, y: cy - h * 0.50))
        path.addCurve(to: CGPoint(x: cx + w * 0.40, y: cy + h * 0.30),
                      control1: CGPoint(x: cx + w * 0.55, y: cy),
                      control2: CGPoint(x: cx + w * 0.55, y: cy + h * 0.20))
        path.addCurve(to: CGPoint(x: cx, y: cy + h * 0.50),
                      control1: CGPoint(x: cx + w * 0.20, y: cy + h * 0.50),
                      control2: CGPoint(x: cx + w * 0.10, y: cy + h * 0.55))
        path.addCurve(to: CGPoint(x: cx - w * 0.45, y: cy + h * 0.20),
                      control1: CGPoint(x: cx - w * 0.20, y: cy + h * 0.45),
                      control2: CGPoint(x: cx - w * 0.40, y: cy + h * 0.40))
        path.addCurve(to: CGPoint(x: cx - w * 0.35, y: cy - h * 0.20),
                      control1: CGPoint(x: cx - w * 0.55, y: cy),
                      control2: CGPoint(x: cx - w * 0.55, y: cy - h * 0.10))
        path.closeSubpath()
        return path
    }
}

struct IceCreamConeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: cx, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct OctagonShape: InsettableShape {
    var insetAmount: CGFloat = 0
    func inset(by amount: CGFloat) -> OctagonShape { OctagonShape(insetAmount: insetAmount + amount) }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = min(rect.width, rect.height) / 2 - insetAmount
        let cx = rect.midX, cy = rect.midY
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4 - .pi / 2
            let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}

struct DodecagonShape: InsettableShape {
    var insetAmount: CGFloat = 0
    func inset(by amount: CGFloat) -> DodecagonShape { DodecagonShape(insetAmount: insetAmount + amount) }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = min(rect.width, rect.height) / 2 - insetAmount
        let cx = rect.midX, cy = rect.midY
        for i in 0..<12 {
            let angle = Double(i) * (2 * .pi / 12) - .pi / 2
            let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}

struct TerrainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.65))
        path.addCurve(
            to: CGPoint(x: w * 0.30, y: h * 0.52),
            control1: CGPoint(x: w * 0.10, y: h * 0.65),
            control2: CGPoint(x: w * 0.20, y: h * 0.58)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.45),
            control1: CGPoint(x: w * 0.38, y: h * 0.48),
            control2: CGPoint(x: w * 0.44, y: h * 0.45)
        )
        path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.38))
        path.addLine(to: CGPoint(x: w, y: h * 0.38))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
    }
}

struct WaveHorizonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let midY = h * 0.52
        let amp = h * 0.07

        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: midY))
        path.addCurve(
            to: CGPoint(x: w * 0.25, y: midY - amp),
            control1: CGPoint(x: w * 0.05, y: midY),
            control2: CGPoint(x: w * 0.15, y: midY - amp)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.42, y: midY),
            control1: CGPoint(x: w * 0.32, y: midY - amp),
            control2: CGPoint(x: w * 0.38, y: midY)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.58, y: midY - amp * 1.3),
            control1: CGPoint(x: w * 0.48, y: midY),
            control2: CGPoint(x: w * 0.52, y: midY - amp * 1.3)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.72, y: midY),
            control1: CGPoint(x: w * 0.64, y: midY - amp * 1.3),
            control2: CGPoint(x: w * 0.68, y: midY)
        )
        path.addCurve(
            to: CGPoint(x: w, y: midY),
            control1: CGPoint(x: w * 0.82, y: midY),
            control2: CGPoint(x: w * 0.92, y: midY)
        )
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
    }
}

struct StarShape: Shape {
    let points: Int
    let innerRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX, cy = rect.midY
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * innerRatio
        let step = Double.pi * 2 / Double(points)
        let startAngle = -Double.pi / 2

        for i in 0..<points {
            let outerAngle = startAngle + Double(i) * step
            let innerAngle = outerAngle + step / 2

            let outerPt = CGPoint(x: cx + outerR * cos(outerAngle), y: cy + outerR * sin(outerAngle))
            let innerPt = CGPoint(x: cx + innerR * cos(innerAngle), y: cy + innerR * sin(innerAngle))

            if i == 0 { path.move(to: outerPt) } else { path.addLine(to: outerPt) }
            path.addLine(to: innerPt)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Hexagon

struct HexagonShape: InsettableShape {
    var insetAmount: CGFloat = 0
    func inset(by amount: CGFloat) -> HexagonShape { HexagonShape(insetAmount: insetAmount + amount) }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = min(rect.width, rect.height) / 2 - insetAmount
        let cx = rect.midX, cy = rect.midY
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 - .pi / 6
            let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Petal

struct PetalShape: Shape {
    let index: Int
    let total: Int
    let size: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY + size * 0.12
        let angleStep = (2 * Double.pi) / Double(total)
        let startAngle = Double(index) * angleStep - .pi / 2
        let endAngle = startAngle + angleStep

        path.move(to: CGPoint(x: cx, y: cy))
        path.addArc(
            center: CGPoint(x: cx, y: cy),
            radius: size * 0.58,
            startAngle: Angle(radians: startAngle),
            endAngle: Angle(radians: endAngle),
            clockwise: false
        )
        path.addQuadCurve(
            to: CGPoint(x: cx, y: cy),
            control: CGPoint(
                x: cx + size * 0.40 * cos(startAngle + angleStep * 1.4),
                y: cy + size * 0.40 * sin(startAngle + angleStep * 1.4)
            )
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Triangle (pencil tip)

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Supporting Shapes

struct OctagramShape: InsettableShape {
    var insetAmount: CGFloat = 0
    func inset(by amount: CGFloat) -> OctagramShape { OctagramShape(insetAmount: insetAmount + amount) }
    func path(in rect: CGRect) -> Path {
        let inset = insetAmount
        let r = min(rect.width, rect.height) / 2 - inset
        let cx = rect.midX, cy = rect.midY
        var path = Path()
        let sides = 8
        let extraRot = -Double.pi / 8
        let innerR = r * 0.72
        for i in 0..<sides {
            let outerAngle = Double(i) * 2 * .pi / Double(sides) + extraRot
            let innerAngle = outerAngle + .pi / Double(sides)
            let op = CGPoint(x: cx + r * cos(outerAngle), y: cy + r * sin(outerAngle))
            let ip = CGPoint(x: cx + innerR * cos(innerAngle), y: cy + innerR * sin(innerAngle))
            if i == 0 { path.move(to: op) } else { path.addLine(to: op) }
            path.addLine(to: ip)
        }
        path.closeSubpath()
        return path
    }
}

struct SeedOfLifeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX, cy = rect.midY
        let r = min(rect.width, rect.height) / 2
        path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3
            let ox = cx + r * cos(angle)
            let oy = cy + r * sin(angle)
            path.addEllipse(in: CGRect(x: ox - r, y: oy - r, width: r * 2, height: r * 2))
        }
        return path
    }
}

struct ShieldShape: InsettableShape {
    var insetAmount: CGFloat = 0
    func inset(by amount: CGFloat) -> ShieldShape { ShieldShape(insetAmount: insetAmount + amount) }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let i = insetAmount
        let w = rect.width - i * 2
        let h = rect.height - i * 2
        let ox = rect.minX + i
        let oy = rect.minY + i
        let r = w * 0.18

        path.move(to: CGPoint(x: ox + r, y: oy))
        path.addLine(to: CGPoint(x: ox + w - r, y: oy))
        path.addQuadCurve(to: CGPoint(x: ox + w, y: oy + r),
                          control: CGPoint(x: ox + w, y: oy))
        path.addLine(to: CGPoint(x: ox + w, y: oy + h * 0.55))
        path.addCurve(to: CGPoint(x: ox + w * 0.50, y: oy + h),
                      control1: CGPoint(x: ox + w, y: oy + h * 0.80),
                      control2: CGPoint(x: ox + w * 0.75, y: oy + h))
        path.addCurve(to: CGPoint(x: ox, y: oy + h * 0.55),
                      control1: CGPoint(x: ox + w * 0.25, y: oy + h),
                      control2: CGPoint(x: ox, y: oy + h * 0.80))
        path.addLine(to: CGPoint(x: ox, y: oy + r))
        path.addQuadCurve(to: CGPoint(x: ox + r, y: oy),
                          control: CGPoint(x: ox, y: oy))
        path.closeSubpath()
        return path
    }
}
struct PentagonShape: InsettableShape {
    var insetAmount: CGFloat = 0
    func inset(by amount: CGFloat) -> PentagonShape { PentagonShape(insetAmount: insetAmount + amount) }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset = insetAmount
        let r = min(rect.width, rect.height) / 2 - inset
        let cx = rect.midX, cy = rect.midY
        for i in 0..<5 {
            let angle = Double(i) * 2 * .pi / 5 - .pi / 2
            let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}

struct GlobeLines: Shape {
    var size: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX, cy = rect.midY
        let r = min(rect.width, rect.height) / 2
        path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        path.move(to: CGPoint(x: cx - r, y: cy))
        path.addLine(to: CGPoint(x: cx + r, y: cy))
        path.move(to: CGPoint(x: cx + r * 0.35, y: cy - r))
        path.addLine(
            to: CGPoint(x: cx + r * 0.35, y: cy + r)
        )
        return path
    }
}

struct ChevronMark: View {
    var size: CGFloat
    var body: some View {
        Image(systemName: "chevron.up")
            .resizable()
            .scaledToFit()
            .fontWeight(.bold)
            .foregroundStyle(Color(red: 0.52, green: 0.07, blue: 0.07))
            .frame(width: size * 0.46, height: size * 0.20)
    }
}

struct RocketFlame: View {
    var size: CGFloat
    var body: some View {
        ZStack {
            ForEach(0..<5) { i in
                let angle = Angle.degrees(-90 + Double(i) * 36)
                RoundedRectangle(cornerRadius: 1)
                    .fill(i % 2 == 0 ? Color(red: 0.85, green: 0.72, blue: 0.08) : Color(red: 0.75, green: 0.10, blue: 0.55))
                    .frame(width: size * 0.06, height: size * 0.14)
                    .offset(y: -size * 0.04)
                    .rotationEffect(angle)
            }
        }
        .frame(width: size * 0.30, height: size * 0.14)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            Text("Achievement Badges").font(.title2.bold()).padding(.top)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 24) {
                BadgeCell(badge: AnyView(NewBeginningsBadge(size: 70)),    label: "New Beginnings")
                BadgeCell(badge: AnyView(MindfulnessBadge(size: 70)),      label: "Mindfulness")
                BadgeCell(badge: AnyView(OvercomingDifficultyBadge(size: 70)), label: "Overcoming Difficulty")
                BadgeCell(badge: AnyView(RestWellBadge(size: 70)),         label: "Rest Well")
                BadgeCell(badge: AnyView(MadeConnectionsBadge(size: 70)),  label: "Made Connections")
                BadgeCell(badge: AnyView(MadeAmendsBadge(size: 70)),       label: "Made Amends")
                BadgeCell(badge: AnyView(ReachedOutBadge(size: 70)),       label: "Reached Out")
                BadgeCell(badge: AnyView(FinishedTasksBadge(size: 70)),    label: "Finished Tasks")
                BadgeCell(badge: AnyView(GoalAchievedBadge(size: 70)),     label: "Goal Achieved")
                BadgeCell(badge: AnyView(ComfortZoneBadge(size: 70)),      label: "Comfort Zone")
                BadgeCell(badge: AnyView(StayedActiveBadge(size: 70)),     label: "Stayed Active")
            }
            .padding()
        }
    }
}

private struct BadgeCell: View {
    let badge: AnyView
    let label: String
    var body: some View {
        VStack(spacing: 8) {
            badge
            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }
}
