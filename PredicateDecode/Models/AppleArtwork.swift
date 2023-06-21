import SwiftUI
import OSLog

let appleArtworkLogger = Logger(subsystem: "Database", category: "AppleArtwork")

struct AppleArtwork: Hashable, Codable {
    
    struct Colors: Hashable, Codable {
        struct Texts: Hashable, Codable {
            let primary: String?
            let secondary: String?
            let tertiary: String?
            let quaternary: String?

            /// Start with `quaternary` (being the lightest and closest to background) and work our way upwards
            var firstAvailableColor: String? {
                quaternary ?? tertiary ?? secondary ?? primary
            }
            
            var asArray: [String] {
                [primary, secondary, tertiary, quaternary]
                    .compactMap { $0 }
            }
            
            init(primary: String?, secondary: String?, tertiary: String?, quaternary: String?) {
                self.primary = primary
                self.secondary = secondary
                self.tertiary = tertiary
                self.quaternary = quaternary
            }
        }
        
        let background: String?
        let texts: Texts
        
        init(background: String?, texts: Texts) {
            self.background = background
            self.texts = texts
        }
    }
    
    struct Size: Hashable, Codable {
        let width: Int
        let height: Int
        
        init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
    }
    
    var url: String?
    let size: Size
    let colors: Colors
    
    init(url: String, size: Size, colors: Colors) {
        self.url = url
        self.size = size
        self.colors = colors
    }
}

extension AppleArtwork {
    init?(from data: Data?) {
        guard let data else { return nil }
        do {
            self = try JSONDecoder().decode(AppleArtwork.self, from: data)
        } catch {
            appleArtworkLogger.error("Error decoding artwork data: \(error)")
            return nil
        }
    }
}

extension AppleArtwork {
    enum ArtworkSize {
        case small, medium, large
    }

    func artworkUrl(_ artworkSize: ArtworkSize) -> String {
        let width = dimension(for: artworkSize, maximum: Int(size.width))
        let height = dimension(for: artworkSize, maximum: Int(size.height))
        guard let url else {
            return ""
        }
        return url
            .replacingOccurrences(of: "{w}", with: String(width))
            .replacingOccurrences(of: "{h}", with: String(height))
    }
    
    func dimension(for size: ArtworkSize, maximum: Int) -> Int {
        switch size {
        case .small:
            return 144
        case .medium:
            return min(282, maximum)
        case .large:
            return maximum
        }
    }
    
    var thumbnailURL: URL? {
        URL(string: artworkUrl(.small))
    }
    
    var mediumArtworkURL: URL? {
        URL(string: artworkUrl(.medium))
    }
    
    var largeArtworkURL: URL? {
        URL(string: artworkUrl(.large))
    }
}
