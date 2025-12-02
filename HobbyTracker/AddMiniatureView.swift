//
//  AddMiniatureView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import SwiftUI
import SwiftData
import PhotosUI // Import this for the photo picker

struct AddMiniatureView: View {
    // 1. Environment and State
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // 2. State for the form fields
    @State private var name: String = ""
    @State private var faction: String = ""
    @State private var status: Status = .unbuilt
    
    // 3. State for the Photo Picker
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    
    // 4. State for the Notes and Recipe fields
    @State private var recipe: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Details Section
                Section("Details") {
                    TextField("Miniature Name", text: $name)
                        .accessibilityIdentifier("miniatureNameField")
                    TextField("Faction", text: $faction)
                }
                
                // MARK: - Status Section
                Section("Painting Status") {
                    // This creates a dropdown menu using our Enum
                    Picker("Status", selection: $status) {
                        ForEach(Status.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                }
                
                // MARK: - Photo Section
                Section("Photo") {
                    // The new SwiftUI PhotosPicker
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images, // Only allow images
                        photoLibrary: .shared()
                    ) {
                        Label("Add Photo", systemImage: "photo")
                    }
                    
                    // Show a preview if a photo was selected
                    if let selectedPhotoData,
                       let uiImage = UIImage(data: selectedPhotoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    }
                }

                // MARK: - Notes & Recipes
                Section("Paint Recipe") {
                    TextField("e.g. Base: Macragge Blue...", text: $recipe, axis: .vertical)
                        .lineLimit(3...6) // Sets a minimum and maximum height
                }

                Section("Notes") {
                    TextField("General notes about the build...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add New Miniature")
            .navigationBarTitleDisplayMode(.inline)
            // MARK: - Toolbar Buttons
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss() // Close the sheet
                    }
                }
                
                // Save Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveMiniature()
                        dismiss() // Close the sheet
                    }
                    // Disable the save button if the name is empty
                    .disabled(name.isEmpty)
                    .accessibilityIdentifier("saveMiniatureButton")
                }
            }
            // MARK: - Photo Loading Logic
            .onChange(of: selectedPhotoItem) {
                // When selectedPhotoItem changes, load the data
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                        selectedPhotoData = data
                    }
                }
            }
        }
    }
    
    // MARK: - Save Function
    private func saveMiniature() {
        // 1. Create the new miniature object
        let newMini = Miniature(name: name, faction: faction, status: status)
        
        // 2. Add the photo data if it exists
        newMini.photo = selectedPhotoData
        
        // 3. Save the new fields
        newMini.recipe = recipe
        newMini.notes = notes
        
        // 4. Insert it into the SwiftData model context
        modelContext.insert(newMini)
        
        // SwiftData will auto-save from here
    }
}

#Preview {
    AddMiniatureView()
}
