import Foundation
import SwiftData
import OSLog

extension Mix {
    
    var fetchDescriptor: FetchDescriptor<Choon> {
        FetchDescriptor<Choon>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
    }
    
    var predicate: Predicate<Choon> {
        mixParams.predicate(
            using: joinTypesDict
        )
    }
    
    var sortDescriptors: [SortDescriptor<Choon>] {
        let order = sortOrder.direction.sortOrder
        switch sortOrder.property {
        case .dateLastPlayed:
            return [SortDescriptor(\.lastPlayedAt, order: order)]
        case .dateReleased:
            return [SortDescriptor(\.releasedAt, order: order)]
        case .dateTagged:
            return [SortDescriptor(\.createdAt, order: order)]
        case .durationInSeconds:
            return [SortDescriptor(\.durationInSeconds, order: order)]
        case .playCount:
            return [SortDescriptor(\.playCount, order: order)]
        case .skipCount:
            return [SortDescriptor(\.skipCount, order: order)]
        case .shuffled:
            return [SortDescriptor(\.createdAt, order: order)]
        }
    }
}

extension Array where Element == MixParam {
    
    func predicate(using joinTypes: [MixParamType : MixParamJoinType]) -> Predicate<Choon> {
        
        let andTagTypes: [MixParamType] = joinTypes.compactMap { key, value in
            guard value == .all, key.isTagType else { return nil }
            return key
        }
        let orTagTypes: [MixParamType] = joinTypes.compactMap { key, value in
            guard value == .any, key.isTagType else { return nil }
            return key
        }
        func tagId(_ id: String) -> [Expression] {
            [.keyPath("Choons.Choon.tagIds"), .string(id)]
        }
        func appleArtistId(_ id: String) -> [Expression] {
            [.keyPath("Choons.Choon.appleArtistIds"), .string(id)]
        }
        func vocalLevelValue(_ value: Int) -> [Expression] {
            [.keyPath("Choons.Choon.vocalLevelValue"), .int(value)]
        }
        func lessThanOrEqualDate(_ date: Date) -> [Expression] {
            [
                .keyPath("Choons.Choon.releasedAt"),
                .double(date.timeIntervalSince1970),
                .lessThanOrEqual
            ]
        }
        func greaterThanOrEqualDate(_ date: Date) -> [Expression] {
            [
                .keyPath("Choons.Choon.releasedAt"),
                .double(date.timeIntervalSince1970),
                .greaterThanOrEqual
            ]
        }
        func lessThanOrEqualDuration(_ double: Double) -> [Expression] {
            [
                .keyPath("Choons.Choon.durationInSeconds"),
                .double(double),
                .lessThanOrEqual
            ]
        }
        func greaterThanOrEqualDuration(_ double: Double) -> [Expression] {
            [
                .keyPath("Choons.Choon.durationInSeconds"),
                .double(double),
                .greaterThanOrEqual
            ]
        }

        func markersCondition(_ hasMarkers: Bool) -> [Expression] {
            [.keyPath("Choons.Choon.hasMarkers"), .bool(hasMarkers)]
        }

        let isNotDislikedCondition: [Expression] = [.keyPath("Choons.Choon.isDisliked"), .bool(false)]

        func or(_ lhs: Joinable, _ rhs: Joinable) -> Joinable {
            .or([lhs, rhs])
        }
        func and(_ lhs: Joinable, _ rhs: Joinable) -> Joinable {
            .and([lhs, rhs])
        }
        
        let contains: Joinable = .contains([.keyPath(.string), .stringValue])
        let equalsInt: Joinable = .equal([.keyPath(.int), .intValue])
        let equalsBool: Joinable = .equal([.keyPath(.bool), .boolValue])
        let compareDouble: Joinable = .comparison([.keyPath(.double), .doubleValue])
        let notEqualsInt: Joinable = .notEqual([.keyPath(.int), .intValue])

        /// Tags used in conjunctions are stored in a flat array
        var andTags = self.includedTagIdWithTypes.filter { andTagTypes.contains($0.type.mixParamType) }
        
        /// Tags used in disjunctions, are stored in this 2-dimensional array, where:
        /// - the first level is the types that we would used conjunctions between
        /// - the second level is the tags within each type that we would just disjunctions between
        var orTagGroups =  orTagTypes.map { type in
            let tags = includedTagIdWithTypes.filter { $0.type.mixParamType == type }
            guard tags.count > 1 else {
                fatalError("OR tag groups must have at least 2 tags each")
            }
            return tags
        }
        
        var includedVocalLevels = includedVocalLevels
        var excludedVocalLevels = excludedVocalLevels
        var excludedTags = self.excludedTagIdWithTypes
        var excludedAppleArtists = self.excludedAppleArtistIds
        var includedAppleArtistIds = self.includedAppleArtistIds

        /// Keeps track of non-array based params that we might add at the start (so that we don't add them again later)
        var releaseDateRangeAdded = false
        var durationRangeAdded = false
        var hasMarkersAdded = false
        var isNotDislikedAdded = false

        var expression: Expression
        var statement: Joinable

        //MARK: - Initialize with starting params
        
        if !orTagGroups.isEmpty {
            if orTagGroups.count > 1 {
                let (statement1, expression1) = orTagGroups.removeFirst().orStatementAndExpression
                let (statement2, expression2) = orTagGroups.removeFirst().orStatementAndExpression
                statement = and(statement1, statement2)
                expression = .array([
                    expression1,
                    expression2
                ])
            } else {
                /// `orTagsGroups.count == 1`
                let (s, e) = orTagGroups.removeFirst().orStatementAndExpression
                statement = s
                expression = e
            }
            
        } else if !includedVocalLevels.isEmpty {
            /// If we have more than 1 included vocal levels—we start by OR-ing them
            if includedVocalLevels.count > 1 {
                let (s, e) = includedVocalLevels.orStatementAndExpression
                statement = s
                expression = e
            } else {
                statement = equalsInt
                expression = .array(vocalLevelValue(includedVocalLevels.first!.rawValue))
            }

            /// Clear the vocal levels as we've already included them
            includedVocalLevels = []
            
        } else if !andTags.isEmpty {
            if andTags.count > 1 {
                let tag1 = andTags.removeFirst()
                let tag2 = andTags.removeFirst()
                statement = and(contains, contains)
                expression = .array([
                    .array(tagId(tag1.id)),
                    .array(tagId(tag2.id))
                ])
            } else {
                /// `andTags.count == 1`
                let tag = andTags.removeFirst()
                statement = contains
                expression = .array(tagId(tag.id))
            }
            
        } else if !excludedTags.isEmpty {

            if excludedTags.count > 1 {
                let tag1 = excludedTags.removeFirst()
                let tag2 = excludedTags.removeFirst()
                statement = and(.negation(contains), .negation(contains))
                expression = .array([
                    .array(tagId(tag1.id)),
                    .array(tagId(tag2.id))
                ])
            } else {
                /// `excludedTags.count == 1`
                let tag = excludedTags.removeFirst()
                statement = .negation(contains)
                expression = .array(tagId(tag.id))
            }
    
        } else if !excludedAppleArtists.isEmpty {

            if excludedAppleArtists.count > 1 {
                let artist1 = excludedAppleArtists.removeFirst()
                let artist2 = excludedAppleArtists.removeFirst()
                
                statement = and(.negation(contains), .negation(contains))
                expression = .array([
                    .array(appleArtistId(artist1)),
                    .array(appleArtistId(artist2))
                ])
            } else {
                /// `excludedAppleArtists.count == 1`
                let artist = excludedAppleArtists.removeFirst()
                statement = .negation(contains)
                expression = .array(appleArtistId(artist))
            }

        } else if !includedAppleArtistIds.isEmpty {

            if includedAppleArtistIds.count > 1 {
                let artist1 = includedAppleArtistIds.removeFirst()
                let artist2 = includedAppleArtistIds.removeFirst()
                
                if let joinType = joinTypes[.appleArtist], joinType == .any {
                    statement = or(contains, contains)
                } else {
                    statement = and(contains, contains)
                }

                expression = .array([
                    .array(appleArtistId(artist1)),
                    .array(appleArtistId(artist2))
                ])
            } else {
                /// `includedAppleArtists.count == 1`
                let artist = includedAppleArtistIds.removeFirst()
                statement = contains
                expression = .array(appleArtistId(artist))
            }


        } else if !excludedVocalLevels.isEmpty {
            
            /// If we have more than 1 excluded vocal levels—we start by AND-ing them
            if excludedVocalLevels.count > 1 {
                let (s, e) = excludedVocalLevels.andStatementAndExpression
                statement = s
                expression = e
            } else {
                statement = notEqualsInt
                expression = .array(vocalLevelValue(excludedVocalLevels.first!.rawValue))
            }
            
            /// Clear the vocal levels as we've already included them
            excludedVocalLevels = []
            
        } else if let releaseDateRange, !(releaseDateRange.0 == nil && releaseDateRange.1 == nil) {
            
            switch (releaseDateRange.0, releaseDateRange.1) {
            case (.some(let start), .some(let end)):
                /// `start...end`
                statement = and(compareDouble, compareDouble)
                expression = .array([
                    .array(greaterThanOrEqualDate(start)),
                    .array(lessThanOrEqualDate(end))
                ])
                
            case (.some(let start), .none):
                /// `>= start`
                statement = compareDouble
                expression = .array(greaterThanOrEqualDate(start))
                
            case (.none, .some(let end)):
                /// `<= end`
                statement = compareDouble
                expression = .array(lessThanOrEqualDate(end))
                
            case (.none, .none):
                fatalError()
            }
            
            releaseDateRangeAdded = true
            
        } else if let durationInSecondsRange, !(durationInSecondsRange.0 == nil && durationInSecondsRange.1 == nil) {
            
            switch (durationInSecondsRange.0, durationInSecondsRange.1) {
            case (.some(let min), .some(let max)):
                /// `min...max`
                statement = and(compareDouble, compareDouble)
                expression = .array([
                    .array(greaterThanOrEqualDuration(Double(min))),
                    .array(lessThanOrEqualDuration(Double(max)))
                ])
                
            case (.some(let min), .none):
                /// `>= min`
                statement = compareDouble
                expression = .array(greaterThanOrEqualDuration(Double(min)))
                
            case (.none, .some(let max)):
                /// `<= max`
                statement = compareDouble
                expression = .array(lessThanOrEqualDuration(Double(max)))
                
            case (.none, .none):
                fatalError()
            }
            
            durationRangeAdded = true
            
        } else if let hasMarkers {
            
            statement = equalsBool
            expression = .array(markersCondition(hasMarkers))

            hasMarkersAdded = true
            
        } else {
            
            statement = equalsBool
            expression = .array(isNotDislikedCondition)

            isNotDislikedAdded = true
            
        }
        
        //MARK: - Now process the remaining params
        
        for tagGroup in orTagGroups {
            let (s, e) = tagGroup.orStatementAndExpression
            statement = and(statement, s)
            expression = .array([
                expression,
                e
            ])
        }
        
        if !includedVocalLevels.isEmpty {
            if includedVocalLevels.count > 1 {
                let (s, e) = includedVocalLevels.orStatementAndExpression
                statement = and(statement, s)
                expression = .array([
                    expression,
                    e
                ])
            } else {
                statement = and(statement, equalsInt)
                expression = .array([
                    expression,
                    .array(vocalLevelValue(includedVocalLevels.first!.rawValue))
                ])
            }
        }

        for tag in andTags {
            statement = and(statement, contains)
            expression = .array([
                expression,
                .array(tagId(tag.id))
            ])
        }
        
        /// Excluded Tags
        for tag in excludedTags {
            statement = and(statement, .negation(contains))
            expression = .array([
                expression,
                .array(tagId(tag.id))
            ])
        }
        
        /// Excluded AppleArtists
        for artist in excludedAppleArtists {
            statement = and(statement, .negation(contains))
            expression = .array([
                expression,
                .array(appleArtistId(artist))
            ])
        }
        
        /// Included AppleArtists
        /// If there's more than one apple artist and the join type is `.any`, OR them together and then AND the result with `statement`
        if includedAppleArtistIds.count > 1, joinTypes[.appleArtist] == .any {

            let (s, e) = includedAppleArtistIds.orStatementAndExpressionForArtists
            statement = and(statement, s)
            expression = .array([
                expression,
                e
            ])
            
        } else {
            /// Otherwise just AND them all together
            for artist in includedAppleArtistIds {
                statement = and(statement, contains)
                expression = .array([
                    expression,
                    .array(appleArtistId(artist))
                ])
            }
        }
        
        if !excludedVocalLevels.isEmpty {
            if excludedVocalLevels.count > 1 {
                let (s, e) = excludedVocalLevels.andStatementAndExpression
                statement = and(statement, s)
                expression = .array([
                    expression,
                    e
                ])
            } else {
                statement = and(statement, notEqualsInt)
                expression = .array([
                    expression,
                    .array(vocalLevelValue(excludedVocalLevels.first!.rawValue))
                ])
            }
        }
        
        if let releaseDateRange, !releaseDateRangeAdded {
            
            switch (releaseDateRange.0, releaseDateRange.1) {
            case (.some(let start), .some(let end)):
                /// `start...end`
                statement = and(statement, and(compareDouble, compareDouble))
                expression = .array([
                    expression,
                    .array([
                        .array(greaterThanOrEqualDate(start)),
                        .array(lessThanOrEqualDate(end))
                    ])
                ])

            case (.some(let start), .none):
                /// `>= start`
                statement = and(statement, compareDouble)
                expression = .array([
                    expression,
                    .array(greaterThanOrEqualDate(start))
                ])

            case (.none, .some(let end)):
                /// `<= end`
                statement = and(statement, compareDouble)
                expression = .array([
                    expression,
                    .array(lessThanOrEqualDate(end))
                ])
                
            case (.none, .none):
                break
            }
        }
        
        if let durationInSecondsRange, !durationRangeAdded {
            
            switch (durationInSecondsRange.0, durationInSecondsRange.1) {
            case (.some(let min), .some(let max)):
                /// `min...max`
                statement = and(statement, and(compareDouble, compareDouble))
                expression = .array([
                    expression,
                    .array([
                        .array(greaterThanOrEqualDuration(Double(min))),
                        .array(lessThanOrEqualDuration(Double(max)))
                    ])
                ])

            case (.some(let max), .none):
                /// `>= max`
                statement = and(statement, compareDouble)
                expression = .array([
                    expression,
                    .array(greaterThanOrEqualDuration(Double(max)))
                ])

            case (.none, .some(let max)):
                /// `<= max`
                statement = and(statement, compareDouble)
                expression = .array([
                    expression,
                    .array(lessThanOrEqualDuration(Double(max)))
                ])
                
            case (.none, .none):
                break
            }
        }
        
        if let hasMarkers, !hasMarkersAdded {
            statement = and(statement, equalsBool)
            expression = .array([
                expression,
                .array(markersCondition(hasMarkers))
            ])
        }
        
        if !isNotDislikedAdded {
            /// Add `isDisliked == false` as a compulsory condition for all (unless we've got an empty mix and added it already)
            statement = and(statement, equalsBool)
            expression = .array([
                expression,
                .array(isNotDislikedCondition)
            ])
        }

        /// Create the structure we'll be encoding
        let content = CustomPredicateContent(
            variable: .init(key: 1),
            expression: expression,
            structure: statement
        )
        let customPredicate = CustomPredicate(predicate: [content])
        
        /// Encode it, then decode it as `ChoonPredicate`
        let json = try! JSONEncoder().encode(customPredicate)
        let request = try! JSONDecoder().decode(ChoonPredicate.self, from: json)
        
        return request.predicate
    }
}
