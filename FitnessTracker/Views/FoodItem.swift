//
//  FoodItem.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI

struct FoodItem: View {

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Grilled Chicken Salad")
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.interMedium, size: FontSize.lg))

                    HStack() {
                        MacroBadge(color: MacroColors.protein, value: "45p")
                        MacroBadge(color: MacroColors.carbs, value: "12c")
                        MacroBadge(color: MacroColors.fats, value: "20f")

                        Divider()
                            .frame(height: FontSize.lg)
                            .overlay(AppColors.macroTextColor)
                            .padding(.horizontal, Spacing.sm)

                        HStack(spacing: Spacing.md) {
                            Circle()
                                .fill(AppColors.macroTextColor)
                                .frame(width: IconSize.xs, height: IconSize.xs)
                            Text("256g")
                                .foregroundStyle(AppColors.macroTextColor.opacity(0.6))
                                .font(.custom(Fonts.interRegular, size: FontSize.xs))
                        }
                    }
                }

                Spacer()

                Text("450 cal")
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.interRegular, size: FontSize.md))
            }
        }
    }
}

// MARK: - Subcomponents

private extension FoodItem {

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
            FoodItem()
        }
        .padding()
    }
}
