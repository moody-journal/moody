import SwiftUI
import SwiftData
import Charts

// MARK: - Chart Range

enum ChartRange: String, CaseIterable, Identifiable {
    case week    = "Week"
    case month   = "Month"
    case year    = "Year"
    case allTime = "All Time"
    var id: String { rawValue }
}

// MARK: - MoodTab

struct MoodTab: View {
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @State private var viewModel = MoodViewModel()
    @State private var chartRange: ChartRange = .week

    var body: some View {
        NavigationStack {
            ZStack {
                JournalGradientBackground()
                    .ignoresSafeArea()

                GeometryReader { geo in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            WeekSummaryCard(viewModel: viewModel)
                            MoodChartView(viewModel: viewModel, range: $chartRange)
                            MoodCalendarView(viewModel: viewModel, range: chartRange)
                            MindfulnessCornerView()
                            StressInfoView()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .frame(width: geo.size.width)
                    }
                }
            }
            .navigationTitle("Mood")
            .onChange(of: entries) { _, new in viewModel.update(from: new) }
            .onAppear { viewModel.update(from: entries) }
        }
    }
}

// MARK: - Week Summary Card

struct WeekSummaryCard: View {
    let viewModel: MoodViewModel

    var mood: Mood? {
        let v = viewModel.averageMoodThisWeek
        guard v > 0 else { return nil }
        return Mood(rawValue: max(1, min(5, Int(v.rounded()))))
    }

