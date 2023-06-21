import Foundation

struct Marker: Codable {
    var emoji: String?
    var name: String?
    var position: TimeInterval
    
    init(emoji: String? = nil, name: String? = nil, position: TimeInterval) {
        self.emoji = emoji?.isEmpty == false ? emoji : nil
        self.name = name?.isEmpty == false ? name : nil
        self.position = position
    }
    
//    static let FieldSeparator = "¬"
//    static let MarkerSeparator = "¦"
//    static let ProgressBarImage = "triangle.fill"
}
