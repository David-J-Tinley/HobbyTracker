//
//  HobbyTrackerApp.swift
//  HobbyTracker
//
//  Created by David J Tinley on 11/10/25.
//

import SwiftUI
import SwiftData // 1. Import SwiftData

@main
struct HobbyTrackerApp: App { // <-- This name will be your project's name
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // 2. Add this modifier to set up the database
        // This injects the "modelContext" into the environment
        // for all other views (like ContentView and AddMiniatureView)
        .modelContainer(for: Miniature.self)
    }
}
