import SwiftUI

// MARK: - New Beginnings Badge (green circle with sprout)
struct NewBeginningsBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.45, green: 0.62, blue: 0.45))
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.90, blue: 0.55),
                            Color(red: 0.05, green: 0.35, blue: 0.25),
                            Color(red: 0.10, green: 0.75, blue: 0.45)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.08)
            Image(systemName: "leaf.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(red: 0.08, green: 0.25, blue: 0.09))
                .frame(width: size * 0.42, height: size * 0.42)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Mindfulness Badge (navy octagram with seed of life)
struct MindfulnessBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            OctagramShape()
                .fill(Color(red: 0.18, green: 0.20, blue: 0.52))
            
            OctagramShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.60, blue: 0.92),
                            Color(red: 0.18, green: 0.20, blue: 0.48)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .scaleEffect(0.72)
            
            OctagramShape()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.60, blue: 0.92),
                            Color(red: 0.18, green: 0.20, blue: 0.48)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.03)
            
            SeedOfLifeShape()
                .stroke(Color(red: 0.18, green: 0.15, blue: 0.52), lineWidth: size * 0.03)
                .frame(width: size * 0.2, height: size * 0.2)
            
            SeedOfLifeShape()
                .stroke(Color(red: 0.40, green: 0.45, blue: 0.80).opacity(0.35), lineWidth: size * 0.012)
                .frame(width: size * 0.2, height: size * 0.2)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Overcoming Difficulty Badge (dark chevron shield)
struct OvercomingDifficultyBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            ShieldShape()
                .fill(Color(red: 0.55, green: 0.55, blue: 0.57))
            ShieldShape()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 0.70, green: 0.12, blue: 0.10), Color(red: 0.40, green: 0.05, blue: 0.05)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.06)
            VStack(spacing: size * 0.04) {
                ChevronMark(size: size)
                ChevronMark(size: size)
            }
            .offset(y: -size * 0.04)
        }
        .frame(width: size, height: size * 1.15)
    }
}

// MARK: - Rest Well Badge (blue circle with crescent moon + ZZZ)
struct RestWellBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.18, green: 0.30, blue: 0.60))
            ZStack {
                Circle()
                    .fill(Color(red: 0.85, green: 0.68, blue: 0.10))
                    .frame(width: size * 0.82, height: size * 0.82)
                Circle()
                    .fill(Color(red: 0.18, green: 0.30, blue: 0.60))
                    .frame(width: size * 0.68, height: size * 0.68)
                    .offset(x: size * 0.20, y: -size * 0.05)
            }
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 0.30, green: 0.50, blue: 0.90), Color(red: 0.10, green: 0.20, blue: 0.50)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.06)
            ZStack {
                Text("z")
                    .font(.system(size: size * 0.14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.65, green: 0.70, blue: 0.90))
                    .offset(x: size * 0.15, y: -size * 0.20)
                Text("z")
                    .font(.system(size: size * 0.19, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.65, green: 0.70, blue: 0.90))
                    .offset(x: size * 0.25, y: -size * 0.10)
                Text("Z")
                    .font(.system(size: size * 0.26, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.65, green: 0.70, blue: 0.90))
                    .offset(x: size * 0.12, y: size * 0.08)
            }
            .offset(y: -size * 0.06)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - Made Connections Badge (silver coin with interlocking rings)
struct MadeConnectionsBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.72, green: 0.72, blue: 0.72))
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 0.92, green: 0.88, blue: 0.70), Color(red: 0.60, green: 0.58, blue: 0.45)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.08)
            HStack(spacing: -size * 0.12) {
                Circle()
                    .stroke(Color(red: 0.38, green: 0.38, blue: 0.36), lineWidth: size * 0.05)
                    .frame(width: size * 0.42, height: size * 0.42)
                Circle()
                    .stroke(Color(red: 0.38, green: 0.38, blue: 0.36), lineWidth: size * 0.05)
                    .frame(width: size * 0.42, height: size * 0.42)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Made Amends Badge (purple globe with grid lines)
struct MadeAmendsBadge: View {
    var size: CGFloat = 60
 
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.82, green: 0.78, blue: 0.86))
            GlobeLines(size: size * 0.5)
                .stroke(Color(red: 0.28, green: 0.05, blue: 0.40), lineWidth: size * 0.04)
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 0.70, green: 0.10, blue: 0.95), Color(red: 0.38, green: 0.05, blue: 0.55)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.08)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Reached Out Badge (purple dial/knob)
struct ReachedOutBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.55, green: 0.45, blue: 0.90))
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 0.75, green: 0.20, blue: 1.0), Color(red: 0.35, green: 0.05, blue: 0.65)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.08)

            Path { path in
                path.addArc(
                    center: CGPoint(x: size / 2, y: size / 2),
                    radius: size * 0.35,
                    startAngle: .degrees(0),
                    endAngle: .degrees(270),
                    clockwise: false
                )
            }
            .stroke(Color(red: 0.28, green: 0.10, blue: 0.55), lineWidth: size * 0.06)

            Path { path in
                path.addArc(
                    center: CGPoint(x: size / 2, y: size / 2),
                    radius: size * 0.35,
                    startAngle: .degrees(270),
                    endAngle: .degrees(360),
                    clockwise: false
                )
            }
            .stroke(
                Color(red: 0.28, green: 0.10, blue: 0.55),
                style: StrokeStyle(lineWidth: size * 0.06, dash: [size * 0.03, size * 0.03])
            )
        }
        .frame(width: size, height: size)
    }
}
// MARK: - Finished Tasks Badge (gold coin with checkmark)
struct FinishedTasksBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.82, green: 0.74, blue: 0.52))
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.88, blue: 0.60), Color(red: 0.60, green: 0.52, blue: 0.28)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.07)
            Image(systemName: "checkmark")
                .resizable()
                .scaledToFit()
                .fontWeight(.medium)
                .foregroundStyle(Color(red: 0.25, green: 0.22, blue: 0.12))
                .frame(width: size * 0.44, height: size * 0.44)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Goal Achieved Badge (rosy gold bullseye)
