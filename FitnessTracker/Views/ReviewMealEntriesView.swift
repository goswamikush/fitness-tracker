//
//  ReviewMealEntriesView.swift
//  FitnessTracker
//

import SwiftUI
import SwiftData

struct ReviewMealEntriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mealName: String
    let sourceMealType: String
    let logDate: Date

    @State private var items: [EditableItem]

    init(mealName: String, sourceMealType: String, logDate: Date, entries: [MealEntry]) {
        self.mealName = mealName
        self.sourceMealType = sourceMealType
        self.logDate = logDate
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
                    MealTotalsSummary(calories: totalCalories, protein: totalProtein, carbs: totalCarbs, fat: totalFat)
                    MealItemsList(items: $items)
                }
                .padding()
                .padding(.bottom, 80)
            }

            MealActionButton(title: "Add to \(mealName)", calories: totalCalories) {
                addEntries()
            }
        }
        .background(AppColors.background)
        .navigationTitle("Yesterday's \(sourceMealType)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func addEntries() {
        for item in items {
            let entry = MealEntry(
                date: logDate,
                mealType: mealName,
                servingGrams: item.servingGrams,
                foodItem: item.foodItem
            )
            modelContext.insert(entry)
        }
        dismiss()
    }
}
