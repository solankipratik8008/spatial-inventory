//
//  Constants.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  Constants.swift
//  SpatialInventory
//
//  Centralizes app-wide constants: colors, spacing, typography, and string labels.
//  Import this file's values anywhere in the project instead of hardcoding.
//

import SwiftUI

// MARK: - App Info

enum AppInfo {
    static let name        = "Spatial Inventory"
    static let version     = "1.0.0"
    static let description = "AR-powered inventory management for the real world."
    static let github      = "https://github.com/yourusername/spatial-inventory"
}

// MARK: - Design Tokens

enum AppSpacing {
    static let xs: CGFloat   = 4
    static let sm: CGFloat   = 8
    static let md: CGFloat   = 16
    static let lg: CGFloat   = 24
    static let xl: CGFloat   = 32
    static let xxl: CGFloat  = 48
}

enum AppRadius {
    static let sm: CGFloat   = 8
    static let md: CGFloat   = 12
    static let lg: CGFloat   = 16
    static let xl: CGFloat   = 24
    static let card: CGFloat = 16
    static let chip: CGFloat = 20
}

enum AppFont {
    static let largeTitle  = Font.largeTitle.weight(.bold)
    static let title       = Font.title2.weight(.semibold)
    static let headline    = Font.headline.weight(.semibold)
    static let body        = Font.body
    static let caption     = Font.caption
    static let caption2    = Font.caption2
}

// MARK: - Brand Colors
// These reference asset catalog colors — we'll create them next.
// Falls back to system colors so the project compiles right away.

enum AppColors {
    /// Primary accent — used for buttons, highlights, active states
    static let accent      = Color("AccentColor")

    /// Card background — slightly elevated from the main background
    static let cardBg      = Color("CardBackground")

    /// Subtle background for chips, tags, and secondary containers
    static let chipBg      = Color("ChipBackground")

    /// Primary text color
    static let textPrimary = Color.primary

    /// Secondary / muted text color
    static let textSecondary = Color.secondary

    // Semantic status colors
    static let success     = Color.green
    static let warning     = Color.orange
    static let danger      = Color.red
    static let info        = Color.blue
}

// MARK: - Inventory Categories

enum InventoryCategory: String, CaseIterable, Codable, Identifiable {
    case electronics   = "Electronics"
    case furniture     = "Furniture"
    case tools         = "Tools"
    case office        = "Office"
    case clothing      = "Clothing"
    case food          = "Food & Beverage"
    case medical       = "Medical"
    case other         = "Other"

    var id: String { rawValue }

    /// SF Symbol name for each category
    var icon: String {
        switch self {
        case .electronics:  return "cpu"
        case .furniture:    return "sofa"
        case .tools:        return "wrench.and.screwdriver"
        case .office:       return "doc.text"
        case .clothing:     return "tshirt"
        case .food:         return "cart"
        case .medical:      return "cross.case"
        case .other:        return "archivebox"
        }
    }

    /// Color associated with each category for visual distinction
    var color: Color {
        switch self {
        case .electronics:  return .blue
        case .furniture:    return .brown
        case .tools:        return .orange
        case .office:       return .purple
        case .clothing:     return .pink
        case .food:         return .green
        case .medical:      return .red
        case .other:        return .gray
        }
    }
}

// MARK: - Low Stock Threshold

enum InventoryThreshold {
    /// Items at or below this quantity are considered "low stock"
    static let lowStock = 5
}

// MARK: - Storage Keys

enum StorageKeys {
    static let inventoryItems = "inventory_items"
}

// MARK: - AR Constants

enum ARConstants {
    static let placementDistance: Float  = 0.5   // metres in front of camera
    static let labelScale: Float         = 0.001  // RealityKit text scale factor
    static let sessionInstructions       = "Move your phone slowly to detect surfaces, then tap to place an inventory label."
}

// MARK: - UI Strings

enum Strings {
    enum Home {
        static let title           = "Dashboard"
        static let totalItems      = "Total Items"
        static let lowStock        = "Low Stock"
        static let recentlyAdded   = "Recently Added"
        static let quickActions    = "Quick Actions"
        static let addItem         = "Add Item"
        static let viewInventory   = "View Inventory"
        static let openAR          = "AR Scanner"
    }

    enum Inventory {
        static let title           = "Inventory"
        static let searchPlaceholder = "Search items..."
        static let empty           = "No items yet"
        static let emptyMessage    = "Tap 'Add Item' to get started."
        static let allCategories   = "All"
    }

    enum AddItem {
        static let title           = "Add Item"
        static let editTitle       = "Edit Item"
        static let namePlaceholder = "e.g. Office Chair"
        static let locationPlaceholder = "e.g. Warehouse A, Shelf 3"
        static let notesPlaceholder    = "Optional notes..."
        static let save            = "Save Item"
        static let update          = "Update Item"
    }

    enum Detail {
        static let quantity        = "Quantity"
        static let category        = "Category"
        static let location        = "Location"
        static let notes           = "Notes"
        static let added           = "Date Added"
        static let editButton      = "Edit"
        static let deleteButton    = "Delete"
        static let deleteConfirm   = "Are you sure you want to delete this item?"
    }

    enum AR {
        static let title           = "AR Scanner"
        static let instructions    = ARConstants.sessionInstructions
        static let unsupported     = "AR is not supported on this device."
        static let tapToPlace      = "Tap a surface to place label"
    }

    enum Settings {
        static let title           = "Settings"
        static let about           = "About"
        static let version         = "Version"
        static let clearData       = "Clear All Data"
        static let clearConfirm    = "This will permanently delete all inventory items."
    }
}
