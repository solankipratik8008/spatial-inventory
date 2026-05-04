//
//  ARInventoryViewModel.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  ARInventoryViewModel.swift
//  SpatialInventory
//
//  Manages the ARKit + RealityKit session for the AR scanner screen.
//  Handles surface detection via raycasting, floating label creation,
//  tap-to-place logic, and placement data capture.
//  Uses @Observable so ARScannerView can observe it directly.
//

import Foundation
import ARKit
import RealityKit
import SwiftUI
import Combine

// MARK: - AR Inventory ViewModel

@Observable
final class ARInventoryViewModel: NSObject {

    // MARK: - Properties

    /// The inventory item currently selected for AR placement
    var selectedItem: InventoryItem? {
        didSet { updateLabelIfNeeded() }
    }

    /// True when a valid surface has been detected under the reticle
    var isSurfaceDetected = false

    // MARK: - Callbacks (SwiftUI layer listens to these)

    /// Fires when surface detection status changes
    var onSurfaceDetected: ((Bool) -> Void)?

    /// Fires when an item is successfully placed in AR space
    var onItemPlaced: ((InventoryItem, ARPlacementData) -> Void)?

    // MARK: - Private AR Properties

    private weak var arView: ARView?

    /// The anchor holding the preview reticle (placement guide)
    private var reticleAnchor: AnchorEntity?

    /// All placed label anchors — keyed by item ID
    private var placedAnchors: [UUID: AnchorEntity] = [:]

    /// Timer that updates the reticle position continuously
    private var updateTimer: Timer?

    /// Last valid world transform from raycasting
    private var lastValidTransform: simd_float4x4?

    // MARK: - Setup

    /// Called by ARViewContainer after the ARView is created
    func setup(arView: ARView) {
        self.arView = arView
        configureSession(arView: arView)
        startReticleUpdates()
    }

    // MARK: - Session Configuration

    private func configureSession(arView: ARView) {
        let config = ARWorldTrackingConfiguration()

        // Enable horizontal plane detection for surface finding
        config.planeDetection = [.horizontal]

        // Enable environment texturing for more realistic label rendering
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }

        arView.session.delegate = self

        // Run with reset to start fresh
        arView.session.run(
            config,
            options: [.resetTracking, .removeExistingAnchors]
        )

        // Subtle coaching overlay helps users find surfaces faster
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session   = arView.session
        coachingOverlay.goal      = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.addSubview(coachingOverlay)

