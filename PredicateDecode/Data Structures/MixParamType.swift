import Foundation

enum MixParamType: Int16, CaseIterable, Codable {
    case mood = 1
    case activity
    case genre
    case instrument
    case vocalLevel
    case hasMarkers
    case releaseDate
    case duration
    case sortOrder
    case custom
    case appleArtist
}

extension MixParamType {
    var defaultJoinType: MixParamJoinType {
        switch self {
        case .vocalLevel:
            return .any
        default:
            return .all
        }
    }
    
    var isJoinable: Bool {
        switch self {
        case .hasMarkers, .releaseDate, .duration, .sortOrder:
            return false
        default:
            return true
        }
    }
    
    var isTagType: Bool {
        switch self {
        case .mood, .activity, .genre, .instrument, .custom:
            return true
        default:
            return false
        }
    }

    var isAppleArtist: Bool {
        switch self {
        case .appleArtist:
            return true
        default:
            return false
        }
    }
}