struct GoalAchievedBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.68, green: 0.60, blue: 0.62))
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.62, blue: 0.62), Color(red: 0.50, green: 0.30, blue: 0.32)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.07)
            Circle()
                .fill(Color(red: 0.48, green: 0.28, blue: 0.30))
                .frame(width: size * 0.72, height: size * 0.72)
            Circle()
                .fill(Color(red: 0.68, green: 0.60, blue: 0.62))
                .frame(width: size * 0.50, height: size * 0.50)
            Circle()
                .fill(Color(red: 0.48, green: 0.28, blue: 0.30))
                .frame(width: size * 0.28, height: size * 0.28)
        }
        .frame(width: size, height: size)
    }
}

struct ComfortZoneBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            PentagonShape()
                .fill(Color(red: 0.88, green: 0.68, blue: 0.68))
            PentagonShape()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.20, blue: 0.18), Color(red: 0.52, green: 0.08, blue: 0.08)],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.05)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.72, green: 0.72, blue: 0.80)],
                        startPoint: .leading, endPoint: .trailing)
                )
                .frame(width: size * 0.22, height: size * 0.42)
                .offset(y: -size * 0.04)

            Triangle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.75, green: 0.15, blue: 0.15), Color(red: 0.50, green: 0.05, blue: 0.05)],
                        startPoint: .top, endPoint: .bottom)
                )
                .frame(width: size * 0.22, height: size * 0.16)
                .scaleEffect(x: 1, y: -1)
                .offset(y: -size * 0.23)

            RocketFinShape()
                .fill(Color(red: 0.70, green: 0.12, blue: 0.12))
                .frame(width: size * 0.14, height: size * 0.16)
                .offset(x: -size * 0.14, y: size * 0.14)

            RocketFinShape()
                .fill(Color(red: 0.70, green: 0.12, blue: 0.12))
                .frame(width: size * 0.14, height: size * 0.16)
                .scaleEffect(x: -1, y: 1)
                .offset(x: size * 0.14, y: size * 0.14)

            Circle()
                .fill(Color(red: 0.55, green: 0.80, blue: 0.95))
                .frame(width: size * 0.10, height: size * 0.10)
                .offset(y: -size * 0.06)
            Circle()
                .stroke(Color(red: 0.40, green: 0.40, blue: 0.50), lineWidth: size * 0.015)
                .frame(width: size * 0.10, height: size * 0.10)
                .offset(y: -size * 0.06)

            TeardropShape()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.85, blue: 0.20), Color(red: 0.95, green: 0.40, blue: 0.05)],
                        startPoint: .top, endPoint: .bottom)
                )
                .frame(width: size * 0.14, height: size * 0.18)
                .rotationEffect(.degrees(180))
                .offset(y: size * 0.26)

            TeardropShape()
                .fill(Color.white.opacity(0.75))
                .frame(width: size * 0.06, height: size * 0.09)
                .rotationEffect(.degrees(180))
                .offset(y: size * 0.24)
        }
        .frame(width: size, height: size * 1.1)
        .scaleEffect(0.82)
        .offset(y: -size * 0.04)
    }
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

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(Color(red: 0.45, green: 0.62, blue: 0.45))
            RoundedRectangle(cornerRadius: size * 0.18)
                .strokeBorder(
                    Color(red: 0.18, green: 0.32, blue: 0.15),
                    lineWidth: size * 0.07)
            RoundedRectangle(cornerRadius: size * 0.10)
                .stroke(Color(red: 0.18, green: 0.32, blue: 0.15), lineWidth: size * 0.04)
                .frame(width: size * 0.72, height: size * 0.72)
            Image(systemName: "figure.run")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(red: 0.10, green: 0.22, blue: 0.10))
                .frame(width: size * 0.40, height: size * 0.40)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Created Something Badge
