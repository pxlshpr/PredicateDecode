import Foundation
import SwiftData

@Model
class Mix {

    @Attribute(.unique) var id: UUID
    var isFavorite: Bool
    var name: String?
    var emoji: String?

    var includedTagIdWithTypesString: String?
    var excludedTagIdWithTypesString: String?
    var includedVocalLevelsString: String?
    var excludedVocalLevelsString: String?
    
    var includedAppleArtistIdsString: String?
    var excludedAppleArtistIdsString: String?

    var joinTypes: MixJoinTypes
    var rangeStrings:  MixRangeStrings

    var hasMarkers: Bool?
    
    var sortOrder: MixParamSortOrder

    var sortPosition: Int
    var playCount: Int
    var lastPlayedAt: Date
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        isFavorite: Bool = false,
        name: String? = nil,
        emoji: String? = nil,
        includedTagIdWithTypesString: String? = nil,
        excludedTagIdWithTypesString: String? = nil,
        includedVocalLevelsString: String? = nil,
        excludedVocalLevelsString: String? = nil,
        includedAppleArtistIdsString: String? = nil,
        excludedAppleArtistIdsString: String? = nil,
        hasMarkers: Bool? = nil,
        joinTypes: MixJoinTypes = .init(),
        rangeStrings: MixRangeStrings = .init(),
        sortOrder: MixParamSortOrder = .shuffled,
        sortPosition: Int = 0,
        playCount: Int = 0,
        lastPlayedAt: Date = Date.now,
        createdAt: Date = Date.now
    ) {
        self.id = id
        self.isFavorite = isFavorite
        self.name = name
        self.emoji = emoji
        self.includedTagIdWithTypesString = includedTagIdWithTypesString
        self.excludedTagIdWithTypesString = excludedTagIdWithTypesString
        self.includedVocalLevelsString = includedVocalLevelsString
        self.excludedVocalLevelsString = excludedVocalLevelsString
        self.includedAppleArtistIdsString = includedAppleArtistIdsString
        self.excludedAppleArtistIdsString = excludedAppleArtistIdsString
        
        self.hasMarkers = hasMarkers
        self.joinTypes = joinTypes
        self.rangeStrings = rangeStrings
        self.sortOrder = sortOrder
        self.sortPosition = sortPosition
        self.playCount = playCount
        self.lastPlayedAt = lastPlayedAt
        self.createdAt = createdAt
    }
    
    func reset() {
        includedTagIdWithTypesString = nil
        excludedTagIdWithTypesString = nil
        includedVocalLevelsString = nil
        excludedVocalLevelsString = nil
        includedAppleArtistIdsString = nil
        excludedAppleArtistIdsString = nil
        hasMarkers = nil

        joinTypes = .init()
        rangeStrings = .init()
        
        sortOrder = .default

        sortPosition = 0
        playCount = 0
        lastPlayedAt = Date.now
        createdAt = Date.now
    }
    
    convenience init(params: [MixParam], joinTypes: [MixParamType : MixParamJoinType]) {
        self.init(
            includedTagIdWithTypesString: params.includedTagIdWithTypes.stringRepresentation,
            excludedTagIdWithTypesString: params.excludedTagIdWithTypes.stringRepresentation,
            includedVocalLevelsString: params.includedVocalLevels.stringRepresentation,
            excludedVocalLevelsString: params.excludedVocalLevels.stringRepresentation,
            
            includedAppleArtistIdsString: params.includedAppleArtistIds.stringRepresentation,
            excludedAppleArtistIdsString: params.excludedAppleArtistIds.stringRepresentation,
            
            hasMarkers: params.hasMarkers,
            joinTypes: params.joinTypesStruct(using: joinTypes),
            rangeStrings: params.rangeStringsStruct,
            sortOrder: params.sortOrder ?? .default
        )
    }
}

extension Mix {
    
    var description: String? {
        switch (emoji, name) {
        case (.some(let emoji), .some(let name)):
            return "\(emoji) \(name)"
        case (.some(let emoji), .none):
            return "\(emoji)"
        case (.none, .some(let name)):
            return "\(name)"
        case (.none, .none):
            return nil
        }
    }
}

extension Mix {
    
    var isTransient: Bool {
        name == nil && emoji == nil
    }

    var joinTypesDict: [MixParamType : MixParamJoinType] {
        joinTypes.asDict
    }
    
    var includedVocalLevels: [VocalLevel] {
        includedVocalLevelsString?.asVocalLevelsArray ?? []
    }
    
    var excludedVocalLevels: [VocalLevel] {
        excludedVocalLevelsString?.asVocalLevelsArray ?? []
    }

