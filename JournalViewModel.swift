import Foundation
import SwiftData
import Observation
import NaturalLanguage
import UIKit
import Combine
import SwiftUI

@Observable
final class JournalViewModel {

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

    var isAnalysing: Bool     = false
    var errorMessage: String? = nil

    // MARK: - Save + Analyse

    @MainActor
    func saveEntry(using context: ModelContext) async {
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

        try? context.save()

        resetDraft()

        guard !trimmed.isEmpty else { return }
        let wordCount = trimmed.split(whereSeparator: \.isWhitespace).count
        guard aiAnalysisEnabled, wordCount >= 40, isRecognisedLanguage(trimmed) else { return }
        await analyseEntry(entry, using: context)
    }

    private func isRecognisedLanguage(_ text: String) -> Bool {
        let recogniser = NLLanguageRecognizer()
        recogniser.processString(text)
        guard
            let dominant = recogniser.dominantLanguage,
            dominant != .undetermined
        else { return false }
        let confidence = recogniser.languageHypotheses(withMaximum: 1)[dominant] ?? 0
        guard confidence >= 0.6 else { return false }

        return !isGibberish(text)
    }

    private func isGibberish(_ text: String) -> Bool {
        let letters = text.lowercased().unicodeScalars.filter { CharacterSet.letters.contains($0) }
        guard letters.count >= 20 else { return true }

        var bigramCounts: [String: Int] = [:]
        var prev: Unicode.Scalar? = nil
        for ch in letters {
            if let p = prev {
                let bigram = "\(p)\(ch)"
                bigramCounts[bigram, default: 0] += 1
            }
            prev = ch
        }
        let total = Double(bigramCounts.values.reduce(0, +))
        let entropy = bigramCounts.values.reduce(0.0) { acc, count in
            let p = Double(count) / total
            return acc - p * log2(p)
        }
        if entropy > 10.5 { return true }

        let uniqueRatio = Double(bigramCounts.keys.count) / total
        if uniqueRatio > 0.85 { return true }

        let vowels = Set("aeiouáéíóúàèìòùâêîôûäëïöüаеёиоуыэюяАЕЁИОУЫЭЮЯ")
        var consonantRun = 0
        var maxConsonantRun = 0
        var longerThan4 = 0
        for scalar in letters {
            let char = Character(scalar)
            if vowels.contains(char) {
                consonantRun = 0
            } else {
                consonantRun += 1
                maxConsonantRun = max(maxConsonantRun, consonantRun)
                if consonantRun > 4 { longerThan4 += 1 }
            }
        }
        let consonantClusterRatio = Double(longerThan4) / Double(letters.count)
        if consonantClusterRatio > 0.1 { return true }
        if isHighlyRepetitive(text) { return true }

        return false
    }

    private func isHighlyRepetitive(_ text: String) -> Bool {
        let words = text.lowercased().split(whereSeparator: \.isWhitespace).map(String.init)
        guard words.count >= 10 else { return false }

        for n in 2...5 {
            guard words.count >= n * 2 else { continue }
            var ngramCounts: [String: Int] = [:]
            for i in 0...(words.count - n) {
                let ngram = words[i..<(i + n)].joined(separator: " ")
                ngramCounts[ngram, default: 0] += 1
            }
            let totalNgrams = Double(words.count - n + 1)
            let maxCount = Double(ngramCounts.values.max() ?? 0)
            if maxCount / totalNgrams > 0.40 { return true }
        }

        let stopWords = Set(["i", "the", "a", "and", "to", "of", "in", "is", "it", "that", "my", "me", "was", "on", "for", "with", "this"])
        let contentWords = words.filter { !stopWords.contains($0) && $0.count >= 3 }
        guard contentWords.count >= 5 else { return false }
        var wordCounts: [String: Int] = [:]
        for word in contentWords { wordCounts[word, default: 0] += 1 }
        let topWordRatio = Double(wordCounts.values.max() ?? 0) / Double(contentWords.count)
        if topWordRatio > 0.35 { return true }

        return false
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
        guard isRecognisedLanguage(trimmed) else {
            return "Entry doesn't appear to be written in a recognisable language"
        }
        return nil
    }

    func resetDraftPublic() {
        resetDraft()
    }

    // MARK: - Private helpers

    @MainActor
    private func analyseEntry(_ entry: JournalEntry, using context: ModelContext) async {
        isAnalysing  = true
        errorMessage = nil

        do {
            let result = try await EntryAnalyser.shared.analyse(entry: entry)

            for (type, title) in result.awards {
                let encouragement = result.encouragements[type]
                let award = Award(
                    type: type,
                    customTitle: title,
                    aiEncouragement: encouragement
                )
                award.entry = entry
                entry.awards.append(award)
                context.insert(award)
            }

            entry.isAnalysed = true
            try? context.save()

        } catch {
            errorMessage = "Could not analyse entry: \(error.localizedDescription)"
        }

        isAnalysing = false
    }

    @MainActor
    func reanalyseEntry(_ entry: JournalEntry, using context: ModelContext) async {
        guard aiAnalysisEnabled else { return }
        let trimmed = entry.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard analysisBlockReason(for: trimmed) == nil else { return }

        for award in entry.awards { context.delete(award) }
        entry.awards     = []
        entry.isAnalysed = false
        try? context.save()

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