struct CreatedSomethingBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            HexagonShape()
                .fill(Color(red: 0.92, green: 0.91, blue: 0.90))

            HexagonShape()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.88, blue: 0.55),
                            Color(red: 0.60, green: 0.45, blue: 0.18),
                            Color(red: 0.90, green: 0.82, blue: 0.48)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.08)

            Canvas { ctx, sz in
                let cx = sz.width / 2
                let cy = sz.height / 2
                let r  = sz.width * 0.50

                let petalColors: [Color] = [
                    Color(red: 0.65, green: 0.35, blue: 0.38),
                    Color(red: 0.88, green: 0.55, blue: 0.18),
                    Color(red: 0.72, green: 0.62, blue: 0.18),
                    Color(red: 0.32, green: 0.58, blue: 0.38),
                    Color(red: 0.52, green: 0.70, blue: 0.82),
                    Color(red: 0.28, green: 0.38, blue: 0.62),
                    Color(red: 0.62, green: 0.55, blue: 0.85),
                ]

                let count   = petalColors.count
                let slice   = (2.0 * .pi) / Double(count)
                let curl    = slice * 0.55

                for i in 0..<count {
                    let start = Double(i) * slice - .pi / 2
                    let end   = start + slice

                    let p1 = CGPoint(x: cx + cos(start + curl) * r,
                                     y: cy + sin(start + curl) * r)
                    let p2 = CGPoint(x: cx + cos(end   + curl) * r,
                                     y: cy + sin(end   + curl) * r)

                    let midAngle = start + slice / 2 + curl
                    let ctrl = CGPoint(x: cx + cos(midAngle) * r * 1.08,
                                       y: cy + sin(midAngle) * r * 1.08)

                    var petal = Path()
                    petal.move(to: CGPoint(x: cx, y: cy))
                    petal.addLine(to: p1)
                    petal.addQuadCurve(to: p2, control: ctrl)
                    petal.closeSubpath()

                    ctx.fill(petal, with: .color(petalColors[i]))

                    var sep = Path()
                    sep.move(to: CGPoint(x: cx, y: cy))
                    sep.addLine(to: p1)
                    ctx.stroke(sep, with: .color(.white.opacity(0.70)), lineWidth: size * 0.022)
                }
            }
            .frame(width: size * 0.82, height: size * 0.82)
            .clipShape(HexagonShape())

            RoundedRectangle(cornerRadius: size * 0.02)
                .fill(Color(red: 0.25, green: 0.35, blue: 0.65))
                .frame(width: size * 0.09, height: size * 0.40)
                .offset(y: -size * 0.05)

            Triangle()
                .fill(Color(red: 0.85, green: 0.68, blue: 0.66))
                .frame(width: size * 0.09, height: size * 0.07)
                .offset(y: size * 0.175)

            RoundedRectangle(cornerRadius: size * 0.01)
                .fill(Color(red: 0.88, green: 0.60, blue: 0.62))
                .frame(width: size * 0.09, height: size * 0.035)
                .offset(y: -size * 0.27)
        }
        .frame(width: size, height: size)
        .clipShape(HexagonShape())
    }
}
struct HelpedOthersBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            StarShape(points: 5, innerRatio: 0.42)
                .fill(
                    Color(red: 0.88, green: 0.72, blue: 0.30)
                )
            StarShape(points: 5, innerRatio: 0.42)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.85, blue: 0.30),
                            Color(red: 0.65, green: 0.55, blue: 0.10),
                            Color(red: 0.95, green: 0.85, blue: 0.30)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.04
                )
            StarShape(points: 5, innerRatio: 0.42)
                .stroke(Color(red: 0.20, green: 0.17, blue: 0.05), lineWidth: size * 0.03)
                .scaleEffect(0.42)
            ForEach(0..<5) { i in
                let angle = Double(i) * (2 * .pi / 5) - .pi / 2
                let innerR = size * 0.42 * 0.42 * 0.5
                let outerR = size * 0.42 * 0.5
                Path { path in
                    path.move(to: CGPoint(x: size / 2, y: size / 2))
                    path.addLine(to: CGPoint(
                        x: size / 2 + outerR * cos(angle),
                        y: size / 2 + outerR * sin(angle)
                    ))
                }
                .stroke(Color(red: 0.20, green: 0.17, blue: 0.05), lineWidth: size * 0.025)
            }
        }
        .frame(width: size, height: size)
    }
}

