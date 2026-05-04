//
//  SettingsView.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  SettingsView.swift
//  SpatialInventory
//
//  Settings and About screen.
//  Shows app info, storage stats, data management,
//  and useful links. Follows iOS Settings visual conventions.
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {

    // MARK: - Dependencies

    @EnvironmentObject var viewModel: InventoryViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var showClearDataAlert  = false
    @State private var showClearedBanner   = false
    @State private var appearanceMode      = AppearanceMode.system
    @AppStorage("lowStockThreshold") private var lowStockThreshold = 5

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {

                // ── App header ──
                appHeaderSection

                // ── Inventory stats ──
                inventoryStatsSection

                // ── Preferences ──
                preferencesSection

                // ── Data management ──
                dataManagementSection

                // ── About ──
                aboutSection

                // ── Footer ──
                footerSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle(Strings.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.accent)
                }
            }
            .alert("Clear All Data", isPresented: $showClearDataAlert) {
                Button("Clear Everything", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(Strings.Settings.clearConfirm +
                     " You currently have \(viewModel.totalItemCount) item(s). This cannot be undone.")
            }
            .overlay(alignment: .top) {
                if showClearedBanner {
                    clearedBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, AppSpacing.sm)
                }
            }
        }
    }

    // MARK: - App Header Section

    private var appHeaderSection: some View {
        Section {
            HStack(spacing: AppSpacing.lg) {

                // App icon
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.accent, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .shadow(
                            color: AppColors.accent.opacity(0.4),
                            radius: 8, x: 0, y: 4
                        )

                    Image(systemName: "cube.transparent.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(AppInfo.name)
                        .font(AppFont.title)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(AppInfo.description)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)

                    Text("Version \(AppInfo.version)")
                        .font(AppFont.caption2)
                        .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                }
            }
            .padding(.vertical, AppSpacing.sm)
        }
    }

    // MARK: - Inventory Stats Section

    private var inventoryStatsSection: some View {
        Section("Inventory Summary") {

            SettingsStatRow(
                icon: "archivebox.fill",
                iconColor: .blue,
                label: "Total Items",
                value: "\(viewModel.totalItemCount)"
            )

            SettingsStatRow(
                icon: "exclamationmark.triangle.fill",
                iconColor: .orange,
                label: "Low Stock Items",
                value: "\(viewModel.lowStockCount)"
            )

            SettingsStatRow(
                icon: "camera.viewfinder",
                iconColor: .teal,
                label: "AR Placed Items",
                value: "\(arPlacedCount)"
            )

            SettingsStatRow(
                icon: "externaldrive.fill",
                iconColor: .purple,
                label: "Storage Used",
                value: InventoryStorageService.shared.fileSize
            )
        }
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        Section("Preferences") {

            // Appearance picker
            Picker(selection: $appearanceMode) {
                ForEach(AppearanceMode.allCases) { mode in
                    Label(mode.label, systemImage: mode.icon)
                        .tag(mode)
                }
            } label: {
                SettingsRowLabel(
                    icon: "paintbrush.fill",
                    iconColor: .indigo,
                    label: "Appearance"
                )
            }
            .pickerStyle(.menu)

            // Low stock threshold stepper
            HStack {
                SettingsRowLabel(
                    icon: "exclamationmark.circle.fill",
                    iconColor: .orange,
                    label: "Low Stock Alert Threshold"
                )

                Spacer()

                Stepper("\(lowStockThreshold) units",
                        value: $lowStockThreshold,
                        in: 1...50)
                    .labelsHidden()

                Text("\(lowStockThreshold)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(minWidth: 28, alignment: .trailing)
            }
        }
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        Section("Data Management") {

            // Export hint (future feature)
            SettingsNavigationRow(
                icon: "square.and.arrow.up.fill",
                iconColor: .green,
                label: "Export Inventory",
                subtitle: "Coming soon",
                isDisabled: true
            ) { }

            // Clear all data — destructive
            Button {
                showClearDataAlert = true
            } label: {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(AppColors.danger.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.danger)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(Strings.Settings.clearData)
                            .font(AppFont.body)
                            .foregroundStyle(AppColors.danger)
                        Text("Permanently removes all inventory items")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()
                }
            }
            .disabled(viewModel.isEmpty)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section("About") {

            // GitHub link
            SettingsLinkRow(
                icon: "chevron.left.forwardslash.chevron.right",
                iconColor: .primary,
                label: "View on GitHub",
                url: AppInfo.github
            )

            // Architecture info
            SettingsInfoRow(
                icon: "square.3.layers.3d",
                iconColor: .purple,
                label: "Architecture",
                value: "MVVM + SwiftUI"
            )

            // Tech stack
            SettingsInfoRow(
                icon: "arkit",
                iconColor: .teal,
                label: "AR Framework",
                value: "ARKit + RealityKit"
            )

            // Storage info
            SettingsInfoRow(
                icon: "doc.fill",
                iconColor: .blue,
                label: "Storage",
                value: "JSON (Local)"
            )

            // iOS requirement
            SettingsInfoRow(
                icon: "iphone",
                iconColor: .gray,
                label: "Requires",
                value: "iOS 17+"
            )
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        Section {
            VStack(spacing: AppSpacing.xs) {
                Text("Built with ❤️ using Swift & SwiftUI")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Text("© 2025 \(AppInfo.name)")
                    .font(AppFont.caption2)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.sm)
            .listRowBackground(Color.clear)
        }
    }

    // MARK: - Cleared Banner

    private var clearedBanner: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColors.success)
            Text("All inventory data cleared.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBg,
                    in: RoundedRectangle(cornerRadius: AppRadius.md))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, AppSpacing.md)
    }

    // MARK: - Actions

    private func clearAllData() {
        viewModel.clearAllData()
        withAnimation {
            showClearedBanner = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { showClearedBanner = false }
        }
    }

    // MARK: - Computed

    private var arPlacedCount: Int {
        viewModel.items.filter { $0.arPlacement != nil }.count
    }
}

