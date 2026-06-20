import SwiftUI
import SwiftData
import PhotosUI
import CoreLocation
import MusicKit
import Combine

final class CardZoomState: ObservableObject {
    static let shared = CardZoomState()
    @Published var isZoomed = false
}

// MARK: - Award Badge View

struct AwardBadgeView: View {
    let type: AwardType
    var size: CGFloat = 28

    var body: some View {
        switch type {
        case .beganSomething:         NewBeginningsBadge(size: size)
        case .spentTimeInNature:          TouchedGrassBadge(size: size)

        case .practicedMindfulness:           MindfulnessBadge(size: size)
        case .prioritisedSleep:              RestWellBadge(size: size)
        case .satWithUncertainty:    SatWithUncertaintyBadge(size: size)
        case .restedWithoutGuilt:     SleptWithoutGuiltBadge(size: size)
        case .heroicNapper:          HeroicNapperBadge(size: size)
        case .learnedSomethingNew:          FedCuriosityBadge(size: size)

        case .handledDifficulty:  OvercomingDifficultyBadge(size: size)
        case .keptGoing:             KeptGoingBadge(size: size)
        case .steppedOutsideComfort:           ComfortZoneBadge(size: size)
        case .movedYourBody:          StayedActiveBadge(size: size)
        case .finishedSomething:         FinishedTasksBadge(size: size)
        case .celebratedAWin:          GoalAchievedBadge(size: size)
        case .showedUpForYourself:   ShowedUpForYourselfBadge(size: size)

        case .connectedWithSomeone:       MadeConnectionsBadge(size: size)
        case .madeAmends:            MadeAmendsBadge(size: size)
        case .askedForHelp:            ReachedOutBadge(size: size)
        case .reachedOutFirst:       ReachedOutFirstBadge(size: size)
        case .helpedOthers:          HelpedOthersBadge(size: size)

        case .saidNo:                SaidNoBadge(size: size)
        case .setABoundary:         SetBoundariesBadge(size: size)
        case .forgivingYourself:     ForgivingYourselfBadge(size: size)

        case .ateWell:     NourishedYourselfBadge(size: size)
        case .disconnectedFromScreens: DisconnectedFromScreensBadge(size: size)

        case .createdSomething:      CreatedSomethingBadge(size: size)

        case .criedItOut:            CriedItOutBadge(size: size)

        case .blewUpMicrowave:       BlewUpMicrowaveBadge(size: size)
        case .sangInTheShower:       SangInTheShowerBadge(size: size)
        case .doomScrolled:          DoomScrolledBadge(size: size)
        case .lostASock:             LostASockBadge(size: size)
        case .breakfastPizza:        BreakfastPizzaBadge(size: size)
        case .autocorrectDisaster:   AutocorrectDisasterBadge(size: size)
        case .rememberedADream:      RememberedADreamBadge(size: size)
        case .guessedTimeCorrectly:  GuessedTimeCorrectlyBadge(size: size)
        case .droppedPhoneOnFace:    DroppedPhoneOnFaceBadge(size: size)

        default:
            Text(type.medal)
                .font(.system(size: size * 0.65))
        }
    }
}

// MARK: - Journal Tab Root

struct JournalTab: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]

    @State private var viewModel            = JournalViewModel()
    @State private var showNewEntry         = false
    @State private var showStatsAndSearch   = false
    @State private var pendingAwards:  [Award] = []
    @State private var currentAward:   Award?  = nil

    private var streakCount: Int {
        var streak = 0
        var day = Calendar.current.startOfDay(for: Date())
        let sortedDates = entries.map { Calendar.current.startOfDay(for: $0.date) }.sorted().reversed()
        for entryDay in sortedDates {
            if entryDay == day { streak += 1; day = Calendar.current.date(byAdding: .day, value: -1, to: day)! }
            else if entryDay < day { break }
        }
        return streak
    }

    var groupedEntries: [(String, [JournalEntry])] {
        let cal = Calendar.current
        var groups: [(String, [JournalEntry])] = []
        var seen: [String: [JournalEntry]] = [:]
        var order: [String] = []

        for entry in entries {
            let label: String
            if cal.isDateInToday(entry.date)     { label = "Today" }
            else if cal.isDateInYesterday(entry.date) { label = "Yesterday" }
            else if let days = cal.dateComponents([.day], from: entry.date, to: Date()).day, days < 7 {
                label = "This Week"
            } else {
                label = entry.date.formatted(.dateTime.month(.wide).year())
            }
            if seen[label] == nil { order.append(label); seen[label] = [] }
            seen[label]!.append(entry)
        }
        return order.map { ($0, seen[$0]!) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                JournalGradientBackground()

                if entries.isEmpty {
                    EmptyJournalView()
                } else {
                    List {
                        ForEach(groupedEntries, id: \.0) { section, sectionEntries in
                            Section {
                                ForEach(sectionEntries) { entry in
                                    ZStack {
                                        NavigationLink(destination: EntryDetailView(entry: entry)) {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                        .contextMenu {
                                            Button(role: .destructive) { deleteEntry(entry) } label: {
                                                Label("Delete Entry", systemImage: "trash")
                                            }
                                        }
                                        EntryRowView(entry: entry)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) { deleteEntry(entry) } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            } header: {
                                Text(section)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.primary)
                                    .textCase(nil)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Moody")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: StatsAndSearchView(
                        entries: entries,
                        totalEntries: entries.count,
                        streak: streakCount
                    )) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showNewEntry = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.indigo)
                    }
                }
            }
            .sheet(isPresented: $showNewEntry) {
                NewEntryView(viewModel: viewModel) {
                    showNewEntry = false
                    Task {
                        await viewModel.saveEntry(using: context)
                        try? await Task.sleep(for: .milliseconds(400))
                        if let latest = entries.first, !latest.awards.isEmpty {
                            pendingAwards = Array(latest.awards)
                            showNextMedal()
                        }
                    }
                }
            }
            .overlay {
                if let award = currentAward {
                    MedalPresentationView(award: award) {
                        withAnimation(.easeOut(duration: 0.3)) { currentAward = nil }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { showNextMedal() }
                    }
                    .id(award.id)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .opacity.combined(with: .move(edge: .bottom))
                    ))
                    .zIndex(100)
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentAward?.id)
        }
    }

    private func showNextMedal() {
        guard !pendingAwards.isEmpty else { return }
        currentAward = pendingAwards.removeFirst()
    }

    private func deleteEntry(_ entry: JournalEntry) {
        context.delete(entry)
    }
}

// MARK: - Stats & Search Page

struct StatsAndSearchView: View {
    let entries: [JournalEntry]
    let totalEntries: Int
    let streak: Int

