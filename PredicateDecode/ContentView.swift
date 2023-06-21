import SwiftUI

struct ContentView: View {
    
    @Environment(\.modelContext) internal var context

    var body: some View {
        
        /// Tap this to encode a native `Predicate`.
        /// The json file (see console for path) is what we need to construct manually.
        ///
        Button("Encode Native Predicate") {
            encodeNativePredicate()
        }.buttonStyle(.borderedProminent)
        
        /// Tap this to encode the same predicate by reversing the approach:
        /// - Constructs the `CustomPredicate` first following the same structure observed in the file above.
        /// - Encodes this into JSON
        /// - Decodes it into `ChoonPredicate` which uses `PredicateCodableConfiguration` to get the `Predicate<Choon>` we're after.
        ///     https://developer.apple.com/documentation/foundation/predicatecodableconfiguration
        ///
        Button("Encode Predicate from JSON") {
            encodePredicateFromJSON()
        }.buttonStyle(.borderedProminent)
        
        
        /// **Update:** One thing I did notice while making this was that `$.predicate.[0].variable.key = 2`
        /// in the native predicate. It was `1` while working on this a week or so back. It seems to still work as long as the `key`
        /// in the rest of the json matches.
        ///
        /// I also noticed that when using nested predicates, multiple `key`s are used where an increment indicates a deeper level.
    }
}
