import SwiftUI
import SwiftData

// MARK: - Awards Tab

struct AwardsTab: View {
    @Query(sort: \Award.earnedAt, order: .reverse) private var awards: [Award]
    @State private var viewModel     = AwardsViewModel()
    @State private var selectedType: AwardType? = nil
    @State private var shelfExpanded = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)

    var body: some View {
        NavigationStack {
            ZStack {
                AwardsBackgroundView()
                    .ignoresSafeArea()

                ScrollView {
                    if awards.isEmpty {
                        VStack(spacing: 22) {
                            EmptyAwardsView()
                            AwardsShelfGalleryView(
                                earnedTypes: Set(viewModel.groupedAwards.map(\.type)),
                                groupedAwards: viewModel.groupedAwards
                            ) { type in
                                selectedType = type
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        VStack(spacing: 22) {
                            MedalShelfView(groups: viewModel.groupedAwards) {
                                shelfExpanded = true
                            }
                            .padding(.top, 8)

                            TotalAwardsBadge(count: awards.count)
                                .padding(.horizontal, 16)

                            AwardsShelfGalleryView(
                                earnedTypes: Set(viewModel.groupedAwards.map(\.type)),
                                groupedAwards: viewModel.groupedAwards
                            ) { type in
                                selectedType = type
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Awards")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .onChange(of: awards) { _, new in viewModel.update(from: new) }
            .onAppear { viewModel.update(from: awards) }
            .sheet(item: $selectedType) { type in
                AwardDetailSheet(type: type, awards: awards.filter { $0.type == type })
            }
            .fullScreenCover(isPresented: $shelfExpanded) {
                MedalCarouselView(groups: viewModel.groupedAwards)
            }
        }
    }
}

// MARK: - Gradient Background

struct AwardsBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var phase: Double = 0

    private var baseColor: Color {
        colorScheme == .dark
            ? Color(red: 0.04, green: 0.03, blue: 0.10)
            : Color(red: 0.97, green: 0.96, blue: 1.00)
    }

    var body: some View {
        ZStack {
            baseColor

            Canvas { ctx, size in
                let blobs: [(x: Double, y: Double, r: Double, hue: Double, opacity: Double)] = [
                    (0.20, 0.18, 0.45, 0.72, colorScheme == .dark ? 0.28 : 0.18),
                    (0.78, 0.12, 0.38, 0.60, colorScheme == .dark ? 0.22 : 0.14),
                    (0.50, 0.55, 0.50, 0.78, colorScheme == .dark ? 0.20 : 0.12),
                    (0.15, 0.80, 0.35, 0.55, colorScheme == .dark ? 0.18 : 0.10),
                    (0.85, 0.75, 0.40, 0.65, colorScheme == .dark ? 0.16 : 0.10),
                ]

                for b in blobs {
                    let cx = size.width  * (b.x + sin(phase + b.hue * 10) * 0.04)
                    let cy = size.height * (b.y + cos(phase + b.hue *  8) * 0.04)
                    let r  = size.width  * b.r

                    let rect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)

                    let brightness = colorScheme == .dark ? 0.55 : 0.80

                    ctx.fill(
                        Path(ellipseIn: rect),
                        with: .radialGradient(
                            Gradient(colors: [
                                Color(hue: b.hue, saturation: 0.70, brightness: brightness, opacity: b.opacity),
                                Color(hue: b.hue, saturation: 0.60, brightness: brightness, opacity: 0)
                            ]),
                            center: CGPoint(x: cx, y: cy),
                            startRadius: 0,
                            endRadius: r
                        )
                    )
                }
            }
            .blendMode(colorScheme == .dark ? .screen : .multiply)
            .drawingGroup()
        }
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Adaptive surface helpers

private func glassFill(_ scheme: ColorScheme, opacity: Double = 0.07) -> Color {
    scheme == .dark
        ? Color.white.opacity(opacity)
        : Color.black.opacity(opacity * 0.6)
}

private func glassBorder(_ scheme: ColorScheme, opacity: Double = 0.10) -> Color {
    scheme == .dark
        ? Color.white.opacity(opacity)
        : Color.black.opacity(opacity * 0.5)
}

private func adaptiveSecondary(_ scheme: ColorScheme, opacity: Double = 0.55) -> Color {
    scheme == .dark
        ? Color.white.opacity(opacity)
        : Color.black.opacity(opacity)
}

// MARK: - Trophy Shelf

struct MedalShelfView: View {
    @Environment(\.colorScheme) private var colorScheme
    let groups:   [(type: AwardType, awards: [Award])]
    let onExpand: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Your Top Awards")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.55))

                Spacer()

                Button(action: onExpand) {
                    HStack(spacing: 4) {
                        Text("View all")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.45))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(glassFill(colorScheme, opacity: 0.08), in: Capsule())
                }
            }
            .padding(.horizontal, 20)

            Button(action: onExpand) {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            colorScheme == .dark
                            ? LinearGradient(
                                colors: [
                                    Color(red: 0.10, green: 0.08, blue: 0.18),
                                    Color(red: 0.07, green: 0.06, blue: 0.13)
                                ],
                                startPoint: .top, endPoint: .bottom
                              )
                            : LinearGradient(
                                colors: [
                                    Color(red: 0.96, green: 0.94, blue: 1.00),
                                    Color(red: 0.92, green: 0.90, blue: 0.98)
                                ],
                                startPoint: .top, endPoint: .bottom
                              )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            glassBorder(colorScheme, opacity: 0.12),
                                            glassBorder(colorScheme, opacity: 0.03)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )

                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .bottom, spacing: 0) {
                                ForEach(groups.prefix(4), id: \.type) { group in
                                    ShelfMedalItem(type: group.type, count: group.awards.count)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 12)
                            .padding(.top, 14)
                        }
                        .frame(maxWidth: .infinity)
                        .allowsHitTesting(false)

                        ShelfPlankView()
                    }
                }
                .frame(height: 128)
                .padding(.horizontal, 16)
                .shadow(
                    color: colorScheme == .dark ? .black.opacity(0.40) : .black.opacity(0.10),
                    radius: 20, x: 0, y: 8
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Badge View Helper (top level, outside any View struct)

@ViewBuilder
func badgeView(for type: AwardType, size: CGFloat) -> some View {
    switch type {
    case .beganSomething:         NewBeginningsBadge(size: size)
    case .createdSomething:       CreatedSomethingBadge(size: size)
    case .handledDifficulty:      OvercomingDifficultyBadge(size: size)
    case .practicedMindfulness:   MindfulnessBadge(size: size)
    case .prioritisedSleep:       RestWellBadge(size: size)
    case .madeAmends:             MadeAmendsBadge(size: size)
    case .connectedWithSomeone:   MadeConnectionsBadge(size: size)
    case .askedForHelp:           ReachedOutBadge(size: size)
    case .finishedSomething:      FinishedTasksBadge(size: size)
    case .celebratedAWin:         GoalAchievedBadge(size: size)
    case .steppedOutsideComfort:  ComfortZoneBadge(size: size)
    case .movedYourBody:          StayedActiveBadge(size: size)
    case .helpedOthers:           HelpedOthersBadge(size: size)
    case .ateWell:                NourishedYourselfBadge(size: size)
    case .reachedOutFirst: ReachedOutFirstBadge(size: size)
    case .learnedSomethingNew: FedCuriosityBadge(size: size)
    case .spentTimeInNature: TouchedGrassBadge(size: size)
    case .disconnectedFromScreens: DisconnectedFromScreensBadge(size: size)
    case .satWithUncertainty: SatWithUncertaintyBadge(size: size)
    case .restedWithoutGuilt: SleptWithoutGuiltBadge(size: size)
    case .keptGoing: KeptGoingBadge(size: size)
    case .saidNo: SaidNoBadge(size: size)
    case .setABoundary: SetBoundariesBadge(size: size)
    case .showedUpForYourself:          ShowedUpForYourselfBadge(size: size)
    case .forgivingYourself:            ForgivingYourselfBadge(size: size)
    case .criedItOut:                   CriedItOutBadge(size: size)
    case .blewUpMicrowave:              BlewUpMicrowaveBadge(size: size)
    case .sangInTheShower:              SangInTheShowerBadge(size: size)
    case .heroicNapper:                 HeroicNapperBadge(size: size)
    case .doomScrolled:                 DoomScrolledBadge(size: size)
    case .lostASock:                    LostASockBadge(size: size)
    case .breakfastPizza:               BreakfastPizzaBadge(size: size)
    case .autocorrectDisaster:          AutocorrectDisasterBadge(size: size)
    case .rememberedADream:             RememberedADreamBadge(size: size)
    case .guessedTimeCorrectly:         GuessedTimeCorrectlyBadge(size: size)
    case .droppedPhoneOnFace:           DroppedPhoneOnFaceBadge(size: size)
    default:                      Text(type.medal).font(.system(size: size * 0.55))
    }
}

// MARK: - Individual Shelf Medal Item

struct ShelfMedalItem: View {
    @Environment(\.colorScheme) private var colorScheme
    let type:  AwardType
    let count: Int

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ShelfMedal3DView(awardType: type, medalShape: .deterministic(for: type))
                    .frame(width: 90, height: 90)

                if count > 1 {
                    Text("×\(count)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.indigo)
                        .clipShape(Capsule())
                        .offset(x: 4, y: -2)
                }
            }
        }
        .frame(width: 90)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.72)
                .delay(Double(abs(type.rawValue.hashValue) % 10) * 0.055),
            value: appeared
        )
        .onAppear { appeared = true }
    }
}