    @State private var searchText = ""
    @FocusState private var searchFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var filteredEntries: [JournalEntry] {
        guard !searchText.isEmpty else { return [] }
        return entries.filter {
            $0.text.localizedCaseInsensitiveContains(searchText) ||
            $0.mood.label.localizedCaseInsensitiveContains(searchText) ||
            ($0.locationName ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.musicTitle ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            JournalGradientBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // MARK: Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("", text: $searchText,
                                  prompt: Text("Search entries, places, songs…")
                                      .foregroundColor(.secondary.opacity(0.6)))
                            .textFieldStyle(.plain)
                            .foregroundStyle(.primary)
                            .focused($searchFocused)
                            .submitLabel(.search)
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .background(.ultraThinMaterial.opacity(0.5))
                    .background(Color(.secondarySystemBackground).opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color(.separator).opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // MARK: Search results (when typing)
                    if !searchText.isEmpty {
                        if filteredEntries.isEmpty {
                            NoResultsView(query: searchText)
                                .padding(.top, 20)
                        } else {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(filteredEntries.count) result\(filteredEntries.count == 1 ? "" : "s")")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)

                                ForEach(filteredEntries) { entry in
                                    NavigationLink(destination: EntryDetailView(entry: entry)) {
                                        EntryRowView(entry: entry)
                                            .padding(.horizontal, 20)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    } else {
                        // MARK: Stats section (shown when not searching)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Stats")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 20)

                            HStack(spacing: 14) {
                                StatsCard(
                                    icon: "book.closed.fill",
                                    iconColor: .indigo,
                                    value: "\(totalEntries)",
                                    label: "Total Entries"
                                )
                                StatsCard(
                                    icon: "flame.fill",
                                    iconColor: streak > 0 ? .orange : Color(.tertiaryLabel),
                                    value: "\(streak)",
                                    label: "Day Streak"
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Search & Stats")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { searchFocused = true }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Stats Card

struct StatsCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color(.separator).opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Refined Entry Row

struct EntryRowView: View {
    let entry: JournalEntry
    @AppStorage("settings_compactRows") private var compactRows = false
    @AppStorage("settings_showMoodOnRow") private var showMoodOnRow  = true

    private var moodAccentColor: Color {
        switch entry.mood {
        case .great:    return .orange
        case .good:     return .yellow
        case .okay:     return .mint
        case .bad:      return .blue
        case .terrible: return .purple
        default:        return .indigo
        }
    }

    var body: some View {
        if compactRows {
            compactRow
        } else {
            fullRow
        }
    }

    // MARK: Full Row (existing layout)
    private var fullRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(moodAccentColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    MoodIcon(mood: entry.mood, animated: false)
                        .font(.title3)
                }
                VStack(alignment: .leading, spacing: 2) {
                    if showMoodOnRow {
                        Text(entry.mood.label)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    if entry.musicTitle != nil {
                        MiniChip(icon: "music.note", label: "")
                    }
                    if entry.locationName != nil {
                        MiniChip(icon: "location.fill", label: "")
                    }
                }
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
            }

            if entry.text.isEmpty {
                Label(
                    entry.audioData != nil ? "Voice note" : "Photo entry",
                    systemImage: entry.audioData != nil ? "waveform" : "photo.on.rectangle"
                )
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            } else {
                Text(entry.text)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }

            if !entry.mediaData.isEmpty {
                AdaptiveMediaGrid(mediaData: entry.mediaData)
            }

            let hasContext = entry.locationName != nil || entry.musicTitle != nil || !entry.awards.isEmpty
            if hasContext {
                HStack(spacing: 6) {
                    if let loc = entry.locationName {
                        ContextTag(icon: "location.fill", text: loc, color: .cyan)
                    }
                    if let song = entry.musicTitle {
                        ContextTag(icon: "music.note", text: song, color: .pink)
                    }
                    Spacer()
                    if !entry.awards.isEmpty {
                        ForEach(entry.awards.prefix(4), id: \.id) { award in
                            AwardPill(award: award)
                        }
                        if entry.awards.count > 4 {
                            Text("+\(entry.awards.count - 4)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(moodAccentColor.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }

    // MARK: Compact Row
    private var compactRow: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(moodAccentColor.opacity(0.15))
                    .frame(width: 34, height: 34)
                MoodIcon(mood: entry.mood, animated: false)
                    .font(.callout)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    if showMoodOnRow {
                        Text(entry.mood.label)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    Text(entry.date.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                        .font(.system(size: showMoodOnRow ? 11 : 13, weight: showMoodOnRow ? .regular : .medium))
                        .foregroundStyle(showMoodOnRow ? .secondary : .primary)
                    Spacer(minLength: 4)
                    if !entry.awards.isEmpty {
                        AwardBadgeView(type: entry.awards[0].type, size: 20)
                    }
                }

                if entry.text.isEmpty {
                    Label(
                        entry.audioData != nil ? "Voice note" : "Photo entry",
                        systemImage: entry.audioData != nil ? "waveform" : "photo.on.rectangle"
                    )
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)
                } else {
                    Text(entry.text)
                        .font(.system(size: 13))
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                        .truncationMode(.tail)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(moodAccentColor.opacity(0.10), lineWidth: 1)
                )
        }
    }
}

// MARK: - Mini Chips & Tags

struct MiniChip: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 9, weight: .semibold))
            }
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Capsule().fill(Color(.quaternarySystemFill)))
    }
}

struct ContextTag: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(color.opacity(0.08)))
    }
}

// MARK: - Award Pill

struct AwardPill: View {
    let award: Award
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        AwardBadgeView(type: award.type, size: 22)
            .padding(.horizontal, 4)
            .padding(.vertical, 3)
    }
}

// MARK: - Photo Slideshow (Card Fan with scroll transition)

struct PhotoSlideshowView: View {
    let images: [UIImage]
    let initialIndex: Int
    let onDismiss: () -> Void

    @State private var currentIndex: Int?
    @State private var isZoomed = false

    init(images: [UIImage], initialIndex: Int, onDismiss: @escaping () -> Void) {
        self.images = images
        self.initialIndex = initialIndex
        self.onDismiss = onDismiss
        _currentIndex = State(initialValue: initialIndex as Int?)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    ForEach(images.indices, id: \.self) { i in
                        CardView(image: images[i], isInteractive: true)
                            .frame(
                                width: UIScreen.main.bounds.width - 80,
                                height: UIScreen.main.bounds.height * 0.72
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .scrollTransition(axis: .horizontal) { content, phase in
                                content
                                    .rotationEffect(.degrees(phase.value * 5))
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                    .opacity(phase.isIdentity ? 1.0 : 0.55)
                                    .offset(y: phase.isIdentity ? 0 : 16)
                            }
                            .id(i)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 40)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $currentIndex)
            .scrollDisabled(CardZoomState.shared.isZoomed)
            .onReceive(CardZoomState.shared.$isZoomed) { zoomed in
                isZoomed = zoomed
            }
            .ignoresSafeArea()

            if images.count > 1 {
                HStack(spacing: 6) {
                    ForEach(images.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == (currentIndex ?? 0) ? Color.white : Color.white.opacity(0.3))
                            .frame(width: i == (currentIndex ?? 0) ? 20 : 6, height: 6)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                    }
                }
                .padding(.bottom, 52)
            }
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Button(action: onDismiss) {
                    ZStack {
                        Circle().fill(.black.opacity(0.5)).frame(width: 36, height: 36)
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                Spacer()
                if images.count > 1 {
                    Text("\((currentIndex ?? 0) + 1) / \(images.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.black.opacity(0.4)))
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: currentIndex)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .statusBarHidden()
    }
}

// MARK: - Dominant color extractor

extension UIImage {
    func dominantColors(count: Int = 2) -> [Color] {
        guard let cgImage = self.cgImage else { return [.black, .gray] }

        let size = CGSize(width: 16, height: 16)
        let ctx = CGContext(
            data: nil,
            width: Int(size.width), height: Int(size.height),
            bitsPerComponent: 8, bytesPerRow: Int(size.width) * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        ctx?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let data = ctx?.data else { return [.black, .gray] }

        let pixels = data.bindMemory(to: UInt8.self, capacity: Int(size.width * size.height) * 4)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0

        let topCount = Int(size.width) * Int(size.height / 3)
        for i in 0..<topCount {
            r += CGFloat(pixels[i * 4])
            g += CGFloat(pixels[i * 4 + 1])
            b += CGFloat(pixels[i * 4 + 2])
        }
        let c1 = Color(
            red:   Double(r / CGFloat(topCount)) / 255,
            green: Double(g / CGFloat(topCount)) / 255,
            blue:  Double(b / CGFloat(topCount)) / 255
        )

        r = 0; g = 0; b = 0
        let total = Int(size.width) * Int(size.height)
        let botStart = total - topCount
        for i in botStart..<total {
            r += CGFloat(pixels[i * 4])
            g += CGFloat(pixels[i * 4 + 1])
            b += CGFloat(pixels[i * 4 + 2])
        }
        let c2 = Color(
            red:   Double(r / CGFloat(topCount)) / 255,
            green: Double(g / CGFloat(topCount)) / 255,
            blue:  Double(b / CGFloat(topCount)) / 255
        )

        return [c1, c2]
    }
}

// MARK: - Card View (image + gradient background + zoom + pan)

private struct CardView: View {
    let image: UIImage
    let isInteractive: Bool

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private var gradientColors: [Color] { image.dominantColors() }
    private var isZoomedIn: Bool { scale > 1.05 }
    @ObservedObject private var zoomState = CardZoomState.shared

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .top,
                    endPoint: .bottom
                )

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(isInteractive ? magnifyGesture : nil)
                    .highPriorityGesture(
                        isInteractive && isZoomedIn ? panGesture(geo: geo) : nil
                    )
                    .onTapGesture(count: 2) {
                        guard isInteractive else { return }
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            if isZoomedIn { snapToReset() }
                            else { scale = 2.5; lastScale = 2.5 }
                        }
                    }
            }
        }
        .onChange(of: isZoomedIn) { _, zoomed in
            CardZoomState.shared.isZoomed = zoomed
        }
        .onDisappear {
            CardZoomState.shared.isZoomed = false
            snapToReset()
        }
    }

    private func snapToReset() {
        scale = 1; lastScale = 1; offset = .zero; lastOffset = .zero
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in scale = max(1.0, min(lastScale * value, 6.0)) }
            .onEnded { _ in
                if scale < 1.2 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { snapToReset() }
                } else {
                    lastScale = scale
                }
            }
    }

    private func panGesture(geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let maxX = (geo.size.width  * (scale - 1)) / 2
                let maxY = (geo.size.height * (scale - 1)) / 2
                offset = CGSize(
                    width:  (lastOffset.width  + value.translation.width).clamped(to: -maxX...maxX),
                    height: (lastOffset.height + value.translation.height).clamped(to: -maxY...maxY)
                )
            }
            .onEnded { _ in lastOffset = offset }
    }
}

