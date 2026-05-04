//
//  InventoryCardView.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  InventoryCardView.swift
//  SpatialInventory
//
//  Reusable card component for displaying a single inventory item.
//  Shows name, category, quantity, location, and stock status badge.
//  Used in InventoryListView and the HomeView dashboard.
//

import SwiftUI

// MARK: - Inventory Card View

struct InventoryCardView: View {

    // MARK: - Properties

    let item: InventoryItem

    /// When true, shows a compact single-line layout (used in dashboard)
    var compact: Bool = false

    // MARK: - Body

    var body: some View {
        if compact {
            compactCard
        } else {
            fullCard
        }
    }

    // MARK: - Full Card (Inventory List)

    private var fullCard: some View {
        HStack(spacing: AppSpacing.md) {

            // Category color bar on the left edge
            RoundedRectangle(cornerRadius: 3)
                .fill(item.category.color)
                .frame(width: 4)
                .padding(.vertical, AppSpacing.xs)

            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(item.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: item.category.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(item.category.color)
            }

            // Item info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // Name + stock badge row
                HStack(alignment: .center, spacing: AppSpacing.sm) {
                    Text(item.name)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    StockBadge(status: item.stockStatusColor, label: item.stockStatusLabel)
                }

                // Category label
                Text(item.category.rawValue)
                    .font(AppFont.caption)
                    .foregroundStyle(item.category.color)

                // Location + quantity row
                HStack(spacing: AppSpacing.md) {
                    if !item.location.isEmpty {
                        Label {
                            Text(item.location)
                                .lineLimit(1)
                        } icon: {
                            Image(systemName: "mappin.circle.fill")
                        }
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()

                    // Quantity pill
                    HStack(spacing: 3) {
                        Image(systemName: "number")
                            .font(.caption2)
                        Text("\(item.quantity)")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(quantityColor)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, 3)
                    .background(quantityColor.opacity(0.12), in: Capsule())
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBg, in: RoundedRectangle(cornerRadius: AppRadius.card))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Compact Card (Dashboard)

    private var compactCard: some View {
        HStack(spacing: AppSpacing.sm) {

            // Small category icon
            ZStack {
                Circle()
                    .fill(item.category.color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: item.category.icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(item.category.color)
            }

            // Name and location
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text(item.location.isEmpty ? item.category.rawValue : item.location)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Quantity + stock status
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(item.quantity)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(quantityColor)

                Text("units")
                    .font(AppFont.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.sm + 2)
        .background(AppColors.cardBg, in: RoundedRectangle(cornerRadius: AppRadius.md))
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }

    // MARK: - Helpers

    /// Color for the quantity display based on stock status
    private var quantityColor: Color {
        switch item.stockStatusColor {
        case .good:       return AppColors.success
        case .low:        return AppColors.warning
        case .outOfStock: return AppColors.danger
        }
    }
}

// MARK: - Stock Badge Component

/// Small colored pill badge showing stock status
struct StockBadge: View {

    let status: StockStatus
    let label: String

    private var badgeColor: Color {
        switch status {
        case .good:       return AppColors.success
        case .low:        return AppColors.warning
        case .outOfStock: return AppColors.danger
        }
    }

    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(badgeColor)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(badgeColor.opacity(0.12), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(badgeColor.opacity(0.3), lineWidth: 0.5)
            )
    }
}

// MARK: - Preview

#Preview("Full Card") {
    VStack(spacing: AppSpacing.md) {
        ForEach(InventoryItem.sampleItems.prefix(3)) { item in
            InventoryCardView(item: item)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Compact Card") {
    VStack(spacing: AppSpacing.sm) {
        ForEach(InventoryItem.sampleItems.prefix(4)) { item in
            InventoryCardView(item: item, compact: true)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
