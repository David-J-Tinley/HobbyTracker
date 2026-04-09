//
//  ExportModels.swift
//  HobbyTracker
//
//  Created by David J Tinley on 12/10/25.
//

import Foundation

// A simple structure that matches your data but is safe for JSON export
struct MiniatureExport: Codable {
    let id: UUID
    let name: String
    let faction: String
    let status: String
    let recipe: String
    let notes: String
    let dateAdded: Date
    // Note: We are excluding photos to keep the file size small and text-based.
}

// A wrapper to hold the entire collection
struct BackupFile: Codable {
    var version: String = "1.0"
    let exportedDate: Date
    let miniatures: [MiniatureExport]
}



// MARK: - Helper Extension
extension MiniatureExport {
    // This helper lets us convert a database object to an export object easily
    init(from mini: Miniature) {
        self.id = mini.id
        self.name = mini.name
        self.faction = mini.faction
        self.status = mini.status.rawValue
        self.recipe = mini.recipe
        self.notes = mini.notes
        self.dateAdded = mini.dateAdded
    }
}
