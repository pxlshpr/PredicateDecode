//
//  Item.swift
//  PredicateDecode
//
//  Created by Ahmed Khalaf on 21/6/2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