struct NourishedYourselfBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.72, green: 0.82, blue: 0.68))
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.20, green: 0.75, blue: 0.40),
                            Color(red: 0.05, green: 0.35, blue: 0.18),
                            Color(red: 0.15, green: 0.60, blue: 0.30)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.10)

            VStack(spacing: size * 0.04) {
                HStack(alignment: .bottom, spacing: size * 0.06) {
                    StarShape(points: 5, innerRatio: 0.42)
                        .fill(goldGradient)
                        .frame(width: size * 0.16, height: size * 0.16)
                    StarShape(points: 5, innerRatio: 0.42)
                        .fill(goldGradient)
                        .frame(width: size * 0.22, height: size * 0.22)
                    StarShape(points: 5, innerRatio: 0.42)
                        .fill(goldGradient)
                        .frame(width: size * 0.16, height: size * 0.16)
                }

                ZStack {
                    Ellipse()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.92, green: 0.92, blue: 0.92), Color(red: 0.75, green: 0.75, blue: 0.75)],
                                startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: size * 0.52, height: size * 0.24)
                        .offset(y: size * 0.04)
                    Ellipse()
                        .fill(Color(red: 0.05, green: 0.25, blue: 0.12))
                        .frame(width: size * 0.44, height: size * 0.10)
                        .offset(y: -size * 0.02)
                    Ellipse()
                        .fill(Color.white.opacity(0.60))
                        .frame(width: size * 0.52, height: size * 0.06)
                        .offset(y: -size * 0.02)
                }
            }
            .offset(y: size * 0.02)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var goldGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.85, blue: 0.30),
                Color(red: 0.55, green: 0.42, blue: 0.05)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }
}

struct ReachedOutFirstBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.32, green: 0.45, blue: 0.92))
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.65, blue: 1.00),
                            Color(red: 0.20, green: 0.28, blue: 0.75),
                            Color(red: 0.45, green: 0.55, blue: 0.95)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.10)
            Image(systemName: "envelope.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(red: 0.94, green: 0.93, blue: 0.90))
                .frame(width: size * 0.48, height: size * 0.48)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

struct FedCuriosityBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.38, green: 0.50, blue: 0.90),
                            Color(red: 0.28, green: 0.38, blue: 0.78)
                        ],
                        startPoint: .top, endPoint: .bottom)
                )
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.45, green: 0.52, blue: 0.90),
                            Color(red: 0.15, green: 0.18, blue: 0.55),
                            Color(red: 0.55, green: 0.60, blue: 0.95)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.10)

            Circle()
                .fill(Color(red: 0.98, green: 0.85, blue: 0.10).opacity(0.25))
                .frame(width: size * 0.24, height: size * 0.24)
                .offset(y: -size * 0.22)

            Image(systemName: "lightbulb.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(red: 0.98, green: 0.85, blue: 0.15))
                .frame(width: size * 0.18, height: size * 0.18)
                .offset(y: -size * 0.22)

            Image(systemName: "book.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(red: 1, green: 1, blue: 1))
                .frame(width: size * 0.38, height: size * 0.38)
                .offset(y: size * 0.10)        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

struct TouchedGrassBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            PentagonShape()
                .fill(Color(red: 0.45, green: 0.62, blue: 0.45))
            PentagonShape()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.90, blue: 0.55),
                            Color(red: 0.05, green: 0.35, blue: 0.25),
                            Color(red: 0.10, green: 0.75, blue: 0.45)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.09)
            Image(systemName: "tree.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(red: 0.08, green: 0.25, blue: 0.12))
                .frame(width: size * 0.44, height: size * 0.44)
                .offset(y: size * 0.04)
        }
        .frame(width: size, height: size)
    }
}

struct DisconnectedFromScreensBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.82, green: 0.82, blue: 0.84),
                            Color(red: 0.62, green: 0.62, blue: 0.65)
                        ],
                        startPoint: .top, endPoint: .bottom)
                )
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.85, blue: 0.45),
                            Color(red: 0.62, green: 0.48, blue: 0.15),
                            Color(red: 0.90, green: 0.80, blue: 0.40)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.09)

            ZStack {
                RoundedRectangle(cornerRadius: size * 0.06)
                    .fill(Color(red: 0.58, green: 0.65, blue: 0.85))
                    .frame(width: size * 0.28, height: size * 0.44)
                RoundedRectangle(cornerRadius: size * 0.06)
                    .stroke(Color(red: 0.15, green: 0.15, blue: 0.18), lineWidth: size * 0.025)
                    .frame(width: size * 0.28, height: size * 0.44)
                RoundedRectangle(cornerRadius: size * 0.02)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.18))
                    .frame(width: size * 0.08, height: size * 0.025)
                    .offset(y: -size * 0.18)
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 0.88, green: 0.52, blue: 0.08))
                    .frame(width: size * 0.14, height: size * 0.14)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

struct SatWithUncertaintyBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 1, green: 1, blue: 1))

            WaveHorizonShape()
                .fill(Color(red: 0.08, green: 0.10, blue: 0.38))
                .frame(width: size, height: size)

            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.45, green: 0.55, blue: 0.92),
                            Color(red: 0.15, green: 0.20, blue: 0.62),
                            Color(red: 0.50, green: 0.60, blue: 0.95)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.09)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

