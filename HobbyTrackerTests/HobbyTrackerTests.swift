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
}
