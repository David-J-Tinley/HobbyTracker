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
}
