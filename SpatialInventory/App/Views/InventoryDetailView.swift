//
//  InventoryDetailView.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  InventoryDetailView.swift
//  SpatialInventory
//
//  Full detail screen for a single inventory item.
//  Shows all properties, photo, AR placement data,
//  and provides edit / delete / AR place actions.
//

import SwiftUI

// MARK: - Inventory Detail View

struct InventoryDetailView: View {

    // MARK: - Dependencies

    @EnvironmentObject var viewModel: InventoryViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    /// The item passed in from the list — we look it up live from the
    /// ViewModel so edits are instantly reflected without re-navigation.
    let item: InventoryItem

    /// Live version of the item from the ViewModel (reflects edits)
    private var liveItem: InventoryItem {
        viewModel.item(for: item.id) ?? item
    }

    // MARK: - UI State

    @State private var showEditSheet     = false
    @State private var showDeleteAlert   = false
    @State private var showARScanner     = false
    @State private var showRemovePlacementAlert = false
    @State private var contentVisible    = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {

                // ── Hero image or category banner ──
                heroSection

                // ── Stock status + quick stats ──
                quickStatsSection

                // ── Item details card ──
                detailsCard

                // ── AR placement card ──
                arPlacementCard

                // ── Notes card ──
                if !liveItem.notes.isEmpty {
                    notesCard
                }

                // ── Action buttons ──
                actionButtons

                Spacer(minLength: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.sm)
        }
        .opacity(contentVisible ? 1 : 0)
        .offset(y: contentVisible ? 0 : 16)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(liveItem.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showEditSheet) {
            AddItemView(existingItem: liveItem)
        }
        .fullScreenCover(isPresented: $showARScanner) {
            ARScannerView(selectedItem: liveItem)
        }
        .alert("Delete Item", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteItem(id: liveItem.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(Strings.Detail.deleteConfirm)
        }
        .alert("Remove AR Placement", isPresented: $showRemovePlacementAlert) {
            Button("Remove", role: .destructive) {
                viewModel.removePlacement(for: liveItem.id)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove the saved AR position for \"\(liveItem.name)\".")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) {
                contentVisible = true
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {

            // Background — image or colored gradient
            if let base64 = liveItem.imageData,
               let data   = Data(base64Encoded: base64),
               let uiImg  = UIImage(data: data) {

                // Show item photo
                Image(uiImage: uiImg)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                    .overlay(
                        // Gradient overlay for text legibility
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                    )

            } else {

                // Fallback: category-colored gradient banner
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                liveItem.category.color.opacity(0.7),
                                liveItem.category.color.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: liveItem.category.icon)
                            .font(.system(size: 60, weight: .ultraLight))
                            .foregroundStyle(.white.opacity(0.3))
                    )
            }

            // Category chip overlay
            HStack {
                Label(liveItem.category.rawValue,
                      systemImage: liveItem.category.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.sm + 2)
                    .padding(.vertical, AppSpacing.xs + 1)
                    .background(.ultraThinMaterial, in: Capsule())

                Spacer()

                // AR placed indicator
                if liveItem.arPlacement != nil {
                    Label("AR Placed", systemImage: "camera.viewfinder")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.sm + 2)
                        .padding(.vertical, AppSpacing.xs + 1)
                        .background(.teal.opacity(0.8), in: Capsule())
                }
            }
            .padding(AppSpacing.md)
        }
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View {
        HStack(spacing: AppSpacing.md) {

            // Quantity tile
            QuickStatTile(
                value: "\(liveItem.quantity)",
                label: Strings.Detail.quantity,
                icon: "number.circle.fill",
                color: quantityColor
            )

            // Stock status tile
            QuickStatTile(
                value: liveItem.stockStatusLabel,
                label: "Status",
                icon: stockStatusIcon,
                color: stockStatusColor
            )

            // Date added tile
            QuickStatTile(
                value: liveItem.dateAddedShort,
                label: Strings.Detail.added,
                icon: "calendar.circle.fill",
                color: .blue
            )
        }
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        FormCard(title: "Item Details") {
            VStack(spacing: 0) {

                DetailRow(
                    icon: "tag.fill",
                    iconColor: liveItem.category.color,
                    label: Strings.Detail.category,
                    value: liveItem.category.rawValue
                )

                Divider().padding(.leading, 36)

                DetailRow(
                    icon: "mappin.circle.fill",
                    iconColor: .red,
                    label: Strings.Detail.location,
                    value: liveItem.location.isEmpty
                        ? "No location set"
                        : liveItem.location
                )

                Divider().padding(.leading, 36)

                DetailRow(
                    icon: "clock.fill",
                    iconColor: .purple,
                    label: "Last Modified",
                    value: liveItem.dateAddedFormatted
                )
            }
        }
    }

    // MARK: - AR Placement Card

    private var arPlacementCard: some View {
        FormCard(title: "AR Placement") {
            if let placement = liveItem.arPlacement {

                // Placement info
                VStack(spacing: AppSpacing.sm) {
                    DetailRow(
                        icon: "scope",
                        iconColor: .teal,
                        label: "Position",
                        value: placement.positionDescription
                    )

                    Divider().padding(.leading, 36)

                    DetailRow(
                        icon: "calendar.badge.clock",
                        iconColor: .teal,
                        label: "Placed On",
                        value: placement.datePlacedFormatted
                    )

                    // Action buttons for placed item
                    HStack(spacing: AppSpacing.sm) {
                        // Re-open AR to update placement
                        Button {
                            showARScanner = true
                        } label: {
                            Label("Update Placement", systemImage: "arrow.triangle.2.circlepath")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.teal)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm)
                                .background(.teal.opacity(0.1),
                                            in: RoundedRectangle(cornerRadius: AppRadius.sm))
                        }

                        // Remove placement
                        Button {
                            showRemovePlacementAlert = true
                        } label: {
                            Label("Remove", systemImage: "xmark.circle")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppColors.danger)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm)
                                .background(AppColors.danger.opacity(0.1),
                                            in: RoundedRectangle(cornerRadius: AppRadius.sm))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, AppSpacing.xs)
                }

            } else {

                // Not yet placed in AR
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(.teal.opacity(0.7))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Not placed in AR yet")
                            .font(AppFont.headline)
                            .foregroundStyle(AppColors.textPrimary)

                        Text("Use AR Scanner to place this item in your space.")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()

                    Button {
                        showARScanner = true
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { showARScanner = true }
            }
        }
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        FormCard(title: "Notes") {
            Text(liveItem.notes)
                .font(AppFont.body)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(Color(.systemBackground))
                )
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: AppSpacing.sm) {

            // Edit button
            PrimaryButton(
                title: Strings.Detail.editButton,
                icon: "pencil.circle.fill"
            ) {
                showEditSheet = true
            }

            // AR Scanner button
            Button {
                showARScanner = true
            } label: {
                Label(
                    liveItem.arPlacement != nil
                        ? "Update AR Placement"
                        : "Place in AR",
                    systemImage: "camera.viewfinder"
                )
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.teal)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(.teal.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .strokeBorder(.teal.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // Delete button
            PrimaryButton(
                title: Strings.Detail.deleteButton,
                icon: "trash.fill",
                isDestructive: true
            ) {
                showDeleteAlert = true
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showEditSheet = true
            } label: {
                Text(Strings.Detail.editButton)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.accent)
            }
        }
    }

    // MARK: - Computed Helpers

    private var quantityColor: Color {
        switch liveItem.stockStatusColor {
        case .good:       return AppColors.success
        case .low:        return AppColors.warning
        case .outOfStock: return AppColors.danger
        }
    }

    private var stockStatusColor: Color {
        switch liveItem.stockStatusColor {
        case .good:       return AppColors.success
        case .low:        return AppColors.warning
        case .outOfStock: return AppColors.danger
        }
    }

    private var stockStatusIcon: String {
        switch liveItem.stockStatusColor {
        case .good:       return "checkmark.circle.fill"
        case .low:        return "exclamationmark.triangle.fill"
        case .outOfStock: return "xmark.circle.fill"
        }
    }
}

// MARK: - Quick Stat Tile

private struct QuickStatTile: View {

    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(AppFont.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.sm)
        .background(AppColors.cardBg,
                    in: RoundedRectangle(cornerRadius: AppRadius.md))
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Detail Row

private struct DetailRow: View {

    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
                Text(value)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        InventoryDetailView(item: .sample)
            .environmentObject(InventoryViewModel())
    }
}

#Preview("With AR Placement") {
    NavigationStack {
        InventoryDetailView(
            item: {
                var item = InventoryItem.sample
                item.arPlacement = ARPlacementData.sample(for: item)
                return item
            }()
        )
        .environmentObject(InventoryViewModel())
    }
}
