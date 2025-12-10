//
//  AddMiniatureView.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import SwiftUI
import SwiftData
import PhotosUI // Import this for the photo picker

// In AddMiniatureView.swift

struct AddMiniatureView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var faction: String = ""
    @State private var status: Status = .unbuilt
    @State private var recipe: String = ""
    @State private var notes: String = ""
    
    // --- UPDATED STATE ---
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedImagesData: [Data] = [] // We store a list now
    @State private var isShowingCamera = false
    @State private var cameraPhotoData: Data? // Temp holder for camera
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Miniature Name", text: $name)
                    TextField("Faction", text: $faction)
                }
                
                Section("Painting Status") {
                    Picker("Status", selection: $status) {
                        ForEach(Status.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                }
                
                // MARK: - Multi-Photo Section
                Section("Progress Photos") {
                    // 1. The Add Buttons
                    HStack(spacing: 20) {
                        Button {
                            isShowingCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                        }
                        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                        .buttonStyle(.borderless)

                        PhotosPicker(selection: $selectedPhotoItems,
                                     maxSelectionCount: 5, // Allow up to 5 at once
                                     matching: .images) {
                            Label("Library", systemImage: "photo.on.rectangle")
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 5)

                    // 2. Horizontal Scroll of Selected Photos
                    if !selectedImagesData.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(selectedImagesData.enumerated()), id: \.offset) { index, data in
                                    if let uiImage = UIImage(data: data) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            // Delete "X" button
                                            Button {
                                                selectedImagesData.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.red)
                                                    .background(.white)
                                                    .clipShape(Circle())
                                            }
                                            .offset(x: 5, y: -5)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 5)
                        }
                    }
                }
                
                Section("Paint Recipe") {
                    TextField("Recipe...", text: $recipe, axis: .vertical).lineLimit(3...6)
                }
                Section("Notes") {
                    TextField("Notes...", text: $notes, axis: .vertical).lineLimit(3...6)
                }
            }
            .navigationTitle("Add New Miniature")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveMiniature() }
                    .disabled(name.isEmpty)
                }
            }
            // --- Camera Sheet ---
            .sheet(isPresented: $isShowingCamera) {
                // We use the temp 'cameraPhotoData' binding
                CameraPicker(selectedData: $cameraPhotoData)
            }
            // --- Watchers ---
            // 1. Handle Camera Photo
            .onChange(of: cameraPhotoData) {
                if let newData = cameraPhotoData {
                    selectedImagesData.append(newData)
                    cameraPhotoData = nil // Reset for next time
                }
            }
            // 2. Handle Library Picker
            .onChange(of: selectedPhotoItems) {
                Task {
                    for item in selectedPhotoItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            selectedImagesData.append(data)
                        }
                    }
                    selectedPhotoItems.removeAll() // Clear selection so we can pick more later
                }
            }
        }
    }
    
    private func saveMiniature() {
        let newMini = Miniature(name: name, faction: faction, status: status)
        newMini.recipe = recipe
        newMini.notes = notes
        
        // Convert our raw data array into MiniaturePhoto objects
        for data in selectedImagesData {
            let photo = MiniaturePhoto(data: data)
            newMini.photos.append(photo)
        }
        
        modelContext.insert(newMini)
        dismiss()
    }
}

#Preview {
    AddMiniatureView()
}