// MARK: - Shelf Plank

struct ShelfPlankView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                        ? [
                            Color(red: 0.44, green: 0.29, blue: 0.14),
                            Color(red: 0.30, green: 0.18, blue: 0.08),
                            Color(red: 0.38, green: 0.24, blue: 0.11)
                          ]
                        : [
                            Color(red: 0.60, green: 0.42, blue: 0.22),
                            Color(red: 0.46, green: 0.29, blue: 0.12),
                            Color(red: 0.54, green: 0.36, blue: 0.17)
                          ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 18)

            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.14 : 0.30))
                    .frame(height: 1.5)
                Spacer()
            }
            .frame(height: 18)

            Canvas { ctx, size in
                var x: CGFloat = 0
                var rng = SystemRandomNumberGenerator()
                while x < size.width {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + 5, y: size.height))
                    ctx.stroke(path, with: .color(.white.opacity(0.06)), lineWidth: 1)
                    x += CGFloat.random(in: 16...36, using: &rng)
                }
            }
            .frame(height: 18)

            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color.black.opacity(colorScheme == .dark ? 0.40 : 0.20))
                    .frame(height: 3)
            }
            .frame(height: 18)
        }
        .shadow(
            color: .black.opacity(colorScheme == .dark ? 0.55 : 0.20),
            radius: 8, x: 0, y: 5
        )
    }
}

