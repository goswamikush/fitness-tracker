//
//  SaveCustomMealView.swift
//  FitnessTracker
//

import SwiftUI
import SwiftData

struct SaveCustomMealView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mealName: String
    let entries: [MealEntry]

    @State private var customName: String
    @State private var items: [EditableItem]

    init(mealName: String, entries: [MealEntry]) {
        self.mealName = mealName
        self.entries = entries
        self._customName = State(initialValue: mealName)
        self._items = State(initialValue: entries.compactMap { entry in
            guard let food = entry.foodItem else { return nil }
            return EditableItem(
                foodItem: food,
                name: food.name,
                servingGrams: entry.servingGrams,
                caloriesPer100g: food.caloriesPer100g,
                proteinPer100g: food.proteinPer100g,
                carbsPer100g: food.carbsPer100g,
                fatPer100g: food.fatPer100g
            )
        })
    }

    private var totalCalories: Int {
        Int(items.reduce(0) { $0 + ($1.caloriesPer100g * $1.servingGrams) / 100 })
    }

    private var totalProtein: Int {
        Int(items.reduce(0) { $0 + ($1.proteinPer100g * $1.servingGrams) / 100 })
    }

    private var totalCarbs: Int {
        Int(items.reduce(0) { $0 + ($1.carbsPer100g * $1.servingGrams) / 100 })
    }

    private var totalFat: Int {
        Int(items.reduce(0) { $0 + ($1.fatPer100g * $1.servingGrams) / 100 })
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    MealNameField(name: $customName)
                    TotalsSummary(calories: totalCalories, protein: totalProtein, carbs: totalCarbs, fat: totalFat)
                    ItemsList(items: $items)
                }
                .padding()
                .padding(.bottom, 80)
            }

            SaveButton(calories: totalCalories) {
                saveCustomMeal()
            }
        }
        .background(AppColors.background)
        .navigationTitle("Save Custom Meal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func saveCustomMeal() {
        let meal = CustomMeal(name: customName)
        modelContext.insert(meal)

        for item in items {
            let customItem = CustomMealItem(
                servingGrams: item.servingGrams,
                foodItem: item.foodItem,
                customMeal: meal
            )
            modelContext.insert(customItem)
        }

        dismiss()
    }
}

// MARK: - EditableItem

struct EditableItem: Identifiable {
    let id = UUID()
    let foodItem: FoodItem
    let name: String
    var servingGrams: Double
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double

    var calories: Int { Int((caloriesPer100g * servingGrams) / 100) }
    var protein: Int { Int((proteinPer100g * servingGrams) / 100) }
    var carbs: Int { Int((carbsPer100g * servingGrams) / 100) }
    var fat: Int { Int((fatPer100g * servingGrams) / 100) }
}

// MARK: - Subcomponents

private extension SaveCustomMealView {

    struct MealNameField: View {
        @Binding var name: String

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("MEAL NAME")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
                    .tracking(1)

                TextField("Enter meal name", text: $name)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.interMedium, size: FontSize.xl))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                    )
            }
        }
    }

    struct TotalsSummary: View {
        let calories: Int
        let protein: Int
        let carbs: Int
        let fat: Int

        var body: some View {
            HStack {
                Text("\(calories) kcal")
                    .foregroundColor(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))

                Spacer()

                HStack(spacing: Spacing.lg) {
                    MacroBadge(value: protein, suffix: "p", color: MacroColors.protein)
                    MacroBadge(value: carbs, suffix: "c", color: MacroColors.carbs)
                    MacroBadge(value: fat, suffix: "f", color: MacroColors.fats)
                }
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

    struct MacroBadge: View {
        let value: Int
        let suffix: String
        let color: Color

        var body: some View {
            HStack(spacing: Spacing.xs) {
                Circle()
                    .fill(color)
                    .frame(width: IconSize.md, height: IconSize.md)
                Text("\(value)\(suffix)")
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.sm))
            }
        }
    }

    struct ItemsList: View {
        @Binding var items: [EditableItem]

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("ITEMS")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
                    .tracking(1)

                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    EditableItemRow(item: $items[index]) {
                        items.remove(at: index)
                    }
                }
            }
        }
    }

    struct EditableItemRow: View {
        @Binding var item: EditableItem
        let onRemove: () -> Void

        var body: some View {
            HStack(spacing: Spacing.lg) {
                NavigationLink(destination: AddEntryView(
                    foodItem: item.foodItem,
                    servingGrams: item.servingGrams,
                    onUpdateServing: { newGrams in
                        item.servingGrams = newGrams
                    }
                )) {
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(item.name.capitalized)
                                .foregroundColor(.white)
                                .font(.custom(Fonts.interMedium, size: FontSize.md))
                            Text("\(item.calories) kcal  ·  \(Int(item.servingGrams))g")
                                .foregroundColor(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }
                }

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.lightMacroTextColor)
                }
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

    struct SaveButton: View {
        let calories: Int
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack {
                    Text("Save Custom Meal")
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
}
