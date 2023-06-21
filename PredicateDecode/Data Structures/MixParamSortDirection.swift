import Foundation

enum MixParamSortDirection: Int16, Codable {
    case ascending = 1
    case descending
    case shuffled
    
    var sortOrder: SortOrder {
        switch self {
        case .ascending:
            return .forward
        case .descending:
            return .reverse
        case .shuffled:
            return .forward
        }
    }
}
