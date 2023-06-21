import Foundation

enum MixParam: Hashable, Equatable {
    /// Boolean values indicate whether they're being used to exclude the parameter
    case tag(id: String, type: TagType, Bool)
    case vocalLevel(VocalLevel, Bool)
    case appleArtist(id: String, Bool)
    
    case releaseDateRange(Date?, Date?)
    case durationInSecondsRange(Int?, Int?)
    case sortOrder(MixParamSortOrder)
    case hasMarkers(Bool)
}

extension MixParam {
    var isTag: Bool {
        switch self {
        case .tag:
            return true
        default:
            return false
        }
    }
    
    var isExcluded: Bool {
        get {
            switch self {
            case .tag(_, _, let bool):
                return bool
            case .appleArtist(_, let bool):
                return bool
            case .vocalLevel(_, let bool):
                return bool
            default:
                return false
            }
        }
        set {
            switch self {
            case .tag(let id, let type, _):
                self = .tag(id: id, type: type, newValue)
            case .appleArtist(let id, _):
                self = .appleArtist(id: id, newValue)
            case .vocalLevel(let vocalLevel, _):
                self = .vocalLevel(vocalLevel, newValue)
            default:
                break
            }
        }
    }
    
    var isReleaseDateRange: Bool {
        switch self {
        case .releaseDateRange:
            return true
        default:
            return false
        }
    }

    var isDurationInSecondsRange: Bool {
        switch self {
        case .durationInSecondsRange:
            return true
        default:
            return false
        }
    }

    var tagType: TagType? {
        switch self {
        case .tag(_, let type, _):
            return type
        default:
            return nil
        }
    }

    var type: MixParamType {
        switch self {
        case .tag(_, let type, _):
            return type.mixParamType
        case .appleArtist:
            return .appleArtist
        case .vocalLevel:
            return .vocalLevel
        case .releaseDateRange:
            return .releaseDate
        case .durationInSecondsRange:
            return .duration
        case .sortOrder:
            return .sortOrder
        case .hasMarkers:
            return .hasMarkers
        }
    }
    
    var tagId: String? {
        switch self {
        case .tag(let id, _, _):
            return id
        default:
            return nil
        }
    }
    
    var tagIdWithType: TagIdWithType? {
        switch self {
        case .tag(let id, let type, _):
            return TagIdWithType(id: id, type: type)
        default:
            return nil
        }
    }
    
    var sortOrder: MixParamSortOrder? {
        switch self {
        case .sortOrder(let sortOrder):
            return sortOrder
        default:
            return nil
        }
    }
    
    var isSortOrder: Bool {
        switch self {
        case .sortOrder:
            return true
        default:
            return false
        }
    }
    
    var isVocalLevel: Bool {
        switch self {
        case .vocalLevel:
            return true
        default:
            return false
        }
    }
    
    var vocalLevel: VocalLevel? {
        switch self {
        case .vocalLevel(let vocalLevel, _):
            return vocalLevel
        default:
            return nil
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
    
    var appleArtistId: String? {
        switch self {
        case .appleArtist(let id, _):
            return id
        default:
            return nil
        }
    }
    
    var isHasMarkers: Bool {
        switch self {
        case .hasMarkers:
            return true
        default:
            return false
        }
    }
    
    var hasMarkersValue: Bool? {
        switch self {
        case .hasMarkers(let bool):
            return bool
        default:
            return nil
        }
    }

    var sortablePropertyWithRangeString: (MixParamSortableProperty, String)? {
        switch self {
            
        case .releaseDateRange(let date, let date2):
            let string = "\(date?.rangeDateFormat ?? "")...\(date2?.rangeDateFormat ?? "")"
            return (.dateReleased, string)
            
        case .durationInSecondsRange(let int, let int2):
            let string = "\(int?.string ?? "")...\(int2?.string ?? "")"
            return (.durationInSeconds, string)
            
        //TODO: Add more as we add them here
            
        case .sortOrder:
            return nil
        case .tag:
            return nil
        case .appleArtist:
            return nil
        case .vocalLevel:
            return nil
            
        case .hasMarkers:
            return nil
        }
    }
    
    func matches(type: MixParamType) -> Bool {
        if type.isTagType {
            return self.tagType?.mixParamType == type
        }
        else if type.isAppleArtist {
            return self.isAppleArtist
        }
        
        /// Does not apply to other types since the joins can't be customized
        return false
    }
    
    var minDurationInSeconds: Int? {
        switch self {
        case .durationInSecondsRange(let min, _):
            return min
        default:
            return nil
        }
    }
    
    var maxDurationInSeconds: Int? {
        switch self {
        case .durationInSecondsRange(_, let max):
            return max
        default:
            return nil
        }
    }
    
    var startDate: Date? {
        switch self {
        case .releaseDateRange(let startDate, _):
            return startDate
        default:
            return nil
        }
    }
    
    var endDate: Date? {
        switch self {
        case .releaseDateRange(_, let endDate):
            return endDate
        default:
            return nil
        }
    }
}
