import SwiftUI
import SwiftData
import OSLog

let predicateLogger = Logger(subsystem: "Experimental", category: "Predicate Coding")

let ZedsDeadID = "02E626E2-71CC-4D97-BA06-944555D9D1D9"
let ImanuID = "85FE0D91-C1C4-4470-AFE4-05681726D1B2"

extension ContentView {
    
    func encodeNativePredicate() {

        let container = try! ModelContainer(for: allModelTypes)
        let context = ModelContext(container)

        let predicate = #Predicate<Choon> { choon in
            (
                choon.appleArtistIds.contains(ZedsDeadID)
                ||
                choon.appleArtistIds.contains(ImanuID)
            )
            &&
            choon.isDisliked == false
        }
        let request = ChoonPredicate(predicate: predicate)
        let json = try! JSONEncoder().encode(request)
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = documentDirectory.appendingPathComponent("native.json")
        try! json.write(to: path)
        predicateLogger.notice("Wrote to: \(path)")

        /// This is how I want to use it, but:
        /// - it doesn't work past a certain number of expressions
        /// - I don't know how I can dynamically choose the number of expressions I'll be feeding in
        ///
        let descriptor = FetchDescriptor<Choon>(predicate: predicate)
        let choons = try! context.fetch(descriptor)
        predicateLogger.info("Got: \(choons.count) choons")
    }
    
    func encodePredicateFromJSON() {
        
        let zedsDead = AppleArtist(id: ZedsDeadID, name: "Zeds Dead")
        let imanu = AppleArtist(id: ImanuID, name: "IMANU")

        var mix: Mix {

            let mixParams: [MixParam] = [
                .appleArtist(id: zedsDead.id, false),
                .appleArtist(id: imanu.id, false)
            ]

            let joinTypesDict: [MixParamType: MixParamJoinType] = [
                .appleArtist : .any
            ]

            return Mix(
                params: mixParams,
                joinTypes: joinTypesDict
            )
        }
        
        let request = ChoonPredicate(predicate: mix.predicate)
        
        let json = try! JSONEncoder().encode(request)
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = documentDirectory.appendingPathComponent("from-json.json")
        try! json.write(to: path)
        predicateLogger.notice("Wrote to: \(path)")

        /// This is how I use it in practice for the time being.
        ///
        let choons = try! context.fetch(mix.fetchDescriptor)
        predicateLogger.notice("Got: \(choons.count) choons")
    }
}
