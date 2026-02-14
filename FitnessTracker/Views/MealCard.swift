//
//  MealCard.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/2/26.
//

import SwiftUI

struct MealCard: View {

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            VStack(spacing: Spacing.xxl) {
                Header()

                FoodItem()

                FoodItem()

                Footer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                )
        )
        .shadow(color: .black.opacity(CardStyle.shadowOpacity), radius: CardStyle.shadowRadius, x: 0, y: CardStyle.shadowY)
        .mask(
            Rectangle()
                .padding(.bottom, CardStyle.maskPadding)
        )
    }
}

// MARK: - Subcomponents

private extension MealCard {

    struct Header: View {
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Lunch")
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))

                    Text("545 kcal")
                        .foregroundStyle(AppColors.macroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.sm))
                }

                Spacer()

                HStack(spacing: Spacing.xl) {
                    Image(systemName: "plus")
                        .font(.system(size: IconSize.lg, weight: .medium))
                        .foregroundColor(AppColors.macroTextColor)

                    Image(systemName: "chevron.up")
                        .font(.system(size: IconSize.lg, weight: .medium))
                        .foregroundColor(AppColors.macroTextColor)
                }
            }
        }
    }

    struct Footer: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Divider()
                    .overlay(AppColors.macroTextColor.opacity(Opacity.divider))
                HStack {
                    HStack(spacing: Spacing.lg) {
                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.protein)
                                .frame(width: IconSize.md, height: IconSize.md)
                            Text("45p")
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }

                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.carbs)
                                .frame(width: IconSize.md, height: IconSize.md)
                            Text("12c")
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }

                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.fats)
                                .frame(width: IconSize.md, height: IconSize.md)
                            Text("20f")
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }
                    }

                    Spacer()

                    Text("900 cal")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                }
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 8) {
            MealCard()
        }
        .padding()
    }
}
