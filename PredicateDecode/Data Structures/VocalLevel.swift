import Foundation

enum VocalLevel: Int, CaseIterable, Codable {
    case standardVocals = 1
    case minimalVocals
    case instrumental
    case notSpecified
}
