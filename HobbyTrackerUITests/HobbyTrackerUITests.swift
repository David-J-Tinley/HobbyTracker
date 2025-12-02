//
//  HobbyTrackerUITests.swift
//  HobbyTrackerUITests
//
//  Created by David J Tinley on 11/10/25.
//

import XCTest

final class HobbyTrackerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAddMiniatureFlow() throws {
        // 1. Launch the application
        let app = XCUIApplication()
        app.launch() // This launch should be fresh for each test

        // --- Start of a full user story ---
        
        // 2. Tap the "Add" button
        // (Assumes you added .accessibilityIdentifier("addMiniatureButton") to your + button)
        let addButton = app.buttons["addMiniatureButton"]
        XCTAssert(addButton.exists, "The 'Add' button should exist")
        addButton.tap()

        // 3. Fill out the "Add Miniature" form
        // (Assumes .accessibilityIdentifier("miniatureNameField"))
        let nameField = app.textFields["miniatureNameField"]
        XCTAssert(nameField.exists, "Name text field should exist")
        nameField.tap()
        nameField.typeText("Space Marine Hero")
        
        // We can find other fields by their placeholder text too
        let factionField = app.textFields["Faction"]
        XCTAssert(factionField.exists, "Faction text field should exist")
        factionField.tap()
        factionField.typeText("Salamanders")
        
        // 4. Tap the "Save" button
        // (Assumes .accessibilityIdentifier("saveMiniatureButton"))
        let saveButton = app.buttons["saveMiniatureButton"]
        XCTAssert(saveButton.exists, "Save button should exist")
        saveButton.tap()
        
        // 5. Verify the new item is on the main list
        // The sheet should be dismissed, and we should be back on the main screen.
        // We can check if static text with our new miniature's name exists.
        let newMiniCell = app.staticTexts["Space Marine Hero"]
        
        // We use an expectation to wait for the sheet to close and the list to update
        let cellExists = newMiniCell.waitForExistence(timeout: 2)
        XCTAssert(cellExists, "The new miniature cell should exist in the list")
        
        // We can also check the faction
        XCTAssert(app.staticTexts["Salamanders"].exists, "The new miniature's faction should be visible")
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    @MainActor
    func testEditMiniatureFlow() throws {
        // 1. Setup: Add a miniature to edit first
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["addMiniatureButton"].tap()
        
        let nameField = app.textFields["miniatureNameField"]
        // Wait for the field if needed (good practice)
        _ = nameField.waitForExistence(timeout: 2)
        nameField.tap()
        nameField.typeText("Ork Boy")
        
        let factionField = app.textFields["Faction"]
        factionField.tap()
        factionField.typeText("Goffs")
        
        app.buttons["saveMiniatureButton"].tap()
        
        // 2. Navigate to the detail screen and tap Edit
        let cell = app.staticTexts["Ork Boy"]
        // Wait for the save sheet to dismiss and the cell to appear
        XCTAssert(cell.waitForExistence(timeout: 5), "The new cell should appear in the list")
        cell.tap()
        
        let editButton = app.buttons["editButton"]
        // CRITICAL FIX: Wait for the navigation push animation to finish
        XCTAssert(editButton.waitForExistence(timeout: 2), "Edit button should exist after navigation")
        editButton.tap()
        
        // 3. Edit the miniature's name
        let editNameField = app.textFields["editNameField"]
        // CRITICAL FIX: Wait for the sheet slide-up animation to finish
        XCTAssert(editNameField.waitForExistence(timeout: 2), "Edit name field should exist after sheet opens")
        
        editNameField.tap()
//        editNameField.doubleTap()
//        editNameField.doubleTap()
        // --- NEW CLEARING LOGIC ---
        // Instead of tapping to select, we hit "Delete" for every character in the field
        if let currentValue = editNameField.value as? String {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            editNameField.typeText(deleteString)
        }
        // --------------------------
        editNameField.typeText("Ork Nob")
        
        // 4. Save the change
        let doneButton = app.buttons["doneButton"]
        XCTAssert(doneButton.exists, "Done button should exist")
        doneButton.tap()
        
        // 5. Verify the change
        // Wait for the sheet to dismiss and title to update
        XCTAssert(app.navigationBars["Ork Nob"].waitForExistence(timeout: 2))
        
        // Optional: Go back and check the main list
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssert(app.staticTexts["Ork Nob"].waitForExistence(timeout: 2))
    }
    @MainActor
    func testDeleteMiniatureFlow() throws {
        // 1. Setup: Add a miniature to delete
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["addMiniatureButton"].tap()
        
        let nameField = app.textFields["miniatureNameField"]
        _ = nameField.waitForExistence(timeout: 2)
        nameField.tap()
        nameField.typeText("To Be Deleted")
        
        app.buttons["saveMiniatureButton"].tap()
        
        // 2. Find the cell
        let cell = app.staticTexts["To Be Deleted"]
        XCTAssert(cell.waitForExistence(timeout: 5), "The new cell should exist")

        // 3. Swipe left to reveal the Delete button
        cell.swipeLeft()
        
        // 4. Tap the delete button
        let deleteButton = app.buttons["Delete"]
        XCTAssert(deleteButton.exists, "Delete button should appear after swipe")
        deleteButton.tap()
        
        // 5. Verify the cell is gone
        // We wait a moment for the animation to finish
        let doesNotExist = cell.waitForExistence(timeout: 2) == false
        XCTAssert(doesNotExist, "The cell should be deleted and no longer exist")
    }
    
    @MainActor
        func testMoveToGalleryFlow() throws {
            let app = XCUIApplication()
            app.launch()
            
            // 1. Add a new miniature to the Backlog
            let addButton = app.buttons["addMiniatureButton"]
            XCTAssert(addButton.exists)
            addButton.tap()
            
            let nameField = app.textFields["miniatureNameField"]
            nameField.tap()
            nameField.typeText("Gallery Candidate")
            
            app.buttons["saveMiniatureButton"].tap()
            
            // 2. Verify it is on the Backlog tab
            let cell = app.staticTexts["Gallery Candidate"]
            XCTAssert(cell.waitForExistence(timeout: 2))
            
            // 3. Mark it as "Complete"
            cell.tap() // Go to details
            
            app.buttons["editButton"].tap()
            
            // Open the Status Picker using the unique ID
            // We use .buttons because a menu-style Picker acts like a button
            let statusPicker = app.buttons["statusPicker"]

            if statusPicker.waitForExistence(timeout: 2) {
                statusPicker.tap()
                
                // Select "Complete" from the menu
                app.buttons["Complete"].tap()
            }

            app.buttons["doneButton"].tap()
            
            // 4. Navigate back to the list
            app.navigationBars.buttons.firstMatch.tap()
            
            // 5. Verify it is GONE from Backlog
            // (Wait a moment for UI to update)
            let cellOnBacklog = app.staticTexts["Gallery Candidate"]
            XCTAssertFalse(cellOnBacklog.exists, "Miniature should no longer be on the Backlog tab")
            
            // 6. Switch to the Gallery Tab (Tab bar button 2)
            // Tab bars usually have buttons labeled with the tab title
            app.tabBars.buttons["Gallery"].tap()
            
            // 7. Verify it IS in the Gallery
            let galleryCell = app.staticTexts["Gallery Candidate"]
            XCTAssert(galleryCell.waitForExistence(timeout: 2), "Miniature should now be in the Gallery")
        }
}
