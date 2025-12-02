//
//  HobbyTrackerTests.swift
//  HobbyTrackerTests
//
//  Created by David J Tinley on 11/10/25.
//

import Testing
import SwiftData
@testable import HobbyTracker // Gives your tests access to your app's code

struct HobbyTrackerTests {

    // 1. Create a model container for testing
    let testContainer: ModelContainer
    
    init() {
        // Create an in-memory database configuration
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            // Create the container using your Miniature model
            testContainer = try ModelContainer(for: Miniature.self, configurations: config)
        } catch {
            fatalError("Failed to create in-memory model container: \(error)")
        }
    }

    @Test func testMiniatureInitialization() {
        // Test that your model's initializer works as expected
        let mini = Miniature(name: "Test Marine", faction: "Ultramarines", status: .built)
        
        #expect(mini.name == "Test Marine")
        #expect(mini.faction == "Ultramarines")
        #expect(mini.status == .built)
        #expect(mini.photo == nil) // Default photo should be nil
    }
    
    @Test func testStatusDisplayName() {
        // Test the computed property in your Status enum
        #expect(Status.wip.displayName == "Work in Progress")
        #expect(Status.unbuilt.displayName == "Unbuilt")
    }

    @MainActor // <-- ADD THIS LINE
    @Test func testSwiftDataCreateAndRead() async throws {
        // Get the main context from your test container
        let context = testContainer.mainContext
        
        // 1. CREATE
        let newMini = Miniature(name: "Librarian", faction: "Blood Angels")
        context.insert(newMini)
        
        // 2. READ
        // We fetch directly from the context to see if it was saved
        // We'll fetch all Miniatures and expect to find just one
        let descriptor = FetchDescriptor<Miniature>()
        let miniatures = try context.fetch(descriptor)
        
        #expect(miniatures.count == 1)
        #expect(miniatures.first?.name == "Librarian")
    }
    
    @MainActor // <-- ADD THIS LINE
    @Test func testSwiftDataDelete() async throws {
        let context = testContainer.mainContext
        
        // Setup: Insert a miniature to delete
        let miniToDelete = Miniature(name: "Terminator", faction: "Dark Angels")
        context.insert(miniToDelete)
        
        // Verify it's there
        var miniatures = try context.fetch(FetchDescriptor<Miniature>())
        #expect(miniatures.count == 1)

        // 3. DELETE
        context.delete(miniToDelete)
        
        // Verify it's gone
        miniatures = try context.fetch(FetchDescriptor<Miniature>())
        #expect(miniatures.isEmpty)
    }
    @MainActor
    @Test func testSwiftDataUpdate() async throws {
        let context = testContainer.mainContext
        
        // 1. Setup: Insert a miniature
        let mini = Miniature(name: "Gretchin", faction: "Goffs", status: .unbuilt)
        context.insert(mini)
        
        // 2. Verify it's saved
        var miniatures = try context.fetch(FetchDescriptor<Miniature>())
        #expect(miniatures.first?.name == "Gretchin")
        #expect(miniatures.first?.status == .unbuilt)

        // 3. UPDATE: Get the object and change its properties
        let miniToUpdate = miniatures.first!
        miniToUpdate.name = "Runtherd"
        miniToUpdate.status = .wip
        
        // 4. VERIFY: Fetch again and check the new values
        // (Fetching again ensures we are reading the latest state from the context)
        miniatures = try context.fetch(FetchDescriptor<Miniature>())
        #expect(miniatures.count == 1)
        #expect(miniatures.first?.name == "Runtherd")
        #expect(miniatures.first?.status == .wip)
    }
    
    @MainActor
        @Test func testBacklogAndGalleryFiltering() async throws {
            let context = testContainer.mainContext
            
            // 1. Setup: Create a mix of miniatures
            let backlogItem1 = Miniature(name: "Soldier A", faction: "Army", status: .unbuilt)
            let backlogItem2 = Miniature(name: "Soldier B", faction: "Army", status: .wip)
            let completedItem = Miniature(name: "General", faction: "Army", status: .complete)
            
            context.insert(backlogItem1)
            context.insert(backlogItem2)
            context.insert(completedItem)
            
            // 2. Fetch All (simulating what the View does)
            let descriptor = FetchDescriptor<Miniature>()
            let allMiniatures = try context.fetch(descriptor)
            
            // 3. Test the "Backlog" Logic
            // Logic: Status != .complete
            let backlog = allMiniatures.filter { $0.status != .complete }
            
            #expect(backlog.count == 2)
            #expect(backlog.contains { $0.name == "Soldier A" })
            #expect(backlog.contains { $0.name == "Soldier B" })
            #expect(!backlog.contains { $0.name == "General" }) // Should NOT be here
            
            // 4. Test the "Gallery" Logic
            // Logic: Status == .complete
            let gallery = allMiniatures.filter { $0.status == .complete }
            
            #expect(gallery.count == 1)
            #expect(gallery.first?.name == "General")
        }
}