    var body: some View {
        HStack(spacing: 16) {
            if let mood {
                MoodIcon(mood: mood, size: 128, animated: true)
            } else {
                Text("—").font(.system(size: 48))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("This week")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(mood?.label ?? "No entries yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                if viewModel.averageMoodThisWeek > 0 {
                    Text(String(format: "Average: %.1f / 5", viewModel.averageMoodThisWeek))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Mood Chart

struct MoodChartView: View {
    let viewModel: MoodViewModel
    @Binding var range: ChartRange

    private var data: [MoodViewModel.DayMood] {
        switch range {
        case .week:    return viewModel.weeklyData
        case .month:   return viewModel.monthlyData
        case .year:    return viewModel.yearlyData
        case .allTime: return viewModel.allTimeData
        }
    }

    private var title: String {
        switch range {
        case .week:    return "7-day trend"
        case .month:   return "30-day trend"
        case .year:    return "12-month trend"
        case .allTime: return "All-time trend"
        }
    }

    private var xUnit: Calendar.Component {
        switch range {
        case .week, .month:   return .day
        case .year, .allTime: return .month
        }
    }

    private var xFormat: Date.FormatStyle {
        switch range {
        case .week:           return .dateTime.weekday(.abbreviated)
        case .month:          return .dateTime.day()
        case .year, .allTime: return .dateTime.month(.abbreviated)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title).font(.headline)
                Spacer(minLength: 0)
            }

            Picker("Range", selection: $range) {
                ForEach(ChartRange.allCases) { r in
                    Text(r.rawValue).tag(r)
                }
            }
            .pickerStyle(.segmented)

            if data.isEmpty {
                Text("Write a few entries to see your mood trend here.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .multilineTextAlignment(.center)
            } else {
                Chart(data) { day in
                    LineMark(
                        x: .value("Date", day.date, unit: xUnit),
                        y: .value("Mood", day.averageMood)
                    )
                    .foregroundStyle(.purple)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", day.date, unit: xUnit),
                        yStart: .value("Base", 0),
                        yEnd:   .value("Mood", day.averageMood)
                    )
                    .foregroundStyle(LinearGradient(
                        colors: [.purple.opacity(0.2), .purple.opacity(0)],
                        startPoint: .top, endPoint: .bottom
                    ))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", day.date, unit: xUnit),
                        y: .value("Mood", day.averageMood)
                    )
                    .foregroundStyle(.indigo)
                    .symbolSize(40)
                }
                .chartYScale(domain: 1...5)
                .chartXAxis {
                    AxisMarks(values: .stride(by: xUnit)) { _ in
                        AxisValueLabel(format: xFormat, centered: true)
                            .font(.system(size: 8))
                        AxisGridLine()
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 160, maxHeight: 160)
                .fixedSize(horizontal: false, vertical: true)
                .chartYAxis {
                    AxisMarks(preset: .aligned, position: .leading, values: [1, 2, 3, 4, 5]) { value in
                        if let raw = value.as(Int.self), let mood = Mood(rawValue: raw) {
                            AxisValueLabel(anchor: .trailing) {
                                MoodIcon(mood: mood, size: 16, animated: false)
                            }
                        }
                        AxisGridLine()
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Mood Calendar

struct MoodCalendarView: View {
    let viewModel: MoodViewModel
    let range: ChartRange

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    private var data: [MoodViewModel.DayMood] {
        switch range {
        case .week:           return viewModel.weeklyData
        case .month:          return viewModel.monthlyData
        case .year, .allTime: return viewModel.allTimeData
        }
    }

    private var calendarTitle: String {
        switch range {
        case .week:    return "Last 7 days"
        case .month:   return "Last 30 days"
        case .year:    return "Last 12 months"
        case .allTime: return "All entries"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(calendarTitle, systemImage: "calendar").font(.headline)

            if range == .year || range == .allTime {
                monthlyGridView
            } else {
                dailyDotGrid
            }

            legendRow
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
    }

    @ViewBuilder
    private var dailyDotGrid: some View {
        if data.isEmpty {
            Text("No entries in this period.")
                .font(.callout).foregroundStyle(.secondary)
        } else {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(["S","M","T","W","T","F","S"].enumerated()), id: \.offset) { _, d in
                    Text(d)
                        .font(.caption2).fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(calendarDays(from: data), id: \.id) { item in
                    if let day = item.dayMood {
                        MoodDotView(day: day)
                    } else if item.isCurrentMonth {
                        Circle().fill(Color.primary.opacity(0.06)).frame(width: 28, height: 28)
                    } else {
                        Color.clear.frame(width: 28, height: 28)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var monthlyGridView: some View {
        if data.isEmpty {
            Text("No entries to display.").font(.callout).foregroundStyle(.secondary)
        } else {
            let months = groupedByMonth(data)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 10) {
                ForEach(months, id: \.date) { month in
                    VStack(spacing: 4) {
                        let mood = Mood(rawValue: max(1, min(5, Int(month.averageMood.rounded())))) ?? .okay
                        MoodIcon(mood: mood, size: 32, animated: false)
                        Text(month.date.formatted(.dateTime.month(.abbreviated).year(.twoDigits)))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                            .lineLimit(1).minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.primary.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .frame(maxWidth: .infinity).clipped()
        }
    }

    private var legendRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Mood.allCases, id: \.rawValue) { mood in
                    HStack(spacing: 4) {
                        Circle().fill(moodColor(mood)).frame(width: 7, height: 7)
                        Text(mood.label)
                            .font(.caption2).fontWeight(.medium).foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 1)
        }
        .padding(.top, 4).frame(maxWidth: .infinity).clipped()
    }

    struct CalendarItem: Identifiable {
        let id: String
        let dayMood: MoodViewModel.DayMood?
        let isCurrentMonth: Bool
    }

    private func calendarDays(from source: [MoodViewModel.DayMood]) -> [CalendarItem] {
        guard !source.isEmpty else { return [] }
        let calendar = Calendar.current
        let today = Date()
        let dayCount = (range == .week) ? 7 : 30
        let startDate = calendar.date(byAdding: .day, value: -(dayCount - 1),
                                      to: calendar.startOfDay(for: today))!
        var moodByDate: [Date: MoodViewModel.DayMood] = [:]
        for d in source { moodByDate[calendar.startOfDay(for: d.date)] = d }
        let startWeekday = calendar.component(.weekday, from: startDate) - 1
        var items: [CalendarItem] = (0..<startWeekday).map {
            CalendarItem(id: "pad-\($0)", dayMood: nil, isCurrentMonth: false)
        }
        for i in 0..<dayCount {
            let date = calendar.date(byAdding: .day, value: i, to: startDate)!
            let normalized = calendar.startOfDay(for: date)
            let isFuture = normalized > calendar.startOfDay(for: today)
            items.append(CalendarItem(id: normalized.formatted(),
                                      dayMood: moodByDate[normalized],
                                      isCurrentMonth: !isFuture))
        }
        return items
    }

    private func groupedByMonth(_ source: [MoodViewModel.DayMood]) -> [MoodViewModel.DayMood] {
        let calendar = Calendar.current
        var grouped: [Date: [Double]] = [:]
        for d in source {
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: d.date))!
            grouped[start, default: []].append(d.averageMood)
        }
        return grouped
            .map { MoodViewModel.DayMood(date: $0.key,
                                         averageMood: $0.value.reduce(0, +) / Double($0.value.count),
                                         entryCount: $0.value.count) }
            .sorted { $0.date < $1.date }
    }

    private func moodColor(_ mood: Mood) -> Color {
        switch mood {
        case .terrible: return .purple.opacity(0.6)
        case .bad:      return .blue.opacity(0.6)
        case .okay:     return .cyan.opacity(0.6)
        case .good:     return .green.opacity(0.6)
        case .great:    return .orange.opacity(0.6)
        }
    }
}

struct MoodDotView: View {
    let day: MoodViewModel.DayMood
    private var mood: Mood {
        Mood(rawValue: max(1, min(5, Int(day.averageMood.rounded())))) ?? .okay
    }
    var body: some View {
        MoodIcon(mood: mood, size: 28, animated: false)
            .help(day.date.formatted(date: .abbreviated, time: .omitted))
    }
}

// MARK: - MoodViewModel extension notes

// MARK: - Mindfulness Corner

struct MindfulnessCornerView: View {

    enum BreathPhase: CaseIterable, Equatable {
        case idle, inhale, holdIn, exhale, holdOut

        var duration: Double {
            switch self {
            case .idle:    return 0
            case .inhale:  return 4
            case .holdIn:  return 4
            case .exhale:  return 6
            case .holdOut: return 2
            }
        }

        var label: String {
            switch self {
            case .idle:    return "Tap to begin"
            case .inhale:  return "Breathe in"
            case .holdIn:  return "Hold"
            case .exhale:  return "Breathe out"
            case .holdOut: return "Hold"
            }
        }

        var subLabel: String {
            switch self {
            case .idle:    return "breathe with the shape"
            case .inhale:  return "expand with the circle"
            case .holdIn:  return "stay still"
            case .exhale:  return "release with the circle"
            case .holdOut: return "stay still"
            }
        }

        var hue: Double {
            switch self {
            case .idle:    return 220
            case .inhale:  return 185
            case .holdIn:  return 200
            case .exhale:  return 270
            case .holdOut: return 240
            }
        }

        var next: BreathPhase {
            switch self {
            case .idle:    return .inhale
            case .inhale:  return .holdIn
            case .holdIn:  return .exhale
            case .exhale:  return .holdOut
            case .holdOut: return .inhale
            }
        }
    }

    private let durationOptions: [(label: String, seconds: Int)] = [
        ("1 min", 60), ("2 min", 120), ("5 min", 300), ("10 min", 600)
    ]

    @State private var isRunning        = false
    @State private var phase: BreathPhase = .idle
    @State private var phaseStart: Date = .now
    @State private var sessionStart: Date = .now
    @State private var selectedDuration = 120
    @State private var sessionComplete  = false
    @State private var showFocusOverlay = false

    @State private var breathTimer:     Timer?
    @State private var celebrationStart: Date? = nil

    @State private var orb = BreathOrb()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Label("Mindfulness Corner", systemImage: "wind")
                .font(.headline)

            Text("Box breathing (4-4-6-2) calms your nervous system in minutes.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            durationPicker

            OrbCanvasView(
                orb:              orb,
                phase:            .idle,
                phaseStart:       .now,
                isRunning:        false,
                celebrationStart: nil
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .frame(maxHeight: 180)
            .contentShape(Rectangle())
            .onTapGesture { startAndOpen() }
            .overlay(alignment: .center) {
                Label("Start session", systemImage: "play.fill")
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.indigo)
                    .clipShape(Capsule())
                    .shadow(color: .indigo.opacity(0.4), radius: 12, x: 0, y: 6)
                    .allowsHitTesting(false)
            }

            Divider()
            quickTips
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
        .fullScreenCover(isPresented: $showFocusOverlay, onDismiss: stopAndReset) {
            MindfulnessFocusOverlay(
                orb:              orb,
                phase:            $phase,
                phaseStart:       $phaseStart,
                sessionStart:     $sessionStart,
                isRunning:        $isRunning,
                sessionComplete:  $sessionComplete,
                celebrationStart: $celebrationStart,
                selectedDuration: selectedDuration,
                onStop: {
                    showFocusOverlay = false
                }
            )
        }
    }

    // MARK: Sub-views

    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Session duration").font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(durationOptions, id: \.seconds) { opt in
                    Button(action: { selectedDuration = opt.seconds }) {
                        Text(opt.label)
                            .font(.subheadline).fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedDuration == opt.seconds
                                        ? Color.indigo
                                        : Color.primary.opacity(0.07))
                            .foregroundStyle(selectedDuration == opt.seconds
                                             ? Color.white
                                             : Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var quickTips: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Mindfulness Tips").font(.subheadline).fontWeight(.semibold)
            MindfulnessTipRow(icon: "5.square.fill", color: .teal,
                title: "5-4-3-2-1 Grounding",
                description: "Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste.")
            MindfulnessTipRow(icon: "figure.mind.and.body", color: .indigo,
                title: "Body Scan",
                description: "Slowly move attention from your feet to your head, releasing tension in each area.")
            MindfulnessTipRow(icon: "sun.horizon.fill", color: .orange,
                title: "Gratitude Pause",
                description: "Think of three things you're grateful for today — even tiny ones count.")
        }
    }

    // MARK: Session control

    private func startAndOpen() {
        sessionComplete  = false
        celebrationStart = nil
        sessionStart     = .now
        isRunning        = true
        advancePhase(to: .inhale)
        showFocusOverlay = true
    }

    private func stopAndReset() {
        isRunning        = false
        sessionComplete  = false
        celebrationStart = nil
        breathTimer?.invalidate(); breathTimer = nil
        phase = .idle
        orb.resetChaos()
    }

    func advancePhase(to next: BreathPhase) {
        if Date().timeIntervalSince(sessionStart) >= Double(selectedDuration) {
            complete(); return
        }
        phase      = next
        phaseStart = .now
        breathTimer?.invalidate()
        guard next.duration > 0 else { return }
        breathTimer = Timer.scheduledTimer(withTimeInterval: next.duration, repeats: false) { _ in
            guard isRunning else { return }
            advancePhase(to: next.next)
        }
    }

    func complete() {
        isRunning       = false
        sessionComplete = true
        breathTimer?.invalidate(); breathTimer = nil
        phase = .idle
        celebrationStart = .now
        breathTimer = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: false) { _ in
            celebrationStart = nil
            orb.resetChaos()
        }
    }
}

// MARK: - Full-Screen Focus Overlay

struct MindfulnessFocusOverlay: View {

    let orb:              BreathOrb
    @Binding var phase:            MindfulnessCornerView.BreathPhase
    @Binding var phaseStart:       Date
    @Binding var sessionStart:     Date
    @Binding var isRunning:        Bool
    @Binding var sessionComplete:  Bool
    @Binding var celebrationStart: Date?
    let selectedDuration:          Int
    let onStop:                    () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            RadialGradient(
                colors: [
                    phaseAccentColor.opacity(0.18),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5), value: phase)

            VStack(spacing: 0) {

                HStack {
                    Spacer()
                    Button(action: onStop) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(12)
                            .background(.white.opacity(0.10))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                OrbCanvasView(
                    orb:              orb,
                    phase:            phase,
                    phaseStart:       phaseStart,
                    isRunning:        isRunning,
                    celebrationStart: celebrationStart
                )
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 6) {
                    Text(sessionComplete ? "Session complete" : phase.label)
                        .font(.title2).fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .animation(.easeInOut(duration: 0.3), value: phase.label)

                    Text(sessionComplete ? "Well done — take a moment to notice how you feel." : phase.subLabel)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.3), value: phase.subLabel)
                }
                .padding(.horizontal, 32)

                sessionProgressBar
                    .padding(.horizontal, 32)
                    .padding(.top, 28)

                Button(action: onStop) {
                    Text(sessionComplete ? "Done" : "End session")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.45))
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Helpers

    private var phaseAccentColor: Color {
        switch phase {
        case .idle:    return Color(hue: 220/360, saturation: 0.5, brightness: 0.6)
        case .inhale:  return Color(hue: 185/360, saturation: 0.6, brightness: 0.6)
        case .holdIn:  return Color(hue: 200/360, saturation: 0.5, brightness: 0.6)
        case .exhale:  return Color(hue: 270/360, saturation: 0.5, brightness: 0.6)
        case .holdOut: return Color(hue: 240/360, saturation: 0.5, brightness: 0.6)
        }
    }

    private var sessionProgressBar: some View {
        TimelineView(.periodic(from: sessionStart, by: 1)) { tl in
            let elapsed  = tl.date.timeIntervalSince(sessionStart)
            let progress = min(elapsed / Double(selectedDuration), 1.0)
            let rem      = max(0, selectedDuration - Int(elapsed))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Session progress")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                    Text(String(format: "%d:%02d", rem / 60, rem % 60))
                        .font(.caption).fontWeight(.medium).monospacedDigit()
                        .foregroundStyle(.white.opacity(0.6))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.10))
                            .frame(height: 4)
                        Capsule()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: geo.size.width * progress, height: 4)
                            .animation(.linear(duration: 1), value: progress)
                    }
                }
                .frame(height: 4)
            }
        }
    }
}

// MARK: - Particle data (value type, mutated by OrbCanvasView each frame)

struct BreathParticle {
    let index:           Int
    let baseAngle:       Double

    var chaosAngle:      Double
    var chaosRadius:     Double
    var chaosSpeed:      Double
    var chaosWobbleAmp:  Double
    var chaosWobblePhase:Double

    let size:            Double
    let opacityBase:     Double

    var trail:           [CGPoint] = []

    static func make(index: Int, total: Int) -> BreathParticle {
        BreathParticle(
            index:            index,
            baseAngle:        Double(index) / Double(total) * .pi * 2,
            chaosAngle:       Double.random(in: 0 ..< .pi * 2),
            chaosRadius:      Double.random(in: 20 ..< 90),
            chaosSpeed:       Double.random(in: -0.018 ..< 0.018),
            chaosWobbleAmp:   Double.random(in: 0   ..< 0.8),
            chaosWobblePhase: Double.random(in: 0   ..< .pi * 2),
            size:             Double.random(in: 2.5 ..< 5.0),
            opacityBase:      Double.random(in: 0.35 ..< 0.9)
        )
    }

    mutating func resetChaos() {
        chaosAngle  = Double.random(in: 0 ..< .pi * 2)
        chaosRadius = Double.random(in: 20 ..< 90)
        chaosSpeed  = Double.random(in: -0.018 ..< 0.018)
        trail       = []
    }
}

// MARK: - Orb state (reference type so Canvas can mutate without triggering SwiftUI diff)

final class BreathOrb {
    static let particleCount  = 120
    static let maxTrailLength = 8

    var particles: [BreathParticle]

    init() {
        particles = (0 ..< Self.particleCount).map {
            BreathParticle.make(index: $0, total: Self.particleCount)
        }
    }

    func resetChaos() {
        for i in particles.indices { particles[i].resetChaos() }
    }

    static func checkmarkTargets(cx: Double, cy: Double, size: Double) -> [CGPoint] {
        let s  = size * 0.55
        let p0 = CGPoint(x: cx + s * -0.42, y: cy + s *  0.05)
        let p1 = CGPoint(x: cx + s * -0.10, y: cy + s *  0.42)
        let p2 = CGPoint(x: cx + s *  0.44, y: cy + s * -0.38)

        let leftCount  = Int(Double(particleCount) * 0.35)
        let rightCount = particleCount - leftCount

        var pts = [CGPoint]()
        pts.reserveCapacity(particleCount)
        for i in 0 ..< leftCount {
            let t = Double(i) / Double(leftCount)
            pts.append(CGPoint(x: p0.x + (p1.x - p0.x) * t, y: p0.y + (p1.y - p0.y) * t))
        }
        for i in 0 ..< rightCount {
            let t = Double(i) / Double(rightCount)
            pts.append(CGPoint(x: p1.x + (p2.x - p1.x) * t, y: p1.y + (p2.y - p1.y) * t))
        }
        return pts
    }
}

// MARK: - Canvas renderer

struct OrbCanvasView: View {
    let orb:               BreathOrb
    let phase:             MindfulnessCornerView.BreathPhase
    let phaseStart:        Date
    let isRunning:         Bool
    let celebrationStart:  Date?

    @State private var globalStart: Date = .now

    private var isPaused: Bool { !isRunning && celebrationStart == nil }

    var body: some View {
        TimelineView(.animation(paused: isPaused)) { tl in
            Canvas { ctx, size in
                let gT = tl.date.timeIntervalSince(globalStart)
                if let cs = celebrationStart {
                    drawCelebration(ctx: ctx, size: size, now: tl.date,
                                    celebStart: cs, globalT: gT)
                } else {
                    draw(ctx: ctx, size: size, now: tl.date, globalT: gT)
                }
            }
        }
        .onAppear { globalStart = .now }
    }

    // MARK: Draw

    private func draw(ctx: GraphicsContext, size: CGSize, now: Date, globalT: Double) {
        let cx = size.width  / 2
        let cy = size.height / 2

        let maxR: Double = min(cx, cy) * 0.62
        let minR: Double = maxR * 0.22

        let phaseElapsed = now.timeIntervalSince(phaseStart)
        let rawT         = phase.duration > 0 ? min(phaseElapsed / phase.duration, 1.0) : 1.0
        let smooth       = eSin(rawT)

        let (blendT, circleR): (Double, Double) = {
            guard isRunning else { return (0.0, minR) }
            switch phase {
            case .idle:
                return (0.0, minR + sin(globalT * 1.6) * (minR * 0.07))
            case .inhale:
                let s = eSin(smooth)
                return (s, lerp(minR, maxR, s))
            case .holdIn:
                return (1.0, maxR + sin(globalT * 1.8) * (maxR * 0.015))
            case .exhale:
                let s = eSin(smooth)
                return (1.0 - s, lerp(maxR, minR, s))
            case .holdOut:
                return (0.0, minR + sin(globalT * 1.6) * (minR * 0.07))
            }
        }()

        let hue       = isRunning ? phase.hue : 220.0
        let glowPulse = isRunning ? 0.5 + 0.5 * sin(globalT * 2.5) : 0.0

        if isRunning && blendT > 0.05 {
            let glowR = circleR * 1.3
            let grad  = Gradient(stops: [
                .init(color: hslColor(hue, 0.70, 0.55, blendT * 0.20), location: 0),
                .init(color: hslColor(hue, 0.70, 0.55, 0),             location: 1),
            ])
            ctx.fill(
                Path(ellipseIn: CGRect(x: cx - glowR, y: cy - glowR,
                                       width: glowR * 2, height: glowR * 2)),
                with: .radialGradient(grad,
                                      center: CGPoint(x: cx, y: cy),
                                      startRadius: circleR * 0.3,
                                      endRadius: glowR)
            )
        }

        if isRunning && blendT > 0.7 {
            let alpha = (blendT - 0.7) / 0.3 * 0.25 + glowPulse * 0.08
            ctx.stroke(
                Path(ellipseIn: CGRect(x: cx - circleR, y: cy - circleR,
                                       width: circleR * 2, height: circleR * 2)),
                with: .color(hslColor(hue, 0.65, 0.60, alpha)),
                style: StrokeStyle(lineWidth: 1.5 + blendT * 2, lineCap: .round)
            )
        }

        let rotOffset = globalT * (isRunning ? 0.08 : 0.02)
        let trailLen  = max(1, Int(blendT * 6 + (1 - blendT) * 2))
        let b3        = pow(blendT, 0.6)

        for i in orb.particles.indices {
            orb.particles[i].chaosAngle += orb.particles[i].chaosSpeed

            let p            = orb.particles[i]
            let scaledChaosR = minR * 0.3 + p.chaosRadius / 90.0 * (minR * 1.6)
            let wobble       = sin(globalT * 1.3 + p.chaosWobblePhase) * p.chaosWobbleAmp * (minR * 0.35) * (1 - blendT)
            let chaosX       = cx + cos(p.chaosAngle) * (scaledChaosR + wobble)
            let chaosY       = cy + sin(p.chaosAngle) * (scaledChaosR + wobble)

            let circAngle = p.baseAngle + rotOffset
            let circX     = cx + cos(circAngle) * circleR
            let circY     = cy + sin(circAngle) * circleR

            let tx = lerp(chaosX, circX, b3)
            let ty = lerp(chaosY, circY, b3)

            orb.particles[i].trail.append(CGPoint(x: tx, y: ty))
            if orb.particles[i].trail.count > BreathOrb.maxTrailLength {
                orb.particles[i].trail.removeFirst()
            }

            if isRunning && blendT > 0.05 {
                let trail    = orb.particles[i].trail
                let startIdx = max(0, trail.count - trailLen)
                for t in startIdx ..< trail.count - 1 {
                    let tf = Double(t - startIdx) / Double(max(trailLen, 1))
                    let ta = p.opacityBase * tf * blendT * 0.3
                    guard ta > 0.005 else { continue }
                    var seg = Path()
                    seg.move(to: trail[t])
                    seg.addLine(to: trail[t + 1])
                    ctx.stroke(seg,
                               with: .color(hslColor(hue, 0.65, 0.65, ta)),
                               style: StrokeStyle(lineWidth: p.size * tf * 0.7, lineCap: .round))
                }
            }

            let pAlpha = isRunning ? p.opacityBase * 0.85 : p.opacityBase * 0.28
            let pHue   = hue + Double(i) / Double(BreathOrb.particleCount) * 30 - 15
            let pColor = isRunning
                ? hslColor(pHue, 0.65, 0.55 + blendT * 0.10, pAlpha)
                : hslColor(220,  0.15, 0.55,                  pAlpha)

            let ps = p.size * (0.7 + blendT * 0.3)
            ctx.fill(
                Path(ellipseIn: CGRect(x: tx - ps, y: ty - ps, width: ps * 2, height: ps * 2)),
                with: .color(pColor)
            )
        }
    }

    // MARK: Celebration draw

    private static let celebFormDur:    Double = 1.2
    private static let celebHoldDur:    Double = 2.5
    private static let celebScatterDur: Double = 0.8

    private func drawCelebration(ctx: GraphicsContext, size: CGSize, now: Date,
                                  celebStart: Date, globalT: Double) {
        let cx   = size.width  / 2
        let cy   = size.height / 2
        let maxR = min(cx, cy) * 0.62
        let minR = maxR * 0.22

        let elapsed  = now.timeIntervalSince(celebStart)
        let formEnd  = Self.celebFormDur
        let holdEnd  = formEnd + Self.celebHoldDur

        let checkmarkT: Double = {
            if elapsed < formEnd  { return eSin(elapsed / formEnd) }
            if elapsed < holdEnd  { return 1.0 }
            let s = (elapsed - holdEnd) / Self.celebScatterDur
            return 1.0 - eSin(min(s, 1.0))
        }()

        let targets  = BreathOrb.checkmarkTargets(cx: cx, cy: cy, size: maxR * 2)
        let tealHue  = 175.0

        for i in orb.particles.indices {
            orb.particles[i].chaosAngle += orb.particles[i].chaosSpeed * (1 - checkmarkT)

            let p        = orb.particles[i]
            let scaledCR = minR * 0.3 + p.chaosRadius / 90.0 * (minR * 1.6)
            let wobble   = sin(globalT * 1.3 + p.chaosWobblePhase) * p.chaosWobbleAmp * (minR * 0.35) * (1 - checkmarkT)
            let chaosX   = cx + cos(p.chaosAngle) * (scaledCR + wobble)
            let chaosY   = cy + sin(p.chaosAngle) * (scaledCR + wobble)

            let target = targets[i]
            let tx = lerp(chaosX, target.x, checkmarkT)
            let ty = lerp(chaosY, target.y, checkmarkT)

            let pHue   = lerp(240.0, tealHue, checkmarkT)
            let pAlpha = lerp(0.35, 0.92, checkmarkT) * p.opacityBase
            let ps     = p.size * lerp(0.85, 1.15, checkmarkT)

            if checkmarkT > 0.75 {
                let glowA = (checkmarkT - 0.75) / 0.25 * 0.10 * p.opacityBase
                ctx.fill(
                    Path(ellipseIn: CGRect(x: tx - ps * 3, y: ty - ps * 3,
                                           width: ps * 6, height: ps * 6)),
                    with: .color(hslColor(tealHue, 0.70, 0.65, glowA))
                )
            }

            ctx.fill(
                Path(ellipseIn: CGRect(x: tx - ps, y: ty - ps, width: ps * 2, height: ps * 2)),
                with: .color(hslColor(pHue, 0.70, 0.60, pAlpha))
            )
        }
    }

    // MARK: Math

    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * t }
    private func eSin(_ t: Double) -> Double { 0.5 - 0.5 * cos(.pi * t) }

    private func hslColor(_ h: Double, _ s: Double, _ l: Double, _ a: Double) -> Color {
        let hNorm      = h.truncatingRemainder(dividingBy: 360) / 360
        let brightness = l + s * min(l, 1 - l)
        let saturation = brightness == 0 ? 0 : 2 * (1 - l / brightness)
        return Color(hue: hNorm, saturation: saturation, brightness: brightness, opacity: a)
    }
}

// MARK: - Mindfulness tip row

struct MindfulnessTipRow: View {
    let icon:        String
    let color:       Color
    let title:       String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3).foregroundStyle(color).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).fontWeight(.medium)
                Text(description)
                    .font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Stress Info & Article Links