// MARK: - Appearance Mode Enum

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"

    var id: String { rawValue }

    var label: String { rawValue }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - Settings Row Components

/// A row that shows an icon, label, and a static value on the right
struct SettingsInfoRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            SettingsIcon(icon: icon, color: iconColor)
            Text(label)
                .font(AppFont.body)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(value)
                .font(AppFont.body)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

/// A row that shows a stat with a bold value
struct SettingsStatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            SettingsIcon(icon: icon, color: iconColor)
            Text(label)
                .font(AppFont.body)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

/// A tappable navigation row with optional subtitle and disabled state
struct SettingsNavigationRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    var subtitle: String? = nil
    var isDisabled: Bool  = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                SettingsIcon(icon: icon, color: isDisabled ? .gray : iconColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(AppFont.body)
                        .foregroundStyle(
                            isDisabled
                                ? AppColors.textSecondary
                                : AppColors.textPrimary
                        )
                    if let subtitle {
                        Text(subtitle)
                            .font(AppFont.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.4))
            }
        }
        .disabled(isDisabled)
    }
}

/// A tappable row that opens a URL in Safari
struct SettingsLinkRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let url: String

    var body: some View {
        if let validURL = URL(string: url) {
            Link(destination: validURL) {
                HStack(spacing: AppSpacing.md) {
                    SettingsIcon(icon: icon, color: iconColor)
                    Text(label)
                        .font(AppFont.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                }
            }
        }
    }
}

/// A row label used inside Picker and Stepper rows
struct SettingsRowLabel: View {
    let icon: String
    let iconColor: Color
    let label: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            SettingsIcon(icon: icon, color: iconColor)
            Text(label)
                .font(AppFont.body)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

/// Reusable icon badge used in all settings rows
struct SettingsIcon: View {
    let icon: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(color.opacity(0.15))
                .frame(width: 32, height: 32)
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(InventoryViewModel())
}
