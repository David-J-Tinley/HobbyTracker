# HobbyTracker

HobbyTracker is a comprehensive iOS application designed for miniature painters and wargamers to track their collection, manage painting projects, and view their progress. Built with **SwiftUI** and **SwiftData**, it serves as a modern digital backlog and gallery for hobbyists.

## 📱 Screenshots

*(Optional: You can add screenshots here later)*

## 🛠 Tech Stack

* **Language:** Swift 5.0+
* **UI Framework:** SwiftUI
* **Database:** SwiftData (Local persistence)
* **Charting:** Swift Charts
* **Camera & Gestures:** UIKit Integration (`UIViewControllerRepresentable`, `UIViewRepresentable`)
* **Minimum Target:** iOS 17.0+

## ✨ Features

### Core Management
* **Backlog System:** Automatically separates "Work in Progress" models from "Completed" ones into two distinct tabs.
* **CRUD Functionality:** Full support to Create, Read, Update, and Delete miniature entries.
* **Smart Filtering:** * **Backlog Tab:** Displays Unbuilt, Built, Primed, and WIP models.
    * **Gallery Tab:** Displays only Complete models in a visual grid layout.

### Advanced Data & Organization
* **SwiftData Integration:** All data is persisted locally on the device using Apple's latest database framework.
* **Search & Sort:** * Full-text search for Name and Faction.
    * Sortable by Newest, Oldest, Alphabetical (A-Z), or Faction.
* **Detailed Records:** Track specific details including:
    * **Faction:** (e.g., Space Marines, Orks)
    * **Status:** (Unbuilt, Built, Primed, WIP, Complete)
    * **Paint Recipes:** A dedicated text area to log specific colors and techniques used.
    * **Notes:** General build notes or reminders.

### Productivity Tools
* **Army Builder (Cloning):** A "Duplicate" feature allowing users to instantly clone a model (including its photo, recipe, and faction) to quickly build squads of identical troops.
* **Statistics Dashboard:** A "Stats" sheet featuring:
    * **Status Breakdown:** A Donut Chart visualizing project completion rates.
    * **Faction Breakdown:** A Bar Chart showing collection size by army.

### Media & Camera
* **Native Camera Support:** Integrated Camera access allows users to snap photos of their models directly within the "Add" or "Edit" forms without leaving the app.
* **Full-Screen Inspector:** A tap-to-zoom image viewer in the Detail screen allowing users to pinch and pan to inspect fine painting details.
* **Photo Library Integration:** Option to upload existing photos from the iOS Photo Library.

## 🚀 How to Run

1.  **Requirements:** Xcode 15+ and an iPhone running iOS 17+.
2.  **Permissions:** The app requires Camera permissions to function fully.
    * *Note:* The "Take Photo" feature must be tested on a physical device, as the iOS Simulator does not support the camera.
3.  **Installation:**
    * Clone the repository.
    * Open `HobbyTracker.xcodeproj`.
    * Select your physical iPhone as the run destination.
    * Build and Run (Cmd+R).

## 🧪 Testing

The project includes a robust suite of **Unit** and **UI Tests** to ensure stability:
* **Unit Tests:** Verify data persistence, cloning logic, statistic calculations, and filtering algorithms.
* **UI Tests:** Verify user flows for adding models, searching/sorting, moving items to the gallery, and camera interaction.

## 🗺 Roadmap (Future Features)

* [ ] **Haptic Feedback:** Add tactile feedback for completing tasks and saving entries.
* [ ] **Visual Polish:** Add confetti animations when a model is marked as "Complete".
* [ ] **Data Export:** Add JSON export functionality for data backup.
* [ ] **iCloud Sync:** Sync collection data across multiple devices (iPhone/iPad).
* [ ] **Project Grouping:** Ability to group individual models into "Squads" or "Armies".
* [ ] **Wishlist:** A separate tab for tracking models the user wants to buy.
* [ ] **Paint Inventory:** A database to track owned paints and brushes.

## 📄 License

This project is for personal use and educational purposes.
