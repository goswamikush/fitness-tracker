//
//  NutritionAnalysisView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/15/26.
//

import SwiftUI
import SwiftData

struct NutritionAnalysisView: View {
    @Query(sort: \MealEntry.date) private var allEntries: [MealEntry]
    var selectedDate: Date = Date()

    private var dayEntries: [MealEntry] {
        allEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    // Macros
    private var protein: Double { dayEntries.reduce(0) { $0 + $1.protein } }
    private var carbs: Double { dayEntries.reduce(0) { $0 + $1.carbs } }
    private var fat: Double { dayEntries.reduce(0) { $0 + $1.fat } }

    // Fat breakdown
    private var saturatedFat: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.saturatedFatPer100g ?? 0) * $1.servingGrams / 100) }
    }
    private var transFat: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.transFatPer100g ?? 0) * $1.servingGrams / 100) }
    }

    // Carb breakdown
    private var fiber: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.fiberPer100g ?? 0) * $1.servingGrams / 100) }
    }
    private var sugar: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.sugarPer100g ?? 0) * $1.servingGrams / 100) }
    }

    // Minerals
    private var sodium: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.sodiumPer100g ?? 0) * $1.servingGrams / 100) }
    }
    private var cholesterol: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.cholesterolPer100g ?? 0) * $1.servingGrams / 100) }
    }
    private var calcium: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.calciumPer100g ?? 0) * $1.servingGrams / 100) }
    }
    private var iron: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.ironPer100g ?? 0) * $1.servingGrams / 100) }
    }

    // Vitamins
    private var vitaminA: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.vitaminAPer100g ?? 0) * $1.servingGrams / 100) }
    }
    private var vitaminC: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.vitaminCPer100g ?? 0) * $1.servingGrams / 100) }
    }
    private var vitaminD: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.vitaminDPer100g ?? 0) * $1.servingGrams / 100) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxl) {
                MacrosAndFiberSection(
                    protein: protein, carbs: carbs, fat: fat,
                    fiber: fiber, sugar: sugar
                )
                FatsSection(
                    totalFat: fat, saturatedFat: saturatedFat, transFat: transFat
                )
                MineralsSection(
                    sodium: sodium, cholesterol: cholesterol,
                    calcium: calcium, iron: iron
                )
                VitaminsSection(
                    vitaminA: vitaminA, vitaminC: vitaminC, vitaminD: vitaminD
                )
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
                return AppColors.negative
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

    struct SectionCard<Content: View>: View {
        let title: String
        @ViewBuilder let content: Content

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text(title)
                    .foregroundStyle(AppColors.macroTextColor)
                    .font(.custom(Fonts.outfitBold, size: FontSize.xs))
                    .tracking(1)

                VStack(spacing: 0) {
                    content
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

    struct MacrosAndFiberSection: View {
        let protein: Double
        let carbs: Double
        let fat: Double
        let fiber: Double
        let sugar: Double

        var body: some View {
            SectionCard(title: "MACROS & FIBER") {
                NutrientRow(name: "Protein", current: protein, goal: 180, unit: "g", color: MacroColors.protein)
                NutrientRow(name: "Carbohydrates", current: carbs, goal: 250, unit: "g", color: MacroColors.carbs)
                NutrientRow(name: "Fat", current: fat, goal: 70, unit: "g", color: MacroColors.fats)
                NutrientRow(name: "Fiber", current: fiber, goal: 28, unit: "g", color: MacroColors.fats)
                NutrientRow(name: "Sugar", current: sugar, goal: 50, unit: "g", color: MacroColors.fats)
            }
        }
    }

    struct FatsSection: View {
        let totalFat: Double
        let saturatedFat: Double
        let transFat: Double

        var body: some View {
            SectionCard(title: "FAT BREAKDOWN") {
                NutrientRow(name: "Total Fat", current: totalFat, goal: 70, unit: "g", color: MacroColors.fats)
                NutrientRow(name: "Saturated Fat", current: saturatedFat, goal: 20, unit: "g", color: MacroColors.fats)
                NutrientRow(name: "Trans Fat", current: transFat, goal: 2, unit: "g", color: MacroColors.fats)
            }
        }
    }

    struct MineralsSection: View {
        let sodium: Double
        let cholesterol: Double
        let calcium: Double
        let iron: Double

        var body: some View {
            SectionCard(title: "MINERALS") {
                NutrientRow(name: "Sodium", current: sodium, goal: 2300, unit: "mg", color: MacroColors.calories)
                NutrientRow(name: "Cholesterol", current: cholesterol, goal: 300, unit: "mg", color: MacroColors.calories)
                NutrientRow(name: "Calcium", current: calcium, goal: 1300, unit: "mg", color: MacroColors.calories)
                NutrientRow(name: "Iron", current: iron, goal: 18, unit: "mg", color: MacroColors.calories)
            }
        }
    }

    struct VitaminsSection: View {
        let vitaminA: Double
        let vitaminC: Double
        let vitaminD: Double

        var body: some View {
            SectionCard(title: "VITAMINS") {
                NutrientRow(name: "Vitamin A", current: vitaminA, goal: 3000, unit: "IU", color: MacroColors.protein)
                NutrientRow(name: "Vitamin C", current: vitaminC, goal: 90, unit: "mg", color: MacroColors.protein)
                NutrientRow(name: "Vitamin D", current: vitaminD, goal: 800, unit: "IU", color: MacroColors.protein)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NutritionAnalysisView()
    }
}
