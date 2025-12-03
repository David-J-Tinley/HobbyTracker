//
//  ContentView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import SwiftUI
import SwiftData

enum SortOption: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case alphabetical = "Name (A-Z)"
    case faction = "Faction"
}

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
    
    // 1. Fetch All
    @Query private var allMiniatures: [Miniature]
    
    // 2. Search & Sort State
    @State private var searchText = ""
    @State private var sortOption: SortOption = .newest
    @State private var isAddingMiniature = false

    // 3. The Power Logic: Filter -> Search -> Sort
    var backlogMiniatures: [Miniature] {
        // A. Start with everything that isn't complete
        var result = allMiniatures.filter { $0.status != .complete }
        
        // B. Apply Search (if user typed anything)
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedStandardContains(searchText) ||
                $0.faction.localizedStandardContains(searchText)
            }
        }
        
        // C. Apply Sort
        return result.sorted {
            switch sortOption {
            case .newest:
                return $0.dateAdded > $1.dateAdded
            case .oldest:
                return $0.dateAdded < $1.dateAdded
            case .alphabetical:
                return $0.name < $1.name
            case .faction:
                return $0.faction < $1.faction
            }
        }
    }

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
            // 4. Add the Search Bar
            .searchable(text: $searchText, prompt: "Search name or faction...")
            .overlay {
                if backlogMiniatures.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Backlog" : "No Results",
                        systemImage: searchText.isEmpty ? "tray" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "You're all caught up!" : "Check your spelling.")
                    )
                }
            }
            .toolbar {
                // 5. Sort Menu (Top Left)
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                    .accessibilityIdentifier("sortMenu")
                }
                
                // Add Button (Top Right)
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
    
    @Query private var allMiniatures: [Miniature]
    
    // State for Search/Sort/Sheet
    @State private var searchText = ""
    @State private var sortOption: SortOption = .newest
    @State private var isShowingStats = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    // Computed Property
    var completedMiniatures: [Miniature] {
        // A. Filter for Complete
        var result = allMiniatures.filter { $0.status == .complete }
        
        // B. Search
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedStandardContains(searchText) ||
                $0.faction.localizedStandardContains(searchText)
            }
        }
        
        // C. Sort
        return result.sorted {
            switch sortOption {
            case .newest: return $0.dateAdded > $1.dateAdded
            case .oldest: return $0.dateAdded < $1.dateAdded
            case .alphabetical: return $0.name < $1.name
            case .faction: return $0.faction < $1.faction
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(completedMiniatures) { miniature in
                        NavigationLink(destination: MiniatureDetailView(miniature: miniature)) {
                            MiniatureGridItem(miniature: miniature)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Completed")
            // Search Bar
            .searchable(text: $searchText, prompt: "Search gallery...")
            .toolbar {
                // Sort Menu
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                    .accessibilityIdentifier("sortMenu")
                }
                
                // Stats Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingStats = true
                    } label: {
                        Image(systemName: "chart.pie.fill")
                    }
                    .accessibilityIdentifier("statsButton")
                }
            }
            .sheet(isPresented: $isShowingStats) {
                StatsView()
            }
            .overlay {
                if completedMiniatures.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Completed Models" : "No Results",
                        systemImage: searchText.isEmpty ? "trophy" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Finish a model to see it here!" : "Try a different search.")
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
