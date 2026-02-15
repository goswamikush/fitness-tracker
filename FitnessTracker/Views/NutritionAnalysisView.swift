//
//  NutritionAnalysisView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/15/26.
//

import SwiftUI

struct NutritionAnalysisView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxl) {
                MacrosAndFiberSection()
                MicronutrientsSection()
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("Nutrition Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Subcomponents

private extension NutritionAnalysisView {

    struct NutrientRow: View {
        let name: String
        let current: Double
        let goal: Double
        let unit: String
        let color: Color

        private var percentage: Int {
            guard goal > 0 else { return 0 }
            return Int((current / goal) * 100)
        }

        private var progress: Double {
            guard goal > 0 else { return 0 }
            return min(current / goal, 1.0)
        }

        private var percentageColor: Color {
            if percentage >= 100 {
                return MacroColors.carbs
            } else if percentage >= 70 {
                return MacroColors.fats
            } else {
                return Color(red: 250/255, green: 100/255, blue: 100/255)
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                        Text("\(Int(current)) / \(Int(goal)) \(unit)")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    Spacer()

                    Text("\(percentage)%")
                        .foregroundStyle(percentageColor)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color.opacity(0.2))

                        RoundedRectangle(cornerRadius: 3)
                            .fill(color)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 5)
            }
            .padding(.vertical, Spacing.md)
        }
    }

    struct MacrosAndFiberSection: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("MACROS & FIBER")
                    .foregroundStyle(AppColors.macroTextColor)
                    .font(.custom(Fonts.outfitBold, size: FontSize.xs))
                    .tracking(1)

                VStack(spacing: 0) {
                    NutrientRow(name: "Protein", current: 140, goal: 180, unit: "g", color: MacroColors.protein)
                    NutrientRow(name: "Carbohydrates", current: 180, goal: 250, unit: "g", color: MacroColors.carbs)
                    NutrientRow(name: "Fat", current: 55, goal: 70, unit: "g", color: MacroColors.fats)
                    NutrientRow(name: "Fiber", current: 18, goal: 30, unit: "g", color: MacroColors.fats)
                    NutrientRow(name: "Sugar", current: 45, goal: 50, unit: "g", color: MacroColors.fats)
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
                .shadow(color: .black.opacity(CardStyle.shadowOpacity), radius: CardStyle.shadowRadius, x: 0, y: CardStyle.shadowY)
            }
        }
    }

    struct MicronutrientsSection: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    Text("MICRONUTRIENTS")
                        .foregroundStyle(AppColors.macroTextColor)
                        .font(.custom(Fonts.outfitBold, size: FontSize.xs))
                        .tracking(1)

                    Spacer()

                    Image(systemName: "info.circle")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.system(size: IconSize.lg))
                }

                VStack(spacing: 0) {
                    NutrientRow(name: "Vitamin D", current: 2, goal: 20, unit: "mcg", color: Color(red: 250/255, green: 100/255, blue: 100/255))
                    NutrientRow(name: "Vitamin C", current: 120, goal: 90, unit: "mg", color: MacroColors.fats)
                    NutrientRow(name: "Calcium", current: 800, goal: 1300, unit: "mg", color: MacroColors.fats)
                    NutrientRow(name: "Iron", current: 10, goal: 18, unit: "mg", color: MacroColors.fats)
                    NutrientRow(name: "Potassium", current: 2200, goal: 3400, unit: "mg", color: MacroColors.fats)
                    NutrientRow(name: "Vitamin A", current: 650, goal: 900, unit: "mcg", color: MacroColors.fats)
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
                .shadow(color: .black.opacity(CardStyle.shadowOpacity), radius: CardStyle.shadowRadius, x: 0, y: CardStyle.shadowY)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NutritionAnalysisView()
    }
}
