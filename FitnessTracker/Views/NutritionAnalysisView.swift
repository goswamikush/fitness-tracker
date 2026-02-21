//
//  NutritionAnalysisView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/15/26.
//

import SwiftUI
import SwiftData

// Returns a color based on how close to the daily goal (0–100%+).
// ≥ 100%: green (achieved), 80–99%: orange (at/near limit), 50–79%: yellow, < 50%: red
private func nutritionProgressColor(_ percent: Int) -> Color {
    if percent >= 100 { return MacroColors.carbs }
    if percent >= 80  { return MacroColors.calories }
    if percent >= 50  { return MacroColors.fats }
    return AppColors.negative
}

struct NutritionAnalysisView: View {
    @Environment(UserGoals.self) private var userGoals
    @Query(sort: \MealEntry.date) private var allEntries: [MealEntry]
    var selectedDate: Date = Date()

    private var dayEntries: [MealEntry] {
        allEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    // Macros
    private var protein: Double { dayEntries.reduce(0) { $0 + $1.protein } }
    private var carbs:   Double { dayEntries.reduce(0) { $0 + $1.carbs } }
    private var fat:     Double { dayEntries.reduce(0) { $0 + $1.fat } }

    // Carb breakdown
    private var fiber: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.fiberPer100g   ?? 0) * $1.servingGrams / 100) }
    }
    private var sugar: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.sugarPer100g   ?? 0) * $1.servingGrams / 100) }
    }

    // Vitamins & minerals
    private var sodium: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.sodiumPer100g       ?? 0) * $1.servingGrams / 100) }
    }
    private var cholesterol: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.cholesterolPer100g  ?? 0) * $1.servingGrams / 100) }
    }
    private var calcium: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.calciumPer100g      ?? 0) * $1.servingGrams / 100) }
    }
    private var iron: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.ironPer100g         ?? 0) * $1.servingGrams / 100) }
    }
    private var vitaminC: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.vitaminCPer100g     ?? 0) * $1.servingGrams / 100) }
    }
    // Convert IU → mcg (÷40) so display matches FDA label convention (DV = 20 mcg)
    private var vitaminDMcg: Double {
        dayEntries.reduce(0) { $0 + (($1.foodItem?.vitaminDPer100g ?? 0) * $1.servingGrams / 100) } / 40
    }

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {

                // ── MACRONUTRIENTS ──────────────────────────────────
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    SectionLabel("MACRONUTRIENTS")
                    MacroCard(icon: "dumbbell.fill", iconColor: MacroColors.protein, name: "Protein",       current: protein, goal: Double(userGoals.proteinGoal), unit: "g")
                    MacroCard(icon: "bolt.fill", iconColor: MacroColors.carbs,   name: "Carbohydrates", current: carbs,   goal: Double(userGoals.carbsGoal),   unit: "g")
                    MacroCard(icon: "drop.fill", iconColor: MacroColors.fats,    name: "Fat",           current: fat,     goal: Double(userGoals.fatGoal),      unit: "g")
                }

                // ── CARB DETAILS ────────────────────────────────────
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    SectionLabel("CARB DETAILS")
                    NutrientCard(icon: "leaf.fill",  name: "Dietary Fiber", current: fiber, goal: 28, unit: "g")
                    NutrientCard(icon: "cube.fill",  name: "Added Sugar",   current: sugar, goal: 50, unit: "g")
                }

                // ── VITAMINS & MINERALS ─────────────────────────────
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack {
                        SectionLabel("VITAMINS & MINERALS")
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(AppColors.lightMacroTextColor)
                            .font(.system(size: 16))
                    }

                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        MiniCard(icon: "heart.fill",                           name: "Sodium",      current: sodium,      goal: 2300, unit: "mg")
                        MiniCard(icon: "staroflife.fill",                      name: "Cholesterol", current: cholesterol, goal: 300,  unit: "mg")
                        MiniCard(icon: "checkmark.shield.fill",                name: "Vitamin C",   current: vitaminC,    goal: 90,   unit: "mg")
                        MiniCard(icon: "sun.max.fill",                         name: "Vitamin D",   current: vitaminDMcg, goal: 20,   unit: "mcg")
                        MiniCard(icon: "figure.strengthtraining.traditional",  name: "Calcium",     current: calcium,     goal: 1300, unit: "mg")
                        MiniCard(icon: "drop.circle.fill",                     name: "Iron",        current: iron,        goal: 18,   unit: "mg")
                    }
                }
            }
            .padding()
            .padding(.bottom, Spacing.xxl)
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Daily Breakdown")
                        .foregroundColor(.white)
                        .font(.custom(Fonts.outfitBold, size: 18))
                    Text("TODAY'S NUTRITION")
                        .foregroundColor(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.xs))
                        .tracking(1)
                }
            }
        }
    }
}

