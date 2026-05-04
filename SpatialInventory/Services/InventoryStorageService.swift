//
//  InventoryStorageService.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  InventoryStorageService.swift
//  SpatialInventory
//
//  Handles persistent storage of inventory items using JSON encoding/decoding.
//  Reads and writes a single JSON file in the app's Documents directory.
//  No View should ever call this directly — only InventoryViewModel does.
//

import Foundation

// MARK: - Storage Service

final class InventoryStorageService {

    // MARK: - Singleton

    /// Shared instance — one storage service for the whole app
    static let shared = InventoryStorageService()

    private init() {}   // Prevent external instantiation

    // MARK: - File URL

    /// The URL of the JSON file on disk where inventory items are saved
    private var fileURL: URL {
        // Documents directory persists across app launches and iCloud backups
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        return documents.appendingPathComponent("inventory_items.json")
    }

    // MARK: - Load

    /// Loads all inventory items from disk.
    /// Returns an empty array if no file exists yet (first launch).
    func load() -> [InventoryItem] {
        // If the file doesn't exist yet, return empty — not an error
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("📦 Storage: No existing data file found. Starting fresh.")
            return []
        }

        do {
            let data  = try Data(contentsOf: fileURL)
            let items = try JSONDecoder().decode([InventoryItem].self, from: data)
            print("📦 Storage: Loaded \(items.count) item(s) from disk.")
            return items
        } catch {
            print("❌ Storage: Failed to load items — \(error.localizedDescription)")
            return []   // Graceful degradation: don't crash, just start empty
        }
    }

    // MARK: - Save

    /// Saves the full array of inventory items to disk.
    /// Call this every time the array changes.
    /// - Parameter items: The complete current inventory array
    func save(_ items: [InventoryItem]) {
        do {
            let encoder        = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted   // Human-readable JSON for debugging
            let data           = try encoder.encode(items)
            try data.write(to: fileURL, options: .atomicWrite)
            // .atomicWrite writes to a temp file first, then renames —
            // this prevents data corruption if the app is killed mid-write.
            print("📦 Storage: Saved \(items.count) item(s) to disk.")
        } catch {
            print("❌ Storage: Failed to save items — \(error.localizedDescription)")
        }
    }

    // MARK: - Delete All

    /// Permanently deletes the JSON file from disk.
    /// Used by the Settings screen "Clear All Data" action.
    func deleteAll() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }

        do {
            try FileManager.default.removeItem(at: fileURL)
            print("📦 Storage: All data cleared.")
        } catch {
            print("❌ Storage: Failed to delete data — \(error.localizedDescription)")
        }
    }

    // MARK: - Debug Helpers

    /// Returns the full file path string — useful for debugging in the console
    var filePath: String {
        fileURL.path
    }

    /// Returns the size of the saved JSON file in a human-readable format
    var fileSize: String {
        guard
            FileManager.default.fileExists(atPath: fileURL.path),
            let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
            let size = attributes[.size] as? Int
        else {
            return "No file"
        }

        if size < 1024 {
            return "\(size) bytes"
        } else {
            return String(format: "%.1f KB", Double(size) / 1024)
        }
    }
}
