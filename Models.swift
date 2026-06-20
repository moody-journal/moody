import Foundation
import SwiftData

// MARK: - Mood

enum Mood: Int, Codable, CaseIterable {
    case terrible = 1
    case bad      = 2
    case okay     = 3
    case good     = 4
    case great    = 5

    var label: String {
        switch self {
        case .terrible: return "Terrible"
        case .bad:      return "Bad"
        case .okay:     return "Okay"
        case .good:     return "Good"
        case .great:    return "Great"
        }
    }

    var emoji: String {
        switch self {
        case .terrible: return "😔"
        case .bad:      return "😕"
        case .okay:     return "😐"
        case .good:     return "🙂"
        case .great:    return "😄"
        }
    }

    var color: String {
        switch self {
        case .terrible: return "moodTerrible"
        case .bad:      return "moodBad"
        case .okay:     return "moodOkay"
        case .good:     return "moodGood"
        case .great:    return "moodGreat"
        }
    }
}

// MARK: - Award Type

enum AwardType: String, Codable, CaseIterable {

    case connectedWithSomeone  = "Connected with someone"
    case helpedOthers          = "Helped others"
    case madeAmends            = "Made amends"
    case reachedOutFirst       = "Reached out first"

    case prioritisedSleep      = "Prioritised sleep"
    case movedYourBody         = "Moved your body"
    case ateWell               = "Nourished yourself"
    case practicedMindfulness  = "Practiced mindfulness"
    case restedWithoutGuilt    = "Rested without guilt"
    case spentTimeInNature     = "Spent time in nature"
    case disconnectedFromScreens = "Disconnected from screens"

    case learnedSomethingNew   = "Learned something new"
    case steppedOutsideComfort = "Stepped outside comfort zone"
    case askedForHelp          = "Asked for help"
    case satWithUncertainty    = "Sat with uncertainty"
    case createdSomething      = "Created something"

    case keptGoing             = "Kept going"
    case handledDifficulty     = "Handled difficulty"
    case setABoundary          = "Set a boundary"
    case saidNo                = "Said no"

    case finishedSomething     = "Finished something"
    case beganSomething        = "Began something"
    case showedUpForYourself   = "Showed up for yourself"
    case celebratedAWin        = "Celebrated a win"

    case forgivingYourself     = "Forgave yourself"
    case criedItOut            = "Let it out"

    case blewUpMicrowave       = "Blew up the microwave"
    case sangInTheShower       = "Sang in the shower"
    case heroicNapper          = "Heroic napper"
    case doomScrolled          = "Doom scrolled into the void"
    case lostASock             = "Lost a sock"
    case breakfastPizza        = "Breakfast pizza"
    case autocorrectDisaster   = "Autocorrect disaster"
    case rememberedADream      = "Remembered a dream"
    case guessedTimeCorrectly  = "Guessed the time correctly"
    case droppedPhoneOnFace    = "Dropped phone on face"

    // MARK: Medal emoji

    var medal: String {
        switch self {
        case .connectedWithSomeone:    return "🤝"
        case .helpedOthers:            return "🌟"
        case .madeAmends:              return "🕊️"
        case .reachedOutFirst:         return "💌"
        case .prioritisedSleep:        return "🌙"
        case .movedYourBody:           return "🏃"
        case .ateWell:                 return "🥗"
        case .practicedMindfulness:    return "🧘"
        case .restedWithoutGuilt:      return "🛋️"
        case .spentTimeInNature:       return "🌿"
        case .disconnectedFromScreens: return "🌅"
        case .learnedSomethingNew:     return "📚"
        case .steppedOutsideComfort:   return "🚀"
        case .askedForHelp:            return "🙋"
        case .satWithUncertainty:      return "🌊"
        case .createdSomething:        return "🎨"
        case .keptGoing:               return "💪"
        case .handledDifficulty:       return "🛡️"
        case .setABoundary:            return "🚦"
        case .saidNo:                  return "✋"
        case .finishedSomething:       return "✅"
        case .beganSomething:          return "🌱"
        case .showedUpForYourself:     return "❤️"
        case .celebratedAWin:          return "🎉"
        case .forgivingYourself:       return "🌸"
        case .criedItOut:              return "💧"
        case .blewUpMicrowave:         return "🔥"
        case .sangInTheShower:         return "🚿"
        case .heroicNapper:            return "🥱"
        case .doomScrolled:            return "📱"
        case .lostASock:               return "🧦"
        case .breakfastPizza:          return "🍕"
        case .autocorrectDisaster:     return "😬"
        case .rememberedADream:        return "🧠"
        case .guessedTimeCorrectly:    return "🎯"
        case .droppedPhoneOnFace:      return "📵"
        }
    }

    // MARK: Short description

