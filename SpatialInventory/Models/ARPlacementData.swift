//
//  ARPlacementData.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  ARPlacementData.swift
//  SpatialInventory
//
//  Stores the AR world-space position and orientation of a placed inventory item.
//  Designed to be lightweight and Codable so it saves cleanly alongside the item.
//

import Foundation
import simd   // Provides SIMD math types used by ARKit and RealityKit

// MARK: - ARPlacementData Model

struct ARPlacementData: Codable, Equatable {

    // MARK: - Properties

    /// Unique ID for this placement record
    let id: UUID

    /// The ID of the inventory item this placement belongs to
    let itemID: UUID

    /// World-space position: x (right), y (up), z (forward/back) in metres
    var positionX: Float
    var positionY: Float
    var positionZ: Float

    /// Euler angles in radians representing the item's orientation
    /// We store Euler angles instead of a full matrix because they are
    /// simpler to encode/decode with Codable.
    var rotationX: Float
    var rotationY: Float
    var rotationZ: Float

    /// Optional human-readable label override for the AR marker.
    /// Defaults to the item name if nil.
    var labelOverride: String?

    /// Date when this placement was recorded
    let datePlaced: Date

    // MARK: - Computed Properties

    /// Convenience: position as a SIMD float3 vector for ARKit/RealityKit use
    var position: SIMD3<Float> {
        SIMD3<Float>(positionX, positionY, positionZ)
    }

    /// Convenience: rotation as a SIMD float3 vector (Euler angles in radians)
    var rotation: SIMD3<Float> {
        SIMD3<Float>(rotationX, rotationY, rotationZ)
    }

    /// Human-readable position string for detail views
    var positionDescription: String {
        String(format: "x: %.2f  y: %.2f  z: %.2f", positionX, positionY, positionZ)
    }

    /// Formatted placement date
    var datePlacedFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: datePlaced)
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        itemID: UUID,
        positionX: Float = 0,
        positionY: Float = 0,
        positionZ: Float = -0.5,   // Default: half a metre in front of camera
        rotationX: Float = 0,
        rotationY: Float = 0,
        rotationZ: Float = 0,
        labelOverride: String? = nil,
        datePlaced: Date = Date()
    ) {
        self.id             = id
        self.itemID         = itemID
        self.positionX      = positionX
        self.positionY      = positionY
        self.positionZ      = positionZ
        self.rotationX      = rotationX
        self.rotationY      = rotationY
        self.rotationZ      = rotationZ
        self.labelOverride  = labelOverride
        self.datePlaced     = datePlaced
    }

    // MARK: - Convenience Initializer from SIMD types
    // Used by ARSessionService when it captures a real-world hit-test result.

    init(
        itemID: UUID,
        position: SIMD3<Float>,
        rotation: SIMD3<Float> = .zero,
        labelOverride: String? = nil
    ) {
        self.init(
            itemID:        itemID,
            positionX:     position.x,
            positionY:     position.y,
            positionZ:     position.z,
            rotationX:     rotation.x,
            rotationY:     rotation.y,
            rotationZ:     rotation.z,
            labelOverride: labelOverride
        )
    }
}

// MARK: - Sample Data (for Xcode Previews)

extension ARPlacementData {

    /// A single sample placement for use in previews
    static func sample(for item: InventoryItem) -> ARPlacementData {
        ARPlacementData(
            itemID:    item.id,
            position:  SIMD3<Float>(0.1, -0.3, -0.6),
            rotation:  SIMD3<Float>(0, 0.5, 0),
            labelOverride: item.name
        )
    }
}