// MARK: - Clamped helper
private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Adaptive Media Grid (read-only)

struct AdaptiveMediaGrid: View {
    let mediaData: [Data]
    var onTapCell: ((Int) -> Void)? = nil

    private let cornerRadius: CGFloat = 12
    private let gap: CGFloat = 3
    @Namespace private var gridNS

    var body: some View {
        let images = mediaData.compactMap { UIImage(data: $0) }
        let count  = images.count

        GeometryReader { geo in
            let w = geo.size.width
            let h = w * 0.6

            gridLayout(images: images, count: count, w: w, h: h)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .frame(width: w, height: h)
                .animation(.spring(response: 0.45, dampingFraction: 0.8), value: count)
        }
        .aspectRatio(1 / 0.6, contentMode: .fit)
    }

    @ViewBuilder
    private func gridLayout(images: [UIImage], count: Int, w: CGFloat, h: CGFloat) -> some View {
        switch count {
        case 1:
            thumb(images[0], dataID: dataID(0), index: 0, w: w, h: h)

        case 2:
            let cw = (w - gap) / 2
            HStack(spacing: gap) {
                thumb(images[0], dataID: dataID(0), index: 0, w: cw, h: h)
                thumb(images[1], dataID: dataID(1), index: 1, w: cw, h: h)
            }

        case 3:
            HStack(spacing: gap) {
                thumb(images[0], dataID: dataID(0), index: 0, w: w * 0.55, h: h)
                VStack(spacing: gap) {
                    thumb(images[1], dataID: dataID(1), index: 1, w: w * 0.45 - gap, h: (h - gap) / 2)
                    thumb(images[2], dataID: dataID(2), index: 2, w: w * 0.45 - gap, h: (h - gap) / 2)
                }
            }

        case 4:
            let cw = (w - gap) / 2; let ch = (h - gap) / 2
            VStack(spacing: gap) {
                HStack(spacing: gap) {
                    thumb(images[0], dataID: dataID(0), index: 0, w: cw, h: ch)
                    thumb(images[1], dataID: dataID(1), index: 1, w: cw, h: ch)
                }
                HStack(spacing: gap) {
                    thumb(images[2], dataID: dataID(2), index: 2, w: cw, h: ch)
                    thumb(images[3], dataID: dataID(3), index: 3, w: cw, h: ch)
                }
            }

        default:
            let sw = (w * 0.45 - gap * 2) / 2; let sh = (h - gap) / 2
            HStack(spacing: gap) {
                thumb(images[0], dataID: dataID(0), index: 0, w: w * 0.55, h: h)
                VStack(spacing: gap) {
                    HStack(spacing: gap) {
                        thumb(images[1], dataID: dataID(1), index: 1, w: sw, h: sh)
                        thumb(images[2], dataID: dataID(2), index: 2, w: sw, h: sh)
                    }
                    HStack(spacing: gap) {
                        thumb(images[3], dataID: dataID(3), index: 3, w: sw, h: sh)
                        ZStack {
                            if let img = images[safe: 4] {
                                Image(uiImage: img)
                                    .resizable().scaledToFill()
                                    .frame(width: sw, height: sh).clipped()
                                    .matchedGeometryEffect(id: dataID(4), in: gridNS)
                            }
                            if count > 5 {
                                Color.black.opacity(0.55)
                                Text("+\(count - 5)")
                                    .font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                            }
                        }
                        .frame(width: sw, height: sh).clipped()
                        .onTapGesture { onTapCell?(4) }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func thumb(_ img: UIImage, dataID: AnyHashable, index: Int, w: CGFloat, h: CGFloat) -> some View {
        Image(uiImage: img)
            .resizable()
            .scaledToFill()
            .frame(width: w, height: h)
            .clipped()
            .matchedGeometryEffect(id: dataID, in: gridNS)
            .contentShape(Rectangle())
            .onTapGesture { onTapCell?(index) }
            .transition(.scale(scale: 0.92).combined(with: .opacity))
    }

    private func dataID(_ index: Int) -> AnyHashable {
        guard index < mediaData.count else { return index }
        let byteHash = mediaData[index].prefix(16).reduce(0) { $0 &* 31 &+ Int($1) }
        return byteHash ^ index
    }
}

// MARK: - Adaptive Media Grid (editable)

struct AdaptiveMediaGridEditable: View {
    let images: [UIImage]
    let onRemove: (Int) -> Void

    private let cornerRadius: CGFloat = 12
    private let gap: CGFloat = 3
    @Namespace private var gridNS
    @State private var slideshowIndex: Int? = nil

    var body: some View {
        let count = images.count

        GeometryReader { geo in
            let w = geo.size.width
            let h = w * 0.6

            editableLayout(count: count, w: w, h: h)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .frame(width: w, height: h)
                .animation(.spring(response: 0.45, dampingFraction: 0.8), value: count)
        }
        .aspectRatio(1 / 0.6, contentMode: .fit)
        .fullScreenCover(item: Binding(
            get: { slideshowIndex.map { SlideshowTarget(index: $0) } },
            set: { slideshowIndex = $0?.index }
        )) { target in
            PhotoSlideshowView(images: images, initialIndex: target.index) {
                slideshowIndex = nil
            }
        }
    }

    @ViewBuilder
    private func editableLayout(count: Int, w: CGFloat, h: CGFloat) -> some View {
        switch count {
        case 1:
            editableThumb(index: 0, w: w, h: h)

        case 2:
            let cw = (w - gap) / 2
            HStack(spacing: gap) {
                editableThumb(index: 0, w: cw, h: h)
                editableThumb(index: 1, w: cw, h: h)
            }

        case 3:
            HStack(spacing: gap) {
                editableThumb(index: 0, w: w * 0.55, h: h)
                VStack(spacing: gap) {
                    editableThumb(index: 1, w: w * 0.45 - gap, h: (h - gap) / 2)
                    editableThumb(index: 2, w: w * 0.45 - gap, h: (h - gap) / 2)
                }
            }

        case 4:
            let cw = (w - gap) / 2; let ch = (h - gap) / 2
            VStack(spacing: gap) {
                HStack(spacing: gap) {
                    editableThumb(index: 0, w: cw, h: ch)
                    editableThumb(index: 1, w: cw, h: ch)
                }
                HStack(spacing: gap) {
                    editableThumb(index: 2, w: cw, h: ch)
                    editableThumb(index: 3, w: cw, h: ch)
                }
            }

        default:
            let sw = (w * 0.45 - gap * 2) / 2; let sh = (h - gap) / 2
            HStack(spacing: gap) {
                editableThumb(index: 0, w: w * 0.55, h: h)
                VStack(spacing: gap) {
                    HStack(spacing: gap) {
                        editableThumb(index: 1, w: sw, h: sh)
                        editableThumb(index: 2, w: sw, h: sh)
                    }
                    HStack(spacing: gap) {
                        editableThumb(index: 3, w: sw, h: sh)
                        ZStack {
                            if let img = images[safe: 4] {
                                Image(uiImage: img)
                                    .resizable().scaledToFill()
                                    .frame(width: sw, height: sh).clipped()
                                    .matchedGeometryEffect(id: stableID(4), in: gridNS)
                            }
                            if images.count > 5 {
                                Color.black.opacity(0.55)
                                Text("+\(images.count - 5)")
                                    .font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                            }
                        }
                        .frame(width: sw, height: sh).clipped()
                        .onTapGesture { slideshowIndex = 4 }
                    }
                }
                .frame(width: w * 0.45 - gap)
            }
        }
    }

    @ViewBuilder
    private func editableThumb(index: Int, w: CGFloat, h: CGFloat) -> some View {
        if index < images.count {
        let img = images[index]

        ZStack(alignment: .topTrailing) {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(width: w, height: h)
                .clipped()
                .matchedGeometryEffect(id: stableID(index), in: gridNS)
                .contentShape(Rectangle())
                .onTapGesture { slideshowIndex = index }

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    onRemove(index)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 4)
            }
            .padding(6)
        }
        .transition(.scale(scale: 0.88).combined(with: .opacity))
        }
    }

    private func stableID(_ index: Int) -> AnyHashable {
        guard index < images.count,
              let data = images[index].jpegData(compressionQuality: 0.05) else { return index }
        let byteHash = data.prefix(12).reduce(0) { $0 &* 31 &+ Int($1) }
        return byteHash ^ index
    }
}

// MARK: - AdaptiveMediaGridWithSlideshow (read-only wrapper)

struct AdaptiveMediaGridWithSlideshow: View {
    let mediaData: [Data]
    @State private var slideshowIndex: Int? = nil

    private var images: [UIImage] { mediaData.compactMap { UIImage(data: $0) } }

    var body: some View {
        AdaptiveMediaGrid(mediaData: mediaData, onTapCell: { idx in
            slideshowIndex = idx
        })
        .fullScreenCover(item: Binding(
            get: { slideshowIndex.map { SlideshowTarget(index: $0) } },
            set: { slideshowIndex = $0?.index }
        )) { target in
            PhotoSlideshowView(images: images, initialIndex: target.index) {
                slideshowIndex = nil
            }
        }
    }
}

private struct SlideshowTarget: Identifiable {
    let index: Int
    var id: Int { index }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - New Entry View (with media, location, music)

struct NewEntryView: View {
    @Bindable var viewModel: JournalViewModel
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var textFocused: Bool

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    @State private var showLocationSearch = false

    @State private var showDatePicker = false

    @State private var showMusicSearch = false
    @State private var musicStatus     = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Mood Meter
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(icon: "face.smiling", text: "Mood Meter")
                        MoodSliderView(mood: $viewModel.draftMood)
                    }

                    // MARK: Text Entry
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(icon: "pencil", text: "Write it out")
                        ZStack(alignment: .topLeading) {
                            if viewModel.draftText.isEmpty {
                                Text("What's on your mind?")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 14)
                                    .padding(.leading, 14)
                            }
                            TextEditor(text: $viewModel.draftText)
                                .focused($textFocused)
                                .frame(minHeight: 180)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                        }
                        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemGroupedBackground)))
                    }

                    // MARK: Date Picker
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(icon: "calendar", text: "Date")
                        Button {
                            showDatePicker.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.indigo)
                                Text(viewModel.draftDate.formatted(date: .complete, time: .omitted))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
                        }
                        .buttonStyle(.plain)
                        if showDatePicker {
                            DatePicker("", selection: $viewModel.draftDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(.indigo)
                                .padding(.horizontal, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showDatePicker)

                    // MARK: Photos / Videos
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            SectionLabel(icon: "photo.on.rectangle", text: "Photos & Videos")
                            Spacer()
                            PhotosPicker(selection: $selectedPhotoItems,
                                         maxSelectionCount: 10,
                                         matching: .any(of: [.images, .videos])) {
                                AddChip(label: "Add")
                            }
                                         .onChange(of: selectedPhotoItems) { _, newItems in
                                             Task {
                                                 var images: [UIImage] = []
                                                 var dataItems: [Data] = []
                                                 for item in newItems {
                                                     if let data = try? await item.loadTransferable(type: Data.self),
                                                        let img = UIImage(data: data) {
                                                         images.append(img)
                                                         dataItems.append(data)
                                                         continue
                                                     }
                                                     if let url = try? await item.loadTransferable(type: URL.self) {
                                                         if let data = try? Data(contentsOf: url) {
                                                             let asset = AVAsset(url: url)
                                                             let gen = AVAssetImageGenerator(asset: asset)
                                                             gen.appliesPreferredTrackTransform = true
                                                             if let cgImage = try? await gen.image(at: .zero).image {
                                                                 images.append(UIImage(cgImage: cgImage))
                                                             } else {
                                                                 images.append(videoPlaceholderImage())
                                                             }
                                                             dataItems.append(data)
                                                         }
                                                     }
                                                 }
                                                 withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                                                     selectedImages = images
                                                     viewModel.draftMediaData = dataItems
                                                 }
                                             }
                                         }
                        }

                        if !selectedImages.isEmpty {
                            AdaptiveMediaGridEditable(images: selectedImages) { idx in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                                    selectedImages.remove(at: idx)
                                    viewModel.draftMediaData.remove(at: idx)
                                    if idx < selectedPhotoItems.count {
                                        selectedPhotoItems.remove(at: idx)
                                    }
                                }
                            }
                        } else {
                            PhotoEmptyState()
                        }
                    }

                    AudioRecorderRow(audioData: $viewModel.draftAudioData)

                    // MARK: Context Row (Location · Music)
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(icon: "sparkle", text: "Add Context")

                        VStack(spacing: 10) {
                            ContextRow(
                                icon: "location.fill",
                                iconColor: .cyan,
                                title: viewModel.draftLocationName ?? "Location",
                                subtitle: viewModel.draftLocationName != nil ? "Tap to change" : "Search for a place",
                                isSet: viewModel.draftLocationName != nil,
                                isLoading: false
                            ) {
                                showLocationSearch = true
                            } onClear: {
                                viewModel.draftLocationName = nil
                                viewModel.draftLocationLatitude  = nil
                                viewModel.draftLocationLongitude  = nil
                            }

                            ContextRow(
                                icon: "music.note",
                                iconColor: .pink,
                                title: viewModel.draftMusicTitle.map { "\($0)\(viewModel.draftMusicArtist.map { " · \($0)" } ?? "")" } ?? "Music",
                                subtitle: viewModel.draftMusicTitle != nil ? "Now playing" : "Capture what you're listening to",
                                isSet: viewModel.draftMusicTitle != nil,
                                isLoading: false,
                                onTap: { showMusicSearch = true },
                                onClear: {
                                    viewModel.draftMusicTitle = nil
                                    viewModel.draftMusicArtist = nil
                                    viewModel.draftMusicArtworkData = nil
                                }
                            )
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave() }
                        .fontWeight(.bold)
                        .disabled(
                            viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                            viewModel.draftMediaData.isEmpty &&
                            viewModel.draftAudioData == nil
                        )
                }
                ToolbarItem(placement: .keyboard) {
                        Button {
                            textFocused = false
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .foregroundStyle(.secondary)
                        }
                    }
            }
            .sheet(isPresented: $showLocationSearch) {
                LocationSearchSheet { name, lat, lon in
                    viewModel.draftLocationName      = name
                    viewModel.draftLocationLatitude  = lat
                    viewModel.draftLocationLongitude = lon
                    showLocationSearch = false
                }
            }
            .sheet(isPresented: $showMusicSearch) {
                MusicSearchSheet { title, artist, artworkData, previewURL in
                    viewModel.draftMusicTitle = title
                    viewModel.draftMusicArtist = artist
                    viewModel.draftMusicArtworkData = artworkData
                    viewModel.draftMusicPreviewURL = previewURL
                    showMusicSearch = false
                }
            }
        }
    }

    func videoPlaceholderImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        return renderer.image { ctx in
            UIColor.systemGray5.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
            let config = UIImage.SymbolConfiguration(pointSize: 60)
            let icon = UIImage(systemName: "video.fill", withConfiguration: config)!
                .withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
            icon.draw(at: CGPoint(x: 70, y: 70))
        }
    }
}

