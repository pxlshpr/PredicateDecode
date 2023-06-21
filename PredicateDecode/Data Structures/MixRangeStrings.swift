import Foundation

struct MixRangeStrings: Hashable, Codable {
    var dateTagged: String
    var dateReleased: String
    var dateLastPlayed: String
    var playCount: String
    var skipCount: String
    var durationInSeconds: String
    
    init(
        dateTagged: String = "",
        dateReleased: String = "",
        dateLastPlayed: String = "",
        playCount: String = "",
        skipCount: String = "",
        durationInSeconds: String = ""
    ) {
        self.dateTagged = dateTagged
        self.dateReleased = dateReleased
        self.dateLastPlayed = dateLastPlayed
        self.playCount = playCount
        self.skipCount = skipCount
        self.durationInSeconds = durationInSeconds
    }
}

extension MixRangeStrings {
    
    init(fromDict dict: [MixParamSortableProperty : String]) {
        self.dateTagged = dict[.dateTagged] ?? ""
        self.dateReleased = dict[.dateReleased] ?? ""
        self.dateLastPlayed = dict[.dateLastPlayed] ?? ""
        self.playCount = dict[.playCount] ?? ""
        self.skipCount = dict[.skipCount] ?? ""
        self.durationInSeconds = dict[.durationInSeconds] ?? ""
    }
}