    var mixParams: [MixParam] {
        var params: [MixParam] = []
        
        /// Included Tags
        if let includedTagIdWithTypesString {
            for tag in includedTagIdWithTypesString.asTagIdWithTypesArray {
                params.append(MixParam.tag(id: tag.id, type: tag.type, false))
            }
        }
        
        /// Excluded Tags
        if let excludedTagIdWithTypesString {
            for tag in excludedTagIdWithTypesString.asTagIdWithTypesArray {
                params.append(MixParam.tag(id: tag.id, type: tag.type, true))
            }
        }
        
        /// Included VocalLevels
        for vocalLevel in includedVocalLevels {
            params.append(MixParam.vocalLevel(vocalLevel, false))
        }

        /// Excluded VocalLevels
        for vocalLevel in excludedVocalLevels {
            params.append(MixParam.vocalLevel(vocalLevel, true))
        }
        
        /// Included AppleArtists
        if let includedAppleArtistIdsString {
            for id in includedAppleArtistIdsString.asAppleArtistIdsArray {
                params.append(MixParam.appleArtist(id: id, false))
            }
        }
        
        /// Excluded AppleArtists
        if let excludedAppleArtistIdsString {
            for id in excludedAppleArtistIdsString.asAppleArtistIdsArray {
                params.append(MixParam.appleArtist(id: id, true))
            }
        }
 
        /// hasMarkers
        if let hasMarkers {
            params.append(.hasMarkers(hasMarkers))
        }
        
        /// Range Strings
        params.append(contentsOf: rangeStrings.mixParams)
        
        /// Sort Order
        params.append(MixParam.sortOrder(sortOrder))
        
        return params
    }
}

extension Mix {
    func hasTagParamsWithoutTagType(_ tagType: TagType) -> Bool {
        for param in mixParams {
            guard !param.isSortOrder else { continue }
            if let paramTagType = param.tagType {
                if paramTagType != tagType {
                    return true
                }
            } else {
                return true
            }
        }
        return false
    }
}

//MARK: - Legacy

//@Model
//class Mix {
//
//    @Attribute(.unique) var id: UUID
//    var name: String?
//    var emoji: String?
//
//    var includedTagIdWithTypesString: String?
//    var excludedTagIdWithTypesString: String?
//    var includedVocalLevelsString: String?
//    var excludedVocalLevelsString: String?
//
//    var joinTypesString: String
//
//    var rangeStringsString: String
//
//    var sortPropertyValue: MixParamSortableProperty.RawValue
//    var sortDirectionValue: MixParamSortDirection.RawValue
//
//    var sortPosition: Int
//    var playCount: Int
//    var lastPlayedAt: Date
//    var createdAt: Date
//}
//
//extension Mix {
//
//    var sortProperty: MixParamSortableProperty {
//        MixParamSortableProperty(rawValue: sortPropertyValue)!
//    }
//
//    var sortDirection: MixParamSortDirection {
//        MixParamSortDirection(rawValue: sortDirectionValue)!
//    }
//
//    var sortOrder: MixParamSortOrder {
//        MixParamSortOrder(direction: sortDirection, property: sortProperty)!
//    }
//
//    var includedTagIdWithTypes: [TagIdWithType] {
//        includedTagIdWithTypesString?
//            .components(separatedBy: ValuesSeparator)
//            .compactMap { TagIdWithType(string: $0) } ?? []
//    }
//
//    var excludedTagIdWithTypes: [TagIdWithType] {
//        excludedTagIdWithTypesString?
//            .components(separatedBy: ValuesSeparator)
//            .compactMap { TagIdWithType(string: $0) } ?? []
//    }
//
//    var includedVocalLevels: [VocalLevel] {
//        guard let includedVocalLevelsString else { return [] }
//        return includedVocalLevelsString
//            .components(separatedBy: ValuesSeparator)
//            .compactMap {
//                guard let rawValue = Int16($0),
//                      let vocalLevel = VocalLevel(rawValue: rawValue) else {
//                    return nil
//                }
//                return vocalLevel
//            }
//    }
//
//    var excludedVocalLevels: [VocalLevel] {
//        guard let excludedVocalLevelsString else { return [] }
//        return excludedVocalLevelsString
//            .components(separatedBy: ValuesSeparator)
//            .compactMap {
//                guard let rawValue = Int16($0),
//                      let vocalLevel = VocalLevel(rawValue: rawValue) else {
//                    return nil
//                }
//                return vocalLevel
//            }
//    }
//
//    var joinTypes: MixJoinTypes {
//        MixJoinTypes(fromStringRepresentation: joinTypesString)
//    }
//
//    var rangeStrings: MixRangeStrings {
//        MixRangeStrings(fromStringRepresentation: rangeStringsString)
//    }
//}

extension MixRangeStrings {
    var mixParams: [MixParam] {
        var params: [MixParam] = []
        
        if let dates = dateReleased.parsedDateRange {
            params.append(MixParam.releaseDateRange(dates.0, dates.1))
        }
        
        if let durations = durationInSeconds.parsedIntRange {
            params.append(MixParam.durationInSecondsRange(durations.0, durations.1))
        }

        //TODO: Add the remaining ones in as needed
        
        return params
    }
}
