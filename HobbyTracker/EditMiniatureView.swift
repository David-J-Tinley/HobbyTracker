//
//  EditMiniatureView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import SwiftUI
import SwiftData
import PhotosUI // For the photo picker

struct EditMiniatureView: View {
    // 1. Environment and Navigation
    @Environment(\.dismiss) private var dismiss
    
    // 2. The miniature we are editing
    // We use @Bindable to allow SwiftUI to directly
    // (and safely) modify the miniature's properties.
    // NOTE: This auto-saves changes. A more complex
    // setup would use @State, but this is cleaner.
    @Bindable var miniature: Miniature
    
    // 3. State for Photo Picker
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    // 4. We'll use a local state for the photo data
    // to provide an instant preview before it's saved.
    @State private var selectedPhotoData: Data?

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Details Section
                Section("Details") {
                    // Here we bind directly to the miniature's properties
                    TextField("Miniature Name", text: $miniature.name)
                    TextField("Faction", text: $miniature.faction)
                }
                
                // MARK: - Status Section
                Section("Painting Status") {
                    Picker("Status", selection: $miniature.status) {
                        ForEach(Status.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(.menu) // A nice dropdown style
                }
                
                // MARK: - Photo Section
                Section("Photo") {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Change Photo", systemImage: "photo")
                    }
                    
                    // Show a preview of the *new* or *existing* photo
                    if let photoData = selectedPhotoData ?? miniature.photo,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    }
                }
            }
            .navigationTitle("Edit Miniature")
            .navigationBarTitleDisplayMode(.inline)
            // MARK: - Toolbar Buttons
            .toolbar {
                // "Done" button
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        // If a new photo was selected, update the miniature
                        if let selectedPhotoData {
                            miniature.photo = selectedPhotoData
                        }
                        dismiss() // Just close the sheet
                    }
                }
            }
            // MARK: - Photo Loading Logic
            .onChange(of: selectedPhotoItem) {
                // When selectedPhotoItem changes, load the data
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                        // Store it in our local state for preview
                        selectedPhotoData = data
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    // This creates a sample miniature just for the preview
    let sampleMini = Miniature(name: "Primaris Intercessor",
                               faction: "Space Marines",
                               status: .wip)
    
    // We pass the sample mini into the Edit view
    return EditMiniatureView(miniature: sampleMini)
}
