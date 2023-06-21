import Foundation
import SwiftData
import OSLog

let choonLogger = Logger(subsystem: "Database", category: "Choon")

@Model
class Choon {
    
    @Attribute(.unique) var id: String
    
    var vocalLevelValue: Int
    var releasedAt: Double
    var isDisliked: Bool

    var playCount: Int
    var skipCount: Int
    var lastPlayedAt: Date?
    var lastPlayFailedAt: Date?

    var updatedAt: Date
    var createdAt: Date

    var markers: [Marker]
    
    /// Convenience properties used for faster access so that scroll performance in lists aren't compromised
    var title: String
    var artist: String
    var album: String
    var thumbnailURL: URL?
    var isLibraryItem: Bool
    var persistentId: String?
    var durationInSeconds: Double
    
    /// Convenience properties for querying
    var tagIds: String
    var appleArtistIds: String
    var numberOfTags: Int
    var hasMarkers: Bool

    @Relationship(inverse: \Tag.choons) var tags: [Tag]
    @Relationship(inverse: \AppleSong.choon) var appleSong: AppleSong?

    /// Temporary properties for search until we figure out how to do case-insensitive predicates in `SwiftData`
    var lowercasedTitle: String
    var lowercasedArtist: String
    
    init(
        id: String,
        title: String,
        artist: String,
        album: String,
        thumbnailURL: URL? = nil,
        appleSong: AppleSong?,
        tags: [Tag],
        markers: [Marker],
        vocalLevel: VocalLevel = .notSpecified,
        releasedAt: Double,
        isDisliked: Bool,
        playCount: Int,
        skipCount: Int,
        lastPlayedAt: Date? = nil,
        lastPlayFailedAt: Date? = nil,
        updatedAt: Date,
        createdAt: Date
    ) {
        choonLogger.debug("Creating Choon")
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.appleSong = appleSong
        self.tags = tags
        self.markers = markers
        self.vocalLevelValue = Int(vocalLevel.rawValue)
        self.releasedAt = releasedAt
        self.isDisliked = isDisliked
        self.playCount = playCount
        self.skipCount = skipCount
        self.lastPlayedAt = lastPlayedAt
        self.lastPlayFailedAt = lastPlayFailedAt
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        
        self.thumbnailURL = thumbnailURL
        self.persistentId = appleSong?.persistentId
        self.durationInSeconds = appleSong?.durationInSeconds ?? 0

        self.lowercasedTitle = title.lowercased()
        self.lowercasedArtist = artist.lowercased()
        
        self.tagIds = tags.map({ $0.id }).joined(separator: UUIDSeparator)
        self.appleArtistIds = (appleSong?.artists ?? []).map({ $0.id }).joined(separator: UUIDSeparator)

        self.numberOfTags = tags.count
        self.hasMarkers = !markers.isEmpty
    }
}
