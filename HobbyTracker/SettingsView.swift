//
//  SettingsView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 12/10/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var miniatures: [Miniature]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // The ShareLink does all the heavy lifting!
                    // It generates the file only when requested.
                    ShareLink(item: generateJSON(),
                              preview: SharePreview("HobbyTracker Backup", image: Image(systemName: "square.and.arrow.up"))) {
                        Label("Export Data to JSON", systemImage: "square.and.arrow.up")
                    }
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("Exporting will create a text file containing all your recipes, notes, and miniature details (excluding photos).")
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    // MARK: - Export Logic
    private func generateJSON() -> URL {
        // 1. Convert Database Objects to Export Objects
        // Uses the new helper we just wrote
        let exportList = miniatures.map { MiniatureExport(from: $0) }
        
        // 2. Wrap them in the Backup container
        let backup = BackupFile(exportedDate: Date(), miniatures: exportList)
        
        // 3. Encode to JSON Data
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Makes it readable for humans
        encoder.dateEncodingStrategy = .iso8601 // Standard date format
        
        do {
            let data = try encoder.encode(backup)
            
            // 4. Write to a temporary file
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = "HobbyTracker_Backup_\(Date().formatted(date: .numeric, time: .omitted)).json"
            let fileURL = tempDirectory.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
            return fileURL
            
        } catch {
            print("Error creating backup: \(error)")
            return URL(fileURLWithPath: "/") // Fallback (shouldn't happen)
        }
    }
}

#Preview {
    SettingsView()
}
