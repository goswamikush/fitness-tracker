//
//  EditWeightSheet.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/17/26.
//

import SwiftUI

private enum EditSheetLayout {
    static let weightFontSize: CGFloat = 48
    static let deleteFillOpacity: Double = 0.12
    static let deleteStrokeOpacity: Double = 0.25
}

struct EditWeightSheet: View {
    @Environment(\.dismiss) private var dismiss
    let entry: WeightEntry
    let onDelete: () -> Void

    @State private var weightText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                VStack(spacing: Spacing.xxl) {
                    Spacer()

                    TextField("", text: $weightText)
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.outfitSemiBold, size: EditSheetLayout.weightFontSize))
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)

                    HStack(spacing: Spacing.md) {
                        Text("kg")
                            .font(.custom(Fonts.interMedium, size: FontSize.lg))
                            .foregroundStyle(MacroColors.carbs)

                        Circle()
                            .fill(AppColors.lightMacroTextColor)
                            .frame(width: IconSize.sm, height: IconSize.sm)

                        Text("EDIT WEIGHT")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interMedium, size: FontSize.xs))
                            .tracking(1)
                    }

                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .tint(MacroColors.carbs)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                        )
                        .fixedSize()

                    Spacer()
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.lightMacroTextColor)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let newWeight = Double(weightText) {
                            entry.weight = newWeight
                            entry.date = selectedDate
                        }
                        dismiss()
                    }
                    .foregroundStyle(MacroColors.carbs)
                    .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "trash")
                            .font(.system(size: FontSize.md, weight: .semibold))
                        Text("Delete Entry")
                            .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                    }
                    .foregroundStyle(AppColors.negative)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(AppColors.negative.opacity(EditSheetLayout.deleteFillOpacity))
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .stroke(AppColors.negative.opacity(EditSheetLayout.deleteStrokeOpacity), lineWidth: CardStyle.borderWidth)
                            )
                    )
                    .padding()
                }
                .confirmationDialog("Delete this entry?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        onDelete()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            weightText = String(format: "%.1f", entry.weight)
            selectedDate = entry.date
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
