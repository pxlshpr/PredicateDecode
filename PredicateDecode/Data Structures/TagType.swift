import Foundation

enum TagType: Int, CaseIterable, Codable {
    case mood = 1
    case activity
    case genre
    case instrument
    case custom
}

extension TagType {
    var mixParamType: MixParamType {
        switch self {
        case .mood:
            return .mood
        case .activity:
            return .activity
        case .genre:
            return .genre
        case .instrument:
            return .instrument
        case .custom:
            return .custom
        }
    }
}
