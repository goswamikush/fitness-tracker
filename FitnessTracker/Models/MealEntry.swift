//
//  MealEntry.swift
//  FitnessTracker
//

import Foundation
import SwiftData

@Model
final class MealEntry {
    var date: Date
    var mealType: String
    var servingGrams: Double
    var foodItem: FoodItem?

    var calories: Double {
        guard let food = foodItem else { return 0 }
        return (food.caloriesPer100g * servingGrams) / 100.0
    }

    var protein: Double {
        guard let food = foodItem else { return 0 }
        return (food.proteinPer100g * servingGrams) / 100.0
    }

    var carbs: Double {
        guard let food = foodItem else { return 0 }
        return (food.carbsPer100g * servingGrams) / 100.0
    }

    var fat: Double {
        guard let food = foodItem else { return 0 }
        return (food.fatPer100g * servingGrams) / 100.0
    }

    init(date: Date, mealType: String, servingGrams: Double, foodItem: FoodItem? = nil) {
        self.date = date
        self.mealType = mealType
        self.servingGrams = servingGrams
        self.foodItem = foodItem
    }
}