struct SleptWithoutGuiltBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            HexagonShape()
                .fill(Color(red: 0.78, green: 0.70, blue: 0.62))
            HexagonShape()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.82, green: 0.58, blue: 0.48),
                            Color(red: 0.52, green: 0.32, blue: 0.25),
                            Color(red: 0.78, green: 0.52, blue: 0.42)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.09)

            ZStack {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.55, green: 0.35, blue: 0.28))
                        .frame(width: size * 0.42, height: size * 0.42)
                        .offset(x: -size * 0.04)
                    Circle()
                        .fill(Color(red: 0.78, green: 0.70, blue: 0.62))
                        .frame(width: size * 0.32, height: size * 0.32)
                        .offset(x: -size * 0.12, y: -size * 0.03)
                }
                .offset(x: size * 0.10, y: size * 0.03)

                Image(systemName: "cup.and.heat.waves.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color(red: 0.55, green: 0.35, blue: 0.28))
                    .frame(width: size * 0.20, height: size * 0.20)
                    .offset(x: -size * 0.10, y: -size * 0.03)
            }
        }
        .frame(width: size, height: size)
        .clipShape(HexagonShape())
    }
}

struct KeptGoingBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.25, blue: 0.55),
                            Color(red: 0.38, green: 0.58, blue: 0.80)
                        ],
                        startPoint: .top, endPoint: .bottom)
                )

            Circle()
                .fill(Color(red: 0.98, green: 0.85, blue: 0.40).opacity(0.35))
                .frame(width: size * 0.30, height: size * 0.30)
                .offset(x: size * 0.18, y: -size * 0.22)

            Circle()
                .fill(Color(red: 0.98, green: 0.88, blue: 0.45))
                .frame(width: size * 0.16, height: size * 0.16)
                .offset(x: size * 0.18, y: -size * 0.22)

            MountainShape(peakX: 0.62, peakY: 0.38)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.62, blue: 0.72),
                            Color(red: 0.38, green: 0.45, blue: 0.58)
                        ],
                        startPoint: .top, endPoint: .bottom)
                )
                .frame(width: size, height: size)

            MountainShape(peakX: 0.35, peakY: 0.30)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.42, green: 0.30, blue: 0.22),
                            Color(red: 0.28, green: 0.18, blue: 0.12)
                        ],
                        startPoint: .top, endPoint: .bottom)
                )
                .frame(width: size, height: size)

            SnowCapShape(peakX: 0.35, peakY: 0.30)
                .fill(Color.white.opacity(0.90))
                .frame(width: size, height: size)

            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.85, blue: 0.45),
                            Color(red: 0.62, green: 0.48, blue: 0.15),
                            Color(red: 0.90, green: 0.80, blue: 0.40)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.09)

            Image(systemName: "figure.hiking")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(red: 0.12, green: 0.08, blue: 0.05))
                .frame(width: size * 0.22, height: size * 0.22)
                .offset(x: -size * 0.08, y: size * 0.08)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
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

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.82, green: 0.82, blue: 0.84),
                            Color(red: 0.58, green: 0.58, blue: 0.60)
                        ],
                        startPoint: .top, endPoint: .bottom)
                )
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.10, blue: 0.10),
                            Color(red: 0.55, green: 0.05, blue: 0.05),
                            Color(red: 0.90, green: 0.08, blue: 0.08)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.10)

            Text("NO")
                .font(.system(size: size * 0.38, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.48, green: 0.04, blue: 0.04))
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

struct SetBoundariesBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            OctagonShape()
                .fill(Color(red: 0.85, green: 0.08, blue: 0.08))
            OctagonShape()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.95, blue: 0.95),
                            Color(red: 0.65, green: 0.65, blue: 0.68),
                            Color(red: 0.90, green: 0.90, blue: 0.92)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: size * 0.10)

            Image(systemName: "hand.raised.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(red: 0.82, green: 0.82, blue: 0.84))
                .frame(width: size * 0.42, height: size * 0.42)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Showed Up For Yourself
struct ShowedUpForYourselfBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            DodecagonShape()
                .fill(Color(red: 0.65, green: 0.45, blue: 0.25))
            DodecagonShape()
                .strokeBorder(LinearGradient(colors: [Color(red: 0.90, green: 0.72, blue: 0.45), Color(red: 0.45, green: 0.28, blue: 0.10)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.07)
            Image(systemName: "person.fill")
                .resizable().scaledToFit()
                .foregroundStyle(Color(red: 0.28, green: 0.15, blue: 0.05))
                .frame(width: size * 0.38, height: size * 0.38)
        }
        .frame(width: size, height: size * 1.1)
    }
}

