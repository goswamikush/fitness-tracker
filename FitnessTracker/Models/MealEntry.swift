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
    var servingUnit: String?
    var servingQuantity: Double?
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

    /// Human-readable serving size. Shows quantity + unit when a non-gram unit was used,
    /// otherwise falls back to grams.
    var servingDisplay: String {
        if let unit = servingUnit, let qty = servingQuantity, unit != "g" {
            let qtyStr = qty == Double(Int(qty)) ? "\(Int(qty))" : String(format: "%.1f", qty)
            return "\(qtyStr) \(unit)"
        }
        return "\(Int(servingGrams))g"
    }

    init(date: Date, mealType: String, servingGrams: Double, foodItem: FoodItem? = nil,
         servingUnit: String? = nil, servingQuantity: Double? = nil) {
        self.date = date
        self.mealType = mealType
        self.servingGrams = servingGrams
        self.foodItem = foodItem
        self.servingUnit = servingUnit
        self.servingQuantity = servingQuantity
    }
}
