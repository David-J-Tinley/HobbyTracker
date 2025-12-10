//
//  HobbyTrackerTests.swift
//  HobbyTrackerTests
//
//  Created by David J Tinley on 11/10/25.
//

import Testing
import SwiftData
import Foundation
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

    // MARK: - Test Mini Initialization
    @Test func testMiniatureInitialization() {
        // Test that your model's initializer works as expected
        let mini = Miniature(name: "Test Marine", faction: "Ultramarines", status: .built)
        
        #expect(mini.name == "Test Marine")
        #expect(mini.faction == "Ultramarines")
        #expect(mini.status == .built)
        #expect(mini.photos.isEmpty) // Default photo should be nil
    }
    
    // MARK: - Test Status Display Name
    @Test func testStatusDisplayName() {
        // Test the computed property in your Status enum
        #expect(Status.wip.displayName == "Work in Progress")
        #expect(Status.unbuilt.displayName == "Unbuilt")
    }

    // MARK: - Test Swift Data Create & Read
    @MainActor
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
    
    // MARK: - Test Swift Data Delete
    @MainActor
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
    
    // MARK: - Test Swift Data Update
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
    
    // MARK: - Test Backlog & Gallery Filtering
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
    
    // MARK: - Test Recipe & Notes Persistence
    @MainActor
        @Test func testRecipeAndNotesPersistence() async throws {
            // 1. Create a mini (uses the new default "" values)
            let mini = Miniature(name: "Test Captain", faction: "Ultramarines")
            
            #expect(mini.recipe == "")
            #expect(mini.notes == "")
            
            // 2. Add some data
            mini.recipe = "Base: Macragge Blue, Shade: Nuln Oil"
            mini.notes = "Used a 32mm base instead of 40mm."
            
            // 3. Save it to the context
            let context = testContainer.mainContext
            context.insert(mini)
            
            // 4. Fetch it back to ensure it saved
            // Add <Miniature> after #Predicate
            let descriptor = FetchDescriptor<Miniature>(predicate: #Predicate<Miniature> { $0.name == "Test Captain" })
            let fetchedMini = try context.fetch(descriptor).first!
            
            #expect(fetchedMini.recipe == "Base: Macragge Blue, Shade: Nuln Oil")
            #expect(fetchedMini.notes == "Used a 32mm base instead of 40mm.")
        }
    
    // MARK: - Test Calculations
    @MainActor
        @Test func testStatsCalculations() async throws {
            let context = testContainer.mainContext
            
            // 1. Setup: Create a diverse collection
            // 2 Ultramarines (1 Built, 1 Wip)
            context.insert(Miniature(name: "Intercessor", faction: "Ultramarines", status: .built))
            context.insert(Miniature(name: "Captain", faction: "Ultramarines", status: .wip))
            
            // 1 Necron (Unbuilt)
            context.insert(Miniature(name: "Warrior", faction: "Necrons", status: .unbuilt))
            
            // 3 Orks (All Complete)
            context.insert(Miniature(name: "Boy 1", faction: "Orks", status: .complete))
            context.insert(Miniature(name: "Boy 2", faction: "Orks", status: .complete))
            context.insert(Miniature(name: "Nob", faction: "Orks", status: .complete))
            
            // 2. Fetch all data
            let descriptor = FetchDescriptor<Miniature>()
            let minis = try context.fetch(descriptor)
            
            // 3. Test Status Counts (The "Donut Chart" Logic)
            let completedCount = minis.filter { $0.status == .complete }.count
            let builtCount = minis.filter { $0.status == .built }.count
            let unbuiltCount = minis.filter { $0.status == .unbuilt }.count
            
            #expect(completedCount == 3) // Should be 3 Orks
            #expect(builtCount == 1)     // Should be 1 Marine
            #expect(unbuiltCount == 1)   // Should be 1 Necron
            
            // 4. Test Faction Grouping (The "Bar Chart" Logic)
            let allFactions = Set(minis.map { $0.faction })
            
            // Calculate counts per faction
            let factionCounts = allFactions.map { faction in
                minis.filter { $0.faction == faction }.count
            }
            
            #expect(factionCounts.contains(3)) // Orks
            #expect(factionCounts.contains(2)) // Ultramarines
            #expect(factionCounts.contains(1)) // Necrons
        }
    
    // MARK: - Test Search and Sort Logic
    @MainActor
        @Test func testSearchAndSortLogic() async throws {
            // 1. Setup: Create items with distinct names and dates
            let oldMini = Miniature(name: "Alpha Squad", faction: "Marines")
            oldMini.dateAdded = Date.distantPast // Force it to be "Old"
            
            let newMini = Miniature(name: "Zulu Squad", faction: "Zerg")
            newMini.dateAdded = Date.now // Force it to be "New"
            
            // 2. Put them in a list
            let minis = [oldMini, newMini]
            
            // 3. Test SEARCH Logic
            // Search for "Zulu" -> Should only find newMini
            let searchResult = minis.filter {
                $0.name.localizedStandardContains("Zulu")
            }
            #expect(searchResult.count == 1)
            #expect(searchResult.first?.name == "Zulu Squad")
            
            // Search for "Squad" -> Should find both
            let commonResult = minis.filter {
                $0.name.localizedStandardContains("Squad")
            }
            #expect(commonResult.count == 2)
            
            // 4. Test SORT Logic
            
            // Sort by Alphabetical (A -> Z)
            let alphaSorted = minis.sorted { $0.name < $1.name }
            #expect(alphaSorted.first?.name == "Alpha Squad")
            #expect(alphaSorted.last?.name == "Zulu Squad")
            
            // Sort by Newest First (Date Descending)
            let newestSorted = minis.sorted { $0.dateAdded > $1.dateAdded }
            #expect(newestSorted.first?.name == "Zulu Squad")
            #expect(newestSorted.last?.name == "Alpha Squad")
        }
    
    // MARK: - Test Mini Cloning w/ Gallery
    @MainActor
        @Test func testMiniatureCloningWithGallery() async throws {
            // 1. Setup Master
            let master = Miniature(name: "Clone Master", faction: "Republic")
            
            // Add a photo to the master
            let sampleData = Data([0xAA, 0xBB])
            let photo = MiniaturePhoto(data: sampleData)
            master.photos.append(photo)
            
            // 2. Perform Clone
            let clone = master.clone()
            
            // 3. Verify Basic Info
            #expect(clone.name == master.name)
            
            // 4. Verify Gallery Cloning
            // The clone should have 1 photo
            #expect(clone.photos.count == 1)
            
            // The data should be the same
            #expect(clone.photos.first?.data == sampleData)
            
            // BUT the Photo ID should be different (it's a deep copy, not the same object)
            #expect(clone.photos.first?.id != master.photos.first?.id)
        }
    
    // MARK: - Test Photo Gallery Logic
    @MainActor
        @Test func testPhotoGalleryLogic() async throws {
            let context = testContainer.mainContext
            let mini = Miniature(name: "Gallery Test", faction: "Test")
            
            // 1. Create two pieces of dummy image data
            let oldData = Data([0x01]) // Pretend this is an old photo
            let newData = Data([0x02]) // Pretend this is a new photo
            
            // 2. Create Photo objects with different dates
            let oldPhoto = MiniaturePhoto(data: oldData, dateTaken: Date.distantPast)
            let newPhoto = MiniaturePhoto(data: newData, dateTaken: Date.now)
            
            // 3. Add them to the miniature (Order shouldn't matter for the logic, but we append)
            mini.photos.append(oldPhoto)
            mini.photos.append(newPhoto)
            
            context.insert(mini)
            
            // 4. Verify Count
            #expect(mini.photos.count == 2)
            
            // 5. Verify Cover Image Logic
            // The app should pick the photo with the latest date (newData)
            #expect(mini.coverImage == newData)
            #expect(mini.coverImage != oldData)
        }
}