// MARK: - Edit Entry View

struct EditEntryView: View {
    let entry: JournalEntry
    @Bindable var viewModel: JournalViewModel
    let onSave: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FocusState private var textFocused: Bool

    @State private var showMusicSearch = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showLocationSearch = false
    @State private var showDatePicker = false

    init(entry: JournalEntry, viewModel: JournalViewModel, onSave: @escaping () -> Void) {
        self.entry = entry
        self.onSave = onSave
        self._viewModel = Bindable(wrappedValue: viewModel)
        viewModel.populateDraft(from: entry)
        self._selectedImages = State(initialValue: entry.mediaData.compactMap { UIImage(data: $0) })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Mood Meter
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(icon: "face.smiling", text: "Mood Meter")
                        MoodSliderView(mood: $viewModel.draftMood)
                    }

                    // MARK: Text Entry
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(icon: "pencil", text: "Write it out")
                        ZStack(alignment: .topLeading) {
                            if viewModel.draftText.isEmpty {
                                Text("What's on your mind?")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 14)
                                    .padding(.leading, 14)
                            }
                            TextEditor(text: $viewModel.draftText)
                                .focused($textFocused)
                                .frame(minHeight: 180)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                        }
                        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemGroupedBackground)))
                    }

                    // MARK: Date Picker
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(icon: "calendar", text: "Date")
                        Button { showDatePicker.toggle() } label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.indigo)
                                Text(viewModel.draftDate.formatted(date: .complete, time: .omitted))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
                        }
                        .buttonStyle(.plain)
                        if showDatePicker {
                            DatePicker("", selection: $viewModel.draftDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(.indigo)
                                .padding(.horizontal, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showDatePicker)

                    // MARK: Photos
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            SectionLabel(icon: "photo.on.rectangle", text: "Photos & Videos")
                            Spacer()
                            PhotosPicker(selection: $selectedPhotoItems,
                                         maxSelectionCount: 10,
                                         matching: .any(of: [.images, .videos])) {
                                AddChip(label: "Add")
                            }
                                         .onChange(of: selectedPhotoItems) { _, newItems in
                                             Task {
                                                 var images: [UIImage] = []
                                                 var dataItems: [Data] = []
                                                 for item in newItems {
                                                     if let data = try? await item.loadTransferable(type: Data.self),
                                                        let img = UIImage(data: data) {
                                                         images.append(img)
                                                         dataItems.append(data)
                                                         continue
                                                     }
                                                     if let url = try? await item.loadTransferable(type: URL.self) {
                                                         if let data = try? Data(contentsOf: url) {
                                                             let asset = AVAsset(url: url)
                                                             let gen = AVAssetImageGenerator(asset: asset)
                                                             gen.appliesPreferredTrackTransform = true
                                                             if let cgImage = try? await gen.image(at: .zero).image {
                                                                 images.append(UIImage(cgImage: cgImage))
                                                             } else {
                                                                 images.append(videoPlaceholderImage())
                                                             }
                                                             dataItems.append(data)
                                                         }
                                                     }
                                                 }
                                                 withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                                                     selectedImages = images
                                                     viewModel.draftMediaData = dataItems
                                                 }
                                             }
                                         }
                        }

                        if !selectedImages.isEmpty {
                            AdaptiveMediaGridEditable(images: selectedImages) { idx in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                                    selectedImages.remove(at: idx)
                                    viewModel.draftMediaData.remove(at: idx)
                                    if idx < selectedPhotoItems.count { selectedPhotoItems.remove(at: idx) }
                                }
                            }
                        } else {
                            PhotoEmptyState()
                        }
                    }

                    AudioRecorderRow(audioData: $viewModel.draftAudioData)

                    // MARK: Context
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(icon: "sparkle", text: "Add Context")
                        VStack(spacing: 10) {
                            ContextRow(
                                icon: "location.fill", iconColor: .cyan,
                                title: viewModel.draftLocationName ?? "Location",
                                subtitle: viewModel.draftLocationName != nil ? "Tap to change" : "Search for a place",
                                isSet: viewModel.draftLocationName != nil, isLoading: false
                            ) { showLocationSearch = true } onClear: {
                                viewModel.draftLocationName = nil
                                viewModel.draftLocationLatitude = nil
                                viewModel.draftLocationLongitude = nil
                            }

                            ContextRow(
                                icon: "music.note",
                                iconColor: .pink,
                                title: viewModel.draftMusicTitle.map { "\($0)\(viewModel.draftMusicArtist.map { " · \($0)" } ?? "")" } ?? "Music",
                                subtitle: viewModel.draftMusicTitle != nil ? "Now playing" : "Capture what you're listening to",
                                isSet: viewModel.draftMusicTitle != nil,
                                isLoading: false,
                                onTap: { showMusicSearch = true },
                                onClear: {
                                    viewModel.draftMusicTitle = nil
                                    viewModel.draftMusicArtist = nil
                                    viewModel.draftMusicArtworkData = nil
                                }
                            )
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        applyEdits()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(
                        viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                        viewModel.draftMediaData.isEmpty &&
                        viewModel.draftAudioData == nil
                    )
                }
                ToolbarItem(placement: .keyboard) {
                        Button {
                            textFocused = false
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .foregroundStyle(.secondary)
                        }
                    }
            }
            .sheet(isPresented: $showLocationSearch) {
                LocationSearchSheet { name, lat, lon in
                    viewModel.draftLocationName = name
                    viewModel.draftLocationLatitude = lat
                    viewModel.draftLocationLongitude = lon
                    showLocationSearch = false
                }
            }
            .sheet(isPresented: $showMusicSearch) {
                MusicSearchSheet { title, artist, artworkData, previewURL in
                    viewModel.draftMusicTitle = title
                    viewModel.draftMusicArtist = artist
                    viewModel.draftMusicArtworkData = artworkData
                    viewModel.draftMusicPreviewURL = previewURL
                    showMusicSearch = false
                }
            }
        }
    }

    private func applyEdits() {
        entry.text    = viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.mood    = viewModel.draftMood
        entry.date    = viewModel.draftDate
        entry.mediaData              = viewModel.draftMediaData
        entry.locationName           = viewModel.draftLocationName
        entry.locationLatitude       = viewModel.draftLocationLatitude
        entry.locationLongitude      = viewModel.draftLocationLongitude
        entry.musicTitle             = viewModel.draftMusicTitle
        entry.musicArtist            = viewModel.draftMusicArtist
        entry.musicArtworkData       = viewModel.draftMusicArtworkData
        entry.audioData = viewModel.draftAudioData
        entry.musicPreviewURL = viewModel.draftMusicPreviewURL
        try? context.save()
        viewModel.resetDraftPublic()
    }

    func videoPlaceholderImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        return renderer.image { ctx in
            UIColor.systemGray5.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
            let config = UIImage.SymbolConfiguration(pointSize: 60)
            let icon = UIImage(systemName: "video.fill", withConfiguration: config)!
                .withTintColor(.systemGray2, renderingMode: .alwaysOriginal)
            icon.draw(at: CGPoint(x: 70, y: 70))
        }
    }
}