// MARK: - Medal Carousel (fullscreen)

struct MedalCarouselView: View {
    let groups: [(type: AwardType, awards: [Award])]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentIndex = 0

    var body: some View {
        ZStack {
            AwardsBackgroundView()
                .ignoresSafeArea()

            CarouselGlowView(hue: glowHue(for: currentIndex))
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: currentIndex)

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.80))
                            .frame(width: 36, height: 36)
                            .background(glassFill(colorScheme, opacity: 0.10), in: Circle())
                    }

                    Spacer()

                    Text("\(currentIndex + 1) of \(groups.count)")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.45))
                        .animation(.none, value: currentIndex)

                    Spacer()

                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)

                TabView(selection: $currentIndex) {
                    ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
                        CarouselMedalPage(type: group.type, awards: group.awards)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                CarouselDots(count: groups.count, current: currentIndex)
                    .padding(.bottom, 36)
            }
        }
    }

    private func glowHue(for index: Int) -> Double {
        guard index < groups.count else { return 0.72 }
        return baseHue(for: groups[index].type)
    }

    private func baseHue(for type: AwardType) -> Double {
        switch type {
        case .connectedWithSomeone, .helpedOthers, .madeAmends:                    return 0.13
        case .prioritisedSleep, .movedYourBody, .ateWell, .practicedMindfulness:   return 0.55
        case .learnedSomethingNew, .steppedOutsideComfort, .askedForHelp:          return 0.60
        case .keptGoing, .handledDifficulty, .setABoundary:                        return 0.72
        case .finishedSomething, .beganSomething, .showedUpForYourself:            return 0.08
        case .reachedOutFirst:                                                     return 0.23
        case .restedWithoutGuilt:                                                  return 0.30
        case .spentTimeInNature:                                                   return 0.40
        case .disconnectedFromScreens:                                             return 0.50
        case .satWithUncertainty:                                                  return 0.32
        case .createdSomething:                                                    return 0.34
        case .saidNo:                                                              return 0.67
        case .celebratedAWin:                                                      return 0.69
        case .forgivingYourself:                                                   return 0.20
        case .criedItOut:                                                          return 0.90
        case .blewUpMicrowave:          return 0.05
        case .sangInTheShower:          return 0.55
        case .heroicNapper:             return 0.70
        case .doomScrolled:             return 0.75
        case .lostASock:                return 0.10
        case .breakfastPizza:           return 0.07
        case .autocorrectDisaster:      return 0.88
        case .rememberedADream:     return 0.72
        case .guessedTimeCorrectly:     return 0.45
        case .droppedPhoneOnFace:               return 0.03
        }
    }
}

