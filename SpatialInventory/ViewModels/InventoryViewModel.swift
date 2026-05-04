//
//  InventoryViewModel.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  InventoryViewModel.swift
//  SpatialInventory
//
//  The central ViewModel for the entire app.
//  Owns the inventory data, handles all CRUD operations,
//  and exposes filtered/computed properties for Views to observe.
//

import Foundation
import Combine

// MARK: - InventoryViewModel

final class InventoryViewModel: ObservableObject {

    // MARK: - Published Properties
    // Any View observing this ViewModel will re-render when these change.

    /// The full unfiltered list of inventory items loaded from disk
    @Published private(set) var items: [InventoryItem] = []

    /// Current search query typed by the user
    @Published var searchQuery: String = ""

    /// Currently selected category filter (nil = show all)
    @Published var selectedCategory: InventoryCategory? = nil

    /// True while a save/load operation is in progress
    @Published var isLoading: Bool = false

    /// Holds any error message to surface in the UI
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies

    private let storage = InventoryStorageService.shared

    // MARK: - Initializer

    init() {
        loadItems()
    }

    // MARK: - Computed: Filtered Items
    // This is what list views display — always derived from `items` + active filters.

    var filteredItems: [InventoryItem] {
        items.filter { item in
            matchesSearch(item) && matchesCategory(item)
        }
    }

    private func matchesSearch(_ item: InventoryItem) -> Bool {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            return true   // Empty query matches everything
        }
        let query = searchQuery.lowercased()
        return item.name.lowercased().contains(query)
            || item.location.lowercased().contains(query)
            || item.notes.lowercased().contains(query)
            || item.category.rawValue.lowercased().contains(query)
    }

    private func matchesCategory(_ item: InventoryItem) -> Bool {
        guard let category = selectedCategory else {
            return true   // No filter selected — show all
        }
        return item.category == category
    }

    // MARK: - Computed: Dashboard Stats

    /// Total number of items in inventory
    var totalItemCount: Int {
        items.count
    }

    /// Number of items at or below the low-stock threshold
    var lowStockCount: Int {
        items.filter { $0.isLowStock }.count
    }

    /// Items sorted by dateAdded descending — newest first
    var recentItems: [InventoryItem] {
        items
            .sorted { $0.dateAdded > $1.dateAdded }
            .prefix(5)
            .map { $0 }   // Convert ArraySlice → Array
    }

    /// Low stock items for the dashboard warning list
    var lowStockItems: [InventoryItem] {
        items
            .filter { $0.isLowStock }
            .sorted { $0.quantity < $1.quantity }
    }

    /// True if there are no items at all
    var isEmpty: Bool {
        items.isEmpty
    }

    /// True if the filtered result is empty but the full list is not
    var isFilteredEmpty: Bool {
        filteredItems.isEmpty && !items.isEmpty
    }

    // MARK: - CRUD: Create

    /// Adds a new item to the inventory and saves to disk.
    /// - Parameter item: A fully constructed InventoryItem
    func addItem(_ item: InventoryItem) {
        items.append(item)
        saveItems()
        print("✅ Added item: \(item.name)")
    }

    // MARK: - CRUD: Update

    /// Updates an existing item in place and saves to disk.
    /// Matches by ID so even if the name changed, the right item is updated.
    /// - Parameter updated: The modified InventoryItem (must have same id)
    func updateItem(_ updated: InventoryItem) {
        guard let index = items.firstIndex(where: { $0.id == updated.id }) else {
            print("⚠️ Update failed: item not found — \(updated.id)")
            return
        }

        var newItem = updated
        newItem.dateModified = Date()   // Stamp the modification time
        items[index] = newItem
        saveItems()
        print("✅ Updated item: \(updated.name)")
    }

    // MARK: - CRUD: Delete

    /// Deletes a single item by ID and saves to disk.
    /// - Parameter id: The UUID of the item to remove
    func deleteItem(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            print("⚠️ Delete failed: item not found — \(id)")
            return
        }
        let name = items[index].name
        items.remove(at: index)
        saveItems()
        print("🗑 Deleted item: \(name)")
    }

    /// Deletes items using SwiftUI's onDelete IndexSet
    /// (used with List's .onDelete modifier)
    func deleteItems(at offsets: IndexSet) {
        // Map offsets from filteredItems back to the real items array
        let idsToDelete = offsets.map { filteredItems[$0].id }
        items.removeAll { idsToDelete.contains($0.id) }
        saveItems()
    }

    // MARK: - CRUD: Clear All

    /// Removes every item and wipes the JSON file from disk.
    /// Called from the Settings screen.
    func clearAllData() {
        items.removeAll()
        storage.deleteAll()
        print("🗑 All inventory data cleared.")
    }

    // MARK: - AR Placement

    /// Saves AR placement data onto an existing inventory item.
    /// - Parameters:
    ///   - itemID: The ID of the item being placed in AR
    ///   - placement: The ARPlacementData captured from the AR session
    func savePlacement(_ placement: ARPlacementData, for itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].arPlacement = placement
        items[index].dateModified = Date()
        saveItems()
        print("📍 AR placement saved for: \(items[index].name)")
    }

    /// Removes the AR placement from an item (un-places it from AR space)
    func removePlacement(for itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].arPlacement = nil
        items[index].dateModified = Date()
        saveItems()
        print("📍 AR placement removed for: \(items[index].name)")
    }

    // MARK: - Filter Helpers

    /// Clears both search query and category filter
    func resetFilters() {
        searchQuery = ""
        selectedCategory = nil
    }

    /// Returns true if any filter is currently active
    var hasActiveFilter: Bool {
        !searchQuery.isEmpty || selectedCategory != nil
    }

    // MARK: - Item Lookup

    /// Finds and returns a single item by ID (optional — returns nil if not found)
    func item(for id: UUID) -> InventoryItem? {
        items.first { $0.id == id }
    }

    // MARK: - Private: Persistence

    /// Loads items from disk into the published `items` array
    private func loadItems() {
        isLoading = true
        // Slight async delay so the loading state is visible on first launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            self.items = self.storage.load()
            self.isLoading = false
        }
    }

    /// Saves the current items array to disk
    private func saveItems() {
        storage.save(items)
    }
}
