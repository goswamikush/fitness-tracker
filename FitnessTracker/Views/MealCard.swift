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
                            .font(.system(size: IconSize.md, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)

                        Image(systemName: "chevron.up")
                            .font(.system(size: IconSize.md, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }
                }

                FoodItem()

                FoodItem()

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
