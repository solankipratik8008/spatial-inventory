//
//  SpatialInventoryApp.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  SpatialInventoryApp.swift
//  SpatialInventory
//
//  Entry point for the Spatial Inventory Management AR App.
//  Sets up the app lifecycle and injects shared state into the view hierarchy.
//

import SwiftUI

@main
struct SpatialInventoryApp: App {

    // MARK: - Shared State

    /// The central ViewModel shared across all views via the environment.
    /// Created once here at the app level so inventory data persists across navigation.
    @StateObject private var inventoryViewModel = InventoryViewModel()

    // MARK: - App Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject the shared ViewModel into the environment so any
                // child view can access it with @EnvironmentObject.
                .environmentObject(inventoryViewModel)
        }
    }
}
