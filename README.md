# Spatial Inventory

Spatial Inventory is an iOS inventory management app built with **SwiftUI**, **ARKit**, **RealityKit**, **MVVM**, **PhotosUI**, and **local JSON persistence**.

The app allows users to create inventory items, track stock levels, attach item photos, search/filter records, view item details, and place inventory labels in augmented reality using ARKit and RealityKit.

▶️ **Demo Video:** [Watch Spatial Inventory Demo](https://youtube.com/shorts/Q-mx1lXHIO0)

[![Watch the Spatial Inventory demo](https://img.youtube.com/vi/Q-mx1lXHIO0/hqdefault.jpg)](https://youtube.com/shorts/Q-mx1lXHIO0)

---

## Overview

Spatial Inventory is a portfolio iOS project focused on combining a practical business workflow with augmented reality.

The app provides a clean inventory management experience where users can add items, manage quantities, track low-stock products, attach photos, and organize items by category and location.

The AR scanner lets users select an inventory item, detect a real-world surface, and place a floating RealityKit label in AR space. The app saves AR placement metadata with the inventory item so the normal inventory UI can show which items have already been placed in AR.

This project demonstrates practical iOS development skills across SwiftUI, ARKit, RealityKit, local persistence, MVVM architecture, and user-friendly mobile UI design.

---

## Demo Video

The project includes a short demo video showing the main Spatial Inventory workflow.

▶️ **Watch Demo on YouTube:** [Spatial Inventory iOS App Demo](https://youtube.com/shorts/Q-mx1lXHIO0)

Demo flow shown in the video:

1. Open Spatial Inventory
2. View the home dashboard
3. Add a new inventory item
4. Enter item name, category, quantity, location, and notes
5. Attach an item photo
6. Save the item locally
7. View saved inventory records
8. Open the item detail screen
9. Launch the AR scanner
10. Detect a real-world surface
11. Place an inventory label in AR
12. Save AR placement metadata
13. Show AR placed status in the app

---

## Features

### Inventory Management

- Add new inventory items
- Edit existing inventory items
- Delete inventory records
- View item details
- Track item name, category, quantity, location, and notes
- Attach item photos using PhotosUI
- Save item images as Base64 data for local JSON persistence
- View recently added items
- View low-stock items on the dashboard

### Search, Filter, and Sort

- Search inventory by item name, category, location, or notes
- Filter items by category
- Sort inventory records by:
  - Newest first
  - Oldest first
  - Name A-Z
  - Name Z-A
  - Lowest quantity
  - Highest quantity
- Clear active filters

### Stock Tracking

- Automatic stock status detection
- In-stock, low-stock, and out-of-stock badges
- Dashboard overview of total items and low-stock count
- Low-stock alert section
- Quantity-based visual indicators

### AR Inventory Placement

- ARKit world tracking
- RealityKit ARView integration
- Horizontal surface detection
- AR coaching overlay
- Reticle placement guide
- Tap-to-place inventory labels
- “Place Label Here” action
- Floating AR label with item name, category, and quantity
- Save AR placement metadata with inventory item
- Show AR placed status in list/detail views
- Update or remove AR placement metadata

### Local Persistence

- Local JSON storage using Codable
- Saves inventory records in the app’s Documents directory
- Data persists across app launches
- Atomic write support to reduce file corruption risk
- No backend required

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Swift | Main programming language |
| SwiftUI | User interface |
| ARKit | AR tracking and surface detection |
| RealityKit | AR rendering and 3D label placement |
| PhotosUI | Item photo picker |
| MVVM | App architecture |
| Codable | JSON encoding and decoding |
| FileManager | Local file storage |
| JSON | Local persistence format |
| Xcode | iOS development environment |

---

## Architecture

Spatial Inventory follows an **MVVM** architecture with a simple service layer for local persistence.

```text
SpatialInventory
├── App
│   ├── Views
│   │   ├── AddItemView.swift
│   │   ├── ARScannerView.swift
│   │   ├── HomeView.swift
│   │   ├── InventoryDetailView.swift
│   │   ├── InventoryListView.swift
│   │   └── SettingsView.swift
│   │
│   ├── Components
│   │   ├── InventoryCardView.swift
│   │   └── SupportingComponents.swift
│   │
│   ├── Models
│   │   ├── InventoryItem.swift
│   │   └── ARPlacementData.swift
│   │
│   ├── Services
│   │   └── InventoryStorageService.swift
│   │
│   ├── Utilities
│   │   ├── Constants.swift
│   │   └── Extensions.swift
│   │
│   └── ViewModels
│       ├── InventoryViewModel.swift
│       └── ARInventoryViewModel.swift
│
├── Assets.xcassets
├── SpatialInventoryTests
├── SpatialInventoryUITests
└── README.md
