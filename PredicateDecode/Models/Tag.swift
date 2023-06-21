import Foundation
import SwiftData

@Model
class Tag {
    
    @Attribute(.unique) var id: String

    var name: String?
    var emoji: String?
    var typeValue: Int

    @Relationship var choons: [Choon]

    init(
        id: String = UUID().uuidString,
        name: String? = nil,
        emoji: String? = nil,
        type: TagType
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.typeValue = type.rawValue
    }
}

extension Tag {
    var type: TagType {
        TagType(rawValue: typeValue)!
    }
}