// MARK: - Forgiving Yourself
struct ForgivingYourselfBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            HexagonShape()
                .fill(Color(red: 0.95, green: 0.78, blue: 0.80))
            HexagonShape()
                .strokeBorder(LinearGradient(colors: [Color(red: 1.0, green: 0.60, blue: 0.65), Color(red: 0.72, green: 0.30, blue: 0.38)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.07)
            Image(systemName: "heart.fill")
                .resizable().scaledToFit()
                .foregroundStyle(Color(red: 0.80, green: 0.25, blue: 0.35))
                .frame(width: size * 0.40, height: size * 0.40)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Cried It Out
struct CriedItOutBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.20, green: 0.32, blue: 0.65))
            Circle()
                .strokeBorder(LinearGradient(colors: [Color(red: 0.48, green: 0.62, blue: 0.95), Color(red: 0.10, green: 0.20, blue: 0.50)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.08)
            Image(systemName: "drop.fill")
                .resizable().scaledToFit()
                .foregroundStyle(Color(red: 0.55, green: 0.72, blue: 0.95))
                .frame(width: size * 0.42, height: size * 0.42)
        }
        .frame(width: size, height: size).clipShape(Circle())
    }
}

// MARK: - Blew Up The Microwave
struct BlewUpMicrowaveBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.14)
                .fill(Color(red: 0.28, green: 0.28, blue: 0.30))
            RoundedRectangle(cornerRadius: size * 0.14)
                .strokeBorder(LinearGradient(colors: [Color(red: 0.50, green: 0.50, blue: 0.52), Color(red: 0.18, green: 0.18, blue: 0.20)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.06)
            ForEach(0..<8) { i in
                let angle = Double(i) * .pi / 4
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(red: 0.98, green: 0.72, blue: 0.10))
                    .frame(width: size * 0.05, height: size * 0.18)
                    .offset(y: -size * 0.18)
                    .rotationEffect(.radians(angle))
            }
            Circle()
                .fill(Color(red: 0.98, green: 0.55, blue: 0.10))
                .frame(width: size * 0.22, height: size * 0.22)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Sang In The Shower
struct SangInTheShowerBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.22, green: 0.60, blue: 0.68))
            Circle()
                .strokeBorder(LinearGradient(colors: [Color(red: 0.42, green: 0.82, blue: 0.88), Color(red: 0.08, green: 0.38, blue: 0.48)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.08)
            Image(systemName: "shower.fill")
                .resizable().scaledToFit()
                .foregroundStyle(Color(red: 0.05, green: 0.28, blue: 0.35))
                .frame(width: size * 0.38, height: size * 0.38)
                .offset(x: -size * 0.06)
            Image(systemName: "music.note")
                .font(.system(size: size * 0.20, weight: .bold))
                .foregroundStyle(Color(red: 0.05, green: 0.28, blue: 0.35))
                .offset(x: size * 0.18, y: -size * 0.14)
        }
        .frame(width: size, height: size).clipShape(Circle())
    }
}

// MARK: - Heroic Napper
struct HeroicNapperBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.18, green: 0.15, blue: 0.50))
            Circle()
                .strokeBorder(LinearGradient(colors: [Color(red: 0.52, green: 0.45, blue: 0.92), Color(red: 0.12, green: 0.08, blue: 0.40)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.08)
            HalfCircleShape()
                .fill(Color(red: 0.75, green: 0.15, blue: 0.18))
                .frame(width: size * 0.55, height: size * 0.30)
                .offset(y: size * 0.15)
            Circle()
                .fill(Color(red: 0.92, green: 0.80, blue: 0.68))
                .frame(width: size * 0.32, height: size * 0.32)
            HStack(spacing: size * 0.08) {
                Capsule()
                    .fill(Color(red: 0.30, green: 0.20, blue: 0.10))
                    .frame(width: size * 0.07, height: size * 0.02)
                Capsule()
                    .fill(Color(red: 0.30, green: 0.20, blue: 0.10))
                    .frame(width: size * 0.07, height: size * 0.02)
            }
            Text("z")
                .font(.system(size: size * 0.14, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.88, green: 0.84, blue: 1.0))
                .offset(x: size * 0.22, y: -size * 0.14)
        }
        .frame(width: size, height: size).clipShape(Circle())
    }
}

// MARK: - Doom Scrolled
struct DoomScrolledBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.15, green: 0.08, blue: 0.35))
            Circle()
                .strokeBorder(LinearGradient(colors: [Color(red: 0.55, green: 0.32, blue: 0.88), Color(red: 0.18, green: 0.05, blue: 0.38)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.08)
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(Color(red: 0.28, green: 0.20, blue: 0.55))
                .frame(width: size * 0.28, height: size * 0.44)
            RoundedRectangle(cornerRadius: size * 0.04)
                .stroke(Color(red: 0.68, green: 0.55, blue: 1.0), lineWidth: size * 0.02)
                .frame(width: size * 0.28, height: size * 0.44)
            VStack(spacing: size * 0.02) {
                ForEach(0..<3) { i in
                    Image(systemName: "chevron.down")
                        .font(.system(size: size * 0.10, weight: .bold))
                        .foregroundStyle(Color(red: 0.68, green: 0.55, blue: 1.0).opacity(1.0 - Double(i) * 0.25))
                }
            }
        }
        .frame(width: size, height: size).clipShape(Circle())
    }
}

