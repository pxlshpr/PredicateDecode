import Foundation

let UUIDSeparator = "_"
let ValuesSeparator = ";"
let KeyValueSeparator = "-"

struct TagIdWithType: Identifiable, Hashable, Codable {
    let id: String
    let type: TagType
    
    var asString: String {
        "\(id)\(UUIDSeparator)\(type.rawValue)"
    }
    
    init(id: String, type: TagType) {
        self.id = id
        self.type = type
    }
    
    init(tag: Tag) {
        self.id = tag.id
        self.type = tag.type
    }
    
    init?(string: String) {
        let components = string.components(separatedBy: UUIDSeparator)
        guard components.count == 2,
              let typeRawValue = Int(components[1]),
              let type = TagType(rawValue: typeRawValue)
        else { return nil }

        self.id = components[0]
        self.type = type
    }
}

extension Array where Element == TagIdWithType {
    var stringRepresentation: String {
        self
            .map { $0.asString }
            .sorted { $0 < $1 }
            .joined(separator: ValuesSeparator)
    }
}

extension String {
    var asTagIdWithTypesArray: [TagIdWithType] {
        self
            .components(separatedBy: ValuesSeparator)
            .compactMap { TagIdWithType(string: $0) }
    }
}
