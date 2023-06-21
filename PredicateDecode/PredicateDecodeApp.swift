//
//  PredicateDecodeApp.swift
//  PredicateDecode
//
//  Created by Ahmed Khalaf on 21/6/2023.
//

import SwiftUI
import SwiftData

@main
struct PredicateDecodeApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
