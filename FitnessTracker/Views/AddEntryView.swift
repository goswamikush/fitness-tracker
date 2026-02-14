//
//  AddEntryView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI

struct AddEntryView: View {
    let brand: String
    let name: String
    let servingSize: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    FoodHeader(brand: brand, name: name, servingSize: servingSize)
                    ServingRow()
                    CalculateByDivider()
                    TargetCaloriesRow(calories: calories)
                    MacroRingsRow(protein: protein, carbs: carbs, fat: fat)
                    MicronutrientsSection()
                }
                .padding()
                .padding(.bottom, 80)
            }

            AddToMealButton(calories: calories)
        }
        .background(AppColors.background)
        .navigationTitle("Add Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Subcomponents

private extension AddEntryView {

    struct FoodHeader: View {
        let brand: String
        let name: String
        let servingSize: String

        var body: some View {
            VStack(spacing: Spacing.md) {
                Text(brand.uppercased())
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.sm))
                    .tracking(1)

                Text(name)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: 24))

                Text("\(servingSize) per serving")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.md))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                    )
                    .overlay(alignment: .top) {
                        MacroColors.carbs
                            .frame(height: 3)
                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: CornerRadius.sm, topTrailingRadius: CornerRadius.sm))
                    }
            )
        }
    }

    struct ServingRow: View {
        var body: some View {
            HStack(spacing: 0) {
                Text("1")
                    .foregroundColor(.white)
                    .font(.custom(Fonts.interMedium, size: FontSize.lg))
                    .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 24)
                    .overlay(Color.white.opacity(CardStyle.borderOpacity))

                HStack(spacing: Spacing.sm) {
                    Text("Srv")
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.lg))
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.system(size: 10))
                }
                .frame(width: 80)
            }
            .padding(.vertical, Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
            )
        }
    }

    struct CalculateByDivider: View {
        var body: some View {
            HStack(spacing: Spacing.lg) {
                line
                Text("OR CALCULATE BY")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
                    .tracking(0.5)
                line
            }
        }

        private var line: some View {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
        }
    }

    struct TargetCaloriesRow: View {
        let calories: Int

        var body: some View {
            HStack {
                Text("Target Calories")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.lg))
                Spacer()
                Text("\(calories)")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.lg))
                Text("kcal")
                    .foregroundColor(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.lg))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
            )
        }
    }

    struct MacroRingsRow: View {
        let protein: Int
        let carbs: Int
        let fat: Int

        var body: some View {
            HStack(spacing: Spacing.xxl) {
                MacroRing(current: Double(protein), goal: 180, color: MacroColors.protein, label: "Protein")
                MacroRing(current: Double(carbs), goal: 250, color: MacroColors.carbs, label: "Carbs")
                MacroRing(current: Double(fat), goal: 70, color: MacroColors.fats, label: "Fat")
            }
            .padding(.vertical, Spacing.md)
        }
    }

    struct MicronutrientsSection: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    Text("MICRONUTRIENTS")
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.xs))
                        .tracking(1)

                    Spacer()

                    Text("% Daily Value")
                        .foregroundColor(MacroColors.carbs)
                        .font(.custom(Fonts.interMedium, size: FontSize.xs))
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(MacroColors.carbs, lineWidth: 1)
                        )
                }

                VStack(spacing: 0) {
                    MicronutrientRow(name: "Fiber", value: "0g", showTopDivider: false)
                    MicronutrientRow(name: "Sugar", value: "0g")
                    MicronutrientRow(name: "Sodium", value: "0mg")
                    MicronutrientRow(name: "Cholesterol", value: "0mg")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                        )
                )
            }
        }
    }

    struct MicronutrientRow: View {
        let name: String
        let value: String
        var showTopDivider: Bool = true

        var body: some View {
            VStack(spacing: 0) {
                if showTopDivider {
                    Divider()
                        .overlay(Color.white.opacity(0.08))
                }

                HStack {
                    Text(name)
                        .foregroundColor(.white)
                        .font(.custom(Fonts.interMedium, size: FontSize.lg))
                    Spacer()
                    Text(value)
                        .foregroundColor(AppColors.macroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.lg))
                }
                .padding(.vertical, Spacing.lg)
            }
        }
    }

    struct AddToMealButton: View {
        let calories: Int

        var body: some View {
            HStack {
                Text("Add to Meal")
                    .foregroundColor(.black)
                    .font(.custom(Fonts.interSemiBold, size: FontSize.xl))

                Spacer()

                HStack(spacing: Spacing.sm) {
                    Text("\(calories)")
                        .foregroundColor(.black)
                        .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
                    Text("kcal")
                        .foregroundColor(.black.opacity(0.7))
                        .font(.custom(Fonts.interRegular, size: FontSize.lg))
                }
            }
            .padding()
            .background(MacroColors.carbs)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        AddEntryView(
            brand: "Blue Diamond",
            name: "Almonds",
            servingSize: "1 oz",
            calories: 164,
            protein: 6,
            carbs: 6,
            fat: 14
        )
    }
}
