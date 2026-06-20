import Foundation
import SwiftData
import Observation

@Observable
final class MoodViewModel {

    struct DayMood: Identifiable {
        let id = UUID()
        let date: Date
        let averageMood: Double
        let entryCount: Int
    }

    var weeklyData:  [DayMood] = []
    var monthlyData: [DayMood] = []
    var yearlyData:  [DayMood] = []
    var allTimeData: [DayMood] = []
    var averageMoodThisWeek: Double = 0

    private let calendar = Calendar.current

    func update(from entries: [JournalEntry]) {
        weeklyData  = aggregateByDay(entries: entries, daysBack: 7)
        monthlyData = aggregateByDay(entries: entries, daysBack: 30)
        yearlyData  = aggregateByMonth(entries: entries, monthsBack: 12)
        allTimeData = aggregateByDay(entries: entries, daysBack: nil)

        let thisWeekValues = weeklyData.map(\.averageMood)
        averageMoodThisWeek = thisWeekValues.isEmpty
            ? 0
            : thisWeekValues.reduce(0, +) / Double(thisWeekValues.count)
    }

    // MARK: - Day-level aggregation

    private func aggregateByDay(entries: [JournalEntry], daysBack: Int?) -> [DayMood] {
        let recent: [JournalEntry]
        if let daysBack {
            let cutoff = calendar.date(byAdding: .day, value: -daysBack, to: .now)!
            recent = entries.filter { $0.date >= cutoff }
        } else {
            recent = entries
        }

        var byDay: [Date: [Int]] = [:]
        for entry in recent {
            let day = calendar.startOfDay(for: entry.date)
            byDay[day, default: []].append(entry.mood.rawValue)
        }

        return byDay
            .map { day, values in
                DayMood(
                    date: day,
                    averageMood: Double(values.reduce(0, +)) / Double(values.count),
                    entryCount: values.count
                )
            }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Month-level aggregation

    private func aggregateByMonth(entries: [JournalEntry], monthsBack: Int?) -> [DayMood] {
        let recent: [JournalEntry]
        if let monthsBack {
            let cutoff = calendar.date(byAdding: .month, value: -monthsBack, to: .now)!
            recent = entries.filter { $0.date >= cutoff }
        } else {
            recent = entries
        }

        var byMonth: [Date: [Int]] = [:]
        for entry in recent {
            let comps = calendar.dateComponents([.year, .month], from: entry.date)
            let monthStart = calendar.date(from: comps)!
            byMonth[monthStart, default: []].append(entry.mood.rawValue)
        }

        return byMonth
            .map { monthStart, values in
                DayMood(
                    date: monthStart,
                    averageMood: Double(values.reduce(0, +)) / Double(values.count),
                    entryCount: values.count
                )
            }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Helpers

    func moodLabel(for value: Double) -> String {
        switch value {
        case ..<1.5: return "Terrible"
        case ..<2.5: return "Bad"
        case ..<3.5: return "Okay"
        case ..<4.5: return "Good"
        default:     return "Great"
        }
    }
}
