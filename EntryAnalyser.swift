import Foundation
import FoundationModels

// MARK: - Analyser Result

struct AnalysisResult {
    let awards: [(type: AwardType, customTitle: String)]
    let encouragements: [AwardType: String]
}

// MARK: - Entry Analyser

actor EntryAnalyser {
    static let shared = EntryAnalyser()
    private init() {}

    func analyse(entry: JournalEntry) async throws -> AnalysisResult {
        guard #available(iOS 18.4, *) else {
            return AnalysisResult(awards: [], encouragements: [:])
        }
        return try await performAnalysis(text: entry.text, mood: entry.mood)
    }

    @available(iOS 18.4, *)
    private func performAnalysis(text: String, mood: Mood) async throws -> AnalysisResult {
        let session = LanguageModelSession()
        let availableTypes = AwardType.allCases.map { "- \($0.rawValue)" }.joined(separator: "\n")

        let moodContext: String
        switch mood {
        case .terrible, .bad:
            moodContext = "The user is having a hard day (mood: \(await mood.label)). Be especially warm and lenient. Even tiny acts of self-care or survival count. Look harder for the small things — getting out of bed, eating, reaching out, anything. Award generously but only if there is genuine evidence in the text."
        case .okay:
            moodContext = "The user is feeling okay (mood: \(await mood.label)). Apply normal judgement — award things that genuinely stand out, don't award routine or trivial actions."
        case .good, .great:
            moodContext = "The user is having a good day (mood: \(await mood.label)). Apply a higher bar — only award things that are genuinely notable achievements or positive behaviours, not just things that happened."
        }

        let prompt = """
        You are a warm, perceptive friend reading someone's private journal entry. Your job is to notice real personal achievements and award them — but you must use careful judgement.

        MOOD CONTEXT:
        \(moodContext)

        YOUR RULES — read every one carefully AND YOU MUST FOLLOW THEM:

        1. READ THE WHOLE ENTRY before deciding anything. Don't award the first achievement you see and stop — scan everything, then decide.

        2. ONLY award things that are explicitly described or strongly implied. Do not invent achievements that aren't in the text. If the entry is vague, short, or meaningless (e.g. a single word, random characters, "I don't know", "nothing happened"), award nothing.

        3. AWARD EVERY SIGNIFICANT THING. If the user genuinely did five big things — finished a project, worked out, apologised to someone, cooked a proper meal, and helped a friend — all five deserve an award. Don't artificially limit it when the entry is rich.

        4. SOFT LIMIT OF 5. In a typical entry, aim for 1–5 awards. If you find yourself awarding more than 5, pause and ask: is each one truly distinct and meaningful, or am I splitting one achievement into multiple awards? Merge overlapping ones. Only exceed 5 if the entry is genuinely packed with real, separate wins.

        5. NEVER award the same achievement twice under different names. Each award must be for a clearly distinct action or behaviour.

        6. DO NOT award for passive things: watching TV, scrolling social media, having a normal conversation, going to work, things that happened to the user rather than choices they made.

        7. DO award for: acts of courage, self-care, emotional effort, helping others, finishing or starting something meaningful, pushing through difficulty, making a healthy choice, creating or learning something, setting a limit, reaching out, resting intentionally.

        8. TITLES should be specific to what the user actually did — not generic. "Finally sent that difficult email" not "Communicated well". 5–10 words.

        9. ENCOURAGEMENTS should sound like a supportive best friend — real, informal, specific to their situation. One sentence. Reference what they actually did. Never generic praise.
        
        10. ONLY award entries longer than 40 words.

        Available award types (you MUST use one of these exactly as written):
        \(availableTypes)

        Respond ONLY with a valid JSON array, no explanation, no markdown fences.
        If no awards are warranted, respond with exactly: []

        Example format:
        [{"type": "Finished something", "title": "Finally submitted that scary report", "encouragement": "Dude, you'd been putting that off for weeks — actually sending it is huge."}]

        Journal entry:
        \"\"\"\(text)\"\"\"
        """

        let response = try await session.respond(to: prompt)
        return try parseResponse(response.content)
    }

    private func parseResponse(_ content: String) throws -> AnalysisResult {
        let cleaned = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            return AnalysisResult(awards: [], encouragements: [:])
        }

        struct RawAward: Decodable {
            let type: String
            let title: String
            let encouragement: String
        }

        let rawAwards = (try? JSONDecoder().decode([RawAward].self, from: data)) ?? []

        var awards: [(type: AwardType, customTitle: String)] = []
        var encouragements: [AwardType: String] = [:]

        for raw in rawAwards {
            if let awardType = AwardType(rawValue: raw.type) {
                guard encouragements[awardType] == nil else { continue }
                awards.append((type: awardType, customTitle: raw.title))
                encouragements[awardType] = raw.encouragement
            }
        }

        return AnalysisResult(awards: awards, encouragements: encouragements)
    }
}

extension EntryAnalyser {
    func analyseAllAwards() -> AnalysisResult {
        let awards = AwardType.allCases.map { type in
            (type: type, customTitle: "Test award for \(type.rawValue)")
        }
        let encouragements = Dictionary(
            uniqueKeysWithValues: AwardType.allCases.map { type in
                (type, "This is a test encouragement for \(type.rawValue).")
            }
        )
        return AnalysisResult(awards: awards, encouragements: encouragements)
    }
}
