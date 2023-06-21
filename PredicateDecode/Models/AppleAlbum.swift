import Foundation
import SwiftData

@Model
class AppleAlbum {

    @Attribute(.unique) var id: UUID
    var title: String

    var artistName: String?
    var storeId: String?
    var storefrontId: String?

    var releaseDate: Date?
    var isSingle: Bool
    
    var artwork: AppleArtwork?
    
    @Relationship(inverse: \AppleSong.album) var songs: [AppleSong]
    
    init(
        id: UUID = UUID(),
        title: String,
        artistName: String? = nil,
        storeId: String? = nil,
        storefrontId: String? = nil,
        releaseDate: Date? = nil,
        isSingle: Bool = false,
        artwork: AppleArtwork? = nil
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.storeId = storeId
        self.storefrontId = storefrontId
        self.releaseDate = releaseDate
        self.isSingle = isSingle
        self.artwork = artwork
    }
}
