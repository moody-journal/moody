import XCTest
import SwiftData
import PDFKit
@testable import Journal

@MainActor
final class JournalRegressionTests: XCTestCase {
    private var previousAISetting: Any?
    override func setUp() {
        super.setUp()
        previousAISetting = UserDefaults.standard.object(forKey: "settings_aiAnalysis")
        UserDefaults.standard.set(true, forKey: "settings_aiAnalysis")
    }
    override func tearDown() {
        UserDefaults.standard.set(previousAISetting, forKey: "settings_aiAnalysis")
        super.tearDown()
    }
    private func container() throws -> ModelContainer {
        try ModelContainer(for: JournalEntry.self, Award.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
    private var text: String { Array(repeating: "Today I worked hard and helped a friend.", count: 8).joined(separator: " ") }
    private func entry(in context: ModelContext) throws -> JournalEntry {
        let entry = JournalEntry(text: text, mood: .good)
        context.insert(entry)
        let award = Award(type: .helpedOthers, customTitle: "Old award")
        context.insert(award)
        award.entry = entry
        entry.isAnalysed = true
        try context.save()
        return entry
    }
    func testSaveReturnsExactBackdatedEntryAndResetsDraft() throws {
        let store = try container(); let context = store.mainContext
        let vm = JournalViewModel()
        vm.draftText = "  Saved journal  "
        vm.draftDate = Date(timeIntervalSince1970: 1000)
        let saved = try XCTUnwrap(vm.saveEntry(using: context))
        XCTAssertEqual(saved.text, "Saved journal")
        XCTAssertEqual(saved.date, Date(timeIntervalSince1970: 1000))
        XCTAssertTrue(vm.draftText.isEmpty)
        XCTAssertFalse(saved.isAnalysed)
        XCTAssertEqual(try context.fetch(FetchDescriptor<JournalEntry>()).count, 1)
    }
    func testFailedReanalysisPreservesAwardsAndRetryState() async throws {
        let store = try container(); let context = store.mainContext
        let saved = try entry(in: context)
        let oldID = saved.awards.first?.id
        let vm = JournalViewModel { _, _ in throw AnalysisFailure.invalidResponse }
        await vm.reanalyseEntry(saved, using: context)
        XCTAssertEqual(saved.awards.first?.id, oldID)
        XCTAssertEqual(saved.awards.count, 1)
        XCTAssertTrue(saved.isAnalysed)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isAnalysing)
    }
    func testSuccessfulReanalysisReplacesAwardsWithoutDuplicates() async throws {
        let store = try container(); let context = store.mainContext
        let saved = try entry(in: context)
        let vm = JournalViewModel { _, _ in AnalysisResult(awards: [(.finishedSomething, "Finished a challenging project")], encouragements: [.finishedSomething: "You kept going."]) }
        await vm.reanalyseEntry(saved, using: context)
        await vm.reanalyseEntry(saved, using: context)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(saved.awards.count, 1)
        XCTAssertEqual(saved.awards.first?.type, .finishedSomething)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Award>()).count, 1)
    }
    func testMultipleMedalsPersistForOneEntryAndSurviveReanalysis() async throws {
        let store = try container()
        let context = store.mainContext
        let saved = try entry(in: context)
        let types: [AwardType] = [.finishedSomething, .helpedOthers, .createdSomething]
        let vm = JournalViewModel { _, _ in
            AnalysisResult(awards: types.map { ($0, "A distinct achievement") },
                           encouragements: Dictionary(uniqueKeysWithValues: types.map { ($0, "Well done on this achievement.") }))
        }
        for _ in 0..<2 {
            await vm.reanalyseEntry(saved, using: context)
            XCTAssertNil(vm.errorMessage)
            XCTAssertEqual(Set(saved.awards.map(\.type)), Set(types))
            XCTAssertEqual(saved.awards.count, 3)
            XCTAssertEqual(try context.fetch(FetchDescriptor<Award>()).count, 3)
            XCTAssertTrue(saved.awards.allSatisfy { $0.entry?.id == saved.id && $0.aiEncouragement != nil })
        }
    }
    func testEmptySuccessfulAnalysisIsDifferentFromFailure() async throws {
        let store = try container(); let context = store.mainContext
        let saved = try entry(in: context)
        let vm = JournalViewModel { _, _ in AnalysisResult(awards: [], encouragements: [:]) }
        await vm.reanalyseEntry(saved, using: context)
        XCTAssertTrue(saved.awards.isEmpty)
        XCTAssertTrue(saved.isAnalysed)
        XCTAssertNil(vm.errorMessage)
    }
    func testEditingDuringAnalysisDiscardsStaleResult() async throws {
        let store = try container(); let context = store.mainContext
        let saved = try entry(in: context)
        let vm = JournalViewModel { _, _ in
            try await Task.sleep(for: .milliseconds(150))
            return AnalysisResult(awards: [], encouragements: [:])
        }
        let task = Task { await vm.reanalyseEntry(saved, using: context) }
        await Task.yield()
        while !vm.isAnalysing { await Task.yield() }
        saved.text = "Edited while analysis was running"
        try context.save()
        await task.value
        XCTAssertEqual(saved.awards.count, 1)
        XCTAssertFalse(vm.isAnalysing)
    }
    func testDuplicateConcurrentAnalysisDoesNotReplaceAwardsTwice() async throws {
        let store = try container(); let context = store.mainContext
        let saved = try entry(in: context)
        let vm = JournalViewModel { _, _ in
            try await Task.sleep(for: .milliseconds(100))
            return AnalysisResult(awards: [(.finishedSomething, "A completed project")], encouragements: [:])
        }
        let task = Task { await vm.reanalyseEntry(saved, using: context) }
        while !vm.isAnalysing { await Task.yield() }
        let second = JournalViewModel { _, _ in throw AnalysisFailure.invalidResponse }
        await second.reanalyseEntry(saved, using: context)
        XCTAssertNil(second.errorMessage)
        await task.value
        XCTAssertEqual(saved.awards.count, 1)
        XCTAssertEqual(saved.awards.first?.type, .finishedSomething)
    }
    func testResetDuringAnalysisDiscardsPendingAwards() async throws {
        let store = try container(); let context = store.mainContext
        let saved = try entry(in: context)
        let vm = JournalViewModel { _, _ in
            try await Task.sleep(for: .milliseconds(100))
            return AnalysisResult(awards: [(.finishedSomething, "A completed project")], encouragements: [:])
        }
        let task = Task { await vm.reanalyseEntry(saved, using: context) }
        while !vm.isAnalysing { await Task.yield() }
        for award in saved.awards { context.delete(award) }
        saved.isAnalysed = false
        try context.save()
        JournalViewModel.invalidatePendingAnalyses()
        await task.value
        XCTAssertTrue(saved.awards.isEmpty)
        XCTAssertFalse(saved.isAnalysed)
    }
    func testLanguageHeuristicNoLongerRejectsValidFortyWordEntry() {
        let vm = JournalViewModel()
        XCTAssertNil(vm.analysisBlockReason(for: Array(repeating: "朋友帮助", count: 40).joined(separator: " ")))
        XCTAssertNotNil(vm.analysisBlockReason(for: "short entry"))
    }
    func testChunkingPreservesAllTextIncludingUnicodeAndLongWords() {
        for input in [String(repeating: "a", count: 15000), String(repeating: " 👨‍👩‍👧‍👦 café\n", count: 2500)] {
            let chunks = EntryAnalyser.chunks(input, limit: 6000)
            XCTAssertEqual(chunks.joined(), input)
            XCTAssertTrue(chunks.allSatisfy { $0.count <= 6000 && !$0.isEmpty })
        }
    }
    func testMoodRangesWeightEntriesAndUseStableDates() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let today = calendar.date(from: DateComponents(year: 2026, month: 9, day: 25, hour: 12))!
        let sixDaysAgo = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: today))!
        let entries = [JournalEntry(text: "one", mood: .great, date: today), JournalEntry(text: "two", mood: .great, date: today), JournalEntry(text: "three", mood: .terrible, date: sixDaysAgo), JournalEntry(text: "old", mood: .terrible, date: calendar.date(byAdding: .day, value: -7, to: today)!)]
        let vm = MoodViewModel()
        vm.update(from: entries, now: today, calendar: calendar)
        XCTAssertEqual(vm.weeklyData.count, 2)
        XCTAssertEqual(vm.averageMoodThisWeek, 11.0 / 3.0, accuracy: 0.0001)
        let ids = vm.weeklyData.map(\.id)
        entries[0].mood = .bad
        vm.update(from: entries, now: today, calendar: calendar)
        XCTAssertEqual(vm.weeklyData.map(\.id), ids)
        XCTAssertEqual(vm.averageMoodThisWeek, 8.0 / 3.0, accuracy: 0.0001)
    }
    func testDeletingEntryCascadesAwards() throws {
        let store = try container(); let context = store.mainContext
        let saved = try entry(in: context)
        context.delete(saved); try context.save()
        XCTAssertTrue(try context.fetch(FetchDescriptor<Award>()).isEmpty)
    }
    func testLongExportContainsLastParagraphAndValidPages() async throws {
        let entry = JournalEntry(text: String(repeating: "A long journal paragraph about today.\n", count: 300) + "FINAL_SENTINEL", mood: .good)
        let exported = await ExportManager.shared.exportURL(from: [ExportEntry(entry)])
        let url = try XCTUnwrap(exported)
        defer { try? FileManager.default.removeItem(at: url) }
        let document = try XCTUnwrap(PDFDocument(url: url))
        XCTAssertGreaterThan(document.pageCount, 2)
        let extracted = (document.string ?? "").filter { !$0.isWhitespace && $0 != "_" }
        XCTAssertTrue(extracted.contains("FINALSENTINEL"))
    }
}
