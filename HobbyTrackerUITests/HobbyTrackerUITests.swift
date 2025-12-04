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
        
        // Navigate to detail screen...
        cell.tap()
        // FIX: Open the menu first!
        let actionsMenu = app.buttons["actionsMenu"]
        XCTAssert(actionsMenu.waitForExistence(timeout: 2), "Actions menu should exist")
        actionsMenu.tap()
        
        // Now find the edit button
        let editButton = app.buttons["editButton"]
        XCTAssert(editButton.waitForExistence(timeout: 2), "Edit button should exist inside the menu")
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
            
            // Tap the new "Actions Menu" (the ellipsis icon)
            let actionsMenu = app.buttons["actionsMenu"]
            XCTAssert(actionsMenu.waitForExistence(timeout: 2), "The Actions Menu (...) needs to be visible")
            actionsMenu.tap()
            
            // NOW tap the Edit button (which is visible inside the open menu)
            let editButton = app.buttons["editButton"]
            XCTAssert(editButton.waitForExistence(timeout: 2), "Edit button should appear inside the menu")
            editButton.tap()
            
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
    
    @MainActor
        func testAddMiniatureWithNotes() throws {
            let app = XCUIApplication()
            app.launch()
            
            // 1. Open the "Add" sheet
            app.buttons["addMiniatureButton"].tap()
            
            // 2. Fill in basic info
            let nameField = app.textFields["miniatureNameField"]
            nameField.tap()
            nameField.typeText("Recipe Tester")
            
            // 3. Fill in the new Recipe field
            // Note: TextFields with vertical axis sometimes act like TextViews,
            // but .textFields["id"] usually finds them in SwiftUI.
            let recipeField = app.textFields["recipeField"]
            XCTAssert(recipeField.exists, "Recipe field should exist")
            recipeField.tap()
            recipeField.typeText("Base: Leadbelcher")
            
            // 4. Fill in the new Notes field
            let notesField = app.textFields["notesField"]
            XCTAssert(notesField.exists, "Notes field should exist")
            notesField.tap()
            notesField.typeText("Watch out for mold lines")
            
            // 5. Save
            app.buttons["saveMiniatureButton"].tap()
            
            // 6. Verify data in Detail View
            // Wait for list to update
            let cell = app.staticTexts["Recipe Tester"]
            XCTAssert(cell.waitForExistence(timeout: 2))
            cell.tap()
            
            // Check that the headers and text exist
            XCTAssert(app.staticTexts["Paint Recipe"].exists)
            XCTAssert(app.staticTexts["Base: Leadbelcher"].exists)
            
            XCTAssert(app.staticTexts["Notes"].exists)
            XCTAssert(app.staticTexts["Watch out for mold lines"].exists)
        }
    
    @MainActor
        func testStatsSheetFlow() throws {
            let app = XCUIApplication()
            app.launch()
            
            // 1. Navigate to the Gallery (Completed) Tab
            // Note: Tab bars usually use the title of the tab as the button name
            let galleryTab = app.tabBars.buttons["Gallery"]
            XCTAssert(galleryTab.exists, "Gallery tab should exist")
            galleryTab.tap()
            
            // 2. Tap the Stats Button
            let statsButton = app.buttons["statsButton"]
            XCTAssert(statsButton.exists, "Stats button should be visible in Gallery")
            statsButton.tap()
            
            // 3. Verify the Sheet Opened
            // We look for the title "Hobby Stats"
            let sheetTitle = app.staticTexts["Hobby Stats"]
            XCTAssert(sheetTitle.waitForExistence(timeout: 2), "Stats sheet should appear")
            
            // 4. Check for Chart Headers
            // This ensures our two main sections are actually rendering
            XCTAssert(app.staticTexts["Project Status"].exists)
            XCTAssert(app.staticTexts["Faction Breakdown"].exists)
            
            // 5. Dismiss the sheet
            app.buttons["Done"].tap()
            
            // 6. Verify we are back on the Gallery
            XCTAssert(statsButton.exists)
        }
    
    @MainActor
        func testSearchAndSortUI() throws {
            let app = XCUIApplication()
            app.launch()
            
            // 1. Add "Zebra" (Added First)
            app.buttons["addMiniatureButton"].tap()
            app.textFields["miniatureNameField"].tap()
            app.textFields["miniatureNameField"].typeText("Zebra")
            app.buttons["saveMiniatureButton"].tap()
            
            // 2. Add "Apple" (Added Second)
            app.buttons["addMiniatureButton"].tap()
            app.textFields["miniatureNameField"].tap()
            app.textFields["miniatureNameField"].typeText("Apple")
            app.buttons["saveMiniatureButton"].tap()
            
            // 3. TEST SEARCH
            // Tap the search bar
            let searchField = app.searchFields.firstMatch
            XCTAssert(searchField.waitForExistence(timeout: 2), "Search bar should exist")
            searchField.tap()
            
            // Search for "Zebra"
            searchField.typeText("Zebra")
            
            // Check results
            XCTAssert(app.staticTexts["Zebra"].exists)
            XCTAssertFalse(app.staticTexts["Apple"].exists, "Apple should be filtered out")
            
            let clearButton = searchField.buttons["Clear text"]
            if clearButton.exists {
                clearButton.tap()
            }
            
            app.buttons["Close"].tap()
            
            // 4. TEST SORT
            // Open Sort Menu
            let sortMenu = app.buttons["sortMenu"]
            // Wait up to 2 seconds for the animation to finish
            XCTAssert(sortMenu.waitForExistence(timeout: 2), "Sort menu should be visible after closing search")
            sortMenu.tap()
            
            // Select "Name (A-Z)"
            // Note: The menu button text matches the Enum rawValue
            app.buttons["Name (A-Z)"].tap()
            
            // Verify Order
            // In accessibility trees, the first cell usually appears first in the query match
            let firstCell = app.cells.firstMatch
            let firstText = firstCell.staticTexts["Apple"]
            
            XCTAssert(firstText.exists, "Apple should be first when sorted alphabetically")
        }
}