// MARK: - Location Search Sheet

import MapKit

// MARK: - Location Search Sheet (improved MKLocalSearch)

struct LocationSearchSheet: View {
    let onSelect: (String, Double, Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query              = ""
    @State private var results: [MKMapItem] = []
    @State private var selectedItem: MKMapItem? = nil
    @State private var isFetchingGPS      = false
    @State private var isSearching        = false
    @State private var userRegion: MKCoordinateRegion? = nil
    @State private var searchTask: Task<Void, Never>?  = nil
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708),
            span:   MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @FocusState private var searchFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                // MARK: Fullscreen Map
                Map(position: $cameraPosition) {
                    if let item = selectedItem {
                        Marker(item.name ?? "Selected", coordinate: item.placemark.coordinate)
                            .tint(.indigo)
                    }
                    UserAnnotation()
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .ignoresSafeArea(edges: .top)

                // MARK: Floating panel
                VStack(spacing: 0) {

                    HStack(spacing: 10) {
                        if isSearching {
                            ProgressView().scaleEffect(0.75)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                        }
                        TextField("Search for a place…", text: $query)
                            .focused($searchFocused)
                            .submitLabel(.search)
                            .autocorrectionDisabled()
                            .onSubmit { triggerSearch(immediate: true) }
                            .onChange(of: query) { _, _ in triggerSearch(immediate: false) }
                        if !query.isEmpty {
                            Button {
                                query = ""
                                results = []
                                searchTask?.cancel()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    if !results.isEmpty || query.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                Button {
                                    Task { await selectCurrentLocation() }
                                } label: {
                                    LocationRow(
                                        icon: "location.fill",
                                        iconColor: .cyan,
                                        title: isFetchingGPS ? "Locating…" : "Use Current Location",
                                        subtitle: "Detect where you are now",
                                        isLoading: isFetchingGPS
                                    )
                                }
                                .disabled(isFetchingGPS)

                                if !results.isEmpty {
                                    Divider().padding(.leading, 56)

                                    ForEach(results, id: \.self) { item in
                                        Button { selectMapItem(item) } label: {
                                            LocationRow(
                                                icon: iconForCategory(item.pointOfInterestCategory),
                                                iconColor: .indigo,
                                                title: item.name ?? item.placemark.formattedAddress,
                                                subtitle: item.placemark.formattedAddress,
                                                isLoading: false
                                            )
                                        }
                                        if item !== results.last {
                                            Divider().padding(.leading, 56)
                                        }
                                    }
                                }
                            }
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding(.horizontal, 16)
                        }
                        .frame(maxHeight: 340)
                        .padding(.top, 8)
                    } else if !query.isEmpty && !isSearching {
                        VStack(spacing: 6) {
                            Image(systemName: "mappin.slash")
                                .font(.system(size: 28))
                                .foregroundStyle(.tertiary)
                            Text("No results for \"\(query)\"")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                searchFocused = true
                Task { await fetchUserRegion() }
            }
        }
    }

    // MARK: - Search trigger with proper debounce + cancellation

    private func triggerSearch(immediate: Bool) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else { results = []; return }

        searchTask = Task {
            if !immediate {
                try? await Task.sleep(for: .milliseconds(300))
            }
            guard !Task.isCancelled else { return }
            await performSearch(query: trimmed)
        }
    }

