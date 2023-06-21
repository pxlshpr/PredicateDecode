import Foundation
import SwiftData

@Model
class AppleArtist {
    
    @Attribute(.unique) var id: String

    var name: String
    
    var storeId: String?
    var storefrontId: String?

    var artwork: AppleArtwork?
    
    @Relationship(inverse: \AppleSong.artists) var songs: [AppleSong]

    init(
        id: String,
        name: String,
        storeId: String? = nil,
        storefrontId: String? = nil,
        artwork: AppleArtwork? = nil
    ) {
        self.id = id
        self.name = name
        self.storeId = storeId
        self.storefrontId = storefrontId
        self.artwork = artwork
    }
}