struct StressInfoView: View {
    @State private var expandedSection: String? = nil

    struct StressFact: Identifiable {
        let id = UUID()
        let icon: String; let color: Color
        let title: String; let detail: String
    }
    struct ArticleLink: Identifiable {
        let id = UUID()
        let icon: String; let color: Color
        let category: String; let title: String
        let url: String; let source: String
    }

    private let facts: [StressFact] = [
        StressFact(icon: "heart.fill",          color: .red,
            title: "Cardiovascular System",
            detail: "Chronic stress raises cortisol, increasing heart rate and blood pressure. Over time it raises the risk of hypertension, heart attack, and stroke."),
        StressFact(icon: "brain.head.profile",  color: .purple,
            title: "Brain & Memory",
            detail: "Prolonged cortisol exposure shrinks the hippocampus, impairing memory consolidation and increasing risk of anxiety and depression."),
        StressFact(icon: "lungs.fill",          color: .teal,
            title: "Immune System",
            detail: "Stress suppresses immune cell activity, making you more susceptible to colds, infections, and slowing wound healing."),
        StressFact(icon: "leaf",                color: .orange,
            title: "Digestive System",
            detail: "The gut-brain axis means stress can cause nausea, IBS flares, appetite changes, and disrupt the gut microbiome."),
        StressFact(icon: "moon.zzz.fill",       color: .indigo,
            title: "Sleep",
            detail: "Elevated cortisol at night disrupts sleep architecture, reducing restorative deep sleep and creating a feedback loop of fatigue and stress."),
        StressFact(icon: "figure.walk",         color: .green,
            title: "Muscles & Posture",
            detail: "Stress causes muscles to tense as a protective reflex. Chronic tension leads to headaches, neck pain, and lower back pain."),
    ]

