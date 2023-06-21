import Foundation
import SwiftData

@Model
class AppleSong {

    @Attribute(.unique) var id: UUID
    var title: String

    var persistentId: String?
    var storeId: String?
    var storefrontId: String?

    var durationInSeconds: Double
    var releaseDate: Date?
    var isExplicit: Bool

    var artistName: String?
    var albumTitle: String?
    var isrc: String?
    var genres: String?

    @Relationship var album: AppleAlbum?
    @Relationship var artists: [AppleArtist]
    @Relationship var choon: Choon?
    
    init(
        id: UUID,
        title: String,
        persistentId: String? = nil,
        storeId: String? = nil,
        storefrontId: String? = nil,
        durationInSeconds: Double,
        releaseDate: Date? = nil,
        isExplicit: Bool,
        artistName: String? = nil,
        albumTitle: String? = nil,
        isrc: String? = nil,
        genres: String? = nil,
        album: AppleAlbum? = nil,
        artists: [AppleArtist] = []
    ) {
        self.id = id
        self.title = title
        self.persistentId = persistentId
        self.storeId = storeId
        self.storefrontId = storefrontId
        self.durationInSeconds = durationInSeconds
        self.releaseDate = releaseDate
        self.isExplicit = isExplicit
        self.artistName = artistName
        self.albumTitle = albumTitle
        self.isrc = isrc
        self.genres = genres
        self.album = album
        self.artists = artists
    }
}
