import Foundation
import SwiftData
import Observation

@Observable
final class MoodViewModel {

    struct DayMood: Identifiable {
        var id: Date { date }
        let date: Date
        let averageMood: Double
        let entryCount: Int
    }

    var weeklyData:  [DayMood] = []
    var monthlyData: [DayMood] = []
    var yearlyData:  [DayMood] = []
    var allTimeData: [DayMood] = []
    var averageMoodThisWeek: Double = 0

    func update(from entries: [JournalEntry], now: Date = .now, calendar: Calendar = .current) {
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? now
        let weekStart = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        let monthStart = calendar.date(byAdding: .day, value: -29, to: today) ?? today
        let currentMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        let yearStart = calendar.date(byAdding: .month, value: -11, to: currentMonth) ?? currentMonth
        var days: [Date: (sum: Int, count: Int)] = [:]
        var months: [Date: (sum: Int, count: Int)] = [:]
        for entry in entries where entry.date < tomorrow {
            let day = calendar.startOfDay(for: entry.date)
            days[day, default: (0, 0)].sum += entry.mood.rawValue
            days[day, default: (0, 0)].count += 1
            if entry.date >= yearStart, let month = calendar.dateInterval(of: .month, for: entry.date)?.start {
                months[month, default: (0, 0)].sum += entry.mood.rawValue
                months[month, default: (0, 0)].count += 1
            }
        }
        allTimeData = days.map { DayMood(date: $0.key, averageMood: Double($0.value.sum) / Double($0.value.count), entryCount: $0.value.count) }.sorted { $0.date < $1.date }
        weeklyData = allTimeData.filter { $0.date >= weekStart }
        monthlyData = allTimeData.filter { $0.date >= monthStart }
        yearlyData = months.map { DayMood(date: $0.key, averageMood: Double($0.value.sum) / Double($0.value.count), entryCount: $0.value.count) }.sorted { $0.date < $1.date }
        let count = weeklyData.reduce(0) { $0 + $1.entryCount }
        averageMoodThisWeek = count == 0 ? 0 : weeklyData.reduce(0) { $0 + $1.averageMood * Double($1.entryCount) } / Double(count)
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
