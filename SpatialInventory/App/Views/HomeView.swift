//
//  HomeView.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  HomeView.swift
//  SpatialInventory
//
//  The main dashboard screen. Shows inventory stats, low stock alerts,
//  recently added items, and quick action navigation buttons.
//

import SwiftUI

// MARK: - Home View

struct HomeView: View {

    // MARK: - Dependencies

    @EnvironmentObject var viewModel: InventoryViewModel

    // MARK: - Navigation State

    @State private var showAddItem     = false
    @State private var showInventory   = false
    @State private var showARScanner   = false

    // MARK: - Animation State

    @State private var statsVisible    = false
    @State private var contentVisible  = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {

                    // ── Header greeting ──
                    headerSection

                    // ── Stats row ──
                    statsSection
                        .opacity(statsVisible ? 1 : 0)
                        .offset(y: statsVisible ? 0 : 20)

                    // ── Quick actions ──
                    quickActionsSection
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 20)

                    // ── Low stock alerts ──
                    if !viewModel.lowStockItems.isEmpty {
                        lowStockSection
                            .opacity(contentVisible ? 1 : 0)
                    }

                    // ── Recently added ──
                    recentItemsSection
                        .opacity(contentVisible ? 1 : 0)

                    Spacer(minLength: AppSpacing.xl)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(Strings.Home.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }

            // ── Navigation destinations ──
            .navigationDestination(isPresented: $showInventory) {
                InventoryListView()
            }
        }
        // ── Sheets ──
        .sheet(isPresented: $showAddItem) {
            AddItemView()
        }
        .fullScreenCover(isPresented: $showARScanner) {
            ARScannerView()
        }
        // ── Entrance animations ──
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                statsVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                contentVisible = true
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)

                Text(AppInfo.name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()

            // App icon badge
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppColors.accent.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: "cube.transparent.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(AppColors.accent)
            }
        }
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(title: "Overview")

            HStack(spacing: AppSpacing.md) {
                StatCard(
                    icon: "archivebox.fill",
                    value: "\(viewModel.totalItemCount)",
                    label: Strings.Home.totalItems,
                    color: .blue
                )

                StatCard(
                    icon: "exclamationmark.triangle.fill",
                    value: "\(viewModel.lowStockCount)",
                    label: Strings.Home.lowStock,
                    color: viewModel.lowStockCount > 0 ? .orange : .green
                )
            }
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(title: Strings.Home.quickActions)

            VStack(spacing: AppSpacing.sm) {

                // Add Item — primary action
                QuickActionButton(
                    title: Strings.Home.addItem,
                    subtitle: "Create a new inventory record",
                    icon: "plus.circle.fill",
                    color: AppColors.accent
                ) {
                    showAddItem = true
                }

                HStack(spacing: AppSpacing.sm) {

                    // View Inventory
                    QuickActionButton(
                        title: Strings.Home.viewInventory,
                        subtitle: "Browse all items",
                        icon: "list.bullet.rectangle.fill",
                        color: .purple,
                        compact: true
                    ) {
                        showInventory = true
                    }

                    // AR Scanner
                    QuickActionButton(
                        title: Strings.Home.openAR,
                        subtitle: "Place items in AR",
                        icon: "camera.viewfinder",
                        color: .teal,
                        compact: true
                    ) {
                        showARScanner = true
                    }
                }
            }
        }
    }

    // MARK: - Low Stock Section

    private var lowStockSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(
                title: "⚠️ Low Stock Alerts",
                actionTitle: "See All",
                action: { showInventory = true }
            )

            VStack(spacing: AppSpacing.sm) {
                ForEach(viewModel.lowStockItems.prefix(3)) { item in
                    NavigationLink(destination: InventoryDetailView(item: item)) {
                        InventoryCardView(item: item, compact: true)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Recent Items Section

    private var recentItemsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            SectionHeader(
                title: Strings.Home.recentlyAdded,
                actionTitle: viewModel.isEmpty ? nil : "See All",
                action: { showInventory = true }
            )

            if viewModel.isEmpty {
                // Empty state when no items exist
                EmptyStateView(
                    icon: "archivebox",
                    title: Strings.Inventory.empty,
                    message: Strings.Inventory.emptyMessage,
                    buttonTitle: Strings.Home.addItem,
                    buttonAction: { showAddItem = true }
                )
                .frame(height: 280)
                .background(AppColors.cardBg, in: RoundedRectangle(cornerRadius: AppRadius.card))

            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.recentItems) { item in
                        NavigationLink(destination: InventoryDetailView(item: item)) {
                            InventoryCardView(item: item, compact: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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

    // MARK: - Helpers

    /// Time-based greeting for the header
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning 👋"
        case 12..<17: return "Good afternoon 👋"
        case 17..<21: return "Good evening 👋"
        default:      return "Welcome back 👋"
        }
    }
}

// MARK: - Quick Action Button

/// Large tappable action card used in the quick actions section
private struct QuickActionButton: View {

    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var compact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(color.opacity(0.15))
                        .frame(width: compact ? 40 : 48,
                               height: compact ? 40 : 48)

                    Image(systemName: icon)
                        .font(.system(size: compact ? 18 : 22,
                                     weight: .medium))
                        .foregroundStyle(color)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: compact ? 14 : 16,
                                     weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    if !compact {
                        Text(subtitle)
                            .font(AppFont.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))
            }
            .padding(compact ? AppSpacing.sm + 2 : AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(AppColors.cardBg,
                        in: RoundedRectangle(cornerRadius: AppRadius.card))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ContentView wrapper
// Temporary root view until we add tab navigation later.
// SpatialInventoryApp.swift points to this.

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(InventoryViewModel())
}
