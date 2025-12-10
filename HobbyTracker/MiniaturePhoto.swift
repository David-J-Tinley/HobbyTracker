//
//  MiniaturePhoto.swift
//  HobbyTracker
//
//  Created by David J Tinley on 12/08/25.
//

import Foundation
import SwiftData

@Model
final class MiniaturePhoto {
    var id: UUID
    @Attribute(.externalStorage) var data: Data
    var dateTaken: Date
    
    // The relationship back to the parent miniature
    // inverse: \Miniature.photos tells SwiftData how they connect
    var miniature: Miniature?
    
    init(data: Data, dateTaken: Date = Date()) {
        self.id = UUID()
        self.data = data
        self.dateTaken = dateTaken
    }
}