    @MainActor
    private func performSearch(query: String) async {
        isSearching = true
        defer { isSearching = false }

        var allResults: [MKMapItem] = []

        async let poiResults  = searchPass(query: query, types: [.pointOfInterest])
        async let addrResults = searchPass(query: query, types: [.address])

        let (pois, addrs) = await (poiResults, addrResults)

        for item in (pois + addrs) {
            let coord = item.placemark.coordinate
            let isDupe = allResults.contains { existing in
                let ec = existing.placemark.coordinate
                return abs(ec.latitude - coord.latitude) < 0.0001 &&
                       abs(ec.longitude - coord.longitude) < 0.0001
            }
            if !isDupe { allResults.append(item) }
        }

        results = Array(allResults.prefix(8))

        if let first = results.first {
            panCamera(to: first.placemark.coordinate, span: 0.04)
        }
    }

    private func searchPass(query: String, types: MKLocalSearch.ResultType) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = types

        if let region = userRegion {
            request.region = region
        } else {
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708),
                span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
            )
        }

        return (try? await MKLocalSearch(request: request).start())?.mapItems ?? []
    }

    // MARK: - Selection

    private func selectMapItem(_ item: MKMapItem) {
        selectedItem = item
        let coord = item.placemark.coordinate
        panCamera(to: coord, span: 0.01)
        let name = item.name ?? item.placemark.formattedAddress
        onSelect(name, coord.latitude, coord.longitude)
    }

    @MainActor
    private func selectCurrentLocation() async {
        isFetchingGPS = true
        defer { isFetchingGPS = false }

        let manager = CLLocationManager()
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            try? await Task.sleep(for: .milliseconds(600))
        }
        guard manager.authorizationStatus == .authorizedWhenInUse ||
              manager.authorizationStatus == .authorizedAlways else { return }
 
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                guard let location = update.location else { continue }
                let coord = location.coordinate
                panCamera(to: coord, span: 0.01)
                let name = await reverseGeocode(location)
                onSelect(name, coord.latitude, coord.longitude)
                return
            }
        } catch {}
    }

    // MARK: - Helpers

    @MainActor
    private func fetchUserRegion() async {
        let manager = CLLocationManager()
        guard manager.authorizationStatus == .authorizedWhenInUse ||
              manager.authorizationStatus == .authorizedAlways else { return }
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                guard let location = update.location else { continue }
                userRegion = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                )
                panCamera(to: location.coordinate, span: 0.05)
                return
            }
        } catch {}
    }

    private func reverseGeocode(_ location: CLLocation) async -> String {
        if #available(iOS 26, *) {
            if let request = MKReverseGeocodingRequest(location: location),
               let item = try? await request.mapItems.first {
                return item.name ?? item.placemark.formattedAddress
            }
        }
        if let placemark = try? await CLGeocoder().reverseGeocodeLocation(location).first {
            return [placemark.name, placemark.locality]
                .compactMap { $0 }.joined(separator: ", ")
        }
        return "Current Location"
    }

    private func panCamera(to coordinate: CLLocationCoordinate2D, span: Double) {
        withAnimation(.easeInOut(duration: 0.4)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
            ))
        }
    }

    private func iconForCategory(_ category: MKPointOfInterestCategory?) -> String {
        guard let category else { return "mappin.circle.fill" }
        switch category {
        case .restaurant, .cafe, .bakery, .brewery, .winery, .foodMarket:
            return "fork.knife.circle.fill"
        case .hotel:
            return "bed.double.circle.fill"
        case .airport:
            return "airplane.circle.fill"
        case .hospital, .pharmacy:
            return "cross.circle.fill"
        case .school, .university, .library:
            return "books.vertical.circle.fill"
        case .park, .beach, .nationalPark:
            return "leaf.circle.fill"
        case .fitnessCenter, .spa:
            return "figure.run.circle.fill"
        case .museum, .theater, .movieTheater:
            return "building.columns.circle.fill"
        case .store, .gasStation:
            return "cart.circle.fill"
        default:
            return "mappin.circle.fill"
        }
    }
}

// MARK: - Location Row

private struct LocationRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isLoading: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 38, height: 38)
                if isLoading {
                    ProgressView().scaleEffect(0.75).tint(iconColor)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }
}

// MARK: - MKPlacemark formatted address helper

private extension MKPlacemark {
    var formattedAddress: String {
        [locality, administrativeArea, countryCode]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

// MARK: - LocationManager (GPS fallback only)

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completion: ((String, Double, Double) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation(completion: @escaping (String, Double, Double) -> Void) {
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        CLGeocoder().reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
            guard let self, let place = placemarks?.first else { return }
            let name = [place.locality, place.administrativeArea]
                .compactMap { $0 }.joined(separator: ", ")
            DispatchQueue.main.async {
                self.completion?(name.isEmpty ? "Unknown Location" : name,
                                 loc.coordinate.latitude, loc.coordinate.longitude)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?("Location Unavailable", 0, 0)
    }
}

// MARK: - Context Row

struct ContextRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isSet: Bool
    let isLoading: Bool
    let onTap: () -> Void
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 38, height: 38)
                if isLoading {
                    ProgressView().scaleEffect(0.7).tint(iconColor)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(isSet ? title : title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSet ? .primary : .secondary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()

            if isSet {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "plus.circle")
                    .foregroundStyle(iconColor.opacity(0.6))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { if !isLoading { onTap() } }
    }
}

// MARK: - Small Helpers

struct SectionLabel: View {
    let icon: String
    let text: String
    var body: some View {
        Label(text, systemImage: icon)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
    }
}

struct AddChip: View {
    let label: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "plus")
                .font(.system(size: 10, weight: .bold))
            Text(label)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(.indigo)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(.indigo.opacity(0.1)))
    }
}

struct PhotoEmptyState: View {
    var body: some View {
        HStack {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 20))
                .foregroundStyle(.tertiary)
            Text("No photos added")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.tertiarySystemGroupedBackground)))
    }
}

// MARK: - No Results View

struct NoResultsView: View {
    let query: String
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("No entries matching \"\(query)\"")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

// MARK: - Detail View

struct EntryDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss
    @State private var editViewModel        = JournalViewModel()
    @State private var replayAward: Award?  = nil
    @State private var showingDeleteConfirm = false
    @State private var showingEdit          = false
    @State private var isReanalysing        = false
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    let entry: JournalEntry

    private var moodAccentColor: Color {
        switch entry.mood {
        case .great:   return .orange
        case .good:    return .yellow
        case .okay:    return .mint
        case .bad:     return .blue
        case .terrible: return .purple
        default:       return .indigo
        }
    }