// MARK: - Lost A Sock
struct LostASockBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.88, green: 0.72, blue: 0.30))
            Circle()
                .strokeBorder(LinearGradient(colors: [Color(red: 1.0, green: 0.88, blue: 0.50), Color(red: 0.60, green: 0.42, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.08)
            SockShape()
                .fill(Color(red: 0.38, green: 0.22, blue: 0.05))
                .frame(width: size * 0.32, height: size * 0.40)
                .offset(x: -size * 0.06)
            Text("?")
                .font(.system(size: size * 0.28, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.38, green: 0.22, blue: 0.05))
                .offset(x: size * 0.14, y: -size * 0.04)
        }
        .frame(width: size, height: size).clipShape(Circle())
    }
}

// MARK: - Breakfast Pizza Badge
struct BreakfastPizzaBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.72, green: 0.48, blue: 0.18))
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.78, blue: 0.35), Color(red: 0.50, green: 0.30, blue: 0.05)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.10
                )

            Canvas { ctx, sz in
                let cx = sz.width / 2
                let cy = sz.height / 2
                let r = sz.width / 2

                var cheese = Path()
                cheese.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                ctx.fill(cheese, with: .color(Color(red: 0.93, green: 0.78, blue: 0.32)))

                for angle in stride(from: 0.0, to: 360.0, by: 45.0) {
                    let rad = angle * .pi / 180
                    let bx = cx + cos(rad) * r * 0.55
                    let by = cy + sin(rad) * r * 0.55
                    var blob = Path()
                    blob.addEllipse(in: CGRect(x: bx - r*0.18, y: by - r*0.18, width: r*0.36, height: r*0.32))
                    ctx.fill(blob, with: .color(Color(red: 0.80, green: 0.22, blue: 0.08).opacity(0.45)))
                }

                let sliceCount = 6
                for i in 0..<sliceCount {
                    let angle = Double(i) * (.pi * 2 / Double(sliceCount))
                    var line = Path()
                    line.move(to: CGPoint(x: cx, y: cy))
                    line.addLine(to: CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r))
                    ctx.stroke(line, with: .color(Color(red: 0.55, green: 0.32, blue: 0.06).opacity(0.6)), lineWidth: size * 0.018)
                }

                let pepperoni: [(CGFloat, CGFloat, CGFloat)] = [
                    (30,  0.28, 0.11),
                    (150, 0.25, 0.11),
                    (270, 0.28, 0.11),
                    (10,  0.55, 0.13),
                    (70,  0.58, 0.14),
                    (130, 0.52, 0.13),
                    (190, 0.57, 0.14),
                    (250, 0.54, 0.13),
                    (310, 0.56, 0.13),
                    (40,  0.75, 0.12),
                    (100, 0.73, 0.12),
                    (160, 0.76, 0.12),
                    (220, 0.74, 0.12),
                    (280, 0.75, 0.12),
                    (340, 0.73, 0.12),
                ]
                for (deg, dist, pepR) in pepperoni {
                    let rad = deg * .pi / 180
                    let px = cx + cos(rad) * r * dist
                    let py = cy + sin(rad) * r * dist
                    let pr = r * pepR
                    var pep = Path()
                    pep.addEllipse(in: CGRect(x: px - pr, y: py - pr, width: pr * 2, height: pr * 2))
                    ctx.fill(pep, with: .color(Color(red: 0.50, green: 0.10, blue: 0.10)))
                    var pepMain = Path()
                    pepMain.addEllipse(in: CGRect(x: px - pr*0.85, y: py - pr*0.85, width: pr*1.7, height: pr*1.7))
                    ctx.fill(pepMain, with: .color(Color(red: 0.72, green: 0.15, blue: 0.14)))
                    var pepHi = Path()
                    pepHi.addEllipse(in: CGRect(x: px - pr*0.35, y: py - pr*0.45, width: pr*0.5, height: pr*0.35))
                    ctx.fill(pepHi, with: .color(Color(red: 0.88, green: 0.40, blue: 0.38).opacity(0.5)))
                }
            }
            .frame(width: size * 0.74, height: size * 0.74)
            .clipShape(Circle())
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - Autocorrect Disaster
struct AutocorrectDisasterBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            PentagonShape()
                .fill(Color(red: 0.92, green: 0.55, blue: 0.65))
            PentagonShape()
                .strokeBorder(LinearGradient(colors: [Color(red: 1.0, green: 0.72, blue: 0.80), Color(red: 0.65, green: 0.22, blue: 0.38)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.07)
            RoundedRectangle(cornerRadius: size * 0.06)
                .fill(Color.white.opacity(0.90))
                .frame(width: size * 0.48, height: size * 0.26)
                .offset(y: -size * 0.04)
            Text("D*ck?")
                .font(.system(size: size * 0.13, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.40, green: 0.08, blue: 0.18))
                .offset(y: -size * 0.04)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Remembered A Dream
struct RememberedADreamBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [Color(red: 0.22, green: 0.15, blue: 0.55), Color(red: 0.38, green: 0.28, blue: 0.72)], startPoint: .top, endPoint: .bottom))
            Circle()
                .strokeBorder(LinearGradient(colors: [Color(red: 0.60, green: 0.52, blue: 0.95), Color(red: 0.18, green: 0.10, blue: 0.50)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.08)

            Image(systemName: "cloud.fill")
                .resizable().scaledToFit()
                .foregroundStyle(Color(red: 0.80, green: 0.75, blue: 1.0).opacity(0.60))
                .frame(width: size * 0.42, height: size * 0.30)
                .offset(y: size * 0.06)

            let stars: [(CGFloat, CGFloat, CGFloat)] = [
                ( 0.00, -0.26, 1.00),
                (-0.13, -0.20, 0.85),
                ( 0.13, -0.20, 0.85),
                (-0.22, -0.10, 0.70),
                ( 0.22, -0.10, 0.70),
            ]
            ForEach(Array(stars.enumerated()), id: \.offset) { _, star in
                Image(systemName: "star.fill")
                    .font(.system(size: size * 0.11 * star.2))
                    .foregroundStyle(Color(red: 0.95, green: 0.90, blue: 1.0).opacity(0.90))
                    .offset(x: star.0 * size, y: star.1 * size)
            }
        }
        .frame(width: size, height: size).clipShape(Circle())
    }
}