// MARK: - Ambient Glow

struct CarouselGlowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let hue: Double

    var body: some View {
        GeometryReader { _ in
            Canvas { ctx, size in
                let cx = size.width  * 0.50
                let cy = size.height * 0.38
                let r  = size.width  * 0.60
                let rect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)

                let opacity = colorScheme == .dark ? 0.38 : 0.20

                ctx.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        Gradient(colors: [
                            Color(hue: hue, saturation: 0.80, brightness: 0.70, opacity: opacity),
                            Color(hue: hue, saturation: 0.60, brightness: 0.40, opacity: 0)
                        ]),
                        center: CGPoint(x: cx, y: cy),
                        startRadius: 0,
                        endRadius: r
                    )
                )
            }
            .drawingGroup()
            .blendMode(colorScheme == .dark ? .screen : .multiply)
        }
    }
}

// MARK: - Single Carousel Page

struct CarouselMedalPage: View {
    @Environment(\.colorScheme) private var colorScheme
    let type:   AwardType
    let awards: [Award]

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                glassFill(colorScheme, opacity: 0.07),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 60,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)

                ShelfMedal3DView(awardType: type, medalShape: .deterministic(for: type))
                    .frame(width: 260, height: 260)
            }
            .scaleEffect(appeared ? 1.0 : 0.75)
            .opacity(appeared ? 1 : 0)

            Spacer().frame(height: 36)

            VStack(spacing: 14) {
                Text(type.rawValue)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)

                Text(type.shortDescription)
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.55))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.yellow.opacity(0.90))
                    Text("Earned \(awards.count) time\(awards.count == 1 ? "" : "s")")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary.opacity(0.85))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(glassFill(colorScheme, opacity: 0.10), in: Capsule())
                .overlay(Capsule().strokeBorder(glassBorder(colorScheme, opacity: 0.15), lineWidth: 1))

                if let latest = awards.max(by: { $0.earnedAt < $1.earnedAt }) {
                    Text("Last earned \(latest.earnedAt.formatted(date: .long, time: .omitted))")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.32))
                }
            }
            .padding(.horizontal, 40)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.05)) {
                appeared = true
            }
        }
        .onDisappear { appeared = false }
    }
}

// MARK: - Page Dots

struct CarouselDots: View {
    let count:   Int
    let current: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == current ? Color.primary : Color.primary.opacity(0.22))
                    .frame(width: i == current ? 20 : 6, height: 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.70), value: current)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Total Badge

struct TotalAwardsBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    let count: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(count) medal\(count == 1 ? "" : "s") earned")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                Text("Keep writing to discover more")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.45))
            }
            Spacer()
            Text("🏅")
                .font(.system(size: 40))
        }
        .padding(18)
        .background(glassFill(colorScheme, opacity: 0.07), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(glassBorder(colorScheme, opacity: 0.10), lineWidth: 1))
    }
}

// MARK: - Award Tile

struct AwardTileView: View {
    @Environment(\.colorScheme) private var colorScheme
    let type:  AwardType
    let count: Int

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(glassFill(colorScheme, opacity: 0.08))
                    .frame(width: 64, height: 64)
                    .overlay(Circle().strokeBorder(glassBorder(colorScheme, opacity: 0.10), lineWidth: 1))
                badgeView(for: type, size: 52)
            }

            Text(type.rawValue)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if count > 1 {
                Text("×\(count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(Color.indigo.opacity(0.80))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(glassFill(colorScheme, opacity: 0.06), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(glassBorder(colorScheme, opacity: 0.09), lineWidth: 1))
        .scaleEffect(appeared ? 1 : 0.92)
        .opacity(appeared ? 1 : 0)
        .animation(
            .spring(response: 0.45, dampingFraction: 0.72)
                .delay(Double(abs(type.rawValue.hashValue) % 8) * 0.04),
            value: appeared
        )
        .onAppear { appeared = true }
    }
}

// MARK: - Award Detail Sheet

extension AwardType: Identifiable {
    public var id: String { rawValue }
}

