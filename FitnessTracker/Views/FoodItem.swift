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
                    // Item
                    HStack() {
                        Text("Grilled Chicken Salad")
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.interMedium, size: FontSize.lg))
                    }

                    // Macros
                    HStack() {
                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.protein)
                                  .frame(width: IconSize.sm, height: IconSize.sm)
                            Text("45p")
                                .foregroundStyle(AppColors.macroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.xs))
                        }

                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.carbs)
                                  .frame(width: IconSize.sm, height: IconSize.sm)
                            Text("12c")
                                .foregroundStyle(AppColors.macroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.xs))
                        }

                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.fats)
                                  .frame(width: IconSize.sm, height: IconSize.sm)
                            Text("20f")
                                .foregroundStyle(AppColors.macroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.xs))
                        }

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
