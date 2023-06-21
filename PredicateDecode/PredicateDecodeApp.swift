import SwiftUI
import SwiftData

@main
struct PredicateDecodeApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: allModelTypes)
    }
}

var allModelTypes: [any PersistentModel.Type] {
    [
        AppleAlbum.self,
        AppleArtist.self,
        AppleSong.self,
        Choon.self,
        Mix.self,
        Tag.self
    ]
}
