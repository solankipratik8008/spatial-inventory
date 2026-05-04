//
//  InventoryItem.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  InventoryItem.swift
//  SpatialInventory
//
//  The core data model representing a single inventory item.
//  Conforms to Codable (JSON storage), Identifiable (SwiftUI lists),
//  and Equatable (change detection).
//

import Foundation

// MARK: - InventoryItem Model

struct InventoryItem: Identifiable, Codable, Equatable {

    // MARK: - Properties

    /// Unique identifier — auto-generated on creation
    let id: UUID

    /// Display name of the item
    var name: String

    /// Category from the predefined list in Constants
    var category: InventoryCategory

    /// How many units are in stock
    var quantity: Int

    /// Physical location description (e.g. "Warehouse A, Shelf 3")
    var location: String

    /// Optional extra notes about the item
    var notes: String

    /// Date the item was first added to the inventory
    let dateAdded: Date

    /// Date the item was last modified
    var dateModified: Date

    /// Optional base64-encoded image string (photo of the item)
    /// Stored as a String so it survives JSON encoding without extra work
    var imageData: String?

    /// Optional AR placement data — where this item was placed in AR space
    var arPlacement: ARPlacementData?

    // MARK: - Computed Properties

    /// True when quantity is at or below the low-stock threshold defined in Constants
    var isLowStock: Bool {
        quantity <= InventoryThreshold.lowStock
    }

    /// True when the item has no units remaining
    var isOutOfStock: Bool {
        quantity == 0
    }

    /// Human-readable relative date string for display
    var dateAddedFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: dateAdded, relativeTo: Date())
    }

    /// Short formatted date for detail views
    var dateAddedShort: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dateAdded)
    }

    /// Stock status label used in UI badges
    var stockStatusLabel: String {
        if isOutOfStock { return "Out of Stock" }
        if isLowStock   { return "Low Stock" }
        return "In Stock"
    }

    /// Color name for stock status badge — maps to AppColors
    var stockStatusColor: StockStatus {
        if isOutOfStock { return .outOfStock }
        if isLowStock   { return .low }
        return .good
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        name: String,
        category: InventoryCategory = .other,
        quantity: Int = 0,
        location: String = "",
        notes: String = "",
        dateAdded: Date = Date(),
        dateModified: Date = Date(),
        imageData: String? = nil,
        arPlacement: ARPlacementData? = nil
    ) {
        self.id           = id
        self.name         = name
        self.category     = category
        self.quantity     = quantity
        self.location     = location
        self.notes        = notes
        self.dateAdded    = dateAdded
        self.dateModified = dateModified
        self.imageData    = imageData
        self.arPlacement  = arPlacement
    }
}

// MARK: - Stock Status Enum

/// Represents the three possible stock states for color-coding in the UI
enum StockStatus {
    case good
    case low
    case outOfStock

    var label: String {
        switch self {
        case .good:       return "In Stock"
        case .low:        return "Low Stock"
        case .outOfStock: return "Out of Stock"
        }
    }
}

// MARK: - Sample Data (for Xcode Previews)

extension InventoryItem {

    /// A collection of realistic sample items used in SwiftUI previews.
    /// These never appear in the real app — only in the canvas.
    static let sampleItems: [InventoryItem] = [
        InventoryItem(
            name: "MacBook Pro 14\"",
            category: .electronics,
            quantity: 3,
            location: "IT Closet, Shelf A",
            notes: "M3 Pro models. Assigned to design team.",
            dateAdded: Date().addingTimeInterval(-86400 * 10)
        ),
        InventoryItem(
            name: "Standing Desk",
            category: .furniture,
            quantity: 2,
            location: "Warehouse B",
            notes: "Electric height-adjustable. Assembly required.",
            dateAdded: Date().addingTimeInterval(-86400 * 5)
        ),
        InventoryItem(
            name: "First Aid Kit",
            category: .medical,
            quantity: 4,
            location: "Break Room Cabinet",
            notes: "Check expiry dates quarterly.",
            dateAdded: Date().addingTimeInterval(-86400 * 20)
        ),
        InventoryItem(
            name: "Wireless Mouse",
            category: .electronics,
            quantity: 1,
            location: "IT Closet, Drawer 2",
            notes: "Low on stock — reorder soon.",
            dateAdded: Date().addingTimeInterval(-86400 * 2)
        ),
        InventoryItem(
            name: "Ergonomic Chair",
            category: .furniture,
            quantity: 0,
            location: "Storage Room C",
            notes: "Out of stock. Order placed.",
            dateAdded: Date().addingTimeInterval(-86400 * 30)
        ),
        InventoryItem(
            name: "Drill Set",
            category: .tools,
            quantity: 5,
            location: "Maintenance Bay",
            notes: "Cordless. Includes 3 battery packs.",
            dateAdded: Date().addingTimeInterval(-86400 * 7)
        )
    ]

    /// Single sample item — useful for single-item previews
    static let sample = sampleItems[0]
}
