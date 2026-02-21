//
//  FoodItemRow.swift
//  FitnessTracker
//

import SwiftUI

struct FoodItemRow: View {
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let servingDisplay: String

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(name)
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.interMedium, size: FontSize.lg))

                    HStack() {
                        MacroBadge(color: MacroColors.protein, value: "\(protein)p")
                        MacroBadge(color: MacroColors.carbs, value: "\(carbs)c")
                        MacroBadge(color: MacroColors.fats, value: "\(fat)f")

                        Divider()
                            .frame(height: FontSize.lg)
                            .overlay(AppColors.macroTextColor)
                            .padding(.horizontal, Spacing.sm)

                        HStack(spacing: Spacing.md) {
                            Circle()
                                .fill(AppColors.macroTextColor)
                                .frame(width: IconSize.xs, height: IconSize.xs)
                            Text(servingDisplay)
                                .foregroundStyle(AppColors.macroTextColor.opacity(0.6))
                                .font(.custom(Fonts.interRegular, size: FontSize.xs))
                        }
                    }
                }

                Spacer()

                Text("\(calories) cal")
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.interRegular, size: FontSize.md))
            }
        }
    }
}

// MARK: - Subcomponents

private extension FoodItemRow {

    struct MacroBadge: View {
        let color: Color
        let value: String

        var body: some View {
            HStack(spacing: Spacing.xs) {
                Circle()
                    .fill(color)
                    .frame(width: IconSize.sm, height: IconSize.sm)
                Text(value)
                    .foregroundStyle(AppColors.macroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.xs))
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 8) {
            FoodItemRow(name: "Grilled Chicken Salad", calories: 450, protein: 45, carbs: 12, fat: 20, servingDisplay: "256g")
        }
        .padding()
    }
}
