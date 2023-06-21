import Foundation

enum MixParamSortableProperty: Int16, CaseIterable, Codable, Hashable, Equatable {
    case dateTagged = 1
    case dateReleased
    case dateLastPlayed
    case playCount

    case skipCount
    case durationInSeconds
    case shuffled
}
