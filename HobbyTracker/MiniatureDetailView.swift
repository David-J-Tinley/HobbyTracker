//
//  MiniatureDetailView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import SwiftUI
import SwiftData

struct MiniatureDetailView: View {
    // 1. We need the context to insert the clone
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let miniature: Miniature
    @State private var isShowingEditSheet = false
    
    // --- CHANGED: Track the specific photo object instead of just a boolean ---
    // This allows us to know exactly WHICH photo was tapped in the gallery.
    @State private var selectedPhoto: MiniaturePhoto?

    var body: some View {
        List {
            // MARK: - Photo Gallery Section
            Section {
                if miniature.photos.isEmpty {
                    // Placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 250)
                        Image(systemName: "photo.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.gray.opacity(0.5))
                    }
                } else {
                    // Horizontal TabView for Gallery
                    TabView {
                        // Sort photos by date so we see the progression
                        ForEach(miniature.photos.sorted(by: { $0.dateTaken < $1.dateTaken })) { photo in
                            if let uiImage = UIImage(data: photo.data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .tag(photo.id)
                                    // --- UPDATED TAP LOGIC ---
                                    .onTapGesture {
                                        // Update your full screen logic to use the specific 'photo' tapped
                                        selectedPhoto = photo
                                    }
                            }
                        }
                    }
                    .tabViewStyle(.page) // Gives us the little dots at the bottom
                    .frame(height: 300)
                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                }
            }
            
            // MARK: - Details Section
            Section("Details") {
                HStack {
                    Text("Faction")
                        .font(.headline)
                    Spacer()
                    Text(miniature.faction)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Status")
                        .font(.headline)
                    Spacer()
                    Text(miniature.status.displayName)
                        .font(.caption)
                        .padding(6)
                        .background(statusColor(for: miniature.status))
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
                }
                
                HStack {
                    Text("Date Added")
                        .font(.headline)
                    Spacer()
                    Text(miniature.dateAdded, style: .date)
                        .foregroundStyle(.secondary)
                }
            }
            
            // MARK: - Recipe & Notes
            if !miniature.recipe.isEmpty {
                Section("Paint Recipe") {
                    Text(miniature.recipe)
                }
            }
            
            if !miniature.notes.isEmpty {
                Section("Notes") {
                    Text(miniature.notes)
                }
            }
        }
        .navigationTitle(miniature.name)
        .navigationBarTitleDisplayMode(.inline)
        // MARK: - Action Menu
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    // Button 1: Edit
                    Button {
                        isShowingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .accessibilityIdentifier("editButton")
                    
                    // Button 2: Duplicate
                    Button {
                        duplicateMiniature()
                    } label: {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    }
                    .accessibilityIdentifier("duplicateButton")
                    
                } label: {
                    // The icon for the menu
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityIdentifier("actionsMenu")
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditMiniatureView(miniature: miniature)
        }
        // --- CHANGED: Use the 'item' version of fullScreenCover ---
        // This opens automatically whenever 'selectedPhoto' is set to a value.
        // Swift automatically passes the photo object into the closure.
        .fullScreenCover(item: $selectedPhoto) { photo in
            if let uiImage = UIImage(data: photo.data) {
                FullScreenImageView(image: uiImage)
            } else {
                Text("Error loading image")
            }
        }
    }
    
    // MARK: - Logic Functions

    private func duplicateMiniature() {
        // Use the new model method
        let newMini = miniature.clone()
        
        // Save and dismiss
        modelContext.insert(newMini)
        dismiss()
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

// MARK: - Preview
#Preview {
    // This creates a sample miniature just for the preview
    // Note: This preview might need updating to add dummy photos if you want to test the gallery
    let sampleMini = Miniature(name: "Primaris Intercessor",
                               faction: "Space Marines",
                               status: .wip)
    
    // Wrap the preview in a NavigationStack to see the title
    return NavigationStack {
        MiniatureDetailView(miniature: sampleMini)
    }
}