    private var entryWordCount: Int {
        entry.text.split(whereSeparator: \.isWhitespace).count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                HStack(spacing: 16) {
                    MoodIcon(mood: entry.mood, size: 128, animated: true)
                        .background(Circle().fill(Color(moodAccentColor)).opacity(0.15)
                        .shadow(color: .black.opacity(0.08), radius: 8))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.mood.label)
                            .font(.title2.bold())
                        Text(entry.date.formatted(date: .complete, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 24).fill(.indigo.opacity(0.06)))

                if let lat = entry.locationLatitude, let lon = entry.locationLongitude {
                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Location", systemImage: "location.fill")
                            .font(.headline)
                            .foregroundStyle(.cyan)

                        Map(position: $mapCameraPosition) {
                            Marker(entry.locationName ?? "Here", coordinate: coord)
                                .tint(.cyan)
                        }
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .disabled(true)
                        .onTapGesture {
                            let item = MKMapItem(placemark: MKPlacemark(coordinate: coord))
                            item.name = entry.locationName
                            item.openInMaps(launchOptions: nil)
                        }
                        .onChange(of: lat) { _, newLat in
                            mapCameraPosition = .region(MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: newLat, longitude: lon),
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            ))
                        }
                        .onChange(of: lon) { _, newLon in
                            mapCameraPosition = .region(MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: lat, longitude: newLon),
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            ))
                        }
                    }
                }
                
                if let song = entry.musicTitle {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Music", systemImage: "music.note.list")
                            .font(.headline)
                            .foregroundStyle(.pink)
                        
                        MusicPreviewPlayer(
                            title: song,
                            artist: entry.musicArtist,
                            artworkData: entry.musicArtworkData,
                            previewURL: entry.musicPreviewURL
                        )
                    }
                }
                
                if !entry.mediaData.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Photos & Videos", systemImage: "photo.on.rectangle")
                            .font(.headline)
                            .foregroundStyle(.indigo)
                        AdaptiveMediaGridWithSlideshow(mediaData: entry.mediaData)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }

                Text(entry.text)
                    .font(.body)
                    .lineSpacing(8)
                    .foregroundStyle(.primary)

                if let audioData = entry.audioData {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Voice Note", systemImage: "mic.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        AudioPlaybackRow(audioData: audioData)
                    }
                }

                if !entry.awards.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Achievements", systemImage: "trophy.fill")
                            .font(.headline)
                            .foregroundStyle(.indigo)
                        ForEach(entry.awards, id: \.id) { award in
                            AwardCardView(award: award)
                                .onTapGesture { replayAward = award }
                        }
                    }
                }

                let blockReason = editViewModel.analysisBlockReason(for: entry.text)
                VStack(alignment: .leading, spacing: 6) {
                    Button {
                        Task {
                            isReanalysing = true
                            await editViewModel.reanalyseEntry(entry, using: context)
                            isReanalysing = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isReanalysing {
                                ProgressView().scaleEffect(0.8).tint(.indigo)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(isReanalysing ? "Re-analysing…" : "Re-analyse Entry")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(blockReason == nil ? .indigo : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(blockReason == nil ? .indigo.opacity(0.08) : Color(.tertiarySystemGroupedBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    blockReason == nil ? .indigo.opacity(0.15) : Color(.separator).opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                    }
                    .disabled(isReanalysing || blockReason != nil || !editViewModel.aiAnalysisEnabled)
                    .buttonStyle(.plain)

                    if let reason = blockReason {
                        Label(reason, systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    if !editViewModel.aiAnalysisEnabled {
                        Label("AI analysis is disabled in Settings", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: blockReason)
            }
            .padding(20)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showingEdit = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(.indigo)
                }

                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Image(systemName: "trash").foregroundStyle(.red)
                }
                .confirmationDialog("Delete Entry?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        context.delete(entry)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This action cannot be undone. Are you sure you want to remove this memory?")
                }
            }
        }
        .onAppear {
            if let lat = entry.locationLatitude, let lon = entry.locationLongitude {
                mapCameraPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            }
        }
        .background(JournalGradientBackground())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            EditEntryView(entry: entry, viewModel: editViewModel) {
                showingEdit = false
            }
        }
        .overlay {
            if let award = replayAward {
                MedalPresentationView(award: award) { replayAward = nil }
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
    }
}

struct DetailChip: View {
    let icon: String
    let text: String
    let color: Color
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(color.opacity(0.1)))
    }
}

extension View {
    func flexibleWidth() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Music Preview Player

struct MusicPreviewPlayer: View {
    let title: String
    let artist: String?
    let artworkData: Data?
    let previewURL: URL?

    @StateObject private var player = MiniAudioPlayer()

    var body: some View {
        HStack(spacing: 14) {
            Group {
                if let data = artworkData, let img = UIImage(data: data) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Image(systemName: "music.note")
                        .font(.title3)
                        .foregroundStyle(.pink)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                if let artist {
                    Text(artist)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                if previewURL != nil {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.quaternarySystemFill)).frame(height: 3)
                            Capsule()
                                .fill(Color.pink)
                                .frame(width: geo.size.width * player.progress, height: 3)
                        }
                    }
                    .frame(height: 12)
                }
            }

            Spacer()

            if let url = previewURL {
                Button {
                    player.toggle(url: url)
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.pink)
                    }
                }
                .buttonStyle(.plain)
            } else {
                Text("No preview")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .onDisappear { player.stop() }
    }
}

// MARK: - Mini Audio Player (AVPlayer wrapper)

@MainActor
final class MiniAudioPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var itemObserver: NSKeyValueObservation?

    func toggle(url: URL) {
        if isPlaying { pause() } else { play(url: url) }
    }

    private func play(url: URL) {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)

        if player == nil {
            player = AVPlayer(url: url)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didFinish),
                name: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem
            )
            timeObserver = player?.addPeriodicTimeObserver(
                forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
                queue: .main
            ) { [weak self] time in
                guard let self,
                      let duration = self.player?.currentItem?.duration,
                      duration.isNumeric else { return }
                self.progress = time.seconds / duration.seconds
            }
        }
        player?.play()
        isPlaying = true
    }

    private func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        progress = 0
    }

    @objc private func didFinish() {
        isPlaying = false
        progress = 0
        player?.seek(to: .zero)
    }
}

// MARK: - Empty State

struct EmptyJournalView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(.indigo.opacity(0.1)).frame(width: 120, height: 120)
                Image(systemName: "book.pages")
                    .font(.system(size: 50))
                    .foregroundStyle(.indigo)
                    .symbolRenderingMode(.hierarchical)
            }
            VStack(spacing: 8) {
                Text("Begin Your Journey")
                    .font(.title2.bold())
                Text("Your journal is empty. Tap + to record your first entry, add photos, your location, music, and discover hidden achievements.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            HStack(spacing: 10) {
                Image(systemName: "sparkles").foregroundStyle(.indigo)
                Text("AI finds wins · Add photos · Log the moment")
                    .font(.caption).fontWeight(.medium).foregroundStyle(.indigo)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(.indigo.opacity(0.07)))
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Gradient Background

struct JournalGradientBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        LinearGradient(
            colors: colorScheme == .light
                ? [Color.white, Color(red: 0.95, green: 0.9, blue: 1.0)]
                : [Color.black, Color(red: 0.1, green: 0.0, blue: 0.2)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - AwardCardView

struct AwardCardView: View {
    let award: Award
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                AwardBadgeView(type: award.type, size: 52)

                VStack(alignment: .leading, spacing: 2) {
                    Text(award.displayTitle).font(.subheadline.bold())
                    Text(award.type.shortDescription).font(.system(size: 11)).foregroundStyle(.tertiary)
                }
                Spacer()
                Image(systemName: "play.circle.fill").foregroundStyle(.indigo.opacity(0.3)).font(.title3)
            }
            .padding(.bottom, award.aiEncouragement != nil ? 12 : 0)

            if let encouragement = award.aiEncouragement {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkles").font(.system(size: 12, weight: .bold)).foregroundStyle(.indigo).padding(.top, 2)
                    Text(encouragement)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .lineSpacing(3)
                        .foregroundStyle(.indigo.opacity(0.8))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 16).fill(.indigo.opacity(0.06)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
        )
    }
}

struct IdentifiableMapItem: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
    var coordinate: CLLocationCoordinate2D { mapItem.placemark.coordinate }
}

// MARK: - iTunes track model (no Apple Music subscription needed)

private struct ItunesTrack: Identifiable {
    let id: Int
    let title: String
    let artist: String
    let artworkURL: URL?
    let previewURL: String?
}

// MARK: - Music Search Sheet (iTunes API fallback)

