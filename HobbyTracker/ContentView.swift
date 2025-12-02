//
//  ContentView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        // The TabView creates the bottom navigation bar
        TabView {
            // Tab 1: The Backlog
            BacklogView()
                .tabItem {
                    Label("Backlog", systemImage: "list.bullet")
                }
            
            // Tab 2: The Completed Gallery
            CompletedView()
                .tabItem {
                    Label("Gallery", systemImage: "trophy.fill")
                }
        }
    }
}

// MARK: - Tab 1: Backlog View
struct BacklogView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 1. Fetch ALL miniatures (no filter in the database query)
    @Query(sort: \Miniature.dateAdded, order: .reverse)
    private var allMiniatures: [Miniature]

    // 2. Filter them in memory using a computed property
    var backlogMiniatures: [Miniature] {
        allMiniatures.filter { $0.status != .complete }
    }
    
    @State private var isAddingMiniature = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(backlogMiniatures) { miniature in
                    NavigationLink(destination: MiniatureDetailView(miniature: miniature)) {
                        MiniatureRow(miniature: miniature)
                    }
                }
                .onDelete(perform: deleteMiniatures)
            }
            .navigationTitle("Backlog")
            // Show a helpful message if the backlog is empty
            .overlay {
                if backlogMiniatures.isEmpty {
                    ContentUnavailableView(
                        "No Backlog",
                        systemImage: "tray",
                        description: Text("You're all caught up! Tap + to add a new project.")
                    )
                }
            }
            // The "Add" button really only belongs on the Backlog
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingMiniature = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addMiniatureButton")
                }
            }
            .sheet(isPresented: $isAddingMiniature) {
                AddMiniatureView()
            }
        }
    }
    
    private func deleteMiniatures(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(backlogMiniatures[index])
        }
    }
}

struct CompletedView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 1. Fetch all items
    @Query(sort: \Miniature.dateAdded, order: .reverse)
    private var allMiniatures: [Miniature]
    
    // 2. Filter for completed ones
    var completedMiniatures: [Miniature] {
        allMiniatures.filter { $0.status == .complete }
    }
    
    // 3. Define a 2-column grid layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // 4. The Grid
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(completedMiniatures) { miniature in
                        NavigationLink(destination: MiniatureDetailView(miniature: miniature)) {
                            // We use a new "Card" view for the grid
                            MiniatureGridItem(miniature: miniature)
                        }
                        .buttonStyle(.plain) // Removes the default blue link color
                    }
                }
                .padding()
            }
            .navigationTitle("Completed")
            .overlay {
                if completedMiniatures.isEmpty {
                    ContentUnavailableView(
                        "No Completed Models",
                        systemImage: "trophy",
                        description: Text("Finish a model to see it displayed here!")
                    )
                }
            }
        }
    }
}

// MARK: - New Grid Item Component
// Add this struct to the bottom of ContentView.swift
struct MiniatureGridItem: View {
    let miniature: Miniature
    
    var body: some View {
        VStack {
            // Large Photo
            if let photoData = miniature.photo,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
            } else {
                // Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 160, height: 160)
                    
                    Image(systemName: "photo.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.gray.opacity(0.5))
                }
            }
            
            // Name Label
            Text(miniature.name)
                .font(.headline)
                .lineLimit(1)
                .padding(.top, 4)
            
            Text(miniature.faction)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Subviews
// We keep this shared row view here so both tabs can use it
struct MiniatureRow: View {
    let miniature: Miniature
    
    var body: some View {
        HStack(spacing: 15) {
            // Photo
            if let photoData = miniature.photo,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.gray.opacity(0.5))
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Details
            VStack(alignment: .leading) {
                Text(miniature.name)
                    .font(.headline)
                Text(miniature.faction)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Status
            Text(miniature.status.displayName)
                .font(.caption)
                .padding(6)
                .background(statusColor(for: miniature.status))
                .clipShape(Capsule())
                .foregroundStyle(.white)
        }
        .padding(.vertical, 6)
    }
    
    private func statusColor(for status: Status) -> Color {
        switch status {
        case .unbuilt: return .gray
        case .built: return .brown
        case .primed: return .black
        case .wip: return .blue
        case .complete: return .green
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Miniature.self, inMemory: true)
}