// MARK: - Subcomponents

private extension NutritionAnalysisView {

    // ── Section label ────────────────────────────────────────────────
    struct SectionLabel: View {
        let title: String
        init(_ title: String) { self.title = title }
        var body: some View {
            Text(title)
                .foregroundStyle(AppColors.lightMacroTextColor)
                .font(.custom(Fonts.interMedium, size: FontSize.xs))
                .tracking(1)
        }
    }

    // ── Full-width macro card (Protein / Carbs / Fat) ─────────────────
    struct MacroCard: View {
        let icon: String
        let iconColor: Color
        let name: String
        let current: Double
        let goal: Double
        let unit: String

        private var percentDisplay: Int { goal > 0 ? Int((current / goal) * 100) : 0 }
        private var progress: Double { goal > 0 ? min(current / goal, 1.0) : 0 }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    // Icon + label
                    HStack(spacing: Spacing.lg) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.07))
                                .frame(width: 40, height: 40)
                            Image(systemName: icon)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(iconColor)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name)
                                .foregroundColor(.white)
                                .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                            Text("\(Int(current)) / \(Int(goal)) \(unit)")
                                .foregroundColor(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }
                    }

                    Spacer()

                    Text("\(percentDisplay)%")
                        .foregroundColor(MacroColors.carbs)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.xl))
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(MacroColors.carbs.opacity(0.15))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(MacroColors.carbs)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 4)
            }
            .padding(Spacing.lg)
            .background(CardBG())
        }
    }

    // ── Full-width nutrient card (Fiber / Sugar) ──────────────────────
    struct NutrientCard: View {
        let icon: String
        let name: String
        let current: Double
        let goal: Double
        let unit: String

        private var percentDisplay: Int { goal > 0 ? Int((current / goal) * 100) : 0 }
        private var progress: Double { goal > 0 ? min(current / goal, 1.0) : 0 }
        private var color: Color { nutritionProgressColor(percentDisplay) }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    HStack(spacing: Spacing.lg) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.07))
                                .frame(width: 40, height: 40)
                            Image(systemName: icon)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(color)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name)
                                .foregroundColor(.white)
                                .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                            Text("\(Int(current)) / \(Int(goal)) \(unit)")
                                .foregroundColor(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }
                    }
                    Spacer()
                    Text("\(percentDisplay)%")
                        .foregroundColor(color)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.xl))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color.opacity(0.15))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 4)
            }
            .padding(Spacing.lg)
            .background(CardBG())
        }
    }

    // ── Half-width mini card (vitamins & minerals grid) ───────────────
    struct MiniCard: View {
        let icon: String
        let name: String
        let current: Double
        let goal: Double
        let unit: String

        private var percentDisplay: Int { goal > 0 ? Int((current / goal) * 100) : 0 }
        private var progress: Double { goal > 0 ? min(current / goal, 1.0) : 0 }
        private var color: Color { nutritionProgressColor(percentDisplay) }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Top row: icon + name + %
                HStack(spacing: Spacing.sm) {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(color)
                    Text(name)
                        .foregroundColor(.white)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.sm))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text("\(percentDisplay)%")
                        .foregroundColor(color)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.sm))
                }

                // Value / goal
                Text("\(formattedValue(current)) / \(formattedValue(goal)) \(unit)")
                    .foregroundColor(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.xs))
                    .lineLimit(2)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color.opacity(0.15))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 3)
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CardBG())
        }

        private func formattedValue(_ v: Double) -> String {
            v < 10 ? String(format: "%.1f", v) : "\(Int(v))"
        }
    }

}

// MARK: - Shared card background

private struct CardBG: View {
    var body: some View {
        RoundedRectangle(cornerRadius: CornerRadius.sm)
            .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
            )
    }
}

#Preview {
    NavigationStack {
        NutritionAnalysisView()
    }
}
