# Spatial Inventory Manager – ARKit Inventory Tracking App

Spatial Inventory Manager is a modern iOS inventory management application built with **SwiftUI**, **ARKit**, **RealityKit**, and **MVVM architecture**. The app helps users organize physical inventory items, manage stock details, and visualize inventory placement in real-world spaces using augmented reality.

This project is designed as a portfolio-level iOS application to demonstrate clean architecture, AR integration, local data handling, reusable SwiftUI components, and a professional mobile user experience.

---

## 📱 App Overview

Spatial Inventory Manager allows users to create, manage, search, and visualize inventory items. Users can add item details such as name, category, quantity, location, notes, and stock status. The AR feature allows users to place or visualize inventory labels in real-world space, making the app useful for organizing storage rooms, offices, warehouses, classrooms, and personal collections.

---

## ✨ Features

- Add new inventory items
- View all inventory items in a clean list
- Search inventory by item name, category, or location
- Filter items by category
- View detailed item information
- Edit existing inventory items
- Delete inventory items
- Track item quantity and low-stock status
- Dashboard with inventory summary
- AR scanner using ARKit
- AR-based item label placement
- Clean SwiftUI user interface
- Reusable UI components
- MVVM-based project structure
- Local data storage
- Light and dark mode friendly design

---

## 🧠 Why I Built This Project

I built this app to combine real-world inventory management with augmented reality. Traditional inventory apps only show records in a list, but this app goes one step further by allowing users to interact with inventory in physical space using AR.

The main goal of this project was to improve my iOS development skills and demonstrate:

- SwiftUI app development
- MVVM architecture
- ARKit and RealityKit integration
- Clean code organization
- Local data management
- Professional UI design
- Portfolio-ready iOS app development

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Swift | Main programming language |
| SwiftUI | User interface development |
| ARKit | Augmented reality features |
| RealityKit | AR object rendering and placement |
| MVVM | Clean architecture pattern |
| Local Storage | Saving inventory data |
| SF Symbols | Native iOS icons |
| Xcode | Development environment |

---

## 🏗️ Architecture

This project follows the **MVVM architecture pattern**.

```text
SpatialInventoryManager/
│
├── App/
│   └── SpatialInventoryApp.swift
│
├── Models/
│   ├── InventoryItem.swift
│   ├── InventoryCategory.swift
│   └── ARPlacementData.swift
│
├── ViewModels/
│   ├── InventoryViewModel.swift
│   ├── AddItemViewModel.swift
│   └── ARInventoryViewModel.swift
│
├── Views/
│   ├── HomeView.swift
│   ├── InventoryListView.swift
│   ├── InventoryDetailView.swift
│   ├── AddItemView.swift
│   ├── ARScannerView.swift
│   ├── ARPlacementView.swift
│   └── SettingsView.swift
│
├── Components/
│   ├── InventoryCardView.swift
│   ├── CategoryChipView.swift
│   ├── EmptyStateView.swift
│   └── PrimaryButton.swift
│
├── Services/
│   ├── InventoryStorageService.swift
│   └── ARSessionService.swift
│
└── Utilities/
    ├── Constants.swift
    └── Extensions.swift


<img width="946" height="2048" alt="image" src="https://github.com/user-attachments/assets/84b908ee-f4d0-41f2-9dad-c6e155ab2f4c" />

