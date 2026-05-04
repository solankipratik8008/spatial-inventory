//
//  AddItemView.swift
//  SpatialInventory
//
//  Created by Pratik Solanki on 2026-05-04.
//

//
//  AddItemView.swift
//  SpatialInventory
//
//  Form screen for creating new inventory items or editing existing ones.
//  Handles both modes with a single view — pass existingItem to enter edit mode.
//  Includes full input validation before saving.
//

import SwiftUI
import PhotosUI

// MARK: - Add / Edit Item View

struct AddItemView: View {

    // MARK: - Dependencies

    @EnvironmentObject var viewModel: InventoryViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Mode Detection

    /// When non-nil, the view operates in Edit mode
    let existingItem: InventoryItem?

    /// True if we're editing an existing item
    private var isEditMode: Bool { existingItem != nil }

    // MARK: - Form Fields

    @State private var name        = ""
    @State private var category    = InventoryCategory.other
    @State private var quantity    = 0
    @State private var location    = ""
    @State private var notes       = ""

    // MARK: - Image Picker

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    // MARK: - UI State

    @State private var isSaving        = false
    @State private var showValidation  = false
    @State private var nameError       = ""
    @State private var showDiscardAlert = false

    // MARK: - Initializer

    init(existingItem: InventoryItem? = nil) {
        self.existingItem = existingItem
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {

                    // ── Image picker section ──
                    imageSection

                    // ── Item details form ──
                    detailsSection

                    // ── Category picker ──
                    categorySection

                    // ── Quantity stepper ──
                    quantitySection

                    // ── Location field ──
                    locationSection

                    // ── Notes field ──
                    notesSection

                    // ── Save button ──
                    saveButton

                    Spacer(minLength: AppSpacing.xxl)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditMode ? Strings.AddItem.editTitle : Strings.AddItem.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep Editing", role: .cancel) { }
            } message: {
                Text("You have unsaved changes. Are you sure you want to discard them?")
            }
        }
        // Pre-fill form when editing
        .onAppear { populateFieldsIfEditing() }
    }

    // MARK: - Image Section

    private var imageSection: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.cardBg)
                    .frame(height: 160)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                if let data = selectedImageData,
                   let uiImage = UIImage(data: data) {
                    // Show selected image
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                } else {
                    // Placeholder
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(AppColors.accent.opacity(0.7))

                        Text("Tap to add photo")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        FormCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {

                FormLabel(title: "Item Name", isRequired: true)

                TextField(Strings.AddItem.namePlaceholder, text: $name)
                    .font(AppFont.body)
                    .padding(AppSpacing.sm + 2)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .strokeBorder(
                                nameError.isEmpty ? Color.clear : AppColors.danger,
                                lineWidth: 1
                            )
                    )
                    // Clear error as user types
                    .onChange(of: name) { _, _ in
                        if !name.isEmpty { nameError = "" }
                    }

                // Validation error message
                if !nameError.isEmpty {
                    Label(nameError, systemImage: "exclamationmark.circle.fill")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.danger)
                }
            }
        }
    }

    // MARK: - Category Section

    private var categorySection: some View {
        FormCard(title: "Category") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(InventoryCategory.allCases) { cat in
                        CategoryChipView(
                            category: cat,
                            isSelected: category == cat
                        ) {
                            withAnimation { category = cat }
                        }
                    }
                }
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }

    // MARK: - Quantity Section

    private var quantitySection: some View {
        FormCard(title: "Quantity") {
            HStack {
                // Decrease button
                Button {
                    if quantity > 0 { quantity -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            quantity > 0 ? AppColors.accent : AppColors.textSecondary.opacity(0.3)
                        )
                }
                .disabled(quantity == 0)

                Spacer()

                // Quantity display
                VStack(spacing: 2) {
                    Text("\(quantity)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(quantityDisplayColor)
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.3), value: quantity)

                    Text("units")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                // Increase button
                Button {
                    quantity += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppColors.accent)
                }
            }
            .padding(.vertical, AppSpacing.xs)

            // Stock status preview
            HStack {
                Spacer()
                StockBadge(
                    status: stockStatusForQuantity,
                    label: stockLabelForQuantity
                )
                Spacer()
            }
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        FormCard(title: "Location") {
            TextField(Strings.AddItem.locationPlaceholder, text: $location)
                .font(AppFont.body)
                .padding(AppSpacing.sm + 2)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(Color(.systemBackground))
                )
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        FormCard(title: "Notes") {
            TextField(
                Strings.AddItem.notesPlaceholder,
                text: $notes,
                axis: .vertical
            )
            .font(AppFont.body)
            .lineLimit(3...6)
            .padding(AppSpacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(Color(.systemBackground))
            )
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        PrimaryButton(
            title: isEditMode ? Strings.AddItem.update : Strings.AddItem.save,
            icon: isEditMode ? "checkmark.circle.fill" : "plus.circle.fill",
            isLoading: isSaving
        ) {
            saveItem()
        }
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                if hasChanges {
                    showDiscardAlert = true
                } else {
                    dismiss()
                }
            }
            .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Logic

    /// Pre-fill form fields when editing an existing item
    private func populateFieldsIfEditing() {
        guard let item = existingItem else { return }
        name     = item.name
        category = item.category
        quantity = item.quantity
        location = item.location
        notes    = item.notes

        // Load image data if present
        if let base64 = item.imageData {
            selectedImageData = Data(base64Encoded: base64)
        }
    }

    /// Validates form, then creates or updates the item
    private func saveItem() {
        // ── Validation ──
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            nameError = "Item name is required."
            return
        }

        isSaving = true

        // Small delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {

            let imageBase64 = selectedImageData?.base64EncodedString()

            if isEditMode, var updated = existingItem {
                // ── Edit mode: update existing item ──
                updated.name      = trimmedName
                updated.category  = category
                updated.quantity  = quantity
                updated.location  = location.trimmingCharacters(in: .whitespaces)
                updated.notes     = notes.trimmingCharacters(in: .whitespaces)
                updated.imageData = imageBase64
                viewModel.updateItem(updated)

            } else {
                // ── Create mode: build a new item ──
                let newItem = InventoryItem(
                    name:      trimmedName,
                    category:  category,
                    quantity:  quantity,
                    location:  location.trimmingCharacters(in: .whitespaces),
                    notes:     notes.trimmingCharacters(in: .whitespaces),
                    imageData: imageBase64
                )
                viewModel.addItem(newItem)
            }

            isSaving = false
            dismiss()
        }
    }

    /// True if the user has made any changes (used for discard confirmation)
    private var hasChanges: Bool {
        guard let item = existingItem else {
            return !name.isEmpty || quantity != 0 || !location.isEmpty || !notes.isEmpty
        }
        return name     != item.name
            || category != item.category
            || quantity != item.quantity
            || location != item.location
            || notes    != item.notes
    }

    // MARK: - Quantity Helpers

    private var stockStatusForQuantity: StockStatus {
        if quantity == 0 { return .outOfStock }
        if quantity <= InventoryThreshold.lowStock { return .low }
        return .good
    }

    private var stockLabelForQuantity: String {
        if quantity == 0 { return "Out of Stock" }
        if quantity <= InventoryThreshold.lowStock { return "Low Stock" }
        return "In Stock"
    }

    private var quantityDisplayColor: Color {
        switch stockStatusForQuantity {
        case .good:       return AppColors.textPrimary
        case .low:        return AppColors.warning
        case .outOfStock: return AppColors.danger
        }
    }
}

// MARK: - Form Card Helper

/// A titled card container used to group related form fields
struct FormCard<Content: View>: View {

    var title: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let title {
                FormLabel(title: title)
            }
            content
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBg, in: RoundedRectangle(cornerRadius: AppRadius.card))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Form Label Helper

/// Consistent label style for form fields
struct FormLabel: View {

    let title: String
    var isRequired: Bool = false

    var body: some View {
        HStack(spacing: 3) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)

            if isRequired {
                Text("*")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.danger)
            }
        }
    }
}

// MARK: - Preview

#Preview("Create Mode") {
    AddItemView()
        .environmentObject(InventoryViewModel())
}

#Preview("Edit Mode") {
    AddItemView(existingItem: .sample)
        .environmentObject(InventoryViewModel())
}
