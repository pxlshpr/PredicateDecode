import Foundation

extension Array where Element == VocalLevel {
    var stringRepresentation: String {
        self
            .sorted { $0.rawValue < $1.rawValue }
            .map { String($0.rawValue) }
            .joined(separator: ValuesSeparator)
    }
}
