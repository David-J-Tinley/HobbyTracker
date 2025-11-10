//
//  Item.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
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