struct MusicSearchSheet: View {
    let onSelect: (String, String?, Data?, URL?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [ItunesTrack] = []
    @State private var isSearching = false
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search for a song…", text: $query)
                        .focused($focused)
                        .submitLabel(.search)
                        .onSubmit { Task { await search() } }
                        .onChange(of: query) { _, val in
                            guard !val.isEmpty else { results = []; return }
                            Task {
                                try? await Task.sleep(for: .milliseconds(400))
                                await search()
                            }
                        }
                    if !query.isEmpty {
                        Button { query = ""; results = [] } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(16)

                if isSearching {
                    ProgressView().padding(.top, 40)
                } else if results.isEmpty && !query.isEmpty {
                    Text("No results for \"\(query)\"")
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    List(results) { track in
                        Button {
                            Task { await selectTrack(track) }
                        } label: {
                            HStack(spacing: 12) {
                                Group {
                                    if let url = track.artworkURL {
                                        AsyncImage(url: url) { img in
                                            img.resizable().scaledToFill()
                                        } placeholder: {
                                            Color(.quaternarySystemFill)
                                        }
                                    } else {
                                        Color(.quaternarySystemFill)
                                    }
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(track.title)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.primary)
                                    Text(track.artist)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(.pink.opacity(0.7))
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Pick a Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { focused = true }
        }
    }

    @MainActor
    private func search() async {
        let term = query.trimmingCharacters(in: .whitespaces)
        guard !term.isEmpty else { return }
        isSearching = true
        defer { isSearching = false }

        let status = await MusicAuthorization.request()
        if status == .authorized {
            var req = MusicCatalogSearchRequest(term: term, types: [Song.self])
            req.limit = 20
            if let response = try? await req.response(), !response.songs.isEmpty {
                results = response.songs.map { song in
                    ItunesTrack(
                        id: song.id.hashValue,
                        title: song.title,
                        artist: song.artistName,
                        artworkURL: song.artwork?.url(width: 50, height: 50),
                        previewURL: nil
                    )
                }
                return
            }
        }

        guard let encoded = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?term=\(encoded)&media=music&entity=song&limit=20")
        else { return }

        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return }

        struct ITunesResponse: Decodable {
            struct Result: Decodable {
                let trackId: Int
                let trackName: String
                let artistName: String
                let artworkUrl60: String?
                let previewUrl: String?
            }
            let results: [Result]
        }

        guard let decoded = try? JSONDecoder().decode(ITunesResponse.self, from: data) else { return }
        results = decoded.results.map { r in
            let hiRes = r.artworkUrl60?.replacingOccurrences(of: "60x60bb", with: "100x100bb")
            let artURL = hiRes.flatMap { URL(string: $0) } ?? r.artworkUrl60.flatMap { URL(string: $0) }
            return ItunesTrack(
                id: r.trackId,
                title: r.trackName,
                artist: r.artistName,
                artworkURL: artURL,
                previewURL: r.previewUrl
                
            )
        }
    }

    @MainActor
    private func selectTrack(_ track: ItunesTrack) async {
        var artworkData: Data? = nil
        if let url = track.artworkURL {
            artworkData = try? await URLSession.shared.data(from: url).0
        }
        let previewURL = track.previewURL.flatMap { URL(string: $0) }
        onSelect(track.title, track.artist, artworkData, previewURL)
    }
}

import AVFoundation

// MARK: - Audio Recorder Row

struct AudioRecorderRow: View {
    @Binding var audioData: Data?
    @StateObject private var recorder = AudioRecorderController()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(icon: "waveform", text: "Audio Recording")

            if let data = audioData {
                AudioPlaybackRow(audioData: data) {
                    audioData = nil
                }
            } else {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(recorder.isRecording ? Color.red.opacity(0.12) : Color.orange.opacity(0.10))
                            .frame(width: 52, height: 52)
                        Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(recorder.isRecording ? .red : .orange)
                            .symbolEffect(.pulse, isActive: recorder.isRecording)
                    }
                    .onTapGesture {
                        if recorder.isRecording {
                            recorder.stopRecording { data in audioData = data }
                        } else {
                            recorder.startRecording()
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(recorder.isRecording ? "Recording…" : "Tap to Record")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(recorder.isRecording ? .red : .primary)
                        Text(recorder.isRecording ? timerString(recorder.elapsed) : "Capture a voice note")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                            .animation(.linear(duration: 1), value: recorder.elapsed)
                    }

                    Spacer()

                    if recorder.isRecording {
                        HStack(spacing: 3) {
                            ForEach(0..<5, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.red.opacity(0.7))
                                    .frame(width: 3, height: 8 + recorder.levels[i] * 16)
                                    .animation(.easeOut(duration: 0.1), value: recorder.levels[i])
                            }
                        }
                        .frame(width: 32, height: 24)
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            }
        }
    }

    private func timerString(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Audio Playback Row

struct AudioPlaybackRow: View {
    let audioData: Data
    var onDelete: (() -> Void)? = nil
    @StateObject private var player = AudioPlayerController()

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.orange)
            }
            .onTapGesture {
                if player.isPlaying {
                    player.pause()
                } else {
                    player.play(data: audioData)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                if player.waveform.isEmpty {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.quaternarySystemFill)).frame(height: 4)
                            Capsule()
                                .fill(Color.orange)
                                .frame(width: geo.size.width * player.progress, height: 4)
                        }
                    }
                    .frame(height: 28)
                } else {
                    WaveformScrubberView(samples: player.waveform, progress: player.progress)
                        .frame(height: 28)
                }

                HStack {
                    Text(timeString(player.currentTime))
                    Spacer()
                    Text(timeString(player.duration))
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
                .animation(.linear(duration: 0.5), value: player.currentTime)
            }

            if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.red.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
        .onAppear { player.loadWaveform(from: audioData) }
        .onDisappear { player.stop() }
    }

    private func timeString(_ t: TimeInterval) -> String {
        let s = max(0, Int(t))
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - Waveform Scrubber View

struct WaveformScrubberView: View {
    let samples: [Float]
    let progress: Double

    var body: some View {
        Canvas { context, size in
            let count = samples.count
            let barWidth: CGFloat = 3
            let spacing: CGFloat = 2
            let totalWidth = CGFloat(count) * (barWidth + spacing) - spacing
            let xOffset = (size.width - totalWidth) / 2

            for i in 0..<count {
                let filled = Double(i) / Double(count) < progress
                let barHeight = max(3, size.height * CGFloat(samples[i]))
                let x = xOffset + CGFloat(i) * (barWidth + spacing)
                let rect = CGRect(
                    x: x,
                    y: (size.height - barHeight) / 2,
                    width: barWidth,
                    height: barHeight
                )
                let path = Path(roundedRect: rect, cornerRadius: 1.5)
                context.fill(path, with: .color(filled ? .orange : Color(.quaternarySystemFill)))
            }
        }
    }
}

// MARK: - Audio Recorder Controller

final class AudioRecorderController: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var elapsed = 0
    @Published var levels: [CGFloat] = [0.5, 0.5, 0.5, 0.5, 0.5]

    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var fileURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("journal_recording.m4a")
    }

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try? session.setActive(true)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        recorder = try? AVAudioRecorder(url: fileURL, settings: settings)
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true
        recorder?.record()
        isRecording = true
        elapsed = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let rec = self.recorder else { return }
            if Int(rec.currentTime) > self.elapsed {
                self.elapsed = Int(rec.currentTime)
            }
            rec.updateMeters()
            let db = rec.averagePower(forChannel: 0)
            let normalized = CGFloat(max(0, (db + 60) / 60))
            self.levels = (0..<5).map { _ in
                let jitter = CGFloat.random(in: -0.08...0.08)
                return min(1, max(0.05, normalized + jitter))
            }
        }
    }

    func stopRecording(completion: (Data?) -> Void) {
        recorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false
        levels = [0.5, 0.5, 0.5, 0.5, 0.5]
        let data = try? Data(contentsOf: fileURL)
        completion(data)
    }

    deinit { timer?.invalidate() }
}

// MARK: - Audio Player Controller

final class AudioPlayerController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var waveform: [Float] = []

    private var player: AVAudioPlayer?
    private var timer: Timer?

    func loadWaveform(from data: Data) {
        guard waveform.isEmpty else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            let samples = Self.sampleWaveform(from: data, buckets: 40)
            DispatchQueue.main.async { self.waveform = samples }
        }
    }

    func play(data: Data) {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        player = try? AVAudioPlayer(data: data)
        player?.delegate = self
        player?.prepareToPlay()
        duration = player?.duration ?? 0
        if waveform.isEmpty { loadWaveform(from: data) }
        player?.play()
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let p = self.player else { return }
            self.currentTime = p.currentTime
            self.progress = self.duration > 0 ? p.currentTime / self.duration : 0
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        timer?.invalidate()
    }

    func stop() {
        player?.stop()
        isPlaying = false
        timer?.invalidate()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.progress = 0
            self.currentTime = 0
            self.timer?.invalidate()
        }
    }

    private static func sampleWaveform(from data: Data, buckets: Int) -> [Float] {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("wf_preview.m4a")
        try? data.write(to: tmp)
        guard
            let file = try? AVAudioFile(forReading: tmp),
            let fmt  = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                     sampleRate: file.fileFormat.sampleRate,
                                     channels: 1,
                                     interleaved: false),
            let buf  = AVAudioPCMBuffer(pcmFormat: fmt,
                                        frameCapacity: AVAudioFrameCount(file.length)),
            (try? file.read(into: buf)) != nil,
            let channel = buf.floatChannelData?[0]
        else { return Array(repeating: 0.5, count: buckets) }

        let frameCount = Int(buf.frameLength)
        let bucketSize = max(1, frameCount / buckets)

        let raw = (0..<buckets).map { b -> Float in
            let start = b * bucketSize
            let end   = min(start + bucketSize, frameCount)
            var sum: Float = 0
            for i in start..<end { sum += abs(channel[i]) }
            return sum / Float(end - start)
        }

        guard let peak = raw.max(), peak > 0 else { return raw }
        return raw.map { max(0.05, $0 / peak) }
    }

    deinit { timer?.invalidate() }
}
