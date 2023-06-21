import Foundation

extension Array where Element == String {
    var stringRepresentation: String? {
        let joined = self.joined(separator: ValuesSeparator)
        guard !joined.isEmpty else { return nil }
        return joined
    }
}
