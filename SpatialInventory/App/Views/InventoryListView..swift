//
//  InventoryListView..swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  InventoryListView.swift
//  SpatialInventory
//
//  The main inventory browser screen.
//  Supports live search, category filtering, swipe-to-delete,
//  and smooth empty state UI.
//

import SwiftUI

// MARK: - Inventory List View

struct InventoryListView: View {

    // MARK: - Dependencies

    @EnvironmentObject var viewModel: InventoryViewModel

    // MARK: - Local State

    @State private var showAddItem       = false
    @State private var itemToDelete: InventoryItem? = nil
    @State private var showDeleteAlert   = false
    @State private var sortOrder         = SortOrder.dateDesc

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            // ── Category filter chips ──
            categoryFilterBar

            // ── Item count summary ──
            if !viewModel.items.isEmpty {
                itemCountBar
            }

            // ── Main list / empty state ──
            ZStack {
                if viewModel.isLoading {
                    loadingView

                } else if viewModel.filteredItems.isEmpty {
                    emptyStateView

                } else {
                    itemList
                }
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.filteredItems.count)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(Strings.Inventory.title)
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $viewModel.searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Strings.Inventory.searchPlaceholder
        )
        .toolbar { toolbarContent }
        .sheet(isPresented: $showAddItem) {
            AddItemView()
        }
        .alert("Delete Item", isPresented: $showDeleteAlert, presenting: itemToDelete) { item in
            Button("Delete", role: .destructive) {
                viewModel.deleteItem(id: item.id)
            }
            Button("Cancel", role: .cancel) { }
        } message: { item in
            Text("Are you sure you want to delete \"\(item.name)\"? This cannot be undone.")
        }
    }

    // MARK: - Category Filter Bar

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {

                // "All" chip — clears the category filter
                AllCategoryChip(
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    withAnimation { viewModel.selectedCategory = nil }
                }

                // One chip per category
                ForEach(InventoryCategory.allCases) { category in
                    CategoryChipView(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation {
                            // Tap selected chip again to deselect
                            if viewModel.selectedCategory == category {
                                viewModel.selectedCategory = nil
                            } else {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
        }
        .background(Color(.systemGroupedBackground))
        // Subtle bottom separator
        .overlay(alignment: .bottom) {
            Divider().opacity(0.5)
        }
    }

    // MARK: - Item Count Bar

    private var itemCountBar: some View {
        HStack {
            Text(countSummaryText)
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            // Reset filters button — only shown when a filter is active
            if viewModel.hasActiveFilter {
                Button {
                    withAnimation { viewModel.resetFilters() }
                } label: {
                    Label("Clear Filters", systemImage: "xmark.circle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
    }

    // MARK: - Item List

    private var itemList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(sortedItems) { item in
                    NavigationLink(destination: InventoryDetailView(item: item)) {
                        InventoryCardView(item: item)
                    }
                    .buttonStyle(.plain)
                    // Swipe actions
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {

                        // Delete swipe
                        Button(role: .destructive) {
                            itemToDelete  = item
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        // Edit swipe
                        NavigationLink(destination: AddItemView(existingItem: item)) {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    // Leading swipe — quick AR shortcut
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        NavigationLink(
                            destination: ARScannerView(selectedItem: item)
                        ) {
                            Label("AR Place", systemImage: "camera.viewfinder")
                        }
                        .tint(.teal)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xxl)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        Group {
            if viewModel.hasActiveFilter {
                // Filtered search returned nothing
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Results",
                    message: "No items match your current search or filter. Try adjusting them.",
                    buttonTitle: "Clear Filters",
                    buttonAction: {
                        withAnimation { viewModel.resetFilters() }
                    }
                )
            } else {
                // Inventory is completely empty
                EmptyStateView(
                    icon: "archivebox",
                    title: Strings.Inventory.empty,
                    message: Strings.Inventory.emptyMessage,
                    buttonTitle: Strings.Home.addItem,
                    buttonAction: { showAddItem = true }
                )
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading inventory...")
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        // Sort menu
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Picker("Sort", selection: $sortOrder) {
                    ForEach(SortOrder.allCases) { order in
                        Label(order.label, systemImage: order.icon)
                            .tag(order)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.accent)
            }
        }

        // Add item button
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showAddItem = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(AppColors.accent)
            }
        }
    }

    // MARK: - Sorting

    private var sortedItems: [InventoryItem] {
        switch sortOrder {
        case .nameAsc:
            return viewModel.filteredItems.sorted { $0.name < $1.name }
        case .nameDesc:
            return viewModel.filteredItems.sorted { $0.name > $1.name }
        case .dateDesc:
            return viewModel.filteredItems.sorted { $0.dateAdded > $1.dateAdded }
        case .dateAsc:
            return viewModel.filteredItems.sorted { $0.dateAdded < $1.dateAdded }
        case .quantityAsc:
            return viewModel.filteredItems.sorted { $0.quantity < $1.quantity }
        case .quantityDesc:
            return viewModel.filteredItems.sorted { $0.quantity > $1.quantity }
        }
    }

    // MARK: - Helpers

    private var countSummaryText: String {
        let filtered = viewModel.filteredItems.count
        let total    = viewModel.totalItemCount
        if viewModel.hasActiveFilter {
            return "\(filtered) of \(total) item\(total == 1 ? "" : "s")"
        }
        return "\(total) item\(total == 1 ? "" : "s") total"
    }
}

// MARK: - Sort Order Enum

enum SortOrder: String, CaseIterable, Identifiable {
    case dateDesc    = "Newest First"
    case dateAsc     = "Oldest First"
    case nameAsc     = "Name A–Z"
    case nameDesc    = "Name Z–A"
    case quantityAsc = "Lowest Quantity"
    case quantityDesc = "Highest Quantity"

    var id: String { rawValue }

    var label: String { rawValue }

    var icon: String {
        switch self {
        case .dateDesc:     return "calendar.badge.clock"
        case .dateAsc:      return "calendar"
        case .nameAsc:      return "textformat.abc"
        case .nameDesc:     return "textformat.abc"
        case .quantityAsc:  return "arrow.up.circle"
        case .quantityDesc: return "arrow.down.circle"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        InventoryListView()
            .environmentObject({
                let vm = InventoryViewModel()
                return vm
            }())
    }
}