// MARK: - Guessed Time Correctly
struct GuessedTimeCorrectlyBadge: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.18, green: 0.52, blue: 0.48))

            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.38, green: 0.78, blue: 0.72),
                            Color(red: 0.06, green: 0.30, blue: 0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.08
                )

            Circle()
                .fill(Color(red: 0.88, green: 0.94, blue: 0.92))
                .frame(width: size * 0.44, height: size * 0.44)

            Circle()
                .stroke(Color(red: 0.12, green: 0.38, blue: 0.35), lineWidth: size * 0.025)
                .frame(width: size * 0.44, height: size * 0.44)

            Canvas { context, canvasSize in
                let cx = canvasSize.width / 2
                let cy = canvasSize.height / 2

                var hourHand = Path()
                hourHand.move(to: CGPoint(x: cx, y: cy))
                hourHand.addLine(to: CGPoint(x: cx - size * 0.06, y: cy - size * 0.10))
                context.stroke(
                    hourHand,
                    with: .color(Color(red: 0.12, green: 0.35, blue: 0.32)),
                    lineWidth: size * 0.03
                )

                var minuteHand = Path()
                minuteHand.move(to: CGPoint(x: cx, y: cy))
                minuteHand.addLine(to: CGPoint(x: cx + size * 0.08, y: cy - size * 0.10))
                context.stroke(
                    minuteHand,
                    with: .color(Color(red: 0.12, green: 0.35, blue: 0.32)),
                    lineWidth: size * 0.025
                )
            }
            .frame(width: size * 0.44, height: size * 0.44)

            Image(systemName: "sparkle")
                .font(.system(size: size * 0.18))
                .foregroundStyle(Color(red: 0.95, green: 0.88, blue: 0.28))
                .offset(x: size * 0.18, y: -size * 0.16)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - Dropped Phone On Face
struct DroppedPhoneOnFaceBadge: View {
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.78, green: 0.15, blue: 0.12))
            Circle()
                .strokeBorder(LinearGradient(colors: [Color(red: 0.95, green: 0.38, blue: 0.32), Color(red: 0.48, green: 0.04, blue: 0.02)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: size * 0.08)
            Circle()
                .fill(Color(red: 0.94, green: 0.80, blue: 0.68))
                .frame(width: size * 0.34, height: size * 0.28)
                .offset(y: size * 0.10)
            HStack(spacing: size * 0.10) {
                ForEach(0..<2) { _ in
                    Image(systemName: "xmark")
                        .font(.system(size: size * 0.08, weight: .bold))
                        .foregroundStyle(Color(red: 0.22, green: 0.10, blue: 0.05))
                }
            }
            .offset(y: size * 0.08)
            RoundedRectangle(cornerRadius: size * 0.04)
                .fill(Color(red: 0.22, green: 0.22, blue: 0.25))
                .frame(width: size * 0.16, height: size * 0.28)
                .rotationEffect(.degrees(20))
                .offset(x: size * 0.02, y: -size * 0.12)
            ForEach(0..<3) { i in
                let positions: [(CGFloat, CGFloat)] = [(-0.20, -0.18), (0.20, -0.20), (0.0, -0.24)]
                Image(systemName: "star.fill")
                    .font(.system(size: size * 0.08))
                    .foregroundStyle(Color(red: 0.98, green: 0.88, blue: 0.25))
                    .offset(x: positions[i].0 * size, y: positions[i].1 * size)
            }
        }
        .frame(width: size, height: size).clipShape(Circle())
    }
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
