//
//  ARScannerView.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  ARScannerView.swift
//  SpatialInventory
//
//  AR camera screen using ARKit + RealityKit.
//  Detects horizontal surfaces, lets the user tap to place an inventory
//  label in real-world space, and saves the placement to the ViewModel.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

// MARK: - AR Scanner View

struct ARScannerView: View {

    // MARK: - Dependencies

    @EnvironmentObject var viewModel: InventoryViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    /// The inventory item to place in AR (optional — if nil, user picks from a list)
    var selectedItem: InventoryItem?

    // MARK: - State

    @State private var arViewModel = ARInventoryViewModel()
    @State private var showItemPicker    = false
    @State private var placedItem: InventoryItem? = nil
    @State private var showPlacedBanner  = false
    @State private var instructionText   = ARConstants.sessionInstructions
    @State private var surfaceDetected   = false

    // MARK: - Body

    var body: some View {
        ZStack {

            // ── AR View (full screen camera) ──
            ARViewContainer(arViewModel: arViewModel)
                .ignoresSafeArea()
                .onTapGesture { location in
                    handleTap(at: location)
                }

            // ── UI overlay ──
            VStack {

                // Top bar
                topBar

                Spacer()

                // Surface detection indicator
                if surfaceDetected {
                    surfaceDetectedPill
                }

                // Placed banner
                if showPlacedBanner {
                    placedSuccessBanner
                }

                // Bottom instruction panel
                bottomPanel
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        // Item picker sheet — shown when no item was pre-selected
        .sheet(isPresented: $showItemPicker) {
            ItemPickerSheet(
                items: viewModel.items,
                onSelect: { item in
                    arViewModel.selectedItem = item
                    showItemPicker = false
                }
            )
        }
        .onAppear {
            // If an item was passed in, set it immediately
            if let item = selectedItem {
                arViewModel.selectedItem = item
            } else {
                // No item passed — prompt user to pick one
                showItemPicker = true
            }

            // Listen for surface detection updates
            arViewModel.onSurfaceDetected = { detected in
                withAnimation { surfaceDetected = detected }
                instructionText = detected
                    ? "Surface detected! Tap to place \(arViewModel.selectedItem?.name ?? "label")."
                    : ARConstants.sessionInstructions
            }

            // Listen for placement events
            arViewModel.onItemPlaced = { item, placement in
                viewModel.savePlacement(placement, for: item.id)
                placedItem = item
                withAnimation { showPlacedBanner = true }
                // Auto-hide banner after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { showPlacedBanner = false }
                }
            }
        }
        .onDisappear {
            arViewModel.pauseSession()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Close button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
            }

            Spacer()

            // Title
            Text(Strings.AR.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(radius: 4)

            Spacer()

            // Item picker button
            Button {
                showItemPicker = true
            } label: {
                Image(systemName: "list.bullet.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
            }
        }
    }

    // MARK: - Surface Detected Pill

    private var surfaceDetectedPill: some View {
        HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(AppColors.success)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(AppColors.success.opacity(0.4), lineWidth: 4)
                        .scaleEffect(1.5)
                )

            Text("Surface Detected")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Placed Success Banner

    private var placedSuccessBanner: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColors.success)

            VStack(alignment: .leading, spacing: 2) {
                Text("Label Placed!")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                if let name = placedItem?.name {
                    Text("\"\(name)\" saved to AR space.")
                        .font(AppFont.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Spacer()

            Button {
                withAnimation { showPlacedBanner = false }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(AppSpacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Bottom Panel

    private var bottomPanel: some View {
        VStack(spacing: AppSpacing.md) {

            // Selected item chip
            if let item = arViewModel.selectedItem {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: item.category.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(item.category.color)

                    Text(item.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer()

                    Text("Qty: \(item.quantity)")
                        .font(AppFont.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
            }

            // Instruction text
            Text(instructionText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(radius: 3)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: AppRadius.md))

            // Place button (alternative to tapping the AR view)
            if surfaceDetected && arViewModel.selectedItem != nil {
                Button {
                    arViewModel.placeAtCenter()
                } label: {
                    Label("Place Label Here", systemImage: "plus.viewfinder")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.accent, in: RoundedRectangle(cornerRadius: AppRadius.md))
                        .shadow(color: AppColors.accent.opacity(0.5), radius: 8, x: 0, y: 4)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: surfaceDetected)
    }

    // MARK: - Tap Handler

    private func handleTap(at location: CGPoint) {
        guard arViewModel.selectedItem != nil else {
            showItemPicker = true
            return
        }
        arViewModel.handleTap(at: location)
    }
}

// MARK: - AR View Container (UIViewRepresentable)

/// Wraps RealityKit's ARView into SwiftUI
struct ARViewContainer: UIViewRepresentable {

    let arViewModel: ARInventoryViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arViewModel.setup(arView: arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Updates handled by arViewModel directly
    }
}

// MARK: - Item Picker Sheet

/// Sheet shown when the user hasn't pre-selected an item for AR placement
struct ItemPickerSheet: View {

    let items: [InventoryItem]
    let onSelect: (InventoryItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredItems: [InventoryItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    EmptyStateView(
                        icon: "archivebox",
                        title: "No Items Yet",
                        message: "Add inventory items first, then place them in AR."
                    )
                } else {
                    List(filteredItems) { item in
                        Button {
                            onSelect(item)
                        } label: {
                            HStack(spacing: AppSpacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(item.category.color.opacity(0.15))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: item.category.icon)
                                        .font(.system(size: 15))
                                        .foregroundStyle(item.category.color)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(AppFont.headline)
                                        .foregroundStyle(AppColors.textPrimary)
                                    Text(item.category.rawValue)
                                        .font(AppFont.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }

                                Spacer()

                                // AR placed indicator
                                if item.arPlacement != nil {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.caption)
                                        .foregroundStyle(.teal)
                                }

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppColors.textSecondary.opacity(0.4))
                            }
                            .padding(.vertical, AppSpacing.xs)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search items...")
                }
            }
            .navigationTitle("Select Item to Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ARScannerView(selectedItem: .sample)
        .environmentObject(InventoryViewModel())
}
