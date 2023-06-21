import Foundation

struct MixParamSortOrder: Codable, Hashable, Equatable {
    var direction: MixParamSortDirection
    var property: MixParamSortableProperty
    
    static var shuffled: MixParamSortOrder {
        self.init(
            direction: .shuffled,
            property: .shuffled
        )
    }
    
    static let `default`: MixParamSortOrder = .init(
        direction: .descending,
        property: .dateTagged
    )
}
