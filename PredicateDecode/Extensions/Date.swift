import Foundation

extension Date {
    var rangeDateFormat: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy_MM_dd"
        return df.string(from: self)
    }
}
