import Foundation

extension Array where Element == MixParam {
    var includedTagIds: [String] {
        self
            .filter { $0.isTag && !$0.isExcluded }
            .compactMap { $0.tagId }
    }
    
    var excludedTagIds: [String] {
        self
            .filter { $0.isTag && $0.isExcluded }
            .compactMap { $0.tagId }
    }
    
    var includedTagIdWithTypes: [TagIdWithType] {
        self
            .filter { $0.isTag && !$0.isExcluded }
            .compactMap { $0.tagIdWithType }
    }
    
    var excludedTagIdWithTypes: [TagIdWithType] {
        self
            .filter { $0.isTag && $0.isExcluded }
            .compactMap { $0.tagIdWithType }
    }

    var includedVocalLevels: [VocalLevel] {
        self
            .filter { $0.isVocalLevel && !$0.isExcluded }
            .compactMap { $0.vocalLevel }
    }
    
    var excludedVocalLevels: [VocalLevel] {
        self
            .filter { $0.isVocalLevel && $0.isExcluded }
            .compactMap { $0.vocalLevel }
    }
    
    var includedAppleArtistIds: [String] {
        self
            .filter { $0.isAppleArtist && !$0.isExcluded }
            .compactMap { $0.appleArtistId }
    }

    var excludedAppleArtistIds: [String] {
        let ids = self
            .filter { $0.isAppleArtist && $0.isExcluded }
            .compactMap { $0.appleArtistId }
        return ids
    }

    var hasMarkers: Bool? {
        self
            .first(where: { $0.isHasMarkers })?
            .hasMarkersValue
    }

    var rangeStringsStruct: MixRangeStrings {
        let dict = self
            .compactMap { $0.sortablePropertyWithRangeString }
            .reduce(into: [MixParamSortableProperty : String]()) { $0[$1.0] = $1.1 } /// map array of tuples to dict
        return MixRangeStrings(fromDict: dict)
    }
    
    var sortOrder: MixParamSortOrder? {
        first(where: { $0.isSortOrder })?.sortOrder
    }

    func joinTypesStruct(using joinTypes: [MixParamType : MixParamJoinType] ) -> MixJoinTypes {

        var joinTypes = joinTypes
        
        /// Ensure every applicable `MixParamType` has an entry in the dict
        for type in self.types {
            if type.isJoinable, !joinTypes.keys.contains(type) {
                joinTypes[type] = type.defaultJoinType
            }
        }
        
        /// Get all the types that have less than 2 non-excluded params
        let joinTypeRedundantTypes = joinTypes.compactMap { paramType, _ in
            
            /// Count how many non-excluded params we have for each type
            let count = nonExcludedParams(of: paramType).count
//            let count = self.filter( {
//                $0.tag?.type.mixParamType == paramType
//                && !$0.isExcluded
//            }).count
            return count < 2 ? paramType : nil
        }
        
        /// Set their join types to `.all` as having them as `.any` is redundant
        var modified = joinTypes
        for type in joinTypeRedundantTypes {
            modified[type] = .all
        }
        
        return MixJoinTypes(fromDict: modified)
    }
    
    func nonExcludedParams(of type: MixParamType) -> [MixParam] {
        filter {
            $0.matches(type: type) && !$0.isExcluded
        }
    }
    
    var types: [MixParamType] {
        self
            .map { $0.type }
            .removingDuplicates()
    }

    var releaseDateRange: (Date?, Date?)? {
        guard let param = first(where: { $0.isReleaseDateRange }) else {
            return nil
        }
        let startDate = param.startDate
        let endDate = param.endDate
        guard !(startDate == nil && endDate == nil) else {
            return nil
        }
        
        return (startDate, endDate)
    }
    
    var durationInSecondsRange: (Int?, Int?)? {
        guard let param = first(where: { $0.isDurationInSecondsRange }) else {
            return nil
        }
        let min = param.minDurationInSeconds
        let max = param.maxDurationInSeconds
        guard !(min == nil && max == nil) else {
            return nil
        }
        
        return (min, max)
    }
}

