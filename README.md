# Spatial Inventory

Spatial Inventory is an iOS inventory management app built with SwiftUI, ARKit, RealityKit, MVVM, PhotosUI, and local JSON persistence.

The app allows users to create inventory items, track stock levels, attach item photos, search/filter records, view item details, and place inventory labels in augmented reality using ARKit and RealityKit.

▶️ Demo Video: https://youtube.com/shorts/Q-mx1lXHIO0

[![Watch the Spatial Inventory demo](https://img.youtube.com/vi/Q-mx1lXHIO0/hqdefault.jpg)](https://youtube.com/shorts/Q-mx1lXHIO0)

---

## Features

- Add new inventory items
- Edit existing inventory items
- Delete inventory records
- Track item name, category, quantity, location, and notes
- Attach item photos using PhotosUI
- Search inventory records
- Filter inventory by category
- Sort by name, date, and quantity
- View total inventory count
- View low-stock alerts
- View recently added items
- Open detailed item information
- Use ARKit surface detection
- Place RealityKit inventory labels in AR
- Save AR placement metadata with inventory items
- Show AR placed status in the app
- Local JSON persistence
- MVVM architecture

---

## Tech Stack

- Swift
- SwiftUI
- ARKit
- RealityKit
- PhotosUI
- MVVM
- Codable
- FileManager
- Local JSON persistence
- Xcode

---

## Demo Flow

1. Open Spatial Inventory
2. View the home dashboard
3. Add a new inventory item
4. Enter item name, category, quantity, location, and notes
5. Attach an item photo
6. Save the item locally
7. View saved inventory records
8. Open item detail screen
9. Launch AR Scanner
10. Detect a real-world surface using ARKit
11. Place a RealityKit inventory label in AR
12. Save AR placement metadata with the item
13. Show AR placed status in the app

---

## Project Structure

```text
SpatialInventory
├── Views
│   ├── AddItemView.swift
│   ├── ARScannerView.swift
│   ├── HomeView.swift
│   ├── InventoryDetailView.swift
│   ├── InventoryListView.swift
│   └── SettingsView.swift
│
├── Components
│   ├── InventoryCardView.swift
│   └── SupportingComponents.swift
│
├── Models
│   ├── InventoryItem.swift
│   └── ARPlacementData.swift
│
├── Services
│   └── InventoryStorageService.swift
│
├── ViewModels
│   ├── InventoryViewModel.swift
│   └── ARInventoryViewModel.swift
│
├── Assets.xcassets
└── README.md


How It Works
Open App
↓
Add Inventory Item
↓
Item is saved locally using JSON
↓
View item in Inventory List
↓
Open Item Detail
↓
Launch AR Scanner
↓
Detect surface using ARKit
↓
Place RealityKit label in AR
↓
Save AR placement metadata
↓
Item shows AR placed status
Local Persistence

Spatial Inventory stores inventory data locally using JSON in the app’s Documents directory.

The app uses:

Codable for encoding and decoding
FileManager for local storage
Atomic writes for safer saving
Local JSON persistence without a backend

Saved data includes:

Item name
Category
Quantity
Location
Notes
Image data
AR placement metadata
Date added
Date modified
AR Placement

The AR scanner uses ARKit and RealityKit to place inventory labels in augmented reality.

The AR label can show:

Item name
Category
Quantity

The app saves AR placement metadata such as position, rotation, item ID, and placement date.

Note: The current version saves AR placement metadata and shows AR placed status in the app. It does not implement full ARWorldMap persistence or room-scale relocalization across app launches.

How to Run on Your Device
Requirements
macOS
Xcode
iPhone with ARKit support
iOS device recommended for AR testing
Steps
git clone https://github.com/solankipratik8008/spatial-inventory.git
cd spatial-inventory
open *.xcodeproj

If the project uses a workspace:

open *.xcworkspace

Then in Xcode:

Select the project target.
Go to Signing & Capabilities.
Select your Apple Developer Team.
Make sure camera permission is added in Info.plist.
Build with Command + B.
Run on a real iPhone with Command + R.
Required Permission

Because the app uses ARKit, it needs camera permission.

Recommended Info.plist camera message:

Spatial Inventory uses the camera to place inventory labels in augmented reality.
Known Limitations
AR labels are placed in the active AR session.
Full ARWorldMap persistence is not implemented yet.
Saved X/Y/Z coordinates may not restore to the exact same physical location after app restart.
Data is stored locally only.
No cloud sync yet.
No barcode or QR scanning yet.
No export/import feature yet.
Images are stored as Base64 strings, which is acceptable for a demo app but not ideal for a large production system.
Future Improvements
Add ARWorldMap persistence
Add barcode or QR scanning
Add CloudKit or Firebase sync
Add CSV/JSON export
Add low-stock notifications
Add item quantity history
Add AR label editing
Add AR search mode
Move images from Base64 JSON storage to file-based image storage
Resume Highlight

Spatial Inventory - SwiftUI, ARKit, RealityKit, MVVM, Local JSON Persistence
Built an iOS inventory management app with item CRUD, photo attachments, search/filter, stock tracking, low-stock alerts, and ARKit/RealityKit tap-to-place inventory labels with saved AR placement metadata.

Author

Pratikkumar Solanki

GitHub: https://github.com/solankipratik8008
LinkedIn: https://www.linkedin.com/in/pratikkumar-solanki-045b62365
Portfolio: https://solankipratik8008.github.io/Portfolio/
Disclaimer

Spatial Inventory is a portfolio/demo app created for learning and showcasing iOS development skills.

The app does not provide enterprise-grade asset tracking, production cloud sync, or production-level AR anchor persistence in its current version. AR labels are placed in the active AR session, and saved AR placement metadata is used for inventory context and UI status.
