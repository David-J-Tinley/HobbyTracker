//
//  Miniature.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import Foundation
import SwiftData

// MARK: - Miniature Class
/**
 * This is your main data model.
 * The @Model macro tells SwiftData to manage this class in the database.
 */
@Model
final class Miniature {
    
    // Properties (columns in your database)
    var id: UUID
    var name: String
    var faction: String
    var status: Status // Uses the custom enum below
    var dateAdded: Date
    // We provide default values ("") so SwiftData can auto-migrate existing data
    var recipe: String = ""
    var notes: String = ""
    
    // --- CHANGED: Replaced single 'photo' with a list ---
    // .cascade means "If I delete the miniature, delete all its photos too"
    @Relationship(deleteRule: .cascade, inverse: \MiniaturePhoto.miniature)
    var photos: [MiniaturePhoto] = []
    
    // Helper: Get the most recent photo for the thumbnail
    var coverImage: Data? {
        // Sort by date so the newest progress pic is the cover
        return photos.sorted { $0.dateTaken < $1.dateTaken }.last?.data
    }

    // The initializer (the "constructor") for creating a new miniature
    init(name: String, faction: String, status: Status = .unbuilt) {
        self.id = UUID()
        self.name = name
        self.faction = faction
        self.status = status
        self.dateAdded = Date()
        // Photos starts empty
    }
    
    // MARK: - Clone Function
    func clone() -> Miniature {
        let newMini = Miniature(name: self.name, faction: self.faction, status: self.status)
        newMini.recipe = self.recipe
        newMini.notes = self.notes
        
        // Copy each photo
        for oldPhoto in self.photos {
            let newPhoto = MiniaturePhoto(data: oldPhoto.data, dateTaken: oldPhoto.dateTaken)
            newMini.photos.append(newPhoto)
        }
        
        return newMini
    }
}

// MARK: - Status Enum
/**
 * This enum defines the specific painting statuses a model can have.
 * - String: Lets us store the value as a readable string.
 * - Codable: Allows SwiftData to easily save and load this enum.
 * - CaseIterable: Lets us easily list all options, which is
 * perfect for a Picker in your "Add" form.
 */
enum Status: String, Codable, CaseIterable {
    case unbuilt = "Unbuilt"
    case built = "Built"
    case primed = "Primed"
    case wip = "Work in Progress"
    case complete = "Complete"
    
    // A computed property to get the name
    var displayName: String {
        return self.rawValue
    }
}
