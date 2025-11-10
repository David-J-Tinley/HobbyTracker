//
//  ContentView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Properties
    
    // 1. Get the SwiftData model context
    @Environment(\.modelContext) private var modelContext
    
    // 2. Fetch all miniatures, sorted by date added (newest first)
    @Query(sort: \Miniature.dateAdded, order: .reverse) private var miniatures: [Miniature]
    
    // 3. State to control the "Add" sheet
    @State private var isAddingMiniature = false

    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                // 4. Loop over the fetched miniatures
                ForEach(miniatures) { miniature in
                    // Wrap the row in a NavigationLink
                    NavigationLink(destination: MiniatureDetailView(miniature: miniature)) {
                        MiniatureRow(miniature: miniature)
                    }
                }
                .onDelete(perform: deleteMiniatures)
            }
            .navigationTitle("Backlog")
            // 6. Show a nice message if the list is empty
            .overlay {
                if miniatures.isEmpty {
                    ContentUnavailableView(
                        "No Miniatures",
                        systemImage: "paintpalette.fill",
                        description: Text("Tap the + button to add your first miniature.")
                    )
                }
            }
            // 7. Toolbar with the "Add" button
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingMiniature = true // Show the sheet
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // 8. The sheet modifier to present the "Add" view
            .sheet(isPresented: $isAddingMiniature) {
                AddMiniatureView()
            }
        }
    }
    
    // MARK: - Functions
    
    // 9. Function to handle deleting items
    private func deleteMiniatures(at offsets: IndexSet) {
        for index in offsets {
            // Find the miniature at that index and delete it
            let miniature = miniatures[index]
            modelContext.delete(miniature)
        }
        // SwiftData will auto-save the deletion
    }
}

// MARK: - Miniature Row View

/**
 * This is a sub-view for a single row in the list.
 * Keeping it separate makes your ContentView cleaner.
 */
struct MiniatureRow: View {
    let miniature: Miniature
    
    var body: some View {
        HStack(spacing: 15) {
            // MARK: - Photo
            if let photoData = miniature.photo,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // Placeholder image
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.gray.opacity(0.5))
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // MARK: - Details
            VStack(alignment: .leading) {
                Text(miniature.name)
                    .font(.headline)
                Text(miniature.faction)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // MARK: - Status
            Text(miniature.status.displayName)
                .font(.caption)
                .padding(6)
                .background(statusColor(for: miniature.status))
                .clipShape(Capsule())
                .foregroundStyle(.white)
        }
        .padding(.vertical, 6)
    }
    
    // Helper function to color-code the status
    private func statusColor(for status: Status) -> Color {
        switch status {
        case .unbuilt:
            return .gray
        case .built:
            return .brown
        case .primed:
            return .black
        case .wip:
            return .blue
        case .complete:
            return .green
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        // This sets up a temporary in-memory database for the preview
        .modelContainer(for: Miniature.self, inMemory: true)
}
