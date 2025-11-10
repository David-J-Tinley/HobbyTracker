//
//  MiniatureDetailView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import SwiftUI
import SwiftData

struct MiniatureDetailView: View {
    // This view receives one miniature to display
    let miniature: Miniature

    var body: some View {
        // We use a List to get the nice grouped iOS styling
        List {
            // MARK: - Photo Section
            Section {
                if let photoData = miniature.photo,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                } else {
                    // Placeholder if no photo
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 250)
                        
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.gray.opacity(0.5))
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                }
            }
            
            // MARK: - Details Section
            Section("Details") {
                // Using HStacks for a "Label: Value" style
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
                    // Re-using the colored status capsule
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
                    // Format the date to be more readable
                    Text(miniature.dateAdded, style: .date)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(miniature.name) // Set the title to the mini's name
        .navigationBarTitleDisplayMode(.inline) // Use a smaller title
    }
    
    // Helper function to color-code the status
    // (We need this here too, just like in MiniatureRow)
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
    // This creates a sample miniature just for the preview
    let sampleMini = Miniature(name: "Primaris Intercessor",
                               faction: "Space Marines",
                               status: .wip)
    
    // Wrap the preview in a NavigationStack to see the title
    return NavigationStack {
        MiniatureDetailView(miniature: sampleMini)
    }
}
