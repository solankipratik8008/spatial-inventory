//
//  Extensions.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  Extensions.swift
//  SpatialInventory
//
//  Project-wide Swift extensions.
//  Covers View modifiers, Color utilities, Date formatting,
//  String helpers, and Array conveniences.
//  No imports beyond SwiftUI and Foundation are needed here.
//

import SwiftUI
import Foundation

// MARK: - ─────────────────────────────────────────
// MARK: View Extensions
// MARK: ─────────────────────────────────────────

extension View {

    // MARK: Conditional Modifier

    /// Applies a modifier only when a condition is true.
    /// Usage: `.if(item.isLowStock) { $0.foregroundStyle(.orange) }`
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: Card Style

    /// Applies the app's standard card styling in one modifier.
    /// Usage: `myView.cardStyle()`
    func cardStyle(padding: CGFloat = AppSpacing.md) -> some View {
        self
            .padding(padding)
            .background(AppColors.cardBg,
                        in: RoundedRectangle(cornerRadius: AppRadius.card))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: Section Card Style

    /// Applies a lighter card style for nested sections.
    func sectionCardStyle() -> some View {
        self
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(Color(.systemBackground))
            )
    }

    // MARK: Hidden Modifier

    /// Hides the view without removing it from layout.
    /// Usage: `.hidden(when: isLoading)`
    func hidden(when condition: Bool) -> some View {
        opacity(condition ? 0 : 1)
    }

    // MARK: Rounded Border

    /// Adds a rounded stroke border around a view.
    func roundedBorder(
        _ color: Color,
        radius: CGFloat = AppRadius.md,
        lineWidth: CGFloat = 1
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .strokeBorder(color, lineWidth: lineWidth)
        )
    }

    // MARK: Loading Overlay

    /// Shows a full-view loading spinner overlay when active.
    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                    VStack(spacing: AppSpacing.md) {
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(.white)
                        Text("Loading...")
                            .font(AppFont.caption)
                            .foregroundStyle(.white)
                    }
                    .padding(AppSpacing.xl)
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: AppRadius.lg))
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }

    // MARK: Shake Animation

    /// Applies a horizontal shake animation — useful for validation errors.
    /// Usage: `.shake(trigger: showValidationError)`
    func shake(trigger: Bool) -> some View {
        self.modifier(ShakeModifier(trigger: trigger))
    }
}

// MARK: Shake Modifier Implementation

private struct ShakeModifier: ViewModifier {
    let trigger: Bool
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _, newValue in
                guard newValue else { return }
                withAnimation(
                    .default.repeatCount(3, autoreverses: true)
                    .speed(6)
                ) {
                    offset = 8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    offset = 0
                }
            }
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Color Extensions
// MARK: ─────────────────────────────────────────

extension Color {

    // MARK: Hex Initializer

