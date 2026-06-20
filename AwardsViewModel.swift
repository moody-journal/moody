import Foundation
import SwiftData
import Observation

@Observable
final class AwardsViewModel {

    var groupedAwards: [(type: AwardType, awards: [Award])] = []
    var totalCount: Int = 0

    func update(from awards: [Award]) {
        totalCount = awards.count

        var dict: [AwardType: [Award]] = [:]
        for award in awards {
            dict[award.type, default: []].append(award)
        }

        groupedAwards = dict
            .map { (type: $0.key, awards: $0.value) }
            .sorted {
                if $0.awards.count != $1.awards.count {
                    return $0.awards.count > $1.awards.count
                }
                return $0.type.rawValue < $1.type.rawValue
            }
    }

    func latestAward(from awards: [Award]) -> Award? {
        awards.max(by: { $0.earnedAt < $1.earnedAt })
    }
}
