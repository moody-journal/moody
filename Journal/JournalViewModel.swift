import Foundation
import SwiftData
import Observation
import UIKit
import Combine
import SwiftUI

@MainActor
@Observable
final class JournalViewModel {

    @ObservationIgnored private let analyse: @Sendable (String, Mood) async throws -> AnalysisResult
    init(analyse: @escaping @Sendable (String, Mood) async throws -> AnalysisResult = { text, mood in
        try await EntryAnalyser.shared.analyse(text: text, mood: mood)
    }) { self.analyse = analyse }

    // MARK: - New-entry form state
    var aiAnalysisEnabled: Bool {
        UserDefaults.standard.object(forKey: "settings_aiAnalysis") as? Bool ?? true
    }
    
    var draftText: String = ""
    var draftMood: Mood   = .okay
    var draftDate: Date   = .now

    var draftMusicPreviewURL: URL? = nil
    // MARK: Media (photos & videos)

    var draftMediaData: [Data] = []

    // MARK: Location

    var draftLocationName: String?
    var draftLocationLatitude: Double?
    var draftLocationLongitude: Double?

    // MARK: Music

    var draftMusicTitle: String?
    var draftMusicArtist: String?
    var draftMusicArtworkData: Data?

    // MARK: Audio

    var draftAudioData: Data? = nil

    // MARK: - UI state

    private var analysisCount = 0
    var isAnalysing: Bool { analysisCount > 0 }
    @ObservationIgnored private static var analysisRevision = 0
    static func invalidatePendingAnalyses() { analysisRevision += 1 }
    @ObservationIgnored private static var analysingIDs: Set<UUID> = []
    var errorMessage: String? = nil

    // MARK: - Save + Analyse

    @MainActor
    func saveEntry(using context: ModelContext) -> JournalEntry? {
        errorMessage = nil
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)

        let entry = JournalEntry(text: trimmed, mood: draftMood, date: draftDate)

        entry.mediaData        = draftMediaData
        entry.locationName     = draftLocationName
        entry.locationLatitude = draftLocationLatitude
        entry.locationLongitude = draftLocationLongitude
        entry.musicTitle       = draftMusicTitle
        entry.musicArtist      = draftMusicArtist
        entry.musicArtworkData = draftMusicArtworkData
        entry.audioData        = draftAudioData
        entry.musicPreviewURL = draftMusicPreviewURL

        context.insert(entry)

        do {
            try context.save()
        } catch {
            context.rollback()
            errorMessage = "Could not save your entry: \(error.localizedDescription)"
            return nil
        }
        resetDraft()
        return entry
    }

    // MARK: - Populate draft from existing entry (for editing)

    func populateDraft(from entry: JournalEntry) {
        draftText  = entry.text
        draftMood  = entry.mood
        draftDate  = entry.date

        draftMediaData        = entry.mediaData
        draftLocationName     = entry.locationName
        draftLocationLatitude = entry.locationLatitude
        draftLocationLongitude = entry.locationLongitude
        draftMusicTitle       = entry.musicTitle
        draftMusicArtist      = entry.musicArtist
        draftMusicArtworkData = entry.musicArtworkData
        draftAudioData        = entry.audioData
        draftMusicPreviewURL = entry.musicPreviewURL
    }

    func analysisBlockReason(for text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let wordCount = trimmed.split(whereSeparator: \.isWhitespace).count
        guard wordCount >= 40 else {
            return "Write at least 40 words to unlock AI analysis (\(wordCount)/40)"
        }
        return nil
    }

    func resetDraftPublic() {
        resetDraft()
    }

    // MARK: - Private helpers

    func analyseEntry(_ entry: JournalEntry, using context: ModelContext) async {
        guard aiAnalysisEnabled, analysisBlockReason(for: entry.text) == nil,
              !Self.analysingIDs.contains(entry.id) else { return }
        let revision = Self.analysisRevision
        let id = entry.id
        let text = entry.text
        let mood = entry.mood
        Self.analysingIDs.insert(id)
        analysisCount += 1
        errorMessage = nil
        defer {
            Self.analysingIDs.remove(id)
            analysisCount -= 1
        }
        do {
            let result = try await analyse(text, mood)
            try Task.checkCancellation()
            guard revision == Self.analysisRevision, aiAnalysisEnabled, entry.modelContext != nil, !entry.isDeleted,
                  entry.text == text, entry.mood == mood else { return }
            // Replace awards only after a successful response; failures preserve the old awards.
            for award in entry.awards { context.delete(award) }
            entry.awards = []
            for (type, title) in result.awards {
                let award = Award(type: type, customTitle: title,
                                  aiEncouragement: result.encouragements[type])
                context.insert(award)
                award.entry = entry
            }
            entry.isAnalysed = true
            do { try context.save() }
            catch {
                context.rollback()
                throw error
            }
        } catch is CancellationError {
            // Leaving or cancelling an analysis must not mark it as completed.
        } catch {
            errorMessage = "Could not analyse entry: \(error.localizedDescription)"
        }
    }

    func reanalyseEntry(_ entry: JournalEntry, using context: ModelContext) async {
        await analyseEntry(entry, using: context)
    }

    private func resetDraft() {
        draftText  = ""
        draftMood  = .okay
        draftDate  = .now

        draftMediaData        = []
        draftLocationName     = nil
        draftLocationLatitude = nil
        draftLocationLongitude = nil
        draftMusicTitle       = nil
        draftMusicArtist      = nil
        draftMusicArtworkData = nil
        draftAudioData        = nil
        draftMusicPreviewURL = nil
    }
}
