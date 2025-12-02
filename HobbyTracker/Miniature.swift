//
//  Miniature.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import Foundation
import SwiftData

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
    
    /**
     * @Attribute(.externalStorage) tells SwiftData to store this
     * data in a separate file, not directly in the database.
     * This is best practice for large data like images.
     */
    @Attribute(.externalStorage) var photo: Data?
    
    // We provide default values ("") so SwiftData can auto-migrate existing data
    var recipe: String = ""
    var notes: String = ""
    
    // The initializer (the "constructor") for creating a new miniature
    init(name: String, faction: String, status: Status = .unbuilt) {
        self.id = UUID()
        self.name = name
        self.faction = faction
        self.status = status
        self.dateAdded = Date()
        self.photo = nil // Default to no photo
    }
}

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
