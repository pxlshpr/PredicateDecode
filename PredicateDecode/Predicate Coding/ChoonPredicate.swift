import Foundation
import SwiftData

struct ChoonPredicate: Codable {
    let predicate: Predicate<Choon>
    
    enum CodingKeys: String, CodingKey {
        case predicate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(predicate, forKey: .predicate, configuration: Self.configuration)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        predicate = try container.decode(Predicate<Choon>.self, forKey: .predicate, configuration: Self.configuration)
    }
    
    static var configuration: PredicateCodableConfiguration {
        var configuration = PredicateCodableConfiguration.standardConfiguration
        configuration.allowType(Choon.self, identifier: "Choons.Choon")
        configuration.allowKeyPath(\Choon.tagIds, identifier: "Choons.Choon.tagIds")
        configuration.allowKeyPath(\Choon.appleArtistIds, identifier: "Choons.Choon.appleArtistIds")
        configuration.allowKeyPath(\Choon.vocalLevelValue, identifier: "Choons.Choon.vocalLevelValue")
        configuration.allowKeyPath(\Choon.isDisliked, identifier: "Choons.Choon.isDisliked")
        configuration.allowKeyPath(\Choon.releasedAt, identifier: "Choons.Choon.releasedAt")
        configuration.allowKeyPath(\Choon.hasMarkers, identifier: "Choons.Choon.hasMarkers")
        configuration.allowKeyPath(\Choon.durationInSeconds, identifier: "Choons.Choon.durationInSeconds")
        return configuration
    }
    
    init(predicate: Predicate<Choon>) {
        self.predicate = predicate
    }
}