    var shortDescription: String {
        switch self {
        case .connectedWithSomeone:
            return "You reached out and made a real connection today."
        case .helpedOthers:
            return "You gave your time or energy to support someone else."
        case .madeAmends:
            return "You chose repair over pride."
        case .reachedOutFirst:
            return "You didn't wait to be noticed. You made the first move."
        case .prioritisedSleep:
            return "You gave your body the rest it needed."
        case .movedYourBody:
            return "You got your body moving — every bit counts."
        case .ateWell:
            return "You took care of your body with good food."
        case .practicedMindfulness:
            return "You paused and paid attention to the present moment."
        case .restedWithoutGuilt:
            return "Rest isn't laziness. You chose to recover on purpose."
        case .spentTimeInNature:
            return "You stepped outside and let the world slow you down."
        case .disconnectedFromScreens:
            return "You gave your mind a break from the noise."
        case .learnedSomethingNew:
            return "You fed your curiosity today."
        case .steppedOutsideComfort:
            return "You chose growth over safety. That takes courage."
        case .askedForHelp:
            return "Asking for help is its own kind of strength."
        case .satWithUncertainty:
            return "You didn't try to fix it or force an answer. You just held it."
        case .createdSomething:
            return "You made something that didn't exist before. That matters."
        case .keptGoing:
            return "You pushed through even when it was hard."
        case .handledDifficulty:
            return "You faced something tough and got through it."
        case .setABoundary:
            return "You honoured what matters to you."
        case .saidNo:
            return "No is a complete sentence. You used it."
        case .finishedSomething:
            return "You saw it through to the end."
        case .beganSomething:
            return "Starting is often the hardest part. You did it."
        case .showedUpForYourself:
            return "You showed up, and that matters."
        case .celebratedAWin:
            return "You stopped to notice something good. That's a skill."
        case .forgivingYourself:
            return "You gave yourself the grace you'd give a friend."
        case .criedItOut:
            return "Letting yourself feel it is braver than holding it in."
        case .blewUpMicrowave:
            return "You heated something for way too long. A legend."
        case .sangInTheShower:
            return "A full concert. Zero shame. Standing ovation from no one."
        case .heroicNapper:
            return "You lay down for 'just five minutes' and woke up a new person."
        case .doomScrolled:
            return "Two hours. You don't want to talk about it."
        case .lostASock:
            return "The dryer claims another victim. Moment of silence."
        case .breakfastPizza:
            return "Cold pizza for breakfast. Nutritionally questionable. Spiritually correct."
        case .autocorrectDisaster:
            return "You sent that. You cannot unsend that. You have been changed by this."
        case .rememberedADream:
            return "It made absolutely no sense. You told someone about it anyway. They nodded politely."
        case .guessedTimeCorrectly:
            return "No phone. No clock. Just instinct, confidence, and being inexplicably right. Eerie."
        case .droppedPhoneOnFace:
            return "Lying down. Scrolling. Then: impact. You saw it coming and did nothing. A classic."
        }
    }
}

// MARK: - Award

@Model
final class Award {
    var id:              UUID
    var type:            AwardType
    var customTitle:     String?
    var aiEncouragement: String?
    var earnedAt:        Date

    @Relationship(inverse: \JournalEntry.awards)
    var entry: JournalEntry?

    init(type: AwardType,
         customTitle: String? = nil,
         aiEncouragement: String? = nil,
         earnedAt: Date = .now) {
        self.id              = UUID()
        self.type            = type
        self.customTitle     = customTitle
        self.aiEncouragement = aiEncouragement
        self.earnedAt        = earnedAt
    }

    var displayTitle: String {
        customTitle ?? type.rawValue
    }
}

// MARK: - JournalEntry

@Model
final class JournalEntry {
    var id:         UUID
    var date:       Date
    var text:       String
    var mood:       Mood
    var isAnalysed: Bool

    // MARK: Media (photos & videos stored as raw Data)
    @Attribute(.externalStorage)
    var mediaData: [Data]

    // MARK: Location
    var locationName: String?
    var locationLatitude: Double?
    var locationLongitude: Double?
    
    var musicPreviewURL: URL?

    // MARK: Music
    var musicTitle: String?
    var musicArtist: String?
    @Attribute(.externalStorage)
    var musicArtworkData: Data?

    var draftAudioData: Data? = nil

    // MARK: Weather
    var weatherCondition: String?
    var weatherTemperatureCelsius: Double?
    var weatherSymbolName: String?

    var audioData: Data? = nil

    @Relationship(deleteRule: .cascade)
    var awards: [Award]

    init(text: String, mood: Mood, date: Date = .now) {
        self.id         = UUID()
        self.date       = date
        self.text       = text
        self.mood       = mood
        self.isAnalysed = false
        self.awards     = []

        self.mediaData                 = []
        self.locationName              = nil
        self.locationLatitude          = nil
        self.locationLongitude         = nil
        self.musicTitle                = nil
        self.musicArtist               = nil
        self.musicArtworkData          = nil
        self.weatherCondition          = nil
        self.weatherTemperatureCelsius = nil
        self.weatherSymbolName         = nil
        self.draftAudioData            = nil
    }
}