    /// Creates a Color from a hex string.
    /// Usage: `Color(hex: "#FF6B6B")` or `Color(hex: "FF6B6B")`
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch cleaned.count {
        case 6:   // RRGGBB
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:   // RRGGBBAA
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: Adaptive Contrast

    /// Returns black or white depending on which has better contrast
    /// against this color — useful for text on dynamic backgrounds.
    var contrastingTextColor: Color {
        // Convert to UIColor to get component values
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0,
            blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Standard luminance formula
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return luminance > 0.5 ? .black : .white
    }

    // MARK: With Opacity Shorthand

    /// Shorthand for `.opacity()` — reads more naturally in view code.
    /// Usage: `AppColors.accent.at(0.5)` instead of `AppColors.accent.opacity(0.5)`
    func at(_ opacity: Double) -> Color {
        self.opacity(opacity)
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Date Extensions
// MARK: ─────────────────────────────────────────

extension Date {

    // MARK: Formatted Strings

    /// Returns a medium-style date string: "Jan 12, 2025"
    var mediumFormatted: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    /// Returns a short date+time string: "Jan 12, 2025, 3:45 PM"
    var shortDateTime: String {
        formatted(date: .abbreviated, time: .shortened)
    }

    /// Returns a relative description: "2 hours ago", "yesterday"
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: .now)
    }

    // MARK: Comparisons

    /// True if the date is within the last 24 hours
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// True if the date is within the last 7 days
    var isThisWeek: Bool {
        guard let weekAgo = Calendar.current.date(
            byAdding: .day, value: -7, to: .now
        ) else { return false }
        return self >= weekAgo
    }

    /// Returns a smart display string:
    /// "Just now" / "Today, 3:45 PM" / "Yesterday" / "Jan 12"
    var smartFormatted: String {
        let calendar = Calendar.current
        let now = Date()

        if now.timeIntervalSince(self) < 60 {
            return "Just now"
        } else if calendar.isDateInToday(self) {
            return "Today, " + formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if isThisWeek {
            return formatted(.dateTime.weekday(.wide))
        } else {
            return mediumFormatted
        }
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: String Extensions
// MARK: ─────────────────────────────────────────

extension String {

    // MARK: Validation

    /// True if the string contains only whitespace or is empty
    var isBlankOrEmpty: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// True if the string has at least `count` non-whitespace characters
    func hasMinLength(_ count: Int) -> Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).count >= count
    }

    // MARK: Formatting

    /// Returns the string with leading/trailing whitespace removed.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Capitalizes only the first letter, leaving the rest unchanged.
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return first.uppercased() + dropFirst()
    }

    // MARK: Search

    /// Case-insensitive contains check — cleaner than calling `.lowercased()` twice
    func containsIgnoringCase(_ other: String) -> Bool {
        localizedCaseInsensitiveContains(other)
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Array Extensions
// MARK: ─────────────────────────────────────────

extension Array where Element == InventoryItem {

    // MARK: Filtering

    /// Returns only items that are low on stock
    var lowStockItems: [InventoryItem] {
        filter { $0.isLowStock }
    }

    /// Returns only items that are completely out of stock
    var outOfStockItems: [InventoryItem] {
        filter { $0.isOutOfStock }
    }

    /// Returns items belonging to a specific category
    func inCategory(_ category: InventoryCategory) -> [InventoryItem] {
        filter { $0.category == category }
    }

    // MARK: Sorting

    /// Sorted by date added, newest first
    var sortedByNewest: [InventoryItem] {
        sorted { $0.dateAdded > $1.dateAdded }
    }

    /// Sorted by name alphabetically
    var sortedByName: [InventoryItem] {
        sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }

    /// Sorted by quantity, lowest first (for restocking priority)
    var sortedByQuantity: [InventoryItem] {
        sorted { $0.quantity < $1.quantity }
    }

    // MARK: Stats

    /// Total quantity across all items
    var totalQuantity: Int {
        reduce(0) { $0 + $1.quantity }
    }

    /// Count of items that have an AR placement saved
    var arPlacedCount: Int {
        filter { $0.arPlacement != nil }.count
    }

    /// Groups items by category, returning a dictionary
    var groupedByCategory: [InventoryCategory: [InventoryItem]] {
        Dictionary(grouping: self) { $0.category }
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Int Extensions
// MARK: ─────────────────────────────────────────

extension Int {

    /// Returns a grammatically correct unit string.
    /// Usage: `5.units("item")` → "5 items", `1.units("item")` → "1 item"
    func units(_ noun: String) -> String {
        "\(self) \(noun)\(self == 1 ? "" : "s")"
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: InventoryItem Extensions
// MARK: ─────────────────────────────────────────

extension InventoryItem {

    /// True if the item was added within the last 7 days
    var isNew: Bool {
        dateAdded.isThisWeek
    }

    /// A one-line summary string — useful for share sheets or export
    var summaryLine: String {
        "\(name) · \(category.rawValue) · Qty: \(quantity) · \(location)"
    }

    /// True if the item has a photo attached
    var hasImage: Bool {
        imageData != nil
    }

    /// True if the item has been placed in AR space
    var isARPlaced: Bool {
        arPlacement != nil
    }
}