        // Disable default AR debug visualizations for clean look
        arView.debugOptions = []
        arView.renderOptions = [.disableMotionBlur]
    }

    // MARK: - Reticle Updates

    /// Starts a timer that casts a ray every frame to find surfaces
    private func startReticleUpdates() {
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / 30.0,   // 30fps reticle updates
            repeats: true
        ) { [weak self] _ in
            self?.updateReticle()
        }
    }

    private func updateReticle() {
        guard let arView else { return }

        // Cast ray from screen center toward the world
        let screenCenter = CGPoint(
            x: arView.bounds.midX,
            y: arView.bounds.midY
        )

        let results = arView.raycast(
            from: screenCenter,
            allowing: .estimatedPlane,
            alignment: .horizontal
        )

        if let result = results.first {
            // Surface found — update reticle position
            lastValidTransform = result.worldTransform
            showReticle(at: result.worldTransform)

            if !isSurfaceDetected {
                isSurfaceDetected = true
                DispatchQueue.main.async {
                    self.onSurfaceDetected?(true)
                }
            }

        } else {
            // No surface — hide reticle
            hideReticle()

            if isSurfaceDetected {
                isSurfaceDetected = false
                DispatchQueue.main.async {
                    self.onSurfaceDetected?(false)
                }
            }
        }
    }

    // MARK: - Reticle Entity

    private func showReticle(at transform: simd_float4x4) {
        guard let arView else { return }

        if reticleAnchor == nil {
            // Build the reticle once
            let anchor = AnchorEntity(world: transform)
            anchor.addChild(makeReticleEntity())
            arView.scene.addAnchor(anchor)
            reticleAnchor = anchor
        } else {
            // Move existing reticle
            reticleAnchor?.setTransformMatrix(transform, relativeTo: nil)
        }

        reticleAnchor?.isEnabled = true
    }

    private func hideReticle() {
        reticleAnchor?.isEnabled = false
    }

    /// Creates a flat ring reticle mesh to guide placement
    private func makeReticleEntity() -> ModelEntity {
        // Thin flat cylinder as a placement ring
        let mesh = MeshResource.generateCylinder(height: 0.002, radius: 0.08)
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor.systemBlue.withAlphaComponent(0.6))
        material.roughness = 1.0
        material.metallic  = 0.0
        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }

    // MARK: - Tap to Place

    /// Called when the user taps the AR view
    func handleTap(at screenPoint: CGPoint) {
        guard let arView,
              let item = selectedItem else { return }

        // Raycast from tap location
        let results = arView.raycast(
            from: screenPoint,
            allowing: .estimatedPlane,
            alignment: .horizontal
        )

        if let result = results.first {
            placeLabel(for: item, at: result.worldTransform)
        } else if let lastTransform = lastValidTransform {
            // Fallback: use last known good surface position
            placeLabel(for: item, at: lastTransform)
        }
    }

    /// Places label at the current screen center — used by the "Place Here" button
    func placeAtCenter() {
        guard let arView,
              let item = selectedItem,
              let transform = lastValidTransform else { return }
        placeLabel(for: item, at: transform)
    }

    // MARK: - Label Placement

    private func placeLabel(for item: InventoryItem, at transform: simd_float4x4) {
        guard let arView else { return }

        // Remove previous label for this item if it exists
        if let existing = placedAnchors[item.id] {
            arView.scene.removeAnchor(existing)
        }

        // Create label anchor at world position
        let anchor = AnchorEntity(world: transform)

        // Build the label entity
        let labelEntity = makeLabelEntity(for: item)
        anchor.addChild(labelEntity)

        arView.scene.addAnchor(anchor)
        placedAnchors[item.id] = anchor

        // Capture placement data
        let position = SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )

        let placement = ARPlacementData(
            itemID:   item.id,
            position: position
        )

        // Notify SwiftUI layer
        DispatchQueue.main.async {
            self.onItemPlaced?(item, placement)
        }

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    // MARK: - Label Entity Builder

    /// Creates a floating inventory label card using RealityKit entities
    private func makeLabelEntity(for item: InventoryItem) -> Entity {
        let container = Entity()

        // ── Background card ──
        let cardWidth: Float  = 0.18
        let cardHeight: Float = 0.10

        let cardMesh = MeshResource.generatePlane(
            width: cardWidth,
            height: cardHeight,
            cornerRadius: 0.012
        )

        var cardMaterial = SimpleMaterial()
        cardMaterial.color = .init(
            tint: UIColor.systemBackground.withAlphaComponent(0.92)
        )
        cardMaterial.roughness = 0.8

        let cardEntity = ModelEntity(mesh: cardMesh, materials: [cardMaterial])
        // Lift card slightly off the surface
        cardEntity.position = SIMD3<Float>(0, 0.001, 0)
        // Rotate flat on the surface
        cardEntity.orientation = simd_quatf(
            angle: -.pi / 2,
            axis: SIMD3<Float>(1, 0, 0)
        )
        container.addChild(cardEntity)

        // ── Item name text ──
        let nameText = buildTextEntity(
            text: item.name,
            fontSize: 0.014,
            color: .label,
            isBold: true
        )
        nameText.position = SIMD3<Float>(-cardWidth / 2 + 0.012, 0.002, -0.008)
        container.addChild(nameText)

        // ── Category label ──
        let categoryText = buildTextEntity(
            text: item.category.rawValue,
            fontSize: 0.010,
            color: .secondaryLabel,
            isBold: false
        )
        categoryText.position = SIMD3<Float>(-cardWidth / 2 + 0.012, 0.002, 0.008)
        container.addChild(categoryText)

        // ── Quantity badge ──
        let qtyText = buildTextEntity(
            text: "Qty: \(item.quantity)",
            fontSize: 0.010,
            color: item.isLowStock ? .systemOrange : .systemGreen,
            isBold: true
        )
        qtyText.position = SIMD3<Float>(-cardWidth / 2 + 0.012, 0.002, 0.024)
        container.addChild(qtyText)

        // ── Vertical stem (card stands up from surface) ──
        let stemMesh = MeshResource.generateBox(
            size: SIMD3<Float>(0.003, 0.04, 0.003),
            cornerRadius: 0.001
        )
        var stemMaterial = SimpleMaterial()
        stemMaterial.color = .init(tint: UIColor.systemBlue.withAlphaComponent(0.8))

        let stemEntity = ModelEntity(mesh: stemMesh, materials: [stemMaterial])
        stemEntity.position = SIMD3<Float>(0, 0.02, 0)
        container.addChild(stemEntity)

        return container
    }

    /// Builds a RealityKit text mesh entity
    private func buildTextEntity(
        text: String,
        fontSize: Float,
        color: UIColor,
        isBold: Bool
    ) -> ModelEntity {

        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: isBold
                ? .boldSystemFont(ofSize: CGFloat(fontSize))
                : .systemFont(ofSize: CGFloat(fontSize)),
            containerFrame: .zero,
            alignment: .left,
            lineBreakMode: .byTruncatingTail
        )

        var material = SimpleMaterial()
        material.color = .init(tint: color.withAlphaComponent(0.95))

        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Rotate text to face up (RealityKit text faces the camera by default)
        entity.orientation = simd_quatf(
            angle: -.pi / 2,
            axis: SIMD3<Float>(1, 0, 0)
        )

        return entity
    }

    // MARK: - Label Updates

    /// Rebuilds the label if the selected item changes while AR is active
    private func updateLabelIfNeeded() {
        guard let item = selectedItem,
              let anchor = placedAnchors[item.id],
              let arView else { return }

        // Remove and re-add updated label
        arView.scene.removeAnchor(anchor)
        placedAnchors.removeValue(forKey: item.id)
    }

    // MARK: - Session Control

    /// Pauses the AR session — called when the view disappears
    func pauseSession() {
        updateTimer?.invalidate()
        updateTimer = nil
        arView?.session.pause()
    }
}

// MARK: - ARSessionDelegate

extension ARInventoryViewModel: ARSessionDelegate {

    /// Called when tracking state changes — useful for showing warnings
    func session(
        _ session: ARSession,
        cameraDidChangeTrackingState camera: ARCamera
    ) {
        switch camera.trackingState {
        case .normal:
            print("🟢 AR Tracking: Normal")
        case .limited(let reason):
            print("🟡 AR Tracking: Limited — \(reason)")
        case .notAvailable:
            print("🔴 AR Tracking: Not Available")
        @unknown default:
            break
        }
    }

    /// Called when the session fails — attempt recovery
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("❌ AR Session failed: \(error.localizedDescription)")

        // Attempt to restart the session
        guard let arView else { return }
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(
            config,
            options: [.resetTracking, .removeExistingAnchors]
        )
    }

    /// Called when the session is interrupted (e.g. phone call)
    func sessionWasInterrupted(_ session: ARSession) {
        print("⚠️ AR Session interrupted")
    }

    /// Called when interruption ends — reset for reliability
    func sessionInterruptionEnded(_ session: ARSession) {
        print("✅ AR Session interruption ended — resetting")
        guard let arView else { return }
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(
            config,
            options: [.resetTracking, .removeExistingAnchors]
        )
    }
}