struct AwardDetailSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    let type:   AwardType
    let awards: [Award]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark
                    ? LinearGradient(
                        colors: [
                            Color(red: 0.06, green: 0.05, blue: 0.14),
                            Color(red: 0.04, green: 0.03, blue: 0.10)
                        ],
                        startPoint: .top, endPoint: .bottom
                      )
                    : LinearGradient(
                        colors: [
                            Color(red: 0.97, green: 0.96, blue: 1.00),
                            Color(red: 0.94, green: 0.92, blue: 0.99)
                        ],
                        startPoint: .top, endPoint: .bottom
                      )
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(glassFill(colorScheme, opacity: 0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .strokeBorder(glassBorder(colorScheme, opacity: 0.10), lineWidth: 1)
                                )
                                .frame(height: 200)

                            ShelfMedal3DView(awardType: type, medalShape: .deterministic(for: type))
                                .frame(width: 170, height: 170)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                        VStack(spacing: 8) {
                            Text(type.rawValue)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                                .multilineTextAlignment(.center)
                            Text(type.shortDescription)
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.55))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)

                        Divider()
                            .overlay(glassBorder(colorScheme, opacity: 0.10))

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Earned \(awards.count) time\(awards.count == 1 ? "" : "s")")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(Color.primary)
                                .padding(.horizontal, 20)

                            ForEach(awards, id: \.id) { award in
                                VStack(alignment: .leading, spacing: 4) {
                                    if let title = award.customTitle {
                                        Text(title)
                                            .font(.system(.subheadline, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color.primary.opacity(0.85))
                                    }
                                    Text(award.earnedAt.formatted(date: .long, time: .omitted))
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.40))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)

                                Divider()
                                    .overlay(glassBorder(colorScheme, opacity: 0.08))
                                    .padding(.leading, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.70))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Empty State

struct EmptyAwardsView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "medal")
                .font(.system(size: 56))
                .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.20))
            Text("No awards yet")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)
            Text("Write your first journal entry and on-device AI will find the small achievements in your day.")
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(adaptiveSecondary(colorScheme, opacity: 0.45))
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Awards Shelf Gallery

struct AwardsShelfGalleryView: View {
    @Environment(\.colorScheme) private var colorScheme
    let earnedTypes: Set<AwardType>
    let groupedAwards: [(type: AwardType, awards: [Award])]
    let onTap: (AwardType) -> Void

    private let allTypes = AwardType.allCases
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)

    private var rows: [[AwardType]] {
        stride(from: 0, to: allTypes.count, by: 4).map {
            Array(allTypes[$0..<min($0 + 4, allTypes.count)])
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                ShelfRowView(
                    types: row,
                    earnedTypes: earnedTypes,
                    groupedAwards: groupedAwards,
                    colorScheme: colorScheme,
                    onTap: onTap
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
}

// MARK: - Single Shelf Row

struct ShelfRowView: View {
    let types: [AwardType]
    let earnedTypes: Set<AwardType>
    let groupedAwards: [(type: AwardType, awards: [Award])]
    let colorScheme: ColorScheme
    let onTap: (AwardType) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(types, id: \.self) { type in
                    let isEarned = earnedTypes.contains(type)
                    let count = groupedAwards.first(where: { $0.type == type })?.awards.count ?? 0

                    Button { if isEarned { onTap(type) } } label: {
                        ShelfAwardItem(
                            type: type,
                            isEarned: isEarned,
                            count: count,
                            colorScheme: colorScheme
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 10)
            .padding(.bottom, 0)

            ShelfPlankView()
        }
    }
}

// MARK: - Individual Award Item on Shelf

struct ShelfAwardItem: View {
    let type: AwardType
    let isEarned: Bool
    let count: Int
    let colorScheme: ColorScheme

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    if isEarned {
                        badgeView(for: type, size: 54)
                    } else {
                        badgeView(for: type, size: 54)
                            .grayscale(1.0)
                            .opacity(colorScheme == .dark ? 0.18 : 0.12)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.20)
                                    : Color.black.opacity(0.15)
                            )
                    }
                }
                .frame(width: 60, height: 60)

                if isEarned && count > 1 {
                    Text("×\(count)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.indigo)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -4)
                }
            }

            Text(isEarned ? type.rawValue : "???")
                .font(.system(size: 9, weight: isEarned ? .semibold : .regular, design: .rounded))
                .foregroundStyle(
                    isEarned
                    ? Color.primary.opacity(0.80)
                    : adaptiveSecondary(colorScheme, opacity: 0.25)
                )
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 68)
                .padding(.bottom, 6)
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.88)
        .animation(
            .spring(response: 0.45, dampingFraction: 0.70)
                .delay(Double(abs(type.rawValue.hashValue) % 12) * 0.04),
            value: appeared
        )
        .onAppear { appeared = true }
    }
}
