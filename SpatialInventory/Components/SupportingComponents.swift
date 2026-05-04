//
//  SupportingComponents.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  SupportingComponents.swift
//  SpatialInventory
//
//  Contains three small reusable UI components:
//  - PrimaryButton: Main action button used throughout the app
//  - CategoryChipView: Filter chip for category selection
//  - EmptyStateView: Friendly UI shown when a list has no content
//

import SwiftUI

// MARK: - ─────────────────────────────────────────
// MARK: Primary Button
// MARK: ─────────────────────────────────────────

/// The app's standard full-width action button.
/// Supports a loading state and an optional SF Symbol icon.
struct PrimaryButton: View {

    // MARK: Properties

    let title: String
    var icon: String?          // Optional SF Symbol name
    var isLoading: Bool = false
    var isDestructive: Bool = false
    let action: () -> Void

    // MARK: Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {

                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                isDestructive ? AppColors.danger : AppColors.accent,
                in: RoundedRectangle(cornerRadius: AppRadius.md)
            )
            // Subtle press animation
            .scaleEffect(isLoading ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isLoading)
        }
        .disabled(isLoading)
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Category Chip View
// MARK: ─────────────────────────────────────────

/// A selectable filter chip representing one inventory category.
/// Shows the category icon + label. Highlights when selected.
struct CategoryChipView: View {

    // MARK: Properties

    let category: InventoryCategory
    let isSelected: Bool
    let onTap: () -> Void

    // MARK: Body

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 12, weight: .medium))

                Text(category.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? .white : category.color)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                isSelected
                    ? category.color
                    : category.color.opacity(0.12),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.clear : category.color.opacity(0.3),
                        lineWidth: 0.5
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

/// An "All" chip shown before the category chips — resets the filter.
struct AllCategoryChip: View {

    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(Strings.Inventory.allCategories)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    isSelected
                        ? AppColors.accent
                        : AppColors.chipBg,
                    in: Capsule()
                )
                .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Empty State View
// MARK: ─────────────────────────────────────────

/// Friendly empty state shown when a list has no content.
/// Supports customizable icon, title, message, and an optional action button.
struct EmptyStateView: View {

    // MARK: Properties

    let icon: String
    let title: String
    let message: String

    /// Optional CTA button below the message
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil

    // MARK: Body

    var body: some View {
        VStack(spacing: AppSpacing.lg) {

            // Animated icon
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.1))
                    .frame(width: 90, height: 90)

                Image(systemName: icon)
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(AppColors.accent.opacity(0.7))
            }

            // Text content
            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppFont.title)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }

            // Optional action button
            if let buttonTitle, let buttonAction {
                PrimaryButton(
                    title: buttonTitle,
                    icon: "plus",
                    action: buttonAction
                )
                .frame(maxWidth: 220)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Stat Card (Dashboard use)
// MARK: ─────────────────────────────────────────

/// A small metric card for the home screen dashboard.
/// Shows an icon, a number value, and a label.
struct StatCard: View {

    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {

            // Icon badge
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(color.opacity(0.15))
                    .frame(width: 38, height: 38)

                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(color)
            }

            Spacer()

            // Value
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            // Label
            Text(label)
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(AppColors.cardBg, in: RoundedRectangle(cornerRadius: AppRadius.card))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Section Header
// MARK: ─────────────────────────────────────────

/// Consistent section header used across all screens.
struct SectionHeader: View {

    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Primary Button") {
    VStack(spacing: AppSpacing.md) {
        PrimaryButton(title: "Save Item", icon: "checkmark") { }
        PrimaryButton(title: "Saving...", isLoading: true) { }
        PrimaryButton(title: "Delete Item", icon: "trash", isDestructive: true) { }
    }
    .padding()
}

#Preview("Category Chips") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: AppSpacing.sm) {
            AllCategoryChip(isSelected: true) { }
            ForEach(InventoryCategory.allCases) { category in
                CategoryChipView(
                    category: category,
                    isSelected: category == .electronics
                ) { }
            }
        }
        .padding()
    }
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "archivebox",
        title: Strings.Inventory.empty,
        message: Strings.Inventory.emptyMessage,
        buttonTitle: "Add Your First Item",
        buttonAction: { }
    )
}

#Preview("Stat Cards") {
    HStack(spacing: AppSpacing.md) {
        StatCard(icon: "archivebox.fill", value: "24",
                 label: "Total Items", color: .blue)
        StatCard(icon: "exclamationmark.triangle.fill", value: "3",
                 label: "Low Stock", color: .orange)
    }
    .padding()
}
