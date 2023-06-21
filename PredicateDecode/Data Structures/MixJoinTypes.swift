import Foundation

struct MixJoinTypes: Hashable, Codable {
    var mood: MixParamJoinType
    var activity: MixParamJoinType
    var genre: MixParamJoinType
    var instrument: MixParamJoinType
    var custom: MixParamJoinType
    
    var appleArtists: MixParamJoinType
    
    init(
        mood: MixParamJoinType = .none,
        activity: MixParamJoinType = .none,
        genre: MixParamJoinType = .none,
        instrument: MixParamJoinType = .none,
        custom: MixParamJoinType = .none,
        appleArtists: MixParamJoinType = .none
    ) {
        self.mood = mood
        self.activity = activity
        self.genre = genre
        self.instrument = instrument
        self.custom = custom
        self.appleArtists = appleArtists
    }
}

extension MixJoinTypes {    
    init(fromDict dict: [MixParamType : MixParamJoinType]) {
        self.mood = dict[.mood] ?? .none
        self.activity = dict[.activity] ?? .none
        self.genre = dict[.genre] ?? .none
        self.instrument = dict[.instrument] ?? .none
        self.custom = dict[.custom] ?? .none
        self.appleArtists = dict[.appleArtist] ?? .none
    }
    
    var asDict: [MixParamType : MixParamJoinType] {
        var dict: [MixParamType : MixParamJoinType] = [:]
        dict[.mood] = mood
        dict[.activity] = activity
        dict[.genre] = genre
        dict[.instrument] = instrument
        dict[.custom] = custom
        dict[.appleArtist] = appleArtists
        return dict
    }
}