    private let articles: [ArticleLink] = [
        ArticleLink(icon: "brain",                  color: .purple,
            category: "Depression", title: "What is Depression?",
            url: "https://www.nimh.nih.gov/health/topics/depression",
            source: "NIH · National Institute of Mental Health"),
        ArticleLink(icon: "waveform.path.ecg",      color: .blue,
            category: "Anxiety", title: "Anxiety Disorders Overview",
            url: "https://www.nimh.nih.gov/health/topics/anxiety-disorders",
            source: "NIH · National Institute of Mental Health"),
        ArticleLink(icon: "bolt.heart.fill",        color: .red,
            category: "Stress", title: "Stress and Your Health",
            url: "https://medlineplus.gov/stress.html",
            source: "MedlinePlus · U.S. National Library of Medicine"),
        ArticleLink(icon: "moon.stars.fill",        color: .indigo,
            category: "Sleep", title: "Stress & Insomnia",
            url: "https://www.helpguide.org/wellness/sleep/insomnia-causes-and-cures",
            source: "HelpGuide"),
        ArticleLink(icon: "person.2.fill",          color: .teal,
            category: "Burnout", title: "Recognising Burnout",
            url: "https://www.helpguide.org/mental-health/stress/burnout-prevention-and-recovery",
            source: "HelpGuide"),
        ArticleLink(icon: "heart.text.square.fill", color: .pink,
            category: "Self-Care", title: "Coping with Stress",
            url: "https://www.nimh.nih.gov/health/publications/so-stressed-out-fact-sheet",
            source: "NIH · National Institute of Mental Health"),
        ArticleLink(icon: "phone.fill", color: .green,
            category: "Crisis", title: "Find Mental Health Support",
            url: "https://www.nimh.nih.gov/health/find-help",
            source: "NIH · National Institute of Mental Health"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Understanding Stress", systemImage: "staroflife.fill").font(.headline)

            Text("Stress is your body's response to pressure. Short-term stress can be helpful — but chronic stress impacts nearly every system in your body.")
                .font(.callout).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 8) {
                ForEach(facts) { fact in
                    StressFactRow(fact: fact,
                                  isExpanded: expandedSection == fact.id.uuidString) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedSection = expandedSection == fact.id.uuidString
                                ? nil : fact.id.uuidString
                        }
                    }
                }
            }

            Divider().padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 10) {
                Label("Helpful Resources & Articles", systemImage: "link")
                    .font(.subheadline).fontWeight(.semibold)
                ForEach(Array(articles.enumerated()), id: \.element.id) { idx, article in
                    ArticleLinkRow(article: article, showDivider: idx < articles.count - 1)
                }
            }

            Text("The information above is educational only and is not a substitute for professional medical advice. If you're in crisis, please contact a qualified mental health professional.")
                .font(.caption2).foregroundStyle(.tertiary)
                .multilineTextAlignment(.leading).padding(.top, 4)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

struct StressFactRow: View {
    let fact: StressInfoView.StressFact
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: fact.icon)
                        .font(.body).foregroundStyle(fact.color).frame(width: 26)
                    Text(fact.title)
                        .font(.subheadline).fontWeight(.medium).foregroundStyle(.primary)
                    Spacer(minLength: 0)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(.vertical, 10).padding(.horizontal, 12)

                if isExpanded {
                    Text(fact.detail)
                        .font(.caption).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12).padding(.bottom, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(fact.color.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ArticleLinkRow: View {
    let article: StressInfoView.ArticleLink
    let showDivider: Bool

    var body: some View {
        VStack(spacing: 0) {
            Link(destination: URL(string: article.url)!) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(article.color.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: article.icon)
                            .font(.callout).foregroundStyle(article.color)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(article.category.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(article.color).tracking(1)
                        Text(article.title)
                            .font(.subheadline).fontWeight(.medium).foregroundStyle(.primary)
                        Text(article.source)
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            if showDivider { Divider().padding(.leading, 48) }
        }
    }
}
